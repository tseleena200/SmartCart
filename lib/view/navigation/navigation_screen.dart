import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'store_map_painter.dart'; // Adjust path if needed

class RouteNavigationView extends StatefulWidget {
  final String aisle;

  const RouteNavigationView({super.key, required this.aisle});

  @override
  State<RouteNavigationView> createState() => _RouteNavigationViewState();
}

class _RouteNavigationViewState extends State<RouteNavigationView>
    with SingleTickerProviderStateMixin {
  final FlutterTts flutterTts = FlutterTts();
  late AnimationController _controller;
  late Animation<double> _animation;

  final Map<String, String> aisleToCategory = {
    "Aisle 1": "Fruits & Vegetables",
    "Aisle 2": "Fishes & Meat",
    "Aisle 3": "Cooking Element",
    "Aisle 4": "Home & Cleaning",
    "Aisle 5": "Kitchen Appliances",
    "Aisle 6": "Snacks Item",
    "Aisle 7": "Dairy & Sweets",
    "Aisle 8": "Personal Care",
    "Aisle 9": "Stationery & Office",
    "Aisle 10": "Health & Wellness",
  };

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();

    flutterTts.speak("Please proceed to ${widget.aisle} via the suggested path.");
  }

  @override
  void dispose() {
    _controller.dispose();
    flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Route Navigation"),
        centerTitle: true,
        backgroundColor: const Color(0xFF87486E),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: FadeTransition(
          opacity: _animation,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "🛒 Your Smart Cart Navigation Plan",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.store_mall_directory, color: Color(0xFF87486E)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        "Proceed to ${widget.aisle}",
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              const Text(
                "Estimated Route:",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 12),
              Column(
                children: getEstimatedSteps(widget.aisle)
                    .map((step) => routeStep(step))
                    .toList(),
              ),
              const SizedBox(height: 30),
              const Text(
                "Store Map:",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 10),
              Center(
                child: SizedBox(
                  width: 240,
                  height: 200,
                  child: StoreMapView(
                    category: aisleToCategory[widget.aisle] ?? "Snacks Item",
                  ),
                ),
              ),
              const Spacer(),
              Center(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.done),
                  label: const Text("I’m Here"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade700,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget routeStep(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          const Icon(Icons.directions_walk, color: Color(0xFF87486E)),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14.5, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  List<String> getEstimatedSteps(String aisle) {
    switch (aisle) {
      case "Aisle 1":
        return [
          "Start from the entrance",
          "Turn left and reach Aisle 1 (Fruits & Vegetables)",
        ];
      case "Aisle 2":
        return [
          "Start from the entrance",
          "Walk forward past Aisle 1 and Aisle 6",
          "Turn left",
          "Reach Aisle 2 (Fishes & Meat)",
        ];
      case "Aisle 3":
        return [
          "Start from the entrance",
          "Go to the top-left corner of the store",
          "Reach Aisle 3 (Cooking Element)",
        ];
      case "Aisle 4":
        return [
          "Start from the entrance",
          "Walk straight ahead past Aisle 10",
          "Turn right",
          "Reach Aisle 4 (Home & Cleaning)",
        ];
      case "Aisle 5":
        return [
          "Start from the entrance",
          "Walk forward and turn right after Snacks",
          "Reach Aisle 5 (Kitchen Appliances)",
        ];
      case "Aisle 6":
        return [
          "Start from the entrance",
          "Walk straight ahead",
          "Reach Aisle 6 (Snacks Item)",
        ];
      case "Aisle 7":
        return [
          "Start from the entrance",
          "Walk straight past Health & Wellness and Snacks Item",
          "Turn slightly right",
          "Reach Dairy & Sweets (Aisle 7)",
        ];
      case "Aisle 8":
        return [
          "Start from the entrance",
          "Walk to the top-right of the store",
          "Reach Aisle 8 (Personal Care)",
        ];
      case "Aisle 9":
        return [
          "Start from the entrance",
          "Aisle 9 (Stationery & Office) is on the bottom left",
        ];
      case "Aisle 10":
        return [
          "Start from the entrance",
          "Walk straight ahead",
          "Reach Aisle 10 (Health & Wellness)",
        ];
      default:
        return [
          "Start from the entrance",
          "Reach ${widget.aisle}",
        ];
    }
  }
}
