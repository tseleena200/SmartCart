import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:onlinegroceries/reviews/review_sheet.dart';
import '../../common/color_extension.dart';
import '../../services/recs_api.dart'; // ← ADD

class AllReviewsScreen extends StatelessWidget {
  final String productId;
  final String currentUserId;
  final String productName;

  const AllReviewsScreen({
    Key? key,
    required this.productId,
    required this.currentUserId,
    required this.productName,
  }) : super(key: key);

  // ← ADD: tiny helper to trigger instant recs recompute
  Future<void> _refreshRecs() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    try { await RecsApi.refreshUserInstant(uid); } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final reviewsRef = FirebaseFirestore.instance
        .collection('Reviews')
        .where('productID', isEqualTo: productId)
        .orderBy('timestamp', descending: true);

    return Scaffold(
      appBar: AppBar(
        title: Text('All Reviews for $productName'),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: reviewsRef.snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text('Error loading reviews.'));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data?.docs ?? [];
                if (docs.isEmpty) {
                  return const Center(child: Text('No reviews yet. Be the first to add one!'));
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: docs.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    final isCurrentUser = data['userID'] == currentUserId;

                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.shade600,
                            blurRadius: 5,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            data['userName'] ?? 'Anonymous',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          RatingBarIndicator(
                            rating: (data['rating'] ?? 0).toDouble(),
                            itemCount: 5,
                            itemSize: 18,
                            itemBuilder: (context, _) => const Icon(Icons.star, color: Colors.amber),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            data['reviewText'] ?? '',
                            style: const TextStyle(color: Colors.black87),
                          ),
                          if (isCurrentUser)
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () async {
                                  await FirebaseFirestore.instance
                                      .collection('Reviews')
                                      .doc(docs[index].id)
                                      .delete();

                                  // ← ADD: refresh recs after deletion
                                  await _refreshRecs();

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("Review deleted successfully."),
                                      backgroundColor: Colors.redAccent,
                                    ),
                                  );
                                },
                                child: const Text(
                                  'Delete',
                                  style: TextStyle(color: Colors.red),
                                ),
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

          FutureBuilder<QuerySnapshot>(
            future: FirebaseFirestore.instance
                .collection('Reviews')
                .where('productID', isEqualTo: productId)
                .where('userID', isEqualTo: currentUserId)
                .get(),
            builder: (context, snapshot) {
              final alreadyReviewed = snapshot.hasData && snapshot.data!.docs.isNotEmpty;

              return Column(
                children: [
                  if (alreadyReviewed)
                    const Padding(
                      padding: EdgeInsets.only(bottom: 8.0),
                      child: Text(
                        "You’ve already reviewed this product",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          // Wait for review screen to close
                          await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => WriteReviewScreen(
                                productID: productId,
                                productName: productName,
                              ),
                            ),
                          );
                          // ← ADD: refresh recs after submit/edit
                          await _refreshRecs();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: TColor.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: Text(
                          alreadyReviewed ? "Edit Your Review" : "Add a Review",
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
