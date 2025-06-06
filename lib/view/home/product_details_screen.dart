import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../../common/color_extension.dart';
import '../../common_widget/round_button.dart';
import 'package:get/get.dart';
import '../../controllers/cart_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../rfid/rfid_removal_overlay.dart';
import '../rfid/rfid_scan_overlay.dart';

class ProductDetails extends StatefulWidget {
  final Map<String, dynamic> product;

  const ProductDetails({super.key, required this.product});

  @override
  State<ProductDetails> createState() => _ProductDetailsState();
}

class _ProductDetailsState extends State<ProductDetails> {
  final CartController cartController = Get.put(CartController());
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  int scannedCount = 0;

  @override
  void initState() {
    super.initState();
    _loadScannedCount();
  }

  Future<void> _loadScannedCount() async {
    final userId = _auth.currentUser?.uid;
    final productId = widget.product['productID'];

    if (userId != null && productId != null) {
      final cartDoc = await _firestore.collection('Carts').doc(userId).get();
      if (cartDoc.exists) {
        final cartData = cartDoc.data()!;
        final items = List<Map<String, dynamic>>.from(cartData['items'] ?? []);
        final item = items.firstWhere((e) => e['productID'] == productId,
            orElse: () => {});
        setState(() {
          scannedCount = item['quantity'] ?? 0;
        });
      }
    }
  }

