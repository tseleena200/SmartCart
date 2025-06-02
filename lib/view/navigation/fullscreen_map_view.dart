import 'package:flutter/material.dart';

class FullscreenMapView extends StatelessWidget {
  const FullscreenMapView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Store Map"),
        backgroundColor: Color(0xFF87486E),
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 1,
          maxScale: 4,
          child: RotatedBox(
            quarterTurns: 1,
            child: Image.asset(
              "assets/img/store map.png",
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}
