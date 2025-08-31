import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import '../../controllers/cart_controller.dart';
import '../../common/color_extension.dart';
import '../rfid/rfid_scan_overlay.dart';
import '../rfid/rfid_removal_overlay.dart';
import 'checkout_screen.dart';
import '../../services/recs_api.dart'; // ← recs API

class MyCartView extends StatefulWidget {
  const MyCartView({super.key});

  @override
  State<MyCartView> createState() => _MyCartViewState();
}

class _MyCartViewState extends State<MyCartView> {
  final CartController cartController = Get.put(CartController());

  Future<void> _refreshRecs() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    try {
      await RecsApi.refreshUserInstant(uid);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final String userId = FirebaseAuth.instance.currentUser?.uid ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F8),
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.white,
        title: Text(
          "M Y  C A R T ",
          style: TextStyle(
            color: TColor.primaryText,
            fontSize: 20,
            fontWeight: FontWeight.w700,
            letterSpacing: .2,
          ),
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
        ),
      ),
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('Carts')
                .doc(userId)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || !snapshot.data!.exists) {
                return const _EmptyCart();
              }

              final cartData =
                  snapshot.data!.data() as Map<String, dynamic>? ?? {};
              final List<dynamic> items = cartData['items'] ?? [];

              if (items.isEmpty) {
                return const _EmptyCart();
              }

              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 140),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  final String name = item['productName'] ?? 'Unnamed';
                  final String imageUrl =
                  _convertDriveUrl(item['imageURL'] ?? '');
                  final String rfid = item['RFIDCode'] ?? '';
                  final int quantity = (item['quantity'] ?? 1).clamp(1, 999);
                  final double finalPrice =
                  (item['itemFinalPrice'] ?? 0).toDouble();
                  final double unitPrice =
                  (item['unitPrice'] ?? 0).toDouble();
                  final double discount =
                  (item['discount'] ?? 0).toDouble().clamp(0, 100);
                  final String unitLabel =
                  (item['unitValue'] != null && item['unitType'] != null)
                      ? '${item['unitValue']} ${item['unitType']}'
                      : '';

                  return Dismissible(
                    key: ValueKey(rfid),
                    direction: DismissDirection.endToStart,
                    background: _SwipeDeleteBackground(),
                    onDismissed: (_) async {
                      for (int i = 0; i < quantity; i++) {
                        await cartController.removeProductFromCartByRFID(rfid);
                      }
                      await _refreshRecs();

                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            behavior: SnackBarBehavior.floating,
                            content: Text('$name removed'),
                            action: SnackBarAction(
                              label: 'Undo',
                              onPressed: () {
                                () async {
                                  for (int i = 0; i < quantity; i++) {
                                    await cartController
                                        .addProductToCartByRFID(rfid);
                                  }
                                  await _refreshRecs();
                                }();
                              },
                            ),
                          ),
                        );
                      }
                    },
                    child: GestureDetector(
                      onLongPress: () =>
                          _showRemoveOptions(context, rfid, name, quantity),
                      child: _CartItemCard(
                        name: name,
                        unitLabel: unitLabel,
                        imageUrl: imageUrl,
                        quantity: quantity,
                        finalPrice: finalPrice,
                        unitPrice: unitPrice * quantity,
                        discount: discount,
                        actions: PopupMenuButton<String>(
                          icon: const Icon(Icons.more_vert),
                          onSelected: (value) async {
                            if (value == 'remove1') {
                              await Get.dialog(
                                RFIDRemovalOverlay(
                                  rfidCode: rfid,
                                  cartController: cartController,
                                ),
                                barrierDismissible: false,
                              );
                              await _refreshRecs();
                            } else if (value == 'removeAll') {
                              for (int i = 0; i < quantity; i++) {
                                await cartController
                                    .removeProductFromCartByRFID(rfid);
                              }
                              await _refreshRecs();

                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    behavior: SnackBarBehavior.floating,
                                    content: Text('$name removed'),
                                    action: SnackBarAction(
                                      label: 'Undo',
                                      onPressed: () {
                                        () async {
                                          for (int i = 0; i < quantity; i++) {
                                            await cartController
                                                .addProductToCartByRFID(rfid);
                                          }
                                          await _refreshRecs();
                                        }();
                                      },
                                    ),
                                  ),
                                );
                              }
                            }
                          },
                          itemBuilder: (context) => const [
                            PopupMenuItem(
                              value: 'remove1',
                              child: Text('Remove 1'),
                            ),
                            PopupMenuItem(
                              value: 'removeAll',
                              child: Text('Remove All'),
                            ),
                          ],
                        ),
                        onDecrease: quantity > 1
                            ? () async {
                          await Get.dialog(
                            RFIDRemovalOverlay(
                              rfidCode: rfid,
                              cartController: cartController,
                            ),
                            barrierDismissible: false,
                          );
                          await _refreshRecs();
                        }
                            : null,
                        onIncrease: () async {
                          await Get.dialog(
                            RFIDScanOverlay(rfidCode: rfid),
                            barrierDismissible: false,
                          );
                          await cartController.addProductToCartByRFID(rfid);
                          await _refreshRecs();
                        },
                      ),
                    ),
                  );
                },
              );
            },
          ),

          // Bottom checkout bar
          Positioned(
            bottom: 12,
            left: 16,
            right: 16,
            child: StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('Carts')
                  .doc(FirebaseAuth.instance.currentUser?.uid ?? '')
                  .snapshots(),
              builder: (context, snapshot) {
                String total = "\$0.00";
                if (snapshot.hasData && snapshot.data!.exists) {
                  final data =
                      snapshot.data!.data() as Map<String, dynamic>? ?? {};
                  final amount = (data['totalAmount'] ?? 0).toDouble();
                  total = "\$${amount.toStringAsFixed(2)}";
                }

                return _CheckoutBar(
                  total: total,
                  onPressed: showCheckout,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showRemoveOptions(
      BuildContext context, String rfid, String name, int quantity) {
    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Modify '$name'",
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 12),
                ListTile(
                  leading: const Icon(Icons.remove),
                  title: const Text("Remove 1"),
                  onTap: () async {
                    Navigator.pop(context);
                    await Get.dialog(
                      RFIDRemovalOverlay(
                        rfidCode: rfid,
                        cartController: cartController,
                      ),
                      barrierDismissible: false,
                    );
                    await _refreshRecs();
                  },
                ),
                ListTile(
                  leading:
                  const Icon(Icons.delete_forever, color: Colors.redAccent),
                  title: const Text("Remove All"),
                  onTap: () async {
                    Navigator.pop(context);
                    for (int i = 0; i < quantity; i++) {
                      await cartController.removeProductFromCartByRFID(rfid);
                    }
                    await _refreshRecs();

                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          behavior: SnackBarBehavior.floating,
                          content: Text('$name removed'),
                          action: SnackBarAction(
                            label: 'Undo',
                            onPressed: () {
                              () async {
                                for (int i = 0; i < quantity; i++) {
                                  await cartController
                                      .addProductToCartByRFID(rfid);
                                }
                                await _refreshRecs();
                              }();
                            },
                          ),
                        ),
                      );
                    }
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.close),
                  title: const Text("Cancel"),
                  onTap: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
        );
      },
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
    return fileId != null
        ? 'https://drive.google.com/uc?export=view&id=$fileId'
        : url;
  }
}

