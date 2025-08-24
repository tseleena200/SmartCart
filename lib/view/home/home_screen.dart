import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:onlinegroceries/view/home/tag_based_product_view.dart';
import '../../common/color_extension.dart';
import '../../common_widget/category_cell.dart';
import '../../common_widget/product_cell.dart';
import '../Notifications/notifications_view.dart';
import '../explore/explore_screen.dart';
import '../home/product_details_screen.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final TextEditingController txtSearch = TextEditingController();
  int _currentBannerIndex = 0;
  String searchQuery = "";

  List<String> bannerList = [
    "assets/img/1.png",
    "assets/img/2.png",
    "assets/img/3.png",
    "assets/img/4.png",
    "assets/img/5.png",
    "assets/img/6.png",
    "assets/img/7.png",
    "assets/img/8.png",
    "assets/img/9.png",
    "assets/img/10.png",
  ];

  final List<Map<String, dynamic>> categoryList = [
    {
      "name": "Fruits & Vegetables",
      "icon": "assets/img/frash_fruits.png",
      "color": Color(0xffc8f1d5),
    },
    {
      "name": "Fishes & Meat",
      "icon": "assets/img/meat_fish.png",
      "color": Color(0xffd2ecff),
    },
    {
      "name": "Dairy",
      "icon": "assets/img/almondmilk.jpeg",
      "color": const Color(0xFFFCE4EC),
    },
  ];

  Stream<QuerySnapshot> _fetchProducts(String field, {int limit = 4}) {
    return FirebaseFirestore.instance
        .collection('Products')
        .where(field, isEqualTo: true)
        .limit(limit)
        .snapshots();
  }

  Stream<QuerySnapshot> _fetchNewArrivals({int limit = 4}) {
    return FirebaseFirestore.instance
        .collection('Products')
        .where('isNewArrival', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots();
  }

  Stream<QuerySnapshot> _searchProducts(String name) {
    return FirebaseFirestore.instance
        .collection('Products')
        .where('productName', isGreaterThanOrEqualTo: name)
        .where('productName', isLessThan: name + 'z')
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              _buildSearchBar(),
              const SizedBox(height: 16),
              _buildBanner(),
              const SizedBox(height: 3),
              _buildBannerIndicator(),
              if (searchQuery.isNotEmpty) ...[
                _buildGridSection("Search Results", _searchProducts(searchQuery)),
              ] else ...[
                _buildStreamSection("Exclusive Offers", _fetchProducts("isExclusive", limit: 4), field: "isExclusive"),
                const SizedBox(height: 8),
                _buildCategorySection(),
                const SizedBox(height: 8),
                _buildStreamSection("Popular Picks", _fetchProducts("isPopular", limit: 4), field: "isPopular"),
                const SizedBox(height: 8),
                _buildGridSection("New Arrivals", _fetchNewArrivals(limit: 4), field: "isNewArrival"),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Image.asset("assets/img/smrtcartlogo.png", width: 50),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text("Branch:", style: TextStyle(fontSize: 12)),
                  Text("Colombo", style: TextStyle(fontWeight: FontWeight.bold))
                ],
              ),
            ],
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NotificationsView()),
              );
            },
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.notifications_none, color: Colors.black, size: 28),
                const Positioned(
                  right: -2,
                  top: -2,
                  child: _UnreadBadge(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(color: Colors.black12.withOpacity(0.04), blurRadius: 6),
          ],
        ),
        child: Row(
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 14),
              child: Icon(Icons.search, color: Colors.grey),
            ),
            Expanded(
              child: TextField(
                controller: txtSearch,
                onChanged: (value) {
                  setState(() {
                    searchQuery = value.trim();
                  });
                },
                decoration: const InputDecoration(
                  hintText: "Search anything you want",
                  border: InputBorder.none,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBanner() {
    return CarouselSlider(
      options: CarouselOptions(
        height: 160,
        autoPlay: true,
        enlargeCenterPage: true,
        viewportFraction: 0.9,
        onPageChanged: (index, _) => setState(() => _currentBannerIndex = index),
      ),
      items: bannerList.map((img) => ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.asset(img, fit: BoxFit.cover, width: double.infinity),
      )).toList(),
    );
  }

  Widget _buildBannerIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: bannerList.asMap().entries.map((entry) {
        return Container(
          width: 8,
          height: 8,
          margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _currentBannerIndex == entry.key
                ? TColor.primary
                : TColor.primary.withOpacity(0.3),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCategorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              const Text("Groceries", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const Spacer(),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ExploreView()),
                  );
                },
                child: const Text("See All", style: TextStyle(color: Colors.black)),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 110,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: categoryList.length,
            itemBuilder: (context, index) {
              return CategoryCell(
                pObj: categoryList[index],
                onPressed: () {},
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStreamSection(String title, Stream<QuerySnapshot> stream, {String? field}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const Spacer(),
              if (field != null)
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TagBasedProductView(
                          title: title,
                          field: field,
                        ),
                      ),
                    );
                  },
                  child: const Text("See All", style: TextStyle(color: Colors.black)),
                ),
            ],
          ),
        ),
        SizedBox(
          height: 270,
          child: StreamBuilder<QuerySnapshot>(
            stream: stream,
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
              final docs = snapshot.data!.docs;
              return ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  final data = docs[index].data() as Map<String, dynamic>;
                  return Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: StreamBuilder<DocumentSnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('Users')
                          .doc(FirebaseAuth.instance.currentUser!.uid)
                          .collection('Favorites')
                          .doc(data['productID'])
                          .snapshots(),
                      builder: (context, favSnapshot) {
                        final isFavorited = favSnapshot.data?.exists ?? false;
                        return ProductCell(
                          pObj: data,
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => ProductDetails(product: data)),
                          ),
                          isFavorite: isFavorited,
                          onCart: () {},
                          onFavoriteToggle: () async {
                            final uid = FirebaseAuth.instance.currentUser!.uid;
                            final favRef = FirebaseFirestore.instance
                                .collection('Users')
                                .doc(uid)
                                .collection('Favorites')
                                .doc(data['productID']);
                            if (isFavorited) {
                              await favRef.delete();
                            } else {
                              await favRef.set({
                                'productID': data['productID'],
                                'productName': data['productName'],
                                'imageURL': data['imageURL'],
                                'price': (data['price'] ?? 0).toDouble(),
                                'discount': (data['discount'] ?? 0).toDouble(),
                                'finalPrice': ((data['price'] ?? 0) *
                                    (1 - (data['discount'] ?? 0) / 100))
                                    .toDouble(),
                                'category': data['category'],
                                'favoritedAt': Timestamp.now(),
                                'userName': FirebaseAuth.instance.currentUser?.displayName ?? "Unknown",
                              });
                            }
                          },
                        );
                      },
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildGridSection(String title, Stream<QuerySnapshot> stream, {String? field}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const Spacer(),
              if (field != null)
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => TagBasedProductView(title: title, field: field)),
                    );
                  },
                  child: const Text("See All", style: TextStyle(color: Colors.black)),
                ),
            ],
          ),
        ),
        StreamBuilder<QuerySnapshot>(
          stream: stream,
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
            final docs = snapshot.data!.docs;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GridView.builder(
                itemCount: docs.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 0.65,
                ),
                itemBuilder: (context, index) {
                  final data = docs[index].data() as Map<String, dynamic>;
                  return StreamBuilder<DocumentSnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('Users')
                        .doc(FirebaseAuth.instance.currentUser!.uid)
                        .collection('Favorites')
                        .doc(data['productID'])
                        .snapshots(),
                    builder: (context, favSnapshot) {
                      final isFavorited = favSnapshot.data?.exists ?? false;
                      return ProductCell(
                        pObj: data,
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => ProductDetails(product: data)),
                        ),
                        isFavorite: isFavorited,
                        onCart: () {},
                        onFavoriteToggle: () async {
                          final uid = FirebaseAuth.instance.currentUser!.uid;
                          final favRef = FirebaseFirestore.instance
                              .collection('Users')
                              .doc(uid)
                              .collection('Favorites')
                              .doc(data['productID']);
                          if (isFavorited) {
                            await favRef.delete();
                          } else {
                            await favRef.set({
                              'productID': data['productID'],
                              'productName': data['productName'],
                              'imageURL': data['imageURL'],
                              'price': (data['price'] ?? 0).toDouble(),
                              'discount': (data['discount'] ?? 0).toDouble(),
                              'finalPrice': ((data['price'] ?? 0) *
                                  (1 - (data['discount'] ?? 0) / 100))
                                  .toDouble(),
                              'category': data['category'],
                              'favoritedAt': Timestamp.now(),
                              'userName': FirebaseAuth.instance.currentUser?.displayName ?? "Unknown",
                            });
                          }
                        },
                      );
                    },
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }
}

class _UnreadBadge extends StatelessWidget {
  const _UnreadBadge({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const SizedBox.shrink();

    final q = FirebaseFirestore.instance
        .collection('Notifications')
        .where('targets', arrayContainsAny: [user.uid, 'ALL']);

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: q.snapshots(),
      builder: (context, snap) {
        if (snap.hasError) {
          return const SizedBox.shrink();
        }
        if (!snap.hasData) return const SizedBox.shrink();

        int unread = 0;
        for (final d in snap.data!.docs) {
          final data = d.data();
          final readBy = List<String>.from(data['readBy'] ?? const []);
          final archivedBy = List<String>.from(data['archivedBy'] ?? const []);
          if (!readBy.contains(user.uid) && !archivedBy.contains(user.uid)) {
            unread++;
          }
        }
        if (unread == 0) return const SizedBox.shrink();

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: Colors.black.withOpacity(0.7), width: 1.5),
          ),
          constraints: const BoxConstraints(minWidth: 16, minHeight: 14),
          child: Text(
            unread > 99 ? '99+' : '$unread',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
          ),
        );
      },
    );
  }
}

