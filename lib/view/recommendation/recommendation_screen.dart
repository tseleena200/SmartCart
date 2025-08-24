import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:onlinegroceries/common/color_extension.dart';
import 'package:onlinegroceries/common_widget/round_button.dart';
import '../../common_widget/recommendation_row.dart';
import '../../common_widget/explore_cell.dart';               // ← use same UI as Explore
import '../home/product_details_screen.dart';
import '../explore/explore_details.dart';

class RecommendationsView extends StatefulWidget {
  const RecommendationsView({super.key});

  @override
  State<RecommendationsView> createState() => _RecommendationsViewState();
}

class _RecommendationsViewState extends State<RecommendationsView> {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  // --- small helpers ---------------------------------------------------------
  Color _parseHex(String? hex) {
    try {
      hex = hex?.replaceAll('#', '') ?? 'FFFFFF';
      if (hex.length == 6) hex = 'FF$hex';
      return Color(int.parse('0x$hex'));
    } catch (_) {
      return Colors.grey.shade300;
    }
  }

  // ---------- UI --------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0.5,
          centerTitle: true,
          title: Text(
            "Recommended For You",
            style: TextStyle(
              color: TColor.primaryText,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          bottom: const TabBar(
            labelColor: Colors.black,
            unselectedLabelColor: Colors.black54,
            indicatorColor: Colors.black,
            tabs: [
              Tab(text: "You May Also Like"),
              Tab(text: "Buy Again"),
              Tab(text: "Top Categories"),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _RecTab(fieldName: 'you_may_also_like'),
            _RecTab(fieldName: 'buy_again'),
            _TopCatsTab(),
          ],
        ),
      ),
    );
  }

  // ---------- RECOMMENDATION LISTS -------------------------------------------
  Future<List<Map<String, dynamic>>> _loadListFor(String fieldName) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return [];

    final recSnap = await _db.collection('Recommendations').doc(uid).get();
    if (!recSnap.exists) return [];

    final data = recSnap.data()!;
    final dynamic field = data[fieldName];

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
    } else {
      return [];
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
          if (prod != null) ...prod,
          "productID": e.productId,
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
    var qs = await _db
        .collection('Products')
        .where('productName', isEqualTo: name)
        .limit(1)
        .get();
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
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
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
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  RoundButton(
                    title: 'Add All To Cart',
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  // ---------- TOP CATEGORIES (pretty like Explore) ---------------------------
  Future<List<Map<String, dynamic>>> _loadTopCategoryCards() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return [];

    final recSnap = await _db.collection('Recommendations').doc(uid).get();
    if (!recSnap.exists) return [];

    // split names
    final names = ((recSnap.data()!['top_categories'] ?? '') as String)
        .split(RegExp(r',\s+'))
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    if (names.isEmpty) return [];

    // fetch each category doc by name (and fallback)
    final results = <Map<String, dynamic>>[];
    for (final n in names) {
      var qs = await _db.collection('Categories').where('name', isEqualTo: n).limit(1).get();
      if (qs.docs.isEmpty) {
        qs = await _db
            .collection('Categories')
            .where('nameLower', isEqualTo: n.toLowerCase())
            .limit(1)
            .get();
      }

      Map<String, dynamic> data;
      if (qs.docs.isNotEmpty) {
        data = qs.docs.first.data() as Map<String, dynamic>;
      } else {
        // fallback card so it still opens products by this name
        data = {'name': n, 'sub': '', 'aisle': 'Aisle ?', 'imageURL': '', 'colorHex': 'FFFFFF'};
      }

      results.add({
        'name': data['name'] ?? n,
        'sub': data['sub'] ?? '',
        'aisle': data['aisle'] ?? '',
        'icon': (data['imageURL'] ?? '').toString(),
        'color': _parseHex(data['colorHex']?.toString()),
        'raw': data, // keep raw doc to pass to ExploreDetails
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

// ---------------- Tabs -------------------------------------------------------

class _RecTab extends StatelessWidget {
  final String fieldName;
  const _RecTab({required this.fieldName});

  @override
  Widget build(BuildContext context) {
    final state = context.findAncestorStateOfType<_RecommendationsViewState>()!;
    return state._buildListFuture(fieldName);
  }
}

class _TopCatsTab extends StatelessWidget {
  const _TopCatsTab();

  @override
  Widget build(BuildContext context) {
    final state = context.findAncestorStateOfType<_RecommendationsViewState>()!;
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: state._loadTopCategoryCards(),
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
                pObj: {
                  'name': c['name'],
                  'sub': c['sub'],
                  'aisle': c['aisle'],
                  'icon': c['icon'],
                  'color': c['color'],
                },
                onPressed: () => state._openCategory(context, c),
              );
            },
          ),
        );
      },
    );
  }
}

// ---------------- models -----------------------------------------------------

class _Entry {
  final String? productId;
  final String? name;
  final double? score;
  _Entry({this.productId, this.name, this.score});
}
