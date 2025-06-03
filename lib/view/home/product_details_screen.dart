import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../../common/color_extension.dart';
import '../../common_widget/round_button.dart';

class ProductDetails extends StatefulWidget {
  final Map<String, dynamic> product;

  const ProductDetails({super.key, required this.product});

  @override
  State<ProductDetails> createState() => _ProductDetailsState();
}

class _ProductDetailsState extends State<ProductDetails> {
  int quantity = 1;
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.sizeOf(context);

    final product = widget.product;
    final String imageUrl = product['imageURL'] ?? '';
    final String name = product['productName'] ?? 'Unnamed';
    final String description = product['description'] ?? 'No description available.';
    final int stockLevel = product['stockLevel'] ?? 0;
    final double price = (product['price'] ?? 0).toDouble();
    final double discount = (product['discount'] ?? 0).toDouble();
    final bool isTrending = product['isPopular'] == true;
    final bool isExclusive = product['isExclusive'] == true;
    final double finalPrice = price * (1 - discount / 100);
    final String nutrition = product['nutrition'] ?? '';
    final String unitLabel =
    (product['unitValue'] != null && product['unitType'] != null)
        ? '${product['unitValue']} ${product['unitType']}'
        : '';

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: media.width * 0.75,
                  decoration: const BoxDecoration(
                    color: Color(0xffF9F9F9),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(28),
                      bottomRight: Radius.circular(28),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 60),
                    child: Center(
                      child: Image.network(
                        imageUrl,
                        width: media.width * 0.70,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 40,
                  left: 16,
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 20,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 18),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),
                if (isExclusive)
                  Positioned(
                    top: 100,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.deepPurple,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text("Exclusive", style: TextStyle(fontSize: 10, color: Colors.white)),
                    ),
                  ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          style: TextStyle(
                            color: TColor.primaryText,
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.favorite_border, color: Colors.grey),
                      ),
                    ],
                  ),

                  Text(
                    "$unitLabel • In Stock: $stockLevel",
                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                  ),

                  const SizedBox(height: 20),

                  Row(
                    children: [
                      InkWell(
                        onTap: () => setState(() => quantity = quantity > 1 ? quantity - 1 : 1),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.grey.shade200,
                          ),
                          child: const Icon(Icons.remove, size: 20),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text("$quantity", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                      const SizedBox(width: 12),
                      InkWell(
                        onTap: () => setState(() => quantity++),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.green,
                          ),
                          child: const Icon(Icons.add, size: 20, color: Colors.white),
                        ),
                      ),
                      const Spacer(),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          if (discount > 0)
                            Text(
                              "\$${price.toStringAsFixed(2)}",
                              style: const TextStyle(
                                decoration: TextDecoration.lineThrough,
                                color: Colors.grey,
                                fontSize: 13,
                              ),
                            ),
                          Text(
                            "\$${finalPrice.toStringAsFixed(2)}",
                            style: TextStyle(
                              color: TColor.primary,
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const Divider(thickness: 1.2, color: Color(0xffEEEEEE)),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Theme(
                    data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                    child: StatefulBuilder(
                      builder: (context, setState) => ExpansionTile(
                        tilePadding: EdgeInsets.zero,
                        onExpansionChanged: (val) => setState(() => isExpanded = val),
                        title: const Text(
                          "Product Details",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                        subtitle: !isExpanded
                            ? Text(
                          description,
                          style: TextStyle(color: TColor.primary),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        )
                            : null,
                        children: isExpanded
                            ? [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Text(
                              description,
                              style: const TextStyle(fontSize: 13, height: 1.5),
                            ),
                          ),
                        ]
                            : [],
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Theme(
                    data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      tilePadding: EdgeInsets.zero,
                      title: const Text("Nutrition", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                      subtitle: Text(nutrition.split(',').first),
                      children: [
                        Text(
                          nutrition.replaceAll(',', '\n•'),
                          style: const TextStyle(fontSize: 13, height: 1.5),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 15),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Review", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                      Row(
                        children: [
                          RatingBar.builder(
                            initialRating: 4.5,
                            minRating: 1,
                            direction: Axis.horizontal,
                            allowHalfRating: true,
                            itemCount: 5,
                            itemSize: 16,
                            ignoreGestures: true,
                            itemBuilder: (context, _) => const Icon(Icons.star, color: Colors.amber),
                            onRatingUpdate: (rating) {},
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.chevron_right, size: 20, color: Colors.grey),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 90),
                  RoundButton(title: "Simulate Scan", onPressed: () {}),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
