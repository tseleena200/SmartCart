import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class TransactionController extends GetxController {
  static TransactionController get instance => Get.find();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String?> completeTransaction({
    required double finalTotal,
    required double originalTotal,
    required String paymentMethodSummary,
    required String discountLabel,
  }) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      Get.snackbar("Error", "User not logged in.");
      return null;
    }

    try {
      final cartRef = _firestore.collection('Carts').doc(userId);
      final cartDoc = await cartRef.get();

      if (!cartDoc.exists || cartDoc.data()?['isPaid'] == true) {
        Get.snackbar("Error", "No active cart to checkout.");
        return null;
      }

      final cartData = cartDoc.data()!;
      final timestamp = Timestamp.now();
      final List<dynamic> rawItems = cartData['items'];

      final List<Map<String, dynamic>> enrichedItems = [];

      for (final item in rawItems) {
        final productId = item['productID'];
        final productSnapshot = await _firestore.collection('Products').doc(productId).get();
        final productData = productSnapshot.data();

        // 🟡 Reduce stock
        final currentStock = productData?['stockLevel'] ?? 0;
        final quantityPurchased = item['quantity'];

        final newStock = currentStock - quantityPurchased;
        if (newStock >= 0) {
          await _firestore.collection('Products').doc(productId).update({
            'stockLevel': newStock
          });
        }

        // ✅ Enrich item
        enrichedItems.add({
          'productID': productId,
          'productName': item['productName'],
          'quantity': quantityPurchased,
          'unitPrice': item['unitPrice'],
          'discount': item['discount'],
          'itemFinalPrice': item['itemFinalPrice'],
          'unitType': item['unitType'],
          'unitValue': item['unitValue'],
          'imageURL': item['imageURL'],
          'RFIDCode': item['RFIDCode'],
          'category': productData?['category'] ?? 'Unknown',
        });
      }


      final transactionData = {
        'userID': userId,
        'userName': cartData['userName'],
        'items': enrichedItems,
        'originalAmount': originalTotal,
        'totalAmount': finalTotal,
        'discountLabel': discountLabel,
        'paymentMethod': paymentMethodSummary,
        'timestamp': timestamp,
      };

      final txnRef = await _firestore.collection('Transactions').add(transactionData);

      await _firestore.collection('Users').doc(userId).update({
        'purchaseHistory.orders': FieldValue.arrayUnion([
          {
            'txnID': txnRef.id,
            'total': finalTotal,
            'itemCount': rawItems.length,
            'timestamp': timestamp,
            'status': 'Completed'
          }
        ])
      });

      await cartRef.update({'isPaid': true});
      await cartRef.delete();

      Get.snackbar("Success", "Transaction completed and saved!");
      return txnRef.id;
    } catch (e) {
      Get.snackbar("Transaction Error", e.toString());
      return null;
    }

  }

}