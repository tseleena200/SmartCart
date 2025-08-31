import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../common/color_extension.dart';
import '../../common_widget/product_cell.dart';
import '../home/product_details_screen.dart';
import '../navigation/navigation_screen.dart';
import 'filter_view.dart';

class ExploreDetailsView extends StatefulWidget {
  final Map eObj;
  const ExploreDetailsView({super.key, required this.eObj});

  @override
  State<ExploreDetailsView> createState() => _ExploreDetailsViewState();
}

class _ExploreDetailsViewState extends State<ExploreDetailsView> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _q = "";

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FilterView()),
              );
            },
            icon: Image.asset("assets/img/filter_ic.png", width: 20, height: 20),
          ),
        ],
        title: Text(
          widget.eObj["name"].toString(),
          style: TextStyle(
            color: TColor.primaryText,
            fontSize: 29,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Column(
        children: [
          // Route button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.navigation),
                label: const Text("Start Route to Aisle"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: TColor.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RouteNavigationView(
                        aisle: widget.eObj['aisle'] ?? 'Aisle ?',
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // Search bar (local filter)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(color: Colors.black12.withOpacity(0.04), blurRadius: 6),
                ],
              ),
              child: Row(
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 14),
                    child: Icon(Icons.search, color: Colors.grey),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _searchCtrl,
                      onChanged: (v) => setState(() => _q = v.trim()),
                      decoration: const InputDecoration(
                        hintText: "Search in this category",
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  if (_q.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchCtrl.clear();
                        setState(() => _q = "");
                      },
                    ),
                ],
              ),
            ),
          ),

          // Products grid
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('Products')
                  .where('category', isEqualTo: widget.eObj['name'])
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("No products in this category."));
                }

                final products = snapshot.data!.docs;

                // Case-insensitive filter by productName
                final filtered = _q.isEmpty
                    ? products
                    : products.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final name = (data["productName"] ?? "").toString();
                  return name.toLowerCase().contains(_q.toLowerCase());
                }).toList();

                if (filtered.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.only(top: 24),
                    child: Center(
                      child: Text(
                        "NO RESULTS FOUND.",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.68,
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                  ),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final data = filtered[index].data() as Map<String, dynamic>;

                    return ProductCell(
                      pObj: {
                        "productName": data["productName"],
                        "imageURL": data["imageURL"],
                        "price": data["price"],
                        "stockLevel": data["stockLevel"],
                        "discount": data["discount"],
                        "isPopular": data["isPopular"],
                        "isNewArrival": data["isNewArrival"],
                      },
                      margin: 0,
                      weight: double.maxFinite,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ProductDetails(product: data),
                          ),
                        );
                      },
                      onCart: () {},
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
