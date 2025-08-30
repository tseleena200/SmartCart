import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'edit_category.dart';


class CategoryListView extends StatelessWidget {
  const CategoryListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Categories')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Categories') // <-- your collection name
            .orderBy('name')
            .snapshots(),
        builder: (context, snap) {
          if (snap.hasError) return const Center(child: Text('Error loading categories'));
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());

          final docs = snap.data!.docs;
          if (docs.isEmpty) return const Center(child: Text('No categories found'));

          return ListView.separated(
            itemCount: docs.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final d = docs[i].data() as Map<String, dynamic>;
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.grey.shade200,
                  backgroundImage: (d['imageURL'] ?? '').toString().isNotEmpty
                      ? NetworkImage(d['imageURL'])
                      : null,
                  child: (d['imageURL'] ?? '').toString().isEmpty
                      ? const Icon(Icons.category)
                      : null,
                ),
                title: Text(d['name'] ?? '—'),
                subtitle: Text('Aisle: ${d['aisle'] ?? '-'}'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EditCategoryView(categoryDoc: docs[i]),
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
