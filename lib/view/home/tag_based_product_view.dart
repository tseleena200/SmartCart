import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../common/color_extension.dart';
import '../../common_widget/product_cell.dart';
import '../home/product_details_screen.dart';

class TagBasedProductView extends StatelessWidget {
  final String title;
  final String field;

  const TagBasedProductView({
    super.key,
    required this.title,
    required this.field,
  });

  @override
  Widget build(BuildContext context) {
    final stream = FirebaseFirestore.instance
        .collection('Products')
        .where(field, isEqualTo: true)
        .snapshots();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Image.asset("assets/img/back.png", width: 20, height: 20),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: TColor.primaryText,
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: stream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No products found."));
          }

          final products = snapshot.data!.docs;

          return GridView.builder(
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.60,
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
            ),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final data = products[index].data() as Map<String, dynamic>;

              return StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('Users')
                    .doc(FirebaseAuth.instance.currentUser!.uid)
                    .collection('Favorites')
                    .doc(data['productID'])
                    .snapshots(),
                builder: (context, favSnapshot) {
                  final isFavorited = favSnapshot.data?.exists ?? false;

                  return ProductCell(
                    pObj: data,
                    margin: 0,
                    weight: double.maxFinite,
                    isFavorite: isFavorited,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ProductDetails(product: data),
                        ),
                      );
                    },
                    onCart: () {}, // no cart logic for now
                    onFavoriteToggle: () async {
                      final uid = FirebaseAuth.instance.currentUser!.uid;
                      final favRef = FirebaseFirestore.instance
                          .collection('Users')
                          .doc(uid)
                          .collection('Favorites')
                          .doc(data['productID']);

                      if (isFavorited) {
                        await favRef.delete();
                      } else {
                        await favRef.set({
                          'productID': data['productID'],
                          'productName': data['productName'],
                          'imageURL': data['imageURL'],
                          'price': (data['price'] ?? 0).toDouble(),
                          'discount': (data['discount'] ?? 0).toDouble(),
                          'finalPrice': ((data['price'] ?? 0) *
                              (1 - (data['discount'] ?? 0) / 100))
                              .toDouble(),
                          'category': data['category'],
                          'favoritedAt': Timestamp.now(),
                          'userName': FirebaseAuth.instance.currentUser?.displayName ?? "Unknown",
                        });
                      }
                    },
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
