import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class TransactionController extends GetxController {
  static TransactionController get instance => Get.find();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> completeTransaction() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      Get.snackbar("Error", "User not logged in.");
      return;
    }

    try {
      final cartRef = _firestore.collection('Carts').doc(userId);
      final cartDoc = await cartRef.get();

      if (!cartDoc.exists || cartDoc.data()?['isPaid'] == true) {
        Get.snackbar("Error", "No active cart to checkout.");
        return;
      }

      final cartData = cartDoc.data()!;
      final transactionData = {
        'userID': userId,
        'userName': cartData['userName'],
        'items': cartData['items'],
        'totalAmount': cartData['totalAmount'],
        'paymentMethod': 'Card',  // you can dynamically set this later
        'timestamp': FieldValue.serverTimestamp(),
      };

      // Save to Transactions collection
      await _firestore.collection('Transactions').add(transactionData);

      // Update Cart to mark it as paid
      await cartRef.update({'isPaid': true});

      Get.snackbar("Success", "Transaction completed successfully!");
    } catch (e) {
      Get.snackbar("Transaction Error", e.toString());
    }
  }
}
