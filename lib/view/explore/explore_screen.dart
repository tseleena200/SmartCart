import 'package:flutter/material.dart';
import 'package:onlinegroceries/view/explore/search_screen.dart';
import '../../common_widget/explore_cell.dart';
import 'explore_details.dart';

class ExploreView extends StatefulWidget {
  const ExploreView({super.key});

  @override
  State<ExploreView> createState() => _ExploreViewState();
}

class _ExploreViewState extends State<ExploreView> {
  final TextEditingController txtSearch = TextEditingController();

  List findProductArr = [
    {
      "name": "Fruits & Vegetables",
      "sub": "20+ Fruits & Veg",
      "aisle": "Aisle 1",
      "icon": "assets/img/frash_fruits.png",
      "color": Color(0xffE6F6EC),
    },
    {
      "name": "Fishes & Meat",
      "sub": "30+ Fishes and Meat",
      "aisle": "Aisle 2",
      "icon": "assets/img/meat_fish.png",
      "color": Color(0xffFFECE4),
    },
    {
      "name": "Cooking Element",
      "sub": "60+ Cooking Element",
      "aisle": "Aisle 3",
      "icon": "assets/img/cooking_oil.png",
      "color": Color(0xffF3E5F5),
    },
    {
      "name": "Home & Cleaning",
      "sub": "1000+ Home Cleaning Product",
      "aisle": "Aisle 4",
      "icon": "assets/img/cleaning.png",
      "color": Color(0xffFFF3E0),
    },
    {
      "name": "Kitchen Appliances",
      "sub": "150+ Kitchen Appliances",
      "aisle": "Aisle 5",
      "icon": "assets/img/kitchen.png",
      "color": Color(0xffE1F5FE),
    },
    {
      "name": "Snacks Item",
      "sub": "1000+ Snack Product",
      "aisle": "Aisle 6",
      "icon": "assets/img/bakery_snacks.png",
      "color": Color(0xffE6F6EC),
    },
    {
      "name": "Dairy & Sweets",
      "sub": "10+ Dairy & Sweets Product",
      "aisle": "Aisle 7",
      "icon": "assets/img/dairy_eggs.png",
      "color": Color(0xffFBE9E7),
    },
    {
      "name": "Personal Care",
      "sub": "10+ Personal Care Product",
      "aisle": "Aisle 8",
      "icon": "assets/img/personal_care.png",
      "color": Color(0xffE3F2FD),
    },
    {
      "name": "Stationery & Office",
      "sub": "10+ Stationery Product",
      "aisle": "Aisle 9",
      "icon": "assets/img/stationery.png",
      "color": Color(0xffFFF0D0),
    },
    {
      "name": "Health & Wellness",
      "sub": "50+ Health Items",
      "aisle": "Aisle 10",
      "icon": "assets/img/personal_care.png",
      "color": Color(0xffE0F2F1),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Categories",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Promo banner
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFFFF0D0),
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "Get 10% off on Groceries Plus T&C Apply",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "Spend LKR 5000 Get 5% Discount",
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ),

          // Section title
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Text(
              "All Categories",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // Grid of categories
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.8, //  Makes the cards slim and wide
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
              ),
              itemCount: findProductArr.length,
              itemBuilder: (context, index) {
                final eObj = findProductArr[index];
                return ExploreCell(
                  pObj: eObj,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ExploreDetailsView(eObj: eObj),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
