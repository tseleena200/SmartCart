import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../constants.dart';

class AdminReviewListView extends StatefulWidget {
  const AdminReviewListView({super.key});

  @override
  State<AdminReviewListView> createState() => _AdminReviewListViewState();
}

class _AdminReviewListViewState extends State<AdminReviewListView> {
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
          title: const Text("All Reviews"),
          backgroundColor: secondaryColor,
        ),
        body: Padding(
          padding: const EdgeInsets.all(defaultPadding),
          child: Column(
            children: [
              TextField(
                controller: _searchController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "Search by product or user...",
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
                  stream: FirebaseFirestore.instance
                      .collection('Reviews')
                      .orderBy('timestamp', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(
                        child: Text("No reviews found.", style: TextStyle(color: Colors.white70)),
                      );
                    }

                    final filteredDocs = snapshot.data!.docs.where((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      final productName = (data['productName'] ?? '').toString().toLowerCase();
                      final userName = (data['userName'] ?? '').toString().toLowerCase();
                      return productName.contains(_searchText) || userName.contains(_searchText);
                    }).toList();

                    return ListView.separated(
                      itemCount: filteredDocs.length,
                      separatorBuilder: (context, index) => const Divider(color: Colors.white24),
                      itemBuilder: (context, index) {
                        final doc = filteredDocs[index];
                        final review = doc.data() as Map<String, dynamic>;

                        return Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: secondaryColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (review['imageURL'] != null)
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    review['imageURL'],
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              else
                                Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade700,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(Icons.image_not_supported, color: Colors.white54),
                                ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Product: ${review['productName'] ?? 'N/A'}",
                                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                                    ),
                                    Text(
                                      "User: ${review['userName'] ?? 'Anonymous'}",
                                      style: const TextStyle(color: Colors.white70),
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        const Icon(Icons.star, color: Colors.amber, size: 18),
                                        const SizedBox(width: 4),
                                        Text("${(review['rating'] ?? 0).toDouble().toStringAsFixed(1)} / 5",
                                            style: const TextStyle(color: Colors.white)),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      review['reviewText'] ?? '',
                                      style: const TextStyle(color: Colors.white),
                                    ),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: TextButton(
                                        onPressed: () async {
                                          final confirm = await showDialog<bool>(
                                            context: context,
                                            builder: (ctx) => AlertDialog(
                                              backgroundColor: bgColor,
                                              title: const Text("Delete Review", style: TextStyle(color: Colors.white)),
                                              content: const Text("Are you sure you want to delete this review?",
                                                  style: TextStyle(color: Colors.white70)),
                                              actions: [
                                                TextButton(
                                                  onPressed: () => Navigator.of(ctx).pop(false),
                                                  child: const Text("Cancel"),
                                                ),
                                                TextButton(
                                                  onPressed: () => Navigator.of(ctx).pop(true),
                                                  child:
                                                  const Text("Delete", style: TextStyle(color: Colors.redAccent)),
                                                ),
                                              ],
                                            ),
                                          );
                                          if (confirm == true) {
                                            await doc.reference.delete();
                                          }
                                        },
                                        child:
                                        const Text("Delete", style: TextStyle(color: Colors.redAccent)),
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
