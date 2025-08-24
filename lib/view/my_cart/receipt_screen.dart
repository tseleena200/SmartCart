import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


import '../../common/color_extension.dart';
import 'email_service.dart';

class ReceiptView extends StatelessWidget {
  final String txnId;

  const ReceiptView({super.key, required this.txnId});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('Transactions').doc(txnId).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Scaffold(body: Center(child: Text("Receipt not found.")));
        }

        final data = snapshot.data!.data() as Map<String, dynamic>;
        final items = List<Map<String, dynamic>>.from(data['items']);
        final originalCost = (data['originalAmount'] ?? data['totalAmount']).toDouble();
        final totalCost = (data['totalAmount'] ?? 0).toDouble();
        final discountLabel = data['discountLabel'] ?? 'None';
        final paymentMethod = data['paymentMethod'] ?? 'Card';
        final timestamp = (data['timestamp'] as Timestamp).toDate();
        final formattedDate = DateFormat('yyyy-MM-dd – kk:mm').format(timestamp);
        final userName = data['userName'] ?? 'User';

        return Scaffold(
          appBar: AppBar(
            title: const Text("Your Receipt"),
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
          ),
          body: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Transaction ID: $txnId", style: const TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Text("Customer: $userName"),
                        const SizedBox(height: 8),
                        Text("Date: $formattedDate", style: const TextStyle(color: Colors.grey)),
                        const Divider(height: 30),

                        const Text("Purchase Summary", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),

                        ...items.map((item) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  "${item['productName']} (${item['unitValue']} ${item['unitType']}) x${item['quantity']}",
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ),
                              Text(
                                "\$${(item['itemFinalPrice']).toStringAsFixed(2)}",
                                style: const TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                        )),

                        const Divider(height: 30),

                        const Text("Payment Details", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("Discount Applied:", style: TextStyle(color: Colors.green)),
                            Text(discountLabel, style: const TextStyle(color: Colors.green)),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                          const Text("Subtotal:"),
                          Text("\$${originalCost.toStringAsFixed(2)}"),
                        ]),
                        const SizedBox(height: 4),
                        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                          const Text("Total Paid:", style: TextStyle(fontWeight: FontWeight.bold)),
                          Text("\$${totalCost.toStringAsFixed(2)}", style: const TextStyle(fontWeight: FontWeight.bold)),
                        ]),
                        const SizedBox(height: 4),
                        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                          const Text("Payment Method:"),
                          Text(paymentMethod),
                        ]),

                        const SizedBox(height: 32),
                        const Divider(),

                        const Center(child: Text("Scan this barcode at exit", style: TextStyle(color: Colors.grey))),
                        const SizedBox(height: 10),
                        Center(
                          child: BarcodeWidget(
                            data: txnId,
                            barcode: Barcode.code128(),
                            width: 200,
                            height: 70,
                          ),
                        ),

                        const SizedBox(height: 20),
                        const Center(
                          child: Text(
                            "🛍️ Thank you for shopping with us!",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.purple),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Center(
                          child: Text(
                            "We hope to see you again soon.",
                            style: TextStyle(fontSize: 13, color: Colors.grey),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Fixed Button
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: TColor.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
                      child: const Text("Back to Home", style: TextStyle(fontSize: 16)),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () {
                        String userEmail = '';
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: const Text("Send Receipt to Email"),
                              content: TextField(
                                decoration: const InputDecoration(labelText: "Enter your email"),
                                onChanged: (value) {
                                  userEmail = value;
                                },
                                keyboardType: TextInputType.emailAddress,
                              ),
                              actions: [
                                TextButton(
                                  child: const Text("Cancel"),
                                  onPressed: () => Navigator.pop(context),
                                ),
                                ElevatedButton(
                                  child: const Text("Send"),
                                  onPressed: () async {
                                    final messengerContext = context; // ✅ Save context before popping
                                    Navigator.pop(context); // ❌ Don't access context after this line

                                    try {
                                      await EmailService.sendReceiptEmail(
                                        toEmail: userEmail,
                                        userName: userName,
                                        txnId: txnId,
                                        items: items,
                                        originalCost: originalCost,
                                        totalCost: totalCost,
                                        discountLabel: discountLabel,
                                        paymentMethod: paymentMethod,
                                        formattedDate: formattedDate,
                                      );

                                      ScaffoldMessenger.of(messengerContext).showSnackBar(
                                        const SnackBar(
                                          content: Text("✅ Receipt sent successfully."),
                                          duration: Duration(seconds: 3),
                                        ),
                                      );
                                    } catch (e) {
                                      ScaffoldMessenger.of(messengerContext).showSnackBar(
                                        SnackBar(
                                          content: Text("❌ Failed to send receipt: $e"),
                                          duration: const Duration(seconds: 4),
                                        ),
                                      );
                                    }
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      },
                      child: const Text(
                        "📧 Send Receipt to Email",
                        style: TextStyle(fontSize: 15, color: Colors.black87),
                      ),
                    ),



                  ],
                ),
              ),


            ],
          ),
        );
      },
    );
  }
}
