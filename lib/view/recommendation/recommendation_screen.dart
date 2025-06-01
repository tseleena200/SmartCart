import 'package:flutter/material.dart';
import 'package:onlinegroceries/common/color_extension.dart';
import 'package:onlinegroceries/common_widget/round_button.dart';
import 'package:onlinegroceries/common_widget/favourite_row.dart';

import '../../common_widget/recommendation_row.dart';

class RecommendationsView extends StatefulWidget {
  const RecommendationsView({super.key});

  @override
  State<RecommendationsView> createState() => _RecommendationsViewState();
}

class _RecommendationsViewState extends State<RecommendationsView> {
  List listArr = [
    {
      "name": "Coca Cola Zero",
      "icon": "assets/img/pepsi_can.png", // Replace with actual asset
      "qty": "355",
      "unit": "ml, Price",
      "price": "\$1.89"
    },
    {
      "name": "Tropicana Orange Juice",
      "icon": "assets/img/juice_apple_grape.png", // Replace with actual asset
      "qty": "1",
      "unit": "L, Price",
      "price": "\$3.49"
    },
    {
      "name": "Oreo Biscuits",
      "icon": "assets/img/almondmilk.jpeg", // Replace with actual asset
      "qty": "154",
      "unit": "g, Price",
      "price": "\$2.29"
    },
    {
      "name": "Lays Classic",
      "icon": "assets/img/apple.png", // Replace with actual asset
      "qty": "200",
      "unit": "g, Price",
      "price": "\$2.99"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
      ),
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            itemCount: listArr.length,
            separatorBuilder: (context, index) => const Divider(
              color: Colors.black26,
              height: 1,
            ),
            itemBuilder: (context, index) {
              var pObj = listArr[index] as Map? ?? {};
              return RecommendationRow(
                pObj: pObj,
                onPressed: () {
                  // Add to cart logic
                },
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                RoundButton(
                  title: "Add All To Cart",
                  onPressed: () {
                    // Logic for adding all items to cart (if needed)
                  },
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
