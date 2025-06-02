import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:onlinegroceries/view/navigation/store_map_painter.dart';


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

  late List<String> directions;

  @override
  void initState() {
    super.initState();

    directions = getEstimatedSteps(widget.aisle);

    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();

    // 🔊 Automatically speak directions when screen loads
    _speakDirections();
  }

  void _speakDirections() {
    final speechText = directions.join(". ");
    flutterTts.speak(speechText);
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
                    const Icon(Icons.store_mall_directory,
                        color: Color(0xFF87486E)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        "Proceed to ${widget.aisle}",
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Estimated Route:",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  TextButton.icon(
                    onPressed: _speakDirections,
                    icon: const Icon(Icons.volume_up, size: 20),
                    label: const Text("Speak"),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF87486E),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Column(
                children:
                directions.map((step) => routeStep(step)).toList(),
              ),
              const SizedBox(height: 30),
              const Text(
                " Need Help ? View The Store Map:",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 10),
              const Center(child: StoreMapView()),
              const Spacer(),
              Center(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.done),
                  label: const Text("I’m Here"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade700,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 14),
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
    // 🔁 Replace this hardcoded map with Firestore call later if needed
    const directions = {
      "Aisle 1":
      "Enter the store and walk straight or turn left. Head to the top-left corner near the exit. That's where you’ll find the produce section.",
      "Aisle 2":
      "Enter the store and turn left. Walk past the bakery and deli. The meat and seafood section is along the left wall.",
      "Aisle 3":
      "Enter the store and turn left. Walk up the left side of the store past the meat section. You'll find the dairy aisle next.",
      "Aisle 4":
      "Enter the store and turn left immediately. The bakery is in the bottom-left corner, next to the deli.",
      "Aisle 5":
      "Enter the store and walk straight ahead. The first horizontal aisle you reach is canned goods.",
      "Aisle 6":
      "Enter the store and walk straight. After passing Aisle 5, you’ll reach Aisle 6 — Pasta and Rice.",
      "Aisle 7":
      "Enter the store and walk straight. Aisle 7 — Herbs and Spices — is after Pasta and Rice.",
      "Aisle 8":
      "Enter the store and walk straight past Aisle 7. You’ll reach Aisle 8 — Frozen Foods.",
      "Aisle 9":
      "Enter and walk straight past Aisle 8. You’ll find Aisle 9 — Ice Cream and Desserts.",
      "Aisle 10":
      "Enter the store and walk straight. Aisle 10 — Breakfast and Cereals — is after Aisle 9.",
      "Aisle 11":
      "Enter the store and walk straight until the seventh row. That’s Aisle 11 — Snacks.",
      "Aisle 12":
      "Enter and go straight to the eighth row. You’ll find Aisle 12 — Beverages.",
      "Aisle 13":
      "Enter the store and walk to the last horizontal aisle above the salad bar. That’s Aisle 13 — Wine and Spirits.",
      "Aisle 14":
      "Enter the store and walk straight. Then turn right. Aisle 14 — Baby Products — is on the lower-right side.",
      "Aisle 15":
      "Enter the store and walk forward. Turn right, and go slightly up. You’ll reach Aisle 15 — Feminine Care.",
      "Aisle 16":
      "Enter the store and turn right. Go to the very bottom-right corner. That’s Aisle 16 — Personal Care.",
      "Aisle 17":
      "Enter the store and walk forward. Turn right toward the center-right wall. That’s Aisle 17 — Health and Wellness.",
      "Aisle 18":
      "Enter the store and walk forward. Turn right above Aisle 17. That’s Aisle 18 — Cleaning Supplies.",
      "Aisle 19":
      "Enter and walk forward. Turn right and go all the way to the top-right corner. That’s Household Essentials.",
      "Aisle 20":
      "Enter and walk forward. Turn right to the topmost part of the right side. You’ll reach Aisle 20 — Pet Supplies.",
      "Aisle 21":
      "Enter the store and turn right. Aisle 21 — Stationery — is near the bottom-right corner beside Personal Care.",
      "Aisle 22":
      "Enter the store and turn right. Just before you reach Personal Care, you’ll find Aisle 22 — Offers.",

    };

    final text = directions[aisle];
    return text != null ? [text] : ["Please proceed to ${widget.aisle}."];
  }
}