/* ---------- UI Pieces (purely visual, no logic changes) ---------- */

class _SwipeDeleteBackground extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.redAccent,
        borderRadius: BorderRadius.circular(16),
      ),
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Icon(Icons.delete_sweep, color: Colors.white),
          SizedBox(width: 6),
          Text("Remove", style: TextStyle(color: Colors.white)),
        ],
      ),
    );
  }
}

class _CartItemCard extends StatelessWidget {
  const _CartItemCard({
    required this.name,
    required this.unitLabel,
    required this.imageUrl,
    required this.quantity,
    required this.finalPrice,
    required this.unitPrice,
    required this.discount,
    required this.onIncrease,
    required this.onDecrease,
    required this.actions,
  });

  final String name;
  final String unitLabel;
  final String imageUrl;
  final int quantity;
  final double finalPrice;
  final double unitPrice; // original * qty (for strike-through if discount)
  final double discount;
  final VoidCallback? onIncrease;
  final VoidCallback? onDecrease;
  final Widget actions;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade500),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            blurRadius: 10,
            spreadRadius: 0,
            offset: Offset(0, 4),
            color: Color(0x1A000000),
          ),
        ],
      ),
      child: Stack(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ProductImage(url: imageUrl),
              const SizedBox(width: 12),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (unitLabel.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF2F2F4),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            unitLabel,
                            style: const TextStyle(
                                fontSize: 11, color: Colors.black54),
                          ),
                        ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          if (discount > 0)
                            Text(
                              "\$${unitPrice.toStringAsFixed(2)}",
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                          if (discount > 0) const SizedBox(width: 6),
                          Text(
                            "\$${finalPrice.toStringAsFixed(2)}",
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                            ),
                          ),
                          if (discount > 0) const SizedBox(width: 8),
                          if (discount > 0)
                            _DiscountChip(label: "${discount.toInt()}% OFF"),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _QuantityStepper(
                        quantity: quantity,
                        onDecrease: onDecrease,
                        onIncrease: onIncrease,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Positioned(top: 0, right: 0, child: actions),
        ],
      ),
    );
  }
}

