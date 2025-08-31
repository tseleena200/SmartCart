// lib/view/recommendation/recommendation_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:onlinegroceries/common/color_extension.dart';
import 'package:onlinegroceries/common_widget/round_button.dart';
import '../../common_widget/recommendation_row.dart';
import '../../common_widget/explore_cell.dart';
import '../home/product_details_screen.dart';
import '../explore/explore_details.dart';

import 'package:get/get.dart';
import '../../controllers/cart_controller.dart';
import '../../services/recs_api.dart';
import '../rfid/rfid_scan_overlay.dart';

class RecommendationsView extends StatefulWidget {
  const RecommendationsView({super.key});

  @override
  State<RecommendationsView> createState() => _RecommendationsViewState();
}

class _RecommendationsViewState extends State<RecommendationsView> {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  final CartController _cart = Get.put(CartController());
  bool _isBatchAdding = false;

  bool _triedKick = false;
  bool? _isColdStart; // null = loading, true = show Starter tab, false = show 3 tabs

  @override
  void initState() {
    super.initState();
    _kickBackendRefresh();
    _checkColdStart();
  }

  Future<void> _kickBackendRefresh() async {
    if (_triedKick) return;
    _triedKick = true;
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    try {
      // fire-and-forget
      // ignore: unawaited_futures
      RecsApi.refreshUserInstant(uid);
    } catch (_) {}
  }

