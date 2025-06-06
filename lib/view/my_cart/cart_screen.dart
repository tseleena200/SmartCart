import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import '../../controllers/cart_controller.dart';
import '../../common/color_extension.dart';
import '../rfid/rfid_scan_overlay.dart';
import '../rfid/rfid_removal_overlay.dart';
import 'checkout_screen.dart';

class MyCartView extends StatefulWidget {
  const MyCartView({super.key});

  @override
  State<MyCartView> createState() => _MyCartViewState();
}

class _MyCartViewState extends State<MyCartView> {
  final CartController cartController = Get.put(CartController());

  @override
  Widget build(BuildContext context) {
    final String userId = FirebaseAuth.instance.currentUser?.uid ?? '';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey.shade200,
        elevation: 0.5,
        centerTitle: true,
        title: Text(
          "My Cart",
          style: TextStyle(
            color: TColor.primaryText,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      backgroundColor: Colors.grey.shade100,
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance.collection('Carts').doc(userId).snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || !snapshot.data!.exists) {
                return const Center(child: Text("Your cart is empty."));
              }

              final cartData = snapshot.data!.data() as Map<String, dynamic>? ?? {};
              final List<dynamic> items = cartData['items'] ?? [];

              if (items.isEmpty) {
                return const Center(child: Text("Your cart is empty."));
              }

              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  final String name = item['productName'] ?? 'Unnamed';
                  final String imageUrl = _convertDriveUrl(item['imageURL'] ?? '');
                  final String rfid = item['RFIDCode'] ?? '';
                  final int quantity = item['quantity'] ?? 1;
                  final double finalPrice = (item['itemFinalPrice'] ?? 0).toDouble();
                  final double unitPrice = (item['unitPrice'] ?? 0).toDouble();
                  final String unitLabel = (item['unitValue'] != null && item['unitType'] != null)
                      ? '${item['unitValue']} ${item['unitType']}'
                      : '';
                  final double discount = (item['discount'] ?? 0).toDouble();

                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          margin: const EdgeInsets.only(right: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey.shade300),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.network(
                              imageUrl,
                              fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      name,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.close),
                                    onPressed: () async {
                                      for (int i = 0; i < quantity; i++) {
                                        await cartController.removeProductFromCartByRFID(rfid);
                                      }
                                    },
                                  ),
                                ],
                              ),
                              if (unitLabel.isNotEmpty)
                                Text(
                                  unitLabel,
                                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                                ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  _quantityButton(
                                    icon: Icons.remove,
                                    onPressed: quantity > 1
                                        ? () async {
                                      await Get.dialog(
                                        RFIDRemovalOverlay(
                                          rfidCode: rfid,
                                          cartController: cartController,
                                        ),
                                        barrierDismissible: false,
                                      );
                                    }
                                        : null,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 10),
                                    child: Text(
                                      quantity.toString(),
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ),
                                  _quantityButton(
                                    icon: Icons.add,
                                    onPressed: () async {
                                      await Get.dialog(
                                        RFIDScanOverlay(rfidCode: rfid),
                                        barrierDismissible: false,
                                      );
                                      await cartController.addProductToCartByRFID(rfid);
                                    },
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  if (discount > 0)
                                    Text(
                                      "\$${(unitPrice * quantity).toStringAsFixed(2)}",
                                      style: const TextStyle(
                                        decoration: TextDecoration.lineThrough,
                                        fontSize: 13,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  const SizedBox(width: 6),
                                  Text(
                                    "\$${finalPrice.toStringAsFixed(2)}",
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  if (discount > 0)
                                    Container(
                                      margin: const EdgeInsets.only(left: 10),
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.green,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        "${discount.toInt()}% OFF",
                                        style: const TextStyle(fontSize: 10, color: Colors.white),
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('Carts')
                  .doc(FirebaseAuth.instance.currentUser?.uid ?? '')
                  .snapshots(),
              builder: (context, snapshot) {
                String total = "\$0.00";
                if (snapshot.hasData && snapshot.data!.exists) {
                  final data = snapshot.data!.data() as Map<String, dynamic>;
                  total = data['totalAmount'] ?? "\$0.00";
                }

                return MaterialButton(
                  onPressed: showCheckout,
                  height: 60,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(19)),
                  minWidth: double.infinity,
                  elevation: 0.1,
                  color: TColor.primary,
                  child: Stack(
                    alignment: Alignment.centerRight,
                    children: [
                      const Center(
                        child: Text(
                          "Go To Checkout",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.black12,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                        child: Text(
                          total,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _quantityButton({required IconData icon, VoidCallback? onPressed}) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: onPressed != null ? TColor.primary : Colors.grey.shade300,
        minimumSize: const Size(32, 32),
        padding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Icon(icon, size: 18, color: Colors.white),
    );
  }

  void showCheckout() {
    showModalBottomSheet(
      backgroundColor: Colors.transparent,
      isDismissible: false,
      context: context,
      builder: (context) => const CheckoutView(),
    );
  }

  String _convertDriveUrl(String url) {
    if (!url.contains('drive.google.com')) return url;
    final regExp = RegExp(r'd/([a-zA-Z0-9_-]+)');
    final match = regExp.firstMatch(url);
    final fileId = match != null ? match.group(1) : null;
    return fileId != null ? 'https://drive.google.com/uc?export=view&id=$fileId' : url;
  }
}