class _ProductImage extends StatelessWidget {
  const _ProductImage({required this.url});
  final String url;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 78,
      height: 78,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: const Color(0xFFF6F6F8),
        border: Border.all(color: const Color(0xFFE8E8ED)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Image.network(
          url,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => const Icon(
              Icons.broken_image_outlined,
              size: 28,
              color: Colors.grey),
          loadingBuilder: (context, child, progress) {
            if (progress == null) return child;
            return const Center(child: CircularProgressIndicator(strokeWidth: 2));
          },
        ),
      ),
    );
  }
}

class _DiscountChip extends StatelessWidget {
  const _DiscountChip({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.green,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 10,
          color: Colors.white,
          fontWeight: FontWeight.w700,
          letterSpacing: .2,
        ),
      ),
    );
  }
}

class _QuantityStepper extends StatelessWidget {
  const _QuantityStepper({
    required this.quantity,
    required this.onDecrease,
    required this.onIncrease,
  });

  final int quantity;
  final VoidCallback? onDecrease;
  final VoidCallback? onIncrease;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F9),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFE8E8ED)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _RoundIconBtn(
            icon: Icons.remove_rounded,
            onTap: onDecrease,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 150),
              child: Text(
                '$quantity',
                key: ValueKey(quantity),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  letterSpacing: .2,
                ),
              ),
            ),
          ),
          _RoundIconBtn(
            icon: Icons.add_rounded,
            onTap: onIncrease,
          ),
        ],
      ),
    );
  }
}

class _RoundIconBtn extends StatelessWidget {
  const _RoundIconBtn({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final bool enabled = onTap != null;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        width: 28,
        height: 28,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: enabled ? TColor.primary : Colors.grey.shade300,
          shape: BoxShape.circle,
          boxShadow: enabled
              ? const [
            BoxShadow(
              blurRadius: 6,
              offset: Offset(0, 3),
              color: Color(0x22000000),
            )
          ]
              : null,
        ),
        child: Icon(icon, size: 18, color: Colors.white),
      ),
    );
  }
}

class _CheckoutBar extends StatelessWidget {
  const _CheckoutBar({required this.total, required this.onPressed});

  final String total;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return PhysicalModel(
      color: Colors.transparent,
      elevation: 8,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        height: 66,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              TColor.primary.withOpacity(.95),
              TColor.primary.withOpacity(.85),
            ],
          ),
        ),
        child: Stack(
          alignment: Alignment.centerRight,
          children: [
            Center(
              child: Text(
                "Go To Checkout",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(.15),
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
              child: Text(
                total,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Positioned.fill(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: onPressed,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyCart extends StatelessWidget {
  const _EmptyCart();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.shopping_bag_outlined, size: 72, color: Colors.black38),
            const SizedBox(height: 12),
            const Text(
              "Your cart is empty",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            const Text(
              "Browse products and add them to your cart.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}
