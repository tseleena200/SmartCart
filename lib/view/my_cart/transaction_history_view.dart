import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:onlinegroceries/view/my_cart/receipt_screen.dart';

class TransactionHistoryView extends StatelessWidget {
  const TransactionHistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final uid = user?.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Transaction History"),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Transactions')
            .where('userID', isEqualTo: uid) // ✅ FIXED HERE
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(child: Text("No transactions found."));
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final txnId = docs[index].id;
              final date = (data['timestamp'] as Timestamp).toDate();
              final formattedDate = DateFormat('yyyy-MM-dd – kk:mm').format(date);
              final total = (data['totalAmount'] ?? 0).toDouble();

              return ListTile(
                title: Text("Order #$txnId"),
                subtitle: Text(formattedDate),
                trailing: Text("\$${total.toStringAsFixed(2)}"),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ReceiptView(txnId: txnId),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
