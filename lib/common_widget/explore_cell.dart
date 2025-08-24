import 'package:flutter/material.dart';

class ExploreCell extends StatelessWidget {
  final Map pObj;
  final VoidCallback onPressed;

  const ExploreCell({
    super.key,
    required this.pObj,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final Color bgColor = pObj["color"] as Color? ?? const Color(0xFFE6F6EC);
    final String title = pObj["name"] as String? ?? "";
    final String subtitle = pObj["sub"] as String? ?? "";
    final String aisle = pObj["aisle"] as String? ?? "";
    final String iconUrl = pObj["icon"] as String? ?? "";

    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 110, // 📦 Bigger height
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 📝 Left: Text
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                    maxLines: 1,
                    softWrap: false,
                      overflow: TextOverflow.ellipsis
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 12, color: Colors.black),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    softWrap: false,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    aisle,
                    style: const TextStyle(fontSize: 11, color: Colors.black),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    softWrap: false,
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            // 🖼️ Right: Bigger image
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                iconUrl,
                width: 64,  // was 58
                height: 64, // was 58
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.broken_image,
                  size: 40,
                  color: Colors.grey,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
