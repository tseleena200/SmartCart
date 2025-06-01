import 'package:flutter/material.dart';
import '../common/color_extension.dart';

class FavouriteRow extends StatefulWidget {
  final Map pObj;
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
        color: const Color(0xFFF8F8F8),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: const Color(0xFFF2F2F2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Image.asset(
              widget.pObj["icon"],
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.pObj["name"],
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "${widget.pObj["qty"]} ${widget.pObj["unit"]}",
                  style: TextStyle(
                    fontSize: 13,
                    color: TColor.secondaryText,
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
                        widget.pObj["status"] ?? "In Stock",
                        style: const TextStyle(fontSize: 11, color: Colors.green),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Row(
                      children: [
                        Text(
                          widget.pObj["price"],
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF87486E),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Stack(
                          alignment: Alignment.topRight,
                          children: [
                            const Icon(Icons.shopping_cart_outlined, size: 20, color: Colors.grey),
                            Container(
                              padding: const EdgeInsets.all(2),
                              decoration: const BoxDecoration(
                                color: Colors.black,
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                (widget.pObj["cartQty"] ?? "1").toString(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )
                          ],
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
                borderRadius: BorderRadius.circular(8),
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
