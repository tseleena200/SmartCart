import 'package:flutter/material.dart';

class StoreMapView extends StatelessWidget {
  final String category;

  const StoreMapView({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: RealisticStoreMapPainter(category),
      size: const Size(380, 300),
    );
  }
}

class RealisticStoreMapPainter extends CustomPainter {
  final String currentCategory;

  RealisticStoreMapPainter(this.currentCategory);

  final double tileWidth = 80;
  final double tileHeight = 50;
  final double spacing = 20;

  final Map<String, Offset> categoryPositions = {
    "Cooking Element": Offset(0, 0),
    "Fishes & Meat": Offset(1, 0),
    "Dairy & Sweets": Offset(2, 0),
    "Personal Care": Offset(3, 0),

    "Fruits & Vegetables": Offset(0, 1),
    "Snacks Item": Offset(1, 1),
    "Kitchen Appliances": Offset(2, 1),

    "Stationery & Office": Offset(0, 2),
    "Health & Wellness": Offset(1, 2),
    "Home & Cleaning": Offset(2, 2),

    "Entrance": Offset(0, 3),
    "Exit": Offset(2, 3),
  };

  final Map<String, Color> categoryColors = {
    "Cooking Element": Colors.lightBlue.shade300,
    "Fishes & Meat": Colors.red.shade200,
    "Dairy & Sweets": Colors.yellow.shade300,
    "Personal Care": Colors.brown.shade300,
    "Fruits & Vegetables": Colors.green.shade300,
    "Snacks Item": Colors.grey.shade400,
    "Kitchen Appliances": Colors.orange.shade300,
    "Stationery & Office": Colors.purple.shade300,
    "Health & Wellness": Colors.teal.shade300,
    "Home & Cleaning": Colors.cyan.shade200,
    "Entrance": Colors.green.shade100,
    "Exit": Colors.brown.shade200,
  };

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    const textStyle = TextStyle(
      fontSize: 10,
      fontWeight: FontWeight.bold,
      color: Colors.black,
    );

    // ✅ Dynamically center horizontally
    const double columns = 4;
    final double totalWidth = columns * tileWidth + (columns - 1) * spacing;
    final double leftOffset = (size.width - totalWidth) / 2;

    categoryPositions.forEach((label, gridPos) {
      final double x = leftOffset + gridPos.dx * (tileWidth + spacing);
      final double y = gridPos.dy * (tileHeight + spacing);

      // Draw tile
      paint.color = categoryColors[label] ?? Colors.grey;
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, y, tileWidth, tileHeight),
        const Radius.circular(10),
      );
      canvas.drawRRect(rect, paint);

      // Determine aisle label if any
      final aisleNumber = getAisleNumber(label);
      final textSpan = TextSpan(
        text: aisleNumber != null ? "$label\nAisle $aisleNumber" : label,
        style: textStyle,
      );
      final textPainter = TextPainter(
        text: textSpan,
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout(maxWidth: tileWidth - 4);
      textPainter.paint(
        canvas,
        Offset(x + (tileWidth - textPainter.width) / 2, y + (tileHeight - textPainter.height) / 2),
      );

      // Draw cart marker
      if (label == currentCategory) {
        final cartPaint = Paint()..color = Colors.deepPurple;
        canvas.drawCircle(
          Offset(x + tileWidth / 2, y + tileHeight - 6),
          5,
          cartPaint,
        );
      }
    });
  }

  String? getAisleNumber(String label) {
    const aisleMap = {
      "Fruits & Vegetables": "1",
      "Fishes & Meat": "2",
      "Cooking Element": "3",
      "Home & Cleaning": "4",
      "Kitchen Appliances": "5",
      "Snacks Item": "6",
      "Dairy & Sweets": "7",
      "Personal Care": "8",
      "Stationery & Office": "9",
      "Health & Wellness": "10",
    };
    return aisleMap[label];
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
