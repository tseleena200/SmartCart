// store_map_view.dart
import 'package:flutter/material.dart';
import 'fullscreen_map_view.dart'; // import the full map screen

class StoreMapView extends StatelessWidget {
  const StoreMapView({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const FullscreenMapView(),
          ),
        );
      },
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              "assets/img/coverpagemap.png",
              width: 240,
              height: 160,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            "Tap to view full map",
            style: TextStyle(fontSize: 12, color: Colors.black54),
          ),
        ],
      ),
    );
  }
}
