import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class CartController extends GetxController {
  static CartController get instance => Get.find();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> addProductToCartByRFID(String rfidCode) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    try {
      final productQuery = await _firestore
          .collection('Products')
          .where('RFIDCode', isEqualTo: rfidCode)
          .limit(1)
          .get();

      if (productQuery.docs.isEmpty) {
        Get.snackbar("Product Not Found", "No product matches the scanned RFID tag.");
        return;
      }

      final product = productQuery.docs.first;
      final productData = product.data();

      final userDoc = await _firestore.collection('Users').doc(userId).get();
      final userData = userDoc.data() ?? {};
      final userName = userData['name'] ?? 'Unknown';

      final cartRef = _firestore.collection('Carts').doc(userId);
      final cartDoc = await cartRef.get();

      List<Map<String, dynamic>> items = [];

      if (cartDoc.exists) {
        final cartData = cartDoc.data()!;
        items = List<Map<String, dynamic>>.from(cartData['items'] ?? []);

        bool found = false;
        for (var item in items) {
          if (item['productID'] == product.id) {
            item['quantity'] += 1;

            // ✅ Recalculate itemFinalPrice
            item['itemFinalPrice'] = _recalculateFinalPrice(item) * item['quantity'];

            found = true;
            break;
          }
        }

        if (!found) {
          items.add(_buildCartItem(product.id, productData, rfidCode));
        }
      } else {
        items = [
          _buildCartItem(product.id, productData, rfidCode)
        ];
      }

      double total = _calculateTotal(items);

      await cartRef.set({
        'cartID': userId,
        'userID': userId,
        'userName': userName,
        'cartStatus': 'active',
        'items': items,
        'totalAmount': "\$${total.toStringAsFixed(2)}",
        'isPaid': false,
        'timestamp': FieldValue.serverTimestamp(),
      });

      Get.snackbar("Scanned!", "Product added to cart successfully.");
    } catch (e) {
      Get.snackbar("Error", e.toString());
    }
  }

  Future<void> removeProductFromCartByRFID(String rfidCode) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    try {
      final productQuery = await _firestore
          .collection('Products')
          .where('RFIDCode', isEqualTo: rfidCode)
          .limit(1)
          .get();

      if (productQuery.docs.isEmpty) {
        Get.snackbar("Product Not Found", "No product matches the RFID tag.");
        return;
      }

      final product = productQuery.docs.first;
      final cartRef = _firestore.collection('Carts').doc(userId);
      final cartDoc = await cartRef.get();

      if (!cartDoc.exists) {
        Get.snackbar("Cart Empty", "No active cart found.");
        return;
      }

      final cartData = cartDoc.data()!;
      final rawItems = cartData['items'] ?? [];
      final items = List<Map<String, dynamic>>.from(
        rawItems.map((e) => Map<String, dynamic>.from(e)),
      );

      bool updated = false;

      for (int i = 0; i < items.length; i++) {
        if (items[i]['productID'] == product.id) {
          if (items[i]['quantity'] > 1) {
            items[i]['quantity'] -= 1;

            // ✅ Recalculate itemFinalPrice
            items[i]['itemFinalPrice'] =
                _recalculateFinalPrice(items[i]) * items[i]['quantity'];
          } else {
            items.removeAt(i);
          }
          updated = true;
          break;
        }
      }

      if (!updated) {
        Get.snackbar("Not in Cart", "This product is not in your cart.");
        return;
      }

      double total = _calculateTotal(items);

      await cartRef.update({
        'items': items,
        'totalAmount': "\$${total.toStringAsFixed(2)}",
      });

      Get.snackbar("Removed", "1 item removed from cart.");
    } catch (e) {
      Get.snackbar("Error", e.toString());
    }
  }

  Map<String, dynamic> _buildCartItem(String productId, Map<String, dynamic> product, String rfidCode) {
    final discountedUnitPrice = _applyDiscount(product);
    return {
      'productID': productId,
      'productName': product['productName'],
      'RFIDCode': rfidCode,
      'imageURL': product['imageURL'],
      'unitPrice': product['price'],
      'unitType': product['unitType'],
      'unitValue': product['unitValue'],
      'quantity': 1,
      'discount': product['discount'] ?? 0,
      'itemFinalPrice': discountedUnitPrice * 1,
    };
  }

  double _applyDiscount(Map<String, dynamic> product) {
    final double price = (product['price'] ?? 0).toDouble();
    final double discount = (product['discount'] ?? 0).toDouble();
    return double.parse((price * (1 - discount / 100)).toStringAsFixed(2));
  }

  double _recalculateFinalPrice(Map<String, dynamic> item) {
    final double unitPrice = (item['unitPrice'] ?? 0).toDouble();
    final double discount = (item['discount'] ?? 0).toDouble();
    return double.parse((unitPrice * (1 - discount / 100)).toStringAsFixed(2));
  }

  double _calculateTotal(List<Map<String, dynamic>> items) {
    double total = 0;
    for (var item in items) {
      final price = _recalculateFinalPrice(item);
      final quantity = item['quantity'] ?? 1;
      total += price * quantity;
    }
    return total;
  }
}