  Future<void> _removeFromCart(String rfidCode) async {
    await cartController.removeProductFromCartByRFID(rfidCode);
    await _loadScannedCount();
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final String imageUrl = product['imageURL'] ?? '';
    final String name = product['productName'] ?? 'Unnamed';
    final String description =
        product['description'] ?? 'No description available.';
    final int stockLevel = product['stockLevel'] ?? 0;
    final double price = (product['price'] ?? 0).toDouble();
    final double discount = (product['discount'] ?? 0).toDouble();
    final bool isExclusive = product['isExclusive'] == true;
    final double finalPrice = price * (1 - discount / 100);
    final String nutrition = product['nutrition'] ?? '';
    final String unitLabel =
        (product['unitValue'] != null && product['unitType'] != null)
            ? '${product['unitValue']} ${product['unitType']}'
            : '';

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: MediaQuery.of(context).size.width * 0.75,
                  decoration: const BoxDecoration(
                    color: Color(0xffF9F9F9),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(28),
                      bottomRight: Radius.circular(28),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 60),
                    child: Center(
                      child: Image.network(
                        imageUrl,
                        width: MediaQuery.of(context).size.width * 0.70,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 40,
                  left: 16,
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 20,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new,
                          color: Colors.black, size: 18),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),
                if (isExclusive)
                  Positioned(
                    top: 100,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.deepPurple,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text("Exclusive",
                          style: TextStyle(fontSize: 10, color: Colors.white)),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(name,
                            style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: TColor.primaryText)),
                      ),
                      IconButton(
                        icon: const Icon(Icons.favorite_border,
                            color: Colors.grey),
                        onPressed: () {},
                      ),
                    ],
                  ),
                  Text("$unitLabel • In Stock: $stockLevel",
                      style:
                          const TextStyle(fontSize: 14, color: Colors.black87)),

                  const SizedBox(height: 10),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Price",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600)),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          if (discount > 0)
                            Text(
                              "\$${price.toStringAsFixed(2)}",
                              style: const TextStyle(
                                decoration: TextDecoration.lineThrough,
                                color: Colors.grey,
                                fontSize: 13,
                              ),
                            ),
                          Text(
                            "\$${finalPrice.toStringAsFixed(2)}",
                            style: TextStyle(
                              color: TColor.primary,
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const Text("1 item per scan",
                              style: TextStyle(
                                  fontSize: 12, color: Colors.black87)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  Theme(
                    data: Theme.of(context).copyWith(
                      dividerColor: Colors.transparent,
                    ),
                    child: ExpansionTile(
                      tilePadding: const EdgeInsets.symmetric(horizontal: 0), // removes default left padding
                      title: const Text(
                        "Product Details",
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Text(description, style: const TextStyle(fontSize: 13, height: 1.5)),
                        ),
                      ],
                    ),
                  ),
                  const Divider(
                    height: 10,
                    thickness: 2,
                    indent: 0,
                    endIndent: 0,
                    color: Colors.black12,
                  ),
                  Theme(
                    data: Theme.of(context).copyWith(
                      dividerColor: Colors.transparent,
                    ),
                    child: ExpansionTile(
                      tilePadding: const EdgeInsets.symmetric(horizontal: 0),
                      title: const Text(
                        "Nutrition",
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(nutrition.split(',').first),
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Text(nutrition.replaceAll(',', '\n•'), style: const TextStyle(fontSize: 13, height: 1.5)),
                        ),
                      ],
                    ),
                  ),

                  const Divider(
                    height: 10,
                    thickness: 2,
                    indent: 0,
                    endIndent: 0,
                    color: Colors.black12,
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12.0), // Matches ExpansionTile spacing
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Review",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                        Row(
                          children: [
                            RatingBarIndicator(
                              rating: 4.5,
                              itemCount: 5,
                              itemSize: 16,
                              itemBuilder: (context, _) =>
                              const Icon(Icons.star, color: Colors.amber),
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.chevron_right, color: Colors.grey),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Divider(
                    height: 10,
                    thickness: 2,
                    indent: 0,
                    endIndent: 0,
                    color: Colors.black12,
                  ),
                  const SizedBox(height: 20),

                  RoundButton(
                    title: "Simulate Scan",
                    onPressed: () async {
                      final rfidCode = product['RFIDCode'];
                      if (rfidCode != null && rfidCode.toString().isNotEmpty) {
                        if (scannedCount >= stockLevel) {
                          Get.snackbar("Stock Limit",
                              "You’ve reached the available stock for this item.",
                              backgroundColor: TColor.error,
                              colorText: Colors.white);
                          return;
                        }

                        // ✅ Use Get.dialog with barrierDismissible set to false
                        await Get.dialog(
                          RFIDScanOverlay(rfidCode: rfidCode),
                          barrierDismissible: false,
                        );

                        // ✅ Then add to cart and update count
                        await cartController.addProductToCartByRFID(rfidCode);
                        await _loadScannedCount();

                        Get.snackbar(
                            "Scanned!", "Product added to cart successfully.",
                            backgroundColor: TColor.success,
                            colorText: Colors.white);
                      } else {
                        Get.snackbar(
                            "Error", "RFID not found for this product.",
                            backgroundColor: TColor.error,
                            colorText: Colors.white);
                      }
                    },
                  ),
                  const SizedBox(height: 20),
                  if (scannedCount > 0)
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.shopping_cart,
                                  size: 20, color: Colors.black54),
                              const SizedBox(width: 8),
                              Text("Total in Cart: $scannedCount",
                                  style: const TextStyle(
                                      fontSize: 14, color: Colors.black87)),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.attach_money,
                                      size: 20, color: Colors.black54),
                                  const SizedBox(width: 8),
                                  Text(
                                      "Subtotal: \$${(scannedCount * finalPrice).toStringAsFixed(2)}",
                                      style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold)),
                                ],
                              ),
                              SizedBox(
                                height: 36,
                                child: ElevatedButton(
                                  onPressed: () async {
                                    final rfidCode = product['RFIDCode'];
                                    if (rfidCode != null && rfidCode.toString().isNotEmpty) {
                                      await Get.dialog(
                                        RFIDRemovalOverlay(
                                          rfidCode: rfidCode,
                                          cartController: cartController,
                                        ),
                                        barrierDismissible: false,
                                      );

                                      // ✅ Refresh scanned count after dialog closes
                                      await _loadScannedCount();

                                      Get.snackbar("Removed", "Product removed from cart.",
                                        backgroundColor: Colors.redAccent,
                                        colorText: Colors.white,
                                      );
                                    } else {
                                      Get.snackbar("Error", "RFID code not found.",
                                        backgroundColor: Colors.red,
                                        colorText: Colors.white,
                                      );
                                    }
                                  },

                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: TColor.primary,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16),
                                  ),
                                  child: const Text("Remove",
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 13)),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
