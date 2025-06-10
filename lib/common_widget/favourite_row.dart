import 'package:flutter/material.dart';
import '../common/color_extension.dart';

class FavouriteRow extends StatefulWidget {
  final Map<String, dynamic> pObj;
  final VoidCallback onPressed;

  const FavouriteRow({super.key, required this.pObj, required this.onPressed});

  @override
  State<FavouriteRow> createState() => _FavouriteRowState();
}

class _FavouriteRowState extends State<FavouriteRow> {
  bool isAdded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFE1CCD6),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black12.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Image.network(
              widget.pObj["imageURL"] ?? '',
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.pObj["productName"] ?? "Unnamed",
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        widget.pObj["category"] ?? "In Stock",
                        style: const TextStyle(fontSize: 11, color: Colors.green),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Row(
                      children: [
                        Text(
                          "\$${widget.pObj["finalPrice"]?.toStringAsFixed(2) ?? '0.00'}",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: TColor.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () {
              widget.onPressed();
              setState(() {
                isAdded = true;
              });
            },
            child: Container(
              decoration: BoxDecoration(
                color: isAdded ? Colors.green : TColor.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.all(10),
              child: Icon(
                isAdded ? Icons.check : Icons.add,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
