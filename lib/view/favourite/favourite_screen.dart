import 'package:flutter/material.dart';
import 'package:onlinegroceries/common/color_extension.dart';
import 'package:onlinegroceries/common_widget/round_button.dart';
import 'package:onlinegroceries/common_widget/favourite_row.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../../controllers/favorite_controller.dart';

class FavouriteView extends StatefulWidget {
  const FavouriteView({super.key});

  @override
  State<FavouriteView> createState() => _FavouriteViewState();
}

class _FavouriteViewState extends State<FavouriteView> {
  final FavoriteController favoriteController = Get.put(FavoriteController());

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
          StreamBuilder<QuerySnapshot>(
            stream: favoriteController.getUserFavoritesStream(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: Text("No favorites added yet."));
              }

              final favorites = snapshot.data!.docs;

              return ListView.separated(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                itemCount: favorites.length,
                separatorBuilder: (_, __) => const SizedBox(height: 1),
                itemBuilder: (context, index) {
                  final fav = favorites[index].data() as Map<String, dynamic>;
                  return Dismissible(
                    key: Key(fav["productID"]),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      color: Colors.red.shade900,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    onDismissed: (_) {
                      favoriteController.removeFromFavorites(fav["productID"]);
                    },
                    child: FavouriteRow(
                      pObj: {
                        "productName": fav["productName"] ?? "Unnamed",
                        "imageURL": fav["imageURL"] ?? "",
                        "finalPrice": (fav["finalPrice"] ?? 0).toDouble(),
                        "category": fav["category"] ?? "In Stock",
                      },
                      onPressed: () {
                        // TODO: handle add-to-cart logic
                      },
                    ),
                  );
                },
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: RoundButton(
              title: "Add All To Cart",
              onPressed: () {
                // TODO: Implement add all to cart logic
              },
            ),
          )
        ],
      ),
    );
  }
}
