import 'package:flutter/material.dart';
import 'package:onlinegroceries/common/color_extension.dart';
import 'package:onlinegroceries/common_widget/round_button.dart';
import 'package:onlinegroceries/common_widget/favourite_row.dart';

class FavouriteView extends StatefulWidget {
  const FavouriteView({super.key});

  @override
  State<FavouriteView> createState() => _FavouriteViewState();
}

class _FavouriteViewState extends State<FavouriteView> {
  List<Map<String, dynamic>> listArr = [
    {
      "name": "Sprite Can",
      "icon": "assets/img/sprite_can.png",
      "qty": "325",
      "unit": "ml, Price",
      "price": "\$1.49"
    },
    {
      "name": "Diet Coke",
      "icon": "assets/img/diet_coke.png",
      "qty": "355",
      "unit": "ml, Price",
      "price": "\$1.99"
    },
    {
      "name": "Apple & Grape Juice",
      "icon": "assets/img/juice_apple_grape.png",
      "qty": "2",
      "unit": "L, Price",
      "price": "\$15.99"
    },
    {
      "name": "Coca Cola Can",
      "icon": "assets/img/cocacola_can.png",
      "qty": "325",
      "unit": "ml, Price",
      "price": "\$4.99"
    },
    {
      "name": "Pepsi Can",
      "icon": "assets/img/pepsi_can.png",
      "qty": "325",
      "unit": "ml, Price",
      "price": "\$4.49"
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
          "My Favourites",
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
            separatorBuilder: (_, __) => const SizedBox(height: 1),
            itemBuilder: (context, index) {
              var pObj = listArr[index];
              return Dismissible(
                key: Key(pObj["name"]),
                direction: DismissDirection.endToStart,
                background: Container(
                  color: Colors.redAccent,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                onDismissed: (_) {
                  setState(() {
                    listArr.removeAt(index);
                  });
                },
                child: FavouriteRow(
                  pObj: pObj,
                  onPressed: () {
                    // Optional: handle single add action
                  },
                ),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: RoundButton(
              title: "Add All To Cart",
              onPressed: () {
                // Handle add all to cart
              },
            ),
          )
        ],
      ),
    );
  }
}
