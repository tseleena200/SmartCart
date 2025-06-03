import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../constants.dart';
import 'add_category.dart';
import 'edit_category.dart';

class AdminCategoryListView extends StatelessWidget {
  const AdminCategoryListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: secondaryColor,
        title: const Text("Manage Categories"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddCategoryView()),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('Categories').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                "No categories found.",
                style: TextStyle(color: Colors.white70),
              ),
            );
          }

          final categories = snapshot.data!.docs;

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: ListView.separated(
                padding: const EdgeInsets.all(defaultPadding),
                itemCount: categories.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final doc = categories[index];
                  final data = doc.data() as Map<String, dynamic>;

                  return Container(
                    decoration: BoxDecoration(
                      color: secondaryColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: _hexToColor(data['colorHex'] ?? '#2697FF'),
                        child: Text(
                          (data['name'] ?? '?')[0].toUpperCase(),
                          style: const TextStyle(color: Colors.black),
                        ),
                      ),
                      title: Text(
                        data['name'] ?? 'Unnamed',
                        style: const TextStyle(color: Colors.white),
                      ),
                      subtitle: Text(
                        "${data['sub'] ?? ''} • ${data['aisle'] ?? ''}",
                        style: const TextStyle(color: Colors.white70),
                      ),
                      trailing: Wrap(
                        spacing: 6,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.orangeAccent),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => EditCategoryView(categoryDoc: doc),
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
                                  backgroundColor: secondaryColor,
                                  title: const Text("Delete Category", style: TextStyle(color: Colors.white)),
                                  content: const Text(
                                    "Are you sure you want to delete this category?",
                                    style: TextStyle(color: Colors.white70),
                                  ),
                                  actions: [
                                    TextButton(
                                      child: const Text("Cancel", style: TextStyle(color: Colors.white)),
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
                                  const SnackBar(content: Text("Category deleted.")),
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Color _hexToColor(String hex) {
    hex = hex.replaceAll('#', '');
    if (hex.length == 6) hex = 'FF$hex';
    return Color(int.parse(hex, radix: 16));
  }
}
