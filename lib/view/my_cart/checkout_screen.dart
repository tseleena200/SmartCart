import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:onlinegroceries/common_widget/checkout_row.dart';
import 'package:onlinegroceries/view/my_cart/receipt_screen.dart';
import '../../common/color_extension.dart';
import '../../common_widget/round_button.dart';
import '../../controllers/transaction_controller.dart';
import 'error_screen.dart';
import 'payment_method_view.dart';

// 👇 import RecsApi
import '../../services/recs_api.dart';

class CheckoutView extends StatefulWidget {
  const CheckoutView({super.key});

  @override
  State<CheckoutView> createState() => _CheckoutViewState();
}

class _CheckoutViewState extends State<CheckoutView> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  double totalCost = 0.0;
  double originalCost = 0.0;
  String paymentMethod = "Select Method";
  String selectedDiscountLabel = 'None';
  double discountValue = 0.0;
  String? selectedCardType;

  final List<Map<String, dynamic>> discountOptions = [
    {'label': 'None', 'type': 'none', 'value': 0.0},
    {'label': 'First 3 Orders - 15% OFF', 'type': 'percent', 'value': 0.15},
    {'label': 'Welcome Offer - 10% OFF', 'type': 'percent', 'value': 0.10},
    {'label': 'Seasonal \$5 OFF', 'type': 'flat', 'value': 5.0},
  ];

  @override
  void initState() {
    super.initState();
    _fetchTotal();
  }

  Future<void> _fetchTotal() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    final cartDoc = await _firestore.collection('Carts').doc(userId).get();
    if (cartDoc.exists) {
      final data = cartDoc.data();
      if (data != null) {
        setState(() {
          originalCost = (data['totalAmount'] ?? 0).toDouble();
          totalCost = originalCost;
        });
      }
    }
  }

  void _applyDiscount() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    double discountedTotal = originalCost;

    try {
      final txnSnapshot = await _firestore
          .collection('Transactions')
          .where('userID', isEqualTo: userId)
          .get();
      final txnCount = txnSnapshot.docs.length;

      final seasonalUsed = txnSnapshot.docs.any(
            (doc) => doc['discountLabel'] == 'Seasonal \$5 OFF',
      );

      final option = discountOptions.firstWhere(
            (d) => d['label'] == selectedDiscountLabel,
        orElse: () => {'type': 'none', 'value': 0.0},
      );

      if (option['label'] == 'First 3 Orders - 15% OFF') {
        if (txnCount < 3) {
          discountedTotal = originalCost - (originalCost * option['value']);
        } else {
          Get.snackbar("Offer Expired", "You’ve already used the 3-order offer.");
          setState(() {
            selectedDiscountLabel = 'None';
          });
        }
      } else if (option['label'] == 'Seasonal \$5 OFF') {
        if (!seasonalUsed) {
          discountedTotal = originalCost - option['value'];
        } else {
          Get.snackbar("Offer Used", "You’ve already used this seasonal offer.");
          setState(() {
            selectedDiscountLabel = 'None';
          });
        }
      } else {
        if (option['type'] == 'percent') {
          discountedTotal = originalCost - (originalCost * option['value']);
        } else if (option['type'] == 'flat') {
          discountedTotal = originalCost - option['value'];
        }
      }

      setState(() {
        totalCost = discountedTotal.clamp(0, originalCost);
      });
    } catch (e) {
      Get.snackbar("Error", "Failed to apply discount: $e");
    }
  }

  Future<void> submitOrder() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      Get.snackbar("Error", "User not logged in.");
      return;
    }
    final txnSnapshot = await _firestore
        .collection('Transactions')
        .where('userID', isEqualTo: userId)
        .get();

    final txnCount = txnSnapshot.docs.length;
    final seasonalUsed = txnSnapshot.docs.any(
          (doc) => doc['discountLabel'] == 'Seasonal \$5 OFF',
    );

    if (selectedDiscountLabel == 'First 3 Orders - 15% OFF' && txnCount >= 3) {
      Get.snackbar("Invalid Discount", "First 3 Orders offer no longer valid.");
      return;
    }

    if (selectedDiscountLabel == 'Seasonal \$5 OFF' && seasonalUsed) {
      Get.snackbar("Invalid Discount", "Seasonal offer already used.");
      return;
    }

    if (paymentMethod == "Select Method") {
      showDialog(
        context: context,
        builder: (_) => const Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.symmetric(horizontal: 20),
          child: ErrorView(),
        ),
      );
      return;
    }

    if (totalCost <= 0.0) {
      Get.snackbar("Error", "Total amount must be greater than \$0.");
      return;
    }

    final txnId = await TransactionController.instance.completeTransaction(
      finalTotal: totalCost,
      originalTotal: originalCost,
      paymentMethodSummary: paymentMethod,
      discountLabel: selectedDiscountLabel,
    );

    if (txnId != null) {
      // ✅ refresh recs after a successful transaction
      try {
        await RecsApi.refreshUserInstant(userId);
      } catch (e) {
        debugPrint("recs refresh failed after checkout: $e");
      }

      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => ReceiptView(txnId: txnId)),
        );
      });
    }
  }

  void showCartConfirmationModal() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    final cartSnapshot = await _firestore.collection('Carts').doc(userId).get();
    final items = (cartSnapshot.data()?['items'] as List<dynamic>? ?? []);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Confirm Your Cart", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              SizedBox(
                height: 200,
                child: ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (_, index) {
                    final item = items[index];
                    return ListTile(
                      title: Text(item['productName'] ?? 'Item'),
                      trailing: Text('x${item['quantity'] ?? 1}'),
                    );
                  },
                ),
              ),
              if (selectedDiscountLabel != 'None')
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    "Discount Applied: $selectedDiscountLabel\nYou saved \$${(originalCost - totalCost).toStringAsFixed(2)}",
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.green),
                  ),
                ),
              Text(
                "Total to Pay: \$${totalCost.toStringAsFixed(2)}",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text("Back to Cart")),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Future.delayed(const Duration(milliseconds: 200), () {
                        submitOrder();
                      });
                    },
                    child: const Text("Confirm & Pay"),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Checkout", style: TextStyle(color: TColor.primaryText, fontSize: 20, fontWeight: FontWeight.w700)),
              InkWell(
                onTap: () => Navigator.pop(context),
                child: Image.asset("assets/img/close.png", width: 15, height: 15, color: TColor.primaryText),
              ),
            ],
          ),
          const Divider(height: 1),
          CheckoutRow(
            title: "Payment",
            value: paymentMethod,
            onPressed: () async {
              final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => const PaymentMethodView()));
              if (result != null && result is Map<String, dynamic>) {
                setState(() {
                  paymentMethod = result['summary'] ?? "Select Method";
                  selectedCardType = result['cardType'] ?? 'master';
                });
              }
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 15),
            child: Row(
              children: [
                Text("Payment Methods: ", style: TextStyle(color: TColor.secondaryText, fontSize: 18, fontWeight: FontWeight.w700)),
                const Spacer(),
                Image.asset(_getCardAsset(selectedCardType), width: 30),
                const SizedBox(width: 15),
                Image.asset("assets/img/next.png", height: 15, color: TColor.primaryText),
              ],
            ),
          ),
          const Divider(height: 1),
          CheckoutRow(
            title: "Discount",
            value: selectedDiscountLabel,
            onPressed: () {
              showModalBottomSheet(
                context: context,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
                ),
                builder: (_) => Column(
                  mainAxisSize: MainAxisSize.min,
                  children: discountOptions.map((option) {
                    return ListTile(
                      title: Text(option['label']),
                      onTap: () {
                        setState(() {
                          selectedDiscountLabel = option['label'];
                          discountValue = option['value'];
                          _applyDiscount();
                        });
                        Navigator.pop(context);
                      },
                    );
                  }).toList(),
                ),
              );
            },
          ),
          CheckoutRow(
            title: "Total Cost",
            value: "\$${totalCost.toStringAsFixed(2)}",
            onPressed: () {},
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: RichText(
              text: TextSpan(
                style: TextStyle(color: TColor.secondaryText, fontSize: 14, fontWeight: FontWeight.w500),
                children: [
                  const TextSpan(text: "By continuing you agree to our "),
                  TextSpan(text: "Terms ", style: TextStyle(color: TColor.primaryText), recognizer: TapGestureRecognizer()..onTap = () {}),
                  const TextSpan(text: " and "),
                  TextSpan(text: "Privacy Policy", style: TextStyle(color: TColor.primaryText), recognizer: TapGestureRecognizer()..onTap = () {}),
                ],
              ),
            ),
          ),
          RoundButton(title: "Place Order", onPressed: () => showCartConfirmationModal()),
          const SizedBox(height: 15),
        ],
      ),
    );
  }

  String _getCardAsset(String? type) {
    switch (type) {
      case 'visa':
        return 'assets/img/visa.png';
      case 'amex':
        return 'assets/img/amex.png';
      case 'master':
      default:
        return 'assets/img/master.png';
    }
  }
}
