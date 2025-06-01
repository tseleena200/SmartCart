import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:google_fonts/google_fonts.dart';

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
  int _currentBannerIndex = 0;

  List exclusiveOfferArr = [
    {"name": "Organic Bananas", "icon": "assets/img/banana.png", "qty": "7", "unit": "pcs", "price": "\$1.99"},
    {"name": "Red Apple", "icon": "assets/img/apple_red.png", "qty": "1", "unit": "Kg", "price": "\$4.99"},
    {"name": "Ginger", "icon": "assets/img/ginger.png", "qty": "250", "unit": "gm", "price": "\$3.99"},
  ];

  List groceriesArr = [
    {"name": "Pulses", "icon": "assets/img/pulses.png", "color": const Color(0xfff4cdf1)},
    {"name": "Rice", "icon": "assets/img/rice.png", "color": const Color(0xfffcbad3)},
    {"name": "Beans", "icon": "assets/img/pulses.png", "color": const Color(0xffe4a4c3)},
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
              _buildBrandedHeader(context),
              _buildSearchBar(),
              _buildBanner(),
              _buildBannerIndicator(),
              _buildSection("Exclusive Offers", exclusiveOfferArr, horizontal: true),
              _buildCategoryPills(),
              _buildSection("New Arrivals", newArrivalsArr),
              _buildSection("Popular Picks", popularArr),
            ],
          ),
        ),
      ),
    );
  }
  Widget _buildBrandedHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Logo + Branch
          Row(
            children: [
              Image.asset(
                "assets/img/logo-transparent.png",
                height: 36,
                fit: BoxFit.contain,
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Branch:",
                    style: TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                  GestureDetector(
                    onTap: () {
                      // TODO: branch selection
                    },
                    child: Row(
                      children: const [
                        Icon(Icons.store_rounded, size: 16, color: Color(0xff87486E)),
                        SizedBox(width: 4),
                        Text(
                          "Colombo",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        Icon(Icons.keyboard_arrow_down, size: 16),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          // Cart icon
          CircleAvatar(
            backgroundColor: Colors.grey.shade100,
            radius: 20,
            child: Icon(Icons.shopping_cart_outlined, color: Color(0xff87486E)),
          ),
        ],
      ),
    );
  }




  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black12.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
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
                style: const TextStyle(fontSize: 14),
                decoration: const InputDecoration(
                  hintText: "Search anything you want",
                  border: InputBorder.none,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.mic_none, color: Colors.grey),
              onPressed: () {
                // TODO: Add your voice input logic here
                debugPrint("Voice search tapped");
              },
            ),
          ],
        ),
      ),
    );
  }



  Widget _buildBanner() {
    return CarouselSlider.builder(
      itemCount: bannerList.length,
      options: CarouselOptions(
        height: 160, // Recommended height to match good aspect ratio
        autoPlay: true,
        enlargeCenterPage: true,
        viewportFraction: 0.9,
      ),
      itemBuilder: (context, index, realIdx) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.asset(
            bannerList[index],
            fit: BoxFit.cover,
            width: double.infinity,
          ),
        );
      },
    );
  }

  Widget _buildBannerIndicator() {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 10), // Adds spacing above and below
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: bannerList.asMap().entries.map((entry) {
          return Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _currentBannerIndex == entry.key
                  ? TColor.primary
                  : TColor.primary.withOpacity(0.3),
            ),
          );
        }).toList(),
      ),
    );
  }



  Widget _buildSection(String title, List items, {bool horizontal = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Text(title,
              style: GoogleFonts.poppins(
                  fontSize: 18, fontWeight: FontWeight.bold, color: TColor.textTitle)),
        ),
        horizontal ? _buildHorizontalScrollSection(items) : _buildVerticalGrid(items),
      ],
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
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: ProductCell(
              pObj: pObj,
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProductDetails())),
              onCart: () => ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("${pObj["name"]} added to cart")),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildVerticalGrid(List items) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        shrinkWrap: true,
        itemCount: items.length,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 0.75,
        ),
        itemBuilder: (context, index) {
          var pObj = items[index];
          return ProductCell(
            pObj: pObj,
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProductDetails())),
            onCart: () => ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("${pObj["name"]} added to cart")),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategoryPills() {
    final List<Color> pastelColors = [
      Color(0xFFFDEBD0),
      Color(0xFFFADADD),
      Color(0xFFD7EAFD),
      Color(0xFFE8F8F5),
      Color(0xFFF9E2F4),
      Color(0xFFFDF2E9),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Text(
            "Groceries",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: TColor.textTitle,
            ),
          ),
        ),
        SizedBox(
          height: 80,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: groceriesArr.length,
            itemBuilder: (context, index) {
              var pObj = groceriesArr[index];
              return Container(
                width: 130,
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                decoration: BoxDecoration(
                  color: pastelColors[index % pastelColors.length],
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12.withOpacity(0.03),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 28,
                      height: 28,
                      child: Image.asset(pObj["icon"], fit: BoxFit.contain),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        pObj["name"],
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: TColor.primaryText,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

}
