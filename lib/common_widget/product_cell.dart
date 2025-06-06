import 'package:flutter/material.dart';
import '../common/color_extension.dart';

class ProductCell extends StatelessWidget {
  final Map pObj;
  final VoidCallback onPressed;
  final VoidCallback onCart;
  final double margin;
  final double weight;
  final VoidCallback? onFavoriteToggle;
  final bool isFavorite;

  const ProductCell({
    super.key,
    required this.pObj,
    required this.onPressed,
    required this.onCart,
    this.onFavoriteToggle,
    this.isFavorite = false,
    this.margin = 8,
    this.weight = 180,
  });

  @override
  Widget build(BuildContext context) {
    final double price = double.tryParse((pObj["price"] ?? "0").toString().replaceAll("\$", "")) ?? 0;
    final int discount = pObj["discount"] is int ? pObj["discount"] : 0;
    final double finalPrice = price * (1 - discount / 100);
    final bool isPopular = pObj["isPopular"] == true;
    final bool isNewArrival = pObj["isNewArrival"] == true;

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onPressed,
      child: Container(
        width: weight,
        margin: EdgeInsets.symmetric(horizontal: margin, vertical: 6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black12.withOpacity(0.1),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
          border: Border.all(
            color: Colors.grey.withOpacity(0.12),
            width: 1,
          ),
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  height: 90,
                  child: pObj["imageURL"] != null && pObj["imageURL"].toString().isNotEmpty
                      ? Image.network(
                    pObj["imageURL"],
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.broken_image, size: 40),
                  )
                      : const Icon(Icons.image, size: 40),
                ),
                const SizedBox(height: 12),
                Text(
                  pObj["productName"] ?? "",
                  style: TextStyle(
                    color: TColor.primaryText,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                if (pObj["unitValue"] != null && pObj["unitType"] != null)
                  Text(
                    "${pObj["unitValue"]} ${pObj["unitType"]}",
                    style: const TextStyle(fontSize: 13, color: Colors.black87),
                  ),
                if (pObj["stockLevel"] != null)
                  Text(
                    "In Stock: ${pObj["stockLevel"]}",
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    discount > 0
                        ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "\$${price.toStringAsFixed(2)}",
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
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    )
                        : Text(
                      "\$${price.toStringAsFixed(2)}",
                      style: TextStyle(
                        color: TColor.primary,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (onFavoriteToggle != null)
                      InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: onFavoriteToggle,
                        child: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: isFavorite ? Colors.red.shade800 : Colors.grey,
                          size: 24,
                        ),
                      )
                    else
                      InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: onCart,
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: TColor.primary,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: TColor.primary.withOpacity(0.25),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: const Icon(Icons.add, color: Colors.white, size: 20),
                        ),
                      ),

                  ],
                ),
              ],
            ),
            if (isPopular)
              Positioned(
                top: 0,
                left: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFC1CC), // Pastel pink
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    "🔥 Trending",
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ),
            if (isNewArrival)
              Positioned(
                top: isPopular ? 28 : 0,
                left: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Color(0xFF96BEE6), // Pastel blue
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    "🆕 New",
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ),

          ],
        ),
      ),
    );
  }
}
