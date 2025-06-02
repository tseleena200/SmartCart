import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import '../../common/color_extension.dart';
import '../../common_widget/round_button.dart';

class ProductDetails extends StatefulWidget {
  const ProductDetails({super.key});

  @override
  State<ProductDetails> createState() => _ProductDetailsState();
}

class _ProductDetailsState extends State<ProductDetails> {
  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.sizeOf(context);

    final double originalPrice = 5.49;
    final double discount = 10; // in percent
    final double finalPrice = originalPrice * (1 - discount / 100);
    final int stockLevel = 15;
    final bool isTrending = true;
    final bool isExclusive = true;

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
                    color: Color(0xffF2F3F2),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(24),
                      bottomRight: Radius.circular(24),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 60), // prevent overlap with status bar
                    child: Center(
                      child: Image.asset(
                        "assets/img/apple_red.png",
                        width: media.width * 0.70,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),

                // Back Button
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

                // Share Button
                Positioned(
                  top: 40,
                  right: 16,
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 20,
                    child: IconButton(
                      icon: const Icon(Icons.share_outlined, color: Colors.black, size: 18),
                      onPressed: () {},
                    ),
                  ),
                ),

                // Trending Badge
                if (isTrending)
                  Positioned(
                    top: 100,
                    left: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.redAccent,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text("🔥 Trending", style: TextStyle(fontSize: 10, color: Colors.white)),
                    ),
                  ),

                // Exclusive Badge
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
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          "Natural Red Apples",
                          style: TextStyle(
                            color: TColor.primaryText,
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: Image.asset("assets/img/fav.png", width: 25, height: 25),
                      ),
                    ],
                  ),
                  Text("In Stock: $stockLevel", style: TextStyle(fontSize: 12, color: Colors.black54)),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      InkWell(
                        onTap: () {},
                        child: Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: Image.asset("assets/img/subtack.png", width: 20, height: 20),
                        ),
                      ),
                      Container(
                        width: 45,
                        height: 45,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: TColor.placeholder.withOpacity(0.5), width: 1),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        alignment: Alignment.center,
                        child: const Text("1", style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                      ),
                      InkWell(
                        onTap: () {},
                        child: Image.asset("assets/img/add_green.png", width: 20, height: 20),
                      ),
                      const Spacer(),
                      discount > 0
                          ? Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            "\$${originalPrice.toStringAsFixed(2)}",
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 13,
                              decoration: TextDecoration.lineThrough,
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
                      )
                          : Text("\$${originalPrice.toStringAsFixed(2)}",
                          style: TextStyle(
                            color: TColor.primary,
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                          )),
                    ],
                  ),
                  const SizedBox(height: 15),
                  const Divider(color: Colors.black38, height: 1),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Expanded(
                        child: Text("Product Details",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: Image.asset("assets/img/detail_open.png", width: 15, height: 15),
                      ),
                    ],
                  ),
                  const Text(
                    "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.",
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 15),
                  const Divider(color: Colors.black38, height: 1),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Expanded(
                        child: Text("Nutrition", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                        height: 25,
                        decoration: BoxDecoration(
                          color: TColor.placeholder.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        alignment: Alignment.center,
                        child: const Text("100g", style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600)),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: Image.asset("assets/img/next.png", width: 15, height: 15, color: TColor.primaryText),
                      ),
                    ],
                  ),
                  const Divider(color: Colors.black38, height: 1),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Expanded(
                        child: Text("Review", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                      ),
                      IgnorePointer(
                        ignoring: true,
                        child: RatingBar.builder(
                          initialRating: 4.5,
                          minRating: 1,
                          direction: Axis.horizontal,
                          allowHalfRating: true,
                          itemCount: 5,
                          itemSize: 15,
                          itemBuilder: (context, _) => const Icon(Icons.star, color: Color(0xffF3603F)),
                          onRatingUpdate: (rating) {},
                        ),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: Image.asset("assets/img/next.png", width: 15, height: 15, color: TColor.primaryText),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  RoundButton(title: " Simulate Scan", onPressed: () {}),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
