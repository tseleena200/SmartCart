import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../constants.dart';

class ManageStockView extends StatelessWidget {
  const ManageStockView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: secondaryColor,
        title: const Text("Manage Stock"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(defaultPadding),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('Products').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(
                child: Text("No products found.", style: TextStyle(color: Colors.white70)),
              );
            }

            final products = snapshot.data!.docs;

            return ListView.separated(
              itemCount: products.length,
              separatorBuilder: (_, __) => const Divider(color: Colors.white24),
              itemBuilder: (context, index) {
                final doc = products[index];
                final data = doc.data() as Map<String, dynamic>;

                final name = data['productName'] ?? 'Unnamed';
                final stock = (data['stockLevel'] ?? 0).toInt();

                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: secondaryColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Text(
                          name,
                          style: const TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Text(
                          "Stock: $stock",
                          style: const TextStyle(color: Colors.white70),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.orangeAccent),
                        onPressed: () {
                          _showEditStockDialog(context, doc.id, name, stock);
                        },
                      )
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  void _showEditStockDialog(BuildContext context, String productId, String name, int currentStock) {
    final TextEditingController stockController = TextEditingController(text: currentStock.toString());

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: bgColor,
        title: Text("Update Stock - $name", style: const TextStyle(color: Colors.white)),
        content: TextField(
          controller: stockController,
          keyboardType: TextInputType.number,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            labelText: 'New Stock Level',
            labelStyle: TextStyle(color: Colors.white70),
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white70)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              final newStock = int.tryParse(stockController.text.trim());
              if (newStock != null && newStock >= 0) {
                await FirebaseFirestore.instance.collection('Products').doc(productId).update({
                  'stockLevel': newStock,
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Stock updated.")),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Invalid stock value.")),
                );
              }
            },
            child: const Text("Update", style: TextStyle(color: Colors.greenAccent)),
          ),
        ],
      ),
    );
  }
}
