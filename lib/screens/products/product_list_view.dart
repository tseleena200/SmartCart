import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../constants.dart';
import 'add_product_view.dart';
import 'edit_product_view.dart';

class ProductListView extends StatefulWidget {
  const ProductListView({super.key});

  @override
  State<ProductListView> createState() => _ProductListViewState();
}

class _ProductListViewState extends State<ProductListView> {
  final TextEditingController _searchController = TextEditingController();
  String _searchText = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchText = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: bgColor,
        appBar: AppBar(
          title: const Text("All Products"),
          backgroundColor: secondaryColor,
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddProductView()),
                );
              },
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(defaultPadding),
          child: Column(
            children: [
              TextField(
                controller: _searchController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "Search products...",
                  hintStyle: const TextStyle(color: Colors.white70),
                  prefixIcon: const Icon(Icons.search, color: Colors.white70),
                  filled: true,
                  fillColor: secondaryColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
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

                    final allProducts = snapshot.data!.docs;
                    final filteredProducts = allProducts.where((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      final name = (data['productName'] ?? '').toString().toLowerCase();
                      return name.contains(_searchText);
                    }).toList();

                    return ListView.separated(
                      itemCount: filteredProducts.length,
                      separatorBuilder: (context, index) => const Divider(color: Colors.white24),
                      itemBuilder: (context, index) {
                        final doc = filteredProducts[index];
                        final product = doc.data() as Map<String, dynamic>;

                        return ListTile(
                          tileColor: secondaryColor,
                          title: Text(
                            product['productName'] ?? 'Unnamed',
                            style: const TextStyle(color: Colors.white),
                          ),
                          subtitle: Text(
                            "\$${product['price']?.toStringAsFixed(2) ?? '0.00'} | ${product['category'] ?? ''}",
                            style: const TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.orangeAccent),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => EditProductView(productDoc: doc),
                                    ),
                                  );
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.redAccent),
                                onPressed: () async {
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      backgroundColor: bgColor,
                                      title: const Text("Delete Product", style: TextStyle(color: Colors.white)),
                                      content: const Text("Are you sure you want to delete this product?", style: TextStyle(color: Colors.white70)),
                                      actions: [
                                        TextButton(
                                          child: const Text("Cancel"),
                                          onPressed: () => Navigator.of(ctx).pop(false),
                                        ),
                                        TextButton(
                                          child: const Text("Delete", style: TextStyle(color: Colors.redAccent)),
                                          onPressed: () => Navigator.of(ctx).pop(true),
                                        ),
                                      ],
                                    ),
                                  );
                                  if (confirm == true) {
                                    await doc.reference.delete();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text("Product deleted.")),
                                    );
                                  }
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
