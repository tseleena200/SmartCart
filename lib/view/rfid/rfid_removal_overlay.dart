import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../controllers/cart_controller.dart';

class RFIDRemovalOverlay extends StatefulWidget {
  final String rfidCode;
  final CartController cartController;

  const RFIDRemovalOverlay({
    super.key,
    required this.rfidCode,
    required this.cartController,
  });

  @override
  State<RFIDRemovalOverlay> createState() => _RFIDRemovalOverlayState();
}

class _RFIDRemovalOverlayState extends State<RFIDRemovalOverlay> {
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _startRemovalSequence();
  }
  Future<void> _startRemovalSequence() async {
    try {
      await _audioPlayer.setReleaseMode(ReleaseMode.loop);
      await _audioPlayer.play(AssetSource('audio/scanner.mp3'));

      await Future.delayed(const Duration(seconds: 2));
      await _audioPlayer.stop();

      //  Try to remove from cart, but don't crash if it fails
      await widget.cartController.removeProductFromCartByRFID(widget.rfidCode);
    } catch (e) {
      debugPrint("Error while removing from cart: $e");
      // Optional: show error snackbar if needed
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to remove item: $e")),
        );
      }
    } finally {
      //  Always close overlay no matter what
      if (mounted) Navigator.pop(context);
    }
  }


  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.4),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Lottie.asset(
                'assets/animations/barcode_scan.json',
                width: 280,
                height: 280,
              ),
              const SizedBox(height: 20),
              const Text(
                'Removing from Cart...',
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
              const SizedBox(height: 10),
              Text(
                widget.rfidCode,
                style: const TextStyle(
                  color: Colors.redAccent,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
