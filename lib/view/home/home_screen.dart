import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../../common/color_extension.dart';
import '../../common_widget/category_cell.dart';
import '../../common_widget/product_cell.dart';
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

  List<String> bannerList = [
    "assets/img/1.png",
    "assets/img/2.png",
    "assets/img/3.png",
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

  Stream<QuerySnapshot> _fetchProducts(String field) {
    return FirebaseFirestore.instance
        .collection('Products')
        .where(field, isEqualTo: true)
        .snapshots();
  }

  Stream<QuerySnapshot> _fetchNewArrivals() {
    return FirebaseFirestore.instance
        .collection('Products')
        .where('isExclusive', isEqualTo: false)
        .where('isPopular', isEqualTo: false)
        .orderBy('createdAt', descending: true)
        .limit(10)
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
              _buildStreamSection("Exclusive Offers", _fetchProducts("isExclusive")),
              const SizedBox(height: 8),
              _buildCategorySection(),
              const SizedBox(height: 8),
              _buildStreamSection("Popular Picks", _fetchProducts("isPopular")),
              const SizedBox(height: 8),
              _buildStreamSection("New Arrivals", _fetchNewArrivals()),
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
          const Icon(Icons.notifications_active_sharp, color: Color(0xFF000000)),
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
          height: 110, // previously 140
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


  Widget _buildStreamSection(String title, Stream<QuerySnapshot> stream) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
        SizedBox(
          height: 250,
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
                    child: ProductCell(
                      pObj: data,
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => ProductDetails(product: data)),
                      ),
                      onCart: () => ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("${data['productName']} added to cart")),
                      ),
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
}
