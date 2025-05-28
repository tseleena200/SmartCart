import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

import '../../common/color_extension.dart';
import '../../common_widget/category_cell.dart';
import '../../common_widget/product_cell.dart';
import '../../view/home/product_details_screen.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final TextEditingController txtSearch = TextEditingController();

  List exclusiveOfferArr = [
    {"name": "Organic Bananas", "icon": "assets/img/banana.png", "qty": "7", "unit": "pcs", "price": "\$1.99"},
    {"name": "Red Apple", "icon": "assets/img/apple_red.png", "qty": "1", "unit": "Kg", "price": "\$4.99"},
    {"name": "Ginger", "icon": "assets/img/ginger.png", "qty": "250", "unit": "gm", "price": "\$3.99"},
  ];

  List groceriesArr = [
    {"name": "Pulses", "icon": "assets/img/pulses.png", "color": const Color(
        0xfff4cdf1)},
    {"name": "Rice", "icon": "assets/img/rice.png", "color": const Color(0xff53B175)},
    {"name": "Beans", "icon": "assets/img/pulses.png", "color": const Color(
        0xffa96ecf)},
  ];

  List newArrivalsArr = [
    {"name": "Strawberries", "icon": "assets/img/strawberry.png", "qty": "1", "unit": "box", "price": "\$2.99"},
    {"name": "Almond Milk", "icon": "assets/img/almondmilk.jpeg", "qty": "1", "unit": "Litre", "price": "\$4.49"},
  ];

  List popularArr = [
    {"name": "Bell Pepper Red", "icon": "assets/img/bell_pepper_red.png", "qty": "1", "unit": "kg", "price": "\$2.99"},
    {"name": "Ginger", "icon": "assets/img/ginger.png", "qty": "250", "unit": "gm", "price": "\$3.99"},
    {"name": "Avocados", "icon": "assets/img/avacado.png", "qty": "3", "unit": "pcs", "price": "\$2.99"},
    {"name": "Blueberries", "icon": "assets/img/blueberry.jpg", "qty": "1", "unit": "box", "price": "\$3.49"},
  ];

  List bannerList = [
    "assets/img/bannertop.png",
    "assets/img/bannertop.png",
    "assets/img/bannertop.png",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // color: const Color(0xFFEDDDE6),
        color: const Color(0xFFFAFAFA),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTopBar(),
                _buildSearchBar(),
                _buildBanner(),
                _buildSectionTitle("Exclusive Offers", Icons.local_offer),
                _buildHorizontalScrollSection(exclusiveOfferArr),
                _buildCategorySection(),
                _buildSection("New Arrivals", Icons.fiber_new, newArrivalsArr),
                _buildSection("Popular Picks", Icons.whatshot, popularArr),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome text
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text.rich(
                TextSpan(
                  children: [
                    const TextSpan(
                      text: "Welcome back,\n",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                    TextSpan(
                      text: "Abishek 👋",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: TColor.primaryText,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.shopping_cart_outlined, size: 22, color: Colors.black),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Branch Info
          GestureDetector(
            onTap: () {
              // handle branch selection
            },
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.store, color: Colors.black, size: 20),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Your Selected Branch",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.black45,
                      ),
                    ),
                    Row(
                      children: const [
                        Text(
                          "Colombo",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(Icons.keyboard_arrow_down, size: 20, color: Colors.black54),
                      ],
                    ),
                  ],
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
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.black12),
          borderRadius: BorderRadius.circular(17),
        ),
        child: TextField(
          controller: txtSearch,
          style: const TextStyle(fontSize: 14),
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.search, color: Colors.black54),
            hintText: "Search anything you want",
            hintStyle: TextStyle(
              color: Colors.black45,
              fontWeight: FontWeight.w400,
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ),
    );
  }


  Widget _buildBanner() {
    return CarouselSlider(
      options: CarouselOptions(
        height: 200.0,
        autoPlay: true,
        enlargeCenterPage: true,
        viewportFraction: 0.9,
      ),
      items: bannerList.map((imgPath) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.asset(imgPath, fit: BoxFit.cover, width: double.infinity),
        );
      }).toList(),
    );
  }

  Widget _buildSection(String title, IconData icon, List items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(title, icon),
        _buildStyledGrid(items),
      ],
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: TColor.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: TColor.primaryText),
              ),
            ],
          ),
          TextButton(
            onPressed: () {},
            child: const Text("See All", style: TextStyle(fontSize: 15, color: Colors.black)),
          ),
        ],
      ),
    );
  }

  Widget _buildStyledGrid(List items) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: GridView.builder(
        itemCount: items.length,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 14,
          crossAxisSpacing: 14,
          childAspectRatio: 0.75,
        ),
        itemBuilder: (context, index) {
          var pObj = items[index];
          return ProductCell(
            pObj: pObj,
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ProductDetails()));
            },
            onCart: () {},
          );
        },
      ),
    );
  }

  Widget _buildHorizontalScrollSection(List items) {
    return SizedBox(
      height: 250,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: items.length,
        itemBuilder: (context, index) {
          var pObj = items[index];
          return ProductCell(
            pObj: pObj,
            // useAltStyle: true,
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ProductDetails()));
            },
            onCart: () {},
          );
        },
      ),
    );
  }

  Widget _buildCategorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("Groceries", Icons.category),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 15),
            itemCount: groceriesArr.length,
            itemBuilder: (context, index) {
              var pObj = groceriesArr[index] as Map? ?? {};
              return CategoryCell(
                pObj: pObj,
                onPressed: () {},
              );
            },
          ),
        ),
      ],
    );
  }
}