  Future<void> _checkColdStart() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      setState(() => _isColdStart = true);
      return;
    }
    try {
      final doc = await _db.collection('Recommendations').doc(uid).get();
      if (!doc.exists) {
        setState(() => _isColdStart = true);
        return;
      }
      final data = doc.data() ?? {};
      bool emptyField(dynamic v) {
        if (v == null) return true;
        if (v is String) return v.trim().isEmpty;
        if (v is List) return v.isEmpty;
        return false;
      }

      final bool ymAlso = !emptyField(data['you_may_also_like']);
      final bool buyAgain = !emptyField(data['buy_again']);
      final bool topCats = !emptyField(data['top_categories']);

      setState(() => _isColdStart = !(ymAlso || buyAgain || topCats));
    } catch (_) {
      // On any error, don’t block UI; fall back to starter tab
      setState(() => _isColdStart = true);
    }
  }

  // ---------- helpers ----------
  Color _parseHex(String? hex) {
    try {
      hex = hex?.replaceAll('#', '') ?? 'FFFFFF';
      if (hex.length == 6) hex = 'FF$hex';
      return Color(int.parse('0x$hex'));
    } catch (_) {
      return Colors.grey.shade300;
    }
  }

  Future<void> _refreshRecs() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    try {
      await RecsApi.refreshUserInstant(uid);
      await _checkColdStart();
    } catch (e) {
      debugPrint("recs refresh failed: $e");
    }
  }

  Future<void> _batchAddRecommended(List<Map<String, dynamic>> listArr) async {
    if (_isBatchAdding) return;
    setState(() => _isBatchAdding = true);
    try {
      int added = 0, skipped = 0;
      for (final row in listArr.take(6)) {
        final prod = (row['product'] ?? {}) as Map<String, dynamic>;
        final rfid = (prod['RFIDCode'] ?? '').toString();
        if (rfid.isEmpty) {
          skipped++;
          continue;
        }
        await Get.dialog(RFIDScanOverlay(rfidCode: rfid), barrierDismissible: false);
        await _cart.addProductToCartByRFID(rfid);
        added++;
      }
      await _refreshRecs();
      if (!mounted) return;
      Get.snackbar("Done", "Added $added item(s). Skipped $skipped.",
          backgroundColor: TColor.success, colorText: Colors.white);
    } catch (e) {
      if (!mounted) return;
      Get.snackbar("Error", e.toString(),
          backgroundColor: TColor.error, colorText: Colors.white);
    } finally {
      if (mounted) setState(() => _isBatchAdding = false);
    }
  }

  // ---------- UI ----------
  @override
  Widget build(BuildContext context) {
    // still deciding cold-start?
    if (_isColdStart == null) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final bool cold = _isColdStart!;

    return DefaultTabController(
      length: cold ? 1 : 3,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0.5,
          centerTitle: true,
          title: Text(
            cold ? "Starter Recommendations" : "Recommended For You",
            style: TextStyle(
              color: TColor.primaryText,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          bottom: TabBar(
            labelColor: Colors.black,
            unselectedLabelColor: Colors.black54,
            indicatorColor: Colors.black,
            tabs: cold
                ? const [Tab(text: "Starter Picks")]
                : const [
              Tab(text: "You May Also Like"),
              Tab(text: "Buy Again"),
              Tab(text: "Top Categories"),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _refreshRecs,
              tooltip: 'Refresh Recommendations',
            ),
          ],
        ),
        body: TabBarView(
          children: cold
              ? [ _StarterTab(buildList: _buildStarterFuture) ]
              : [
            _RecTab(fieldName: 'you_may_also_like', buildList: _buildListFuture),
            _RecTab(fieldName: 'buy_again', buildList: _buildListFuture),
            _TopCatsTab(loadCards: _loadTopCategoryCards, openCategory: _openCategory),
          ],
        ),
      ),
    );
  }

  // ---------- Starter picks (ONLY for cold start users) ----------
  Future<List<Map<String, dynamic>>> _loadStarterPicks() async {
    final out = <Map<String, dynamic>>[];
    final seen = <String>{};

    void push(QueryDocumentSnapshot<Map<String, dynamic>> d) {
      if (!seen.add(d.id)) return;
      final data = d.data();
      data['productID'] = d.id;

      final image = (data['imageURL'] ?? data['imageUrl'] ?? data['image'] ?? '').toString();
      final iconIsNetwork = image.startsWith('http');
      final rawPrice = data['price'] ?? data['mrp'] ?? data['sellingPrice'];
      final priceStr = rawPrice == null ? '' : '\$${rawPrice.toString()}';

      out.add({
        "product": data,
        "name": data['productName'] ?? 'Unknown Product',
        "icon": iconIsNetwork ? image : (image.isEmpty ? 'assets/img/placeholder.png' : image),
        "iconIsNetwork": iconIsNetwork,
        "qty": (data['unitValue'] ?? '').toString(),
        "unit": (data['unitType'] ?? '').toString().isNotEmpty ? "${data['unitType']}, Price" : "Price",
        "price": priceStr,
        "score": null,
      });
    }

    // 1) highest discounts
    final disc = await _db
        .collection('Products')
        .where('discount', isGreaterThan: 0)
        .orderBy('discount', descending: true)
        .limit(6)
        .get(const GetOptions(source: Source.serverAndCache));
    for (final d in disc.docs) push(d);

    // 2) new arrivals (fill to 10)
    if (out.length < 10) {
      final rest = await _db
          .collection('Products')
          .orderBy('createdAt', descending: true)
          .limit(10 - out.length)
          .get(const GetOptions(source: Source.serverAndCache));
      for (final d in rest.docs) push(d);
    }

    return out;
  }

  Widget _buildStarterFuture() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _loadStarterPicks(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snap.hasError) {
          return Center(child: Text('Error: ${snap.error}'));
        }
        final listArr = snap.data ?? [];
        if (listArr.isEmpty) {
          return const Center(child: Text('No starter items yet.'));
        }

        return Stack(
          alignment: Alignment.bottomCenter,
          children: [
            ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 140),
              itemCount: listArr.length,
              separatorBuilder: (_, __) => const Divider(color: Colors.black26, height: 1),
              itemBuilder: (context, index) {
                final pObj = listArr[index];
                return RecommendationRow(
                  pObj: pObj,
                  onPressed: () {
                    final productData = pObj['product'] as Map<String, dynamic>? ?? {};
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => ProductDetails(product: productData)),
                    );
                  },
                );
              },
            ),
            Positioned(
              left: 20,
              right: 20,
              bottom: 86,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.blueGrey.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.blueGrey.shade100),
                ),
                child: const Text(
                  "Starter picks shown because there’s no interaction history yet.\n"
                      "Personalised recommendations will appear after a bit of activity",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: Colors.black87),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: RoundButton(
                title: _isBatchAdding ? 'Adding...' : 'Simulate Add Recommended Items',
                onPressed: () {
                  if (_isBatchAdding) return;
                  _batchAddRecommended(listArr);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  // ---------- Personalised lists (NO cold-start fallback here) ----------
  Future<List<Map<String, dynamic>>> _loadListFor(String fieldName) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return [];

    final recSnap = await _db.collection('Recommendations').doc(uid).get();
    if (!recSnap.exists) return [];

    final data = recSnap.data()!;
    final dynamic field = data[fieldName];
    if (field == null || (field is String && field.trim().isEmpty)) {
      return [];
    }

    // parse entries
    final entries = <_Entry>[];
    if (field is String) {
      entries.addAll(_parseRecString(field));
    } else if (field is List) {
      for (final item in field) {
        if (item is Map) {
          entries.add(_Entry(
            productId: item['productID']?.toString(),
            name: item['productName']?.toString() ?? item['name']?.toString(),
            score: _toDouble(item['score']),
          ));
        } else if (item is String) {
          entries.addAll(_parseRecString(item));
        }
      }
    }

    // hydrate from Products
    final items = <Map<String, dynamic>>[];
    for (final e in entries) {
      Map<String, dynamic>? prod;

      if (e.productId != null && e.productId!.isNotEmpty) {
        prod = await _fetchProductById(e.productId!);
      }
      if (prod == null && e.name != null && e.name!.isNotEmpty) {
        prod = await _fetchProductByName(e.name!);
      }

      if (prod == null) {
        items.add({
          "name": e.name ?? "Unknown Product",
          "icon": "assets/img/placeholder.png",
          "iconIsNetwork": false,
          "qty": "",
          "unit": "",
          "price": "",
          "score": e.score,
        });
        continue;
      }

      final image = (prod['imageURL'] ??
          prod['imageUrl'] ??
          prod['image'] ??
          'assets/img/placeholder.png')
          .toString();
      final iconIsNetwork = image.startsWith('http');

      String unitVal = '';
      String unitType = '';
      final t = prod['tags'];
      if (t is Map) {
        unitVal = (t['unitValue'] ?? '').toString();
        unitType = (t['unitType'] ?? '').toString();
      } else if (t is List && t.isNotEmpty && t.first is Map) {
        unitVal = (t.first['unitValue'] ?? '').toString();
        unitType = (t.first['unitType'] ?? '').toString();
      }
      unitVal = (prod['unitValue'] ?? unitVal).toString();
      unitType = (prod['unitType'] ?? unitType).toString();

      final rawPrice = prod['price'] ?? prod['mrp'] ?? prod['sellingPrice'];
      final priceStr = rawPrice == null ? '' : '\$${rawPrice.toString()}';

      items.add({
        "product": {
          ...prod,
          "productID": e.productId ?? prod['productID'],
        },
        "name": prod['productName'] ?? e.name ?? "Unknown Product",
        "icon": image,
        "iconIsNetwork": iconIsNetwork,
        "qty": unitVal,
        "unit": unitType.isNotEmpty ? "$unitType, Price" : "Price",
        "price": priceStr,
        "score": e.score,
      });
    }

    return items;
  }

  Future<Map<String, dynamic>?> _fetchProductById(String pid) async {
    final doc = await _db.collection('Products').doc(pid).get();
    return doc.data();
  }

  Future<Map<String, dynamic>?> _fetchProductByName(String name) async {
    var qs = await _db.collection('Products').where('productName', isEqualTo: name).limit(1).get();
    if (qs.docs.isNotEmpty) return qs.docs.first.data();

    qs = await _db
        .collection('Products')
        .where('productNameLower', isEqualTo: name.toLowerCase())
        .limit(1)
        .get();
    if (qs.docs.isNotEmpty) return qs.docs.first.data();
    return null;
  }

  List<_Entry> _parseRecString(String s) {
    final out = <_Entry>[];
    if (s.trim().isEmpty) return out;
    final reg = RegExp(r'^(.*?)\s*\(([-+]?\d*\.?\d+)\)$');
    for (final p in s.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty)) {
      final m = reg.firstMatch(p);
      if (m != null) {
        out.add(_Entry(name: m.group(1)!.trim(), score: double.tryParse(m.group(2)!) ?? 0));
      } else {
        out.add(_Entry(name: p));
      }
    }
    return out;
  }

  double? _toDouble(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString());
  }

  Widget _buildListFuture(String fieldName) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _loadListFor(fieldName),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snap.hasError) return Center(child: Text('Error: ${snap.error}'));
        final listArr = snap.data ?? [];
        if (listArr.isEmpty) return const Center(child: Text('Nothing here yet.'));

        return Stack(
          alignment: Alignment.bottomCenter,
          children: [
            ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 140),
              itemCount: listArr.length,
              separatorBuilder: (_, __) => const Divider(color: Colors.black26, height: 1),
              itemBuilder: (context, index) {
                final pObj = listArr[index];
                return RecommendationRow(
                  pObj: pObj,
                  onPressed: () {
                    final productData = pObj['product'] as Map<String, dynamic>? ?? {};
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => ProductDetails(product: productData)),
                    );
                  },
                );
              },
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: RoundButton(
                title: _isBatchAdding ? 'Adding...' : 'Simulate Add Recommended Items',
                onPressed: () {
                  if (_isBatchAdding) return;
                  _batchAddRecommended(listArr);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  // ---------- Top categories ----------
  Future<List<Map<String, dynamic>>> _loadTopCategoryCards() async {
    final uid = _auth.currentUser?.uid;

    if (uid != null) {
      final recSnap = await _db.collection('Recommendations').doc(uid).get();
      if (recSnap.exists) {
        final raw = (recSnap.data()?['top_categories'] ?? '') as String;
        final names = raw.split(RegExp(r',\s+')).map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
        if (names.isNotEmpty) return _resolveCategoryCards(names);
      }
    }

    // fallback to ranked or recent categories
    try {
      final qs = await _db
          .collection('Categories')
          .orderBy('rank')
          .limit(6)
          .get(const GetOptions(source: Source.serverAndCache));
      if (qs.docs.isNotEmpty) {
        final names = qs.docs.map((d) => (d.data()['name'] ?? '').toString()).where((e) => e.isNotEmpty).toList();
        return _resolveCategoryCards(names);
      }
    } catch (_) {
      final qs = await _db
          .collection('Categories')
          .orderBy('createdAt', descending: true)
          .limit(6)
          .get(const GetOptions(source: Source.serverAndCache));
      if (qs.docs.isNotEmpty) {
        final names = qs.docs.map((d) => (d.data()['name'] ?? '').toString()).where((e) => e.isNotEmpty).toList();
        return _resolveCategoryCards(names);
      }
    }
    return [];
  }

  Future<List<Map<String, dynamic>>> _resolveCategoryCards(List<String> names) async {
    final results = <Map<String, dynamic>>[];
    for (final n in names) {
      var qs = await _db.collection('Categories').where('name', isEqualTo: n).limit(1).get();
      if (qs.docs.isEmpty) {
        qs = await _db.collection('Categories').where('nameLower', isEqualTo: n.toLowerCase()).limit(1).get();
      }
      Map<String, dynamic> data;
      if (qs.docs.isNotEmpty) {
        data = qs.docs.first.data();
      } else {
        data = {'name': n, 'sub': '', 'aisle': 'Aisle ?', 'imageURL': '', 'colorHex': 'FFFFFF'};
      }

      results.add({
        'name': data['name'] ?? n,
        'sub': data['sub'] ?? '',
        'aisle': data['aisle'] ?? '',
        'icon': (data['imageURL'] ?? '').toString(),
        'color': _parseHex(data['colorHex']?.toString()),
        'raw': data,
      });
    }
    return results;
  }

  Future<void> _openCategory(BuildContext context, Map<String, dynamic> card) async {
    final raw = (card['raw'] as Map<String, dynamic>?) ??
        {
          'name': card['name'],
          'aisle': card['aisle'] ?? 'Aisle ?',
          'sub': card['sub'] ?? '',
          'imageURL': card['icon'] ?? '',
          'colorHex': '#FFFFFF',
        };

    if (!mounted) return;
    Navigator.push(context, MaterialPageRoute(builder: (_) => ExploreDetailsView(eObj: raw)));
  }
}

// ---------------- Tabs ----------------

class _RecTab extends StatelessWidget {
  final String fieldName;
  final Widget Function(String) buildList;
  const _RecTab({required this.fieldName, required this.buildList});

  @override
  Widget build(BuildContext context) {
    return buildList(fieldName);
  }
}

class _StarterTab extends StatelessWidget {
  final Widget Function() buildList;
  const _StarterTab({required this.buildList});

  @override
  Widget build(BuildContext context) => buildList();
}

class _TopCatsTab extends StatelessWidget {
  final Future<List<Map<String, dynamic>>> Function() loadCards;
  final Future<void> Function(BuildContext, Map<String, dynamic>) openCategory;
  const _TopCatsTab({required this.loadCards, required this.openCategory});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: loadCards(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snap.hasError) return Center(child: Text('Error: ${snap.error}'));

        final cards = snap.data ?? [];
        if (cards.isEmpty) return const Center(child: Text('No top categories yet.'));

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: GridView.builder(
            itemCount: cards.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.6,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
            ),
            itemBuilder: (context, i) {
              final c = cards[i];
              return ExploreCell(
                pObj: {'name': c['name'], 'sub': c['sub'], 'aisle': c['aisle'], 'icon': c['icon'], 'color': c['color']},
                onPressed: () => openCategory(context, c),
              );
            },
          ),
        );
      },
    );
  }
}

// ---------------- models ----------------
class _Entry {
  final String? productId;
  final String? name;
  final double? score;
  _Entry({this.productId, this.name, this.score});
}
