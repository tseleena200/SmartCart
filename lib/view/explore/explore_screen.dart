import 'package:flutter/material.dart';
import 'package:onlinegroceries/view/explore/search_screen.dart';
import '../../common_widget/explore_cell.dart';
import '../main_tabview/main_tab.dart';
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
      "sub": "20+ Fresh Produce Items",
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
      "name": "Dairy",
      "sub": "Milk, Cheese, Yogurt",
      "aisle": "Aisle 3",
      "icon": "assets/img/dairy_eggs.png", // reuse
      "color": Color(0xffFBE9E7),
    },
    {
      "name": "Bakery",
      "sub": "Fresh Bread & Pastries",
      "aisle": "Aisle 4",
      "icon": "assets/img/bakery_snacks.png", // reuse
      "color": Color(0xffFFF3E0),
    },
    {
      "name": "Canned Goods",
      "sub": "Tinned Foods & Preserves",
      "aisle": "Aisle 5",
      "icon": "assets/img/cooking_oil.png", // TODO: Replace with canned image
      "color": Color(0xffFFFDE7),
    },
    {
      "name": "Pasta & Rice",
      "sub": "Staples & Grains",
      "aisle": "Aisle 6",
      "icon": "assets/img/meat_fish.png", // TODO: Replace with pasta/rice icon
      "color": Color(0xffE1F5FE),
    },
    {
      "name": "Herbs & Spices",
      "sub": "Flavorful Additions",
      "aisle": "Aisle 7",
      "icon": "assets/img/cooking_oil.png", // TODO: Replace with spice icon
      "color": Color(0xffF3E5F5),
    },
    {
      "name": "Frozen Foods",
      "sub": "Veggies, Meals & More",
      "aisle": "Aisle 8",
      "icon": "assets/img/bakery_snacks.png", // TODO: Replace with frozen icon
      "color": Color(0xffE0F7FA),
    },
    {
      "name": "Ice Cream & Desserts",
      "sub": "Chilled Sweet Treats",
      "aisle": "Aisle 9",
      "icon": "assets/img/dairy_eggs.png", // reuse
      "color": Color(0xffFFF0F0),
    },
    {
      "name": "Breakfast & Cereals",
      "sub": "Morning Essentials",
      "aisle": "Aisle 10",
      "icon": "assets/img/frash_fruits.png", // TODO: Replace with cereal icon
      "color": Color(0xffFBE4FF),
    },
    {
      "name": "Snacks Item",
      "sub": "Chips, Nuts & More",
      "aisle": "Aisle 11",
      "icon": "assets/img/bakery_snacks.png", // reuse
      "color": Color(0xffE6F6EC),
    },
    {
      "name": "Beverages",
      "sub": "Juices, Water, Soft Drinks",
      "aisle": "Aisle 12",
      "icon": "assets/img/personal_care.png", // TODO: Replace with drinks icon
      "color": Color(0xffE1F5FE),
    },
    {
      "name": "Wine & Spirits",
      "sub": "Alcoholic Drinks",
      "aisle": "Aisle 13",
      "icon": "assets/img/kitchen.png", // TODO: Replace with wine icon
      "color": Color(0xffFFF3F0),
    },
    {
      "name": "Baby Products",
      "sub": "Diapers, Food, Care",
      "aisle": "Aisle 14",
      "icon": "assets/img/dairy_eggs.png", // TODO: Replace with baby icon
      "color": Color(0xffFFF3E0),
    },
    {
      "name": "Feminine Care",
      "sub": "Pads, Washes, Hygiene",
      "aisle": "Aisle 15",
      "icon": "assets/img/personal_care.png", // reuse
      "color": Color(0xffFCE4EC),
    },
    {
      "name": "Personal Care",
      "sub": "Bath, Hair, Grooming",
      "aisle": "Aisle 16",
      "icon": "assets/img/personal_care.png",
      "color": Color(0xffE3F2FD),
    },
    {
      "name": "Health & Wellness",
      "sub": "OTC & Supplements",
      "aisle": "Aisle 17",
      "icon": "assets/img/personal_care.png", // reuse
      "color": Color(0xffE0F2F1),
    },
    {
      "name": "Cleaning Supplies",
      "sub": "Home & Surface Care",
      "aisle": "Aisle 18",
      "icon": "assets/img/cleaning.png",
      "color": Color(0xffE0F7FA),
    },
    {
      "name": "Household Essentials",
      "sub": "Daily Use Items",
      "aisle": "Aisle 19",
      "icon": "assets/img/kitchen.png", // reuse
      "color": Color(0xffFFF8E1),
    },
    {
      "name": "Pet Supplies",
      "sub": "Food, Toys, Care",
      "aisle": "Aisle 20",
      "icon": "assets/img/personal_care.png", // TODO: Replace with pet icon
      "color": Color(0xffFFF0D0),
    },
    {
      "name": "Stationery & Office",
      "sub": "Pens, Books & Supplies",
      "aisle": "Aisle 21",
      "icon": "assets/img/stationery.png",
      "color": Color(0xffFFF0D0),
    },
    {
      "name": "Offers",
      "sub": "Deals & Discounts",
      "aisle": "Aisle 22",
      "icon": "assets/img/bakery_snacks.png", // TODO: Replace with discount tag icon
      "color": Color(0xffFFECE4),
    },
  ];


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.grey.shade100,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const MainTabView()),
                  (route) => false, // remove all previous routes
            );
          },
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
