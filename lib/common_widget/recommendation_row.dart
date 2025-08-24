import 'package:flutter/material.dart';
import '../common/color_extension.dart';

class RecommendationRow extends StatelessWidget {
  final Map<String, dynamic> pObj;
  final VoidCallback onPressed;

  const RecommendationRow({
    super.key,
    required this.pObj,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final iconUrl = (pObj["icon"] ?? "").toString();
    final isNetworkImage = iconUrl.startsWith("http");

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: isNetworkImage
                ? Image.network(
              iconUrl,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) =>
                  Image.asset("assets/img/placeholder.png"),
            )
                : Image.asset(
              iconUrl.isNotEmpty
                  ? iconUrl
                  : "assets/img/placeholder.png",
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  (pObj["name"] ?? "").toString(),
                  style: const TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "${pObj["qty"] ?? ""} ${pObj["unit"] ?? ""}",
                  style: TextStyle(
                    fontSize: 13,
                    color: TColor.secondaryText,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2E4F5),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    "Recommended",
                    style: TextStyle(
                      fontSize: 11,
                      color: Color(0xFF87486E),
                    ),
                  ),
                )
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                (pObj["price"] ?? "").toString(),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: onPressed,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: TColor.primary,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(
                    Icons.add,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}
