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
    final Color bgColor = pObj["color"] ?? const Color(0xFFE6F6EC);
    final String title = pObj["name"] ?? "";
    final String subtitle = pObj["sub"] ?? "";
    final String aisle = pObj["aisle"] ?? "";
    final String icon = pObj["icon"] ?? "";

    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Left: Text info
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    aisle,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),

            // Right: Image
            Image.asset(
              icon,
              width: 58,
              height: 58,
              fit: BoxFit.contain,
            ),
          ],
        ),
      ),
    );
  }
}
