import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class WriteReviewScreen extends StatefulWidget {
  final String productID;
  final String productName;

  const WriteReviewScreen({
    super.key,
    required this.productID,
    required this.productName,

  });

  @override
  State<WriteReviewScreen> createState() => _WriteReviewScreenState();
}

class _WriteReviewScreenState extends State<WriteReviewScreen> {
  final TextEditingController _reviewController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  double _rating = 0.0;
  bool _isLoading = false;
  bool _isExistingReview = false;
  String? _docID;

  @override
  void initState() {
    super.initState();
    _loadExistingReview();
  }

  Future<void> _loadExistingReview() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final query = await _firestore
        .collection('Reviews')
        .where('productID', isEqualTo: widget.productID)
        .where('userID', isEqualTo: user.uid)
        .get();

    if (query.docs.isNotEmpty) {
      final doc = query.docs.first;
      _reviewController.text = doc['reviewText'] ?? "";
      _rating = (doc['rating'] ?? 0).toDouble();
      _isExistingReview = true;
      _docID = doc.id;
      setState(() {});
    }
  }

  Future<void> _submitReview() async {
    final user = _auth.currentUser;
    if (user == null || _rating == 0.0) return;

    setState(() => _isLoading = true);

    try {
      final userNameDoc = await _firestore.collection('Users').doc(user.uid).get();
      final userName = userNameDoc.data()?['name'] ?? 'Unknown';

      final data = {
        'productID': widget.productID,
        'productName': widget.productName,
        'userID': user.uid,
        'userName': userName,
        'rating': _rating,
        'reviewText': _reviewController.text.trim(),
        'timestamp': FieldValue.serverTimestamp(),
      };

      if (_isExistingReview && _docID != null) {
        final docRef = _firestore.collection('Reviews').doc(_docID);
        await docRef.set(data, SetOptions(merge: true));
      } else {
        await _firestore.collection('Reviews').add(data);
      }

      Get.back();
    } catch (e) {
      print("🔥 Error submitting review: $e");
      Get.snackbar("Error", "Could not submit review.");
    } finally {
      setState(() => _isLoading = false);
    }
  }


  Future<void> _deleteReview() async {
    if (_isExistingReview && _docID != null) {
      await _firestore.collection('Reviews').doc(_docID).delete();
      Get.snackbar("Deleted", "Your review has been deleted.");
    }
    Get.back();
  }

  Future<bool> _onWillPop() async {
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Discard changes?"),
        content:
        const Text("Are you sure you want to go back without saving?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text("Cancel")),
          TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text("Discard")),
        ],
      ),
    ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Review: ${widget.productName}"),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () async {
              if (await _onWillPop()) Get.back();
            },
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Your Rating:", style: TextStyle(fontSize: 16)),
              const SizedBox(height: 8),
              RatingBar.builder(
                initialRating: _rating,
                minRating: 1,
                direction: Axis.horizontal,
                allowHalfRating: true,
                itemCount: 5,
                itemBuilder: (context, _) => const Icon(Icons.star, color: Colors.amber),
                onRatingUpdate: (rating) => setState(() => _rating = rating),
              ),
              const SizedBox(height: 16),
              const Text("Write a Review:", style: TextStyle(fontSize: 16)),
              const SizedBox(height: 8),
              TextField(
                controller: _reviewController,
                maxLines: 5,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Share your experience...",
                ),
              ),
              const Spacer(),
              if (_isExistingReview)
                TextButton(
                  onPressed: _deleteReview,
                  child: const Text("Delete Review", style: TextStyle(color: Colors.red)),
                ),
              ElevatedButton(
                onPressed: _isLoading ? null : _submitReview,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Submit Review"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
