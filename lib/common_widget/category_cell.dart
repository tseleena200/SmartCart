import 'package:flutter/material.dart';
import '../common/color_extension.dart';

class CategoryCell extends StatelessWidget {
  final Map pObj;
  final VoidCallback onPressed;
  const CategoryCell({super.key, required this.pObj, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onPressed,
      child: Container(
        width: 150, // Wide pill
        height: 200, // Enough for image+text
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: (pObj["color"] as Color? ?? TColor.primary).withOpacity(0.30),
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: (pObj["color"] as Color? ?? TColor.primary).withOpacity(0.07),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: Image.asset(
                pObj["icon"] ?? "",
                fit: BoxFit.contain,
                width: 90,
                height: 90,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              pObj["name"] ?? "",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: TColor.primaryText,
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.1,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
