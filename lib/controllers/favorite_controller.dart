import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class FavoriteController extends GetxController {
  static FavoriteController get instance => Get.find();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Add a product to favorites
  Future<void> addToFavorites({
    required String productID,
    required String productName,
    required String imageURL,
    required double price,
    required double discount,
    required double finalPrice,
    required String category,
    required String userName,
  }) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    try {
      final docRef = _firestore
          .collection('Users')
          .doc(userId)
          .collection('Favorites')
          .doc(productID); // 1 product = 1 favorite doc

      await docRef.set({
        'productID': productID,
        'productName': productName,
        'imageURL': imageURL,
        'price': price.toDouble(),         // ✅ ensure type safety
        'discount': discount.toDouble(),   // ✅ ensure type safety
        'finalPrice': finalPrice.toDouble(), // ✅ ensure type safety
        'category': category,
        'favoritedAt': Timestamp.now(),
        'userName': userName, // Optional but useful
      });

      Get.snackbar("Added", "$productName added to favorites.");
    } catch (e) {
      Get.snackbar("Error", "Failed to add to favorites: $e");
    }
  }

  /// Remove a product from favorites
  Future<void> removeFromFavorites(String productID) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    try {
      await _firestore
          .collection('Users')
          .doc(userId)
          .collection('Favorites')
          .doc(productID)
          .delete();

      Get.snackbar("Removed", "Product removed from favorites.");
    } catch (e) {
      Get.snackbar("Error", "Failed to remove favorite: $e");
    }
  }

  /// Get real-time favorites stream for UI
  Stream<QuerySnapshot> getUserFavoritesStream() {
    final userId = _auth.currentUser?.uid;
    return _firestore
        .collection('Users')
        .doc(userId)
        .collection('Favorites')
        .orderBy('favoritedAt', descending: true)
        .snapshots();
  }
}
