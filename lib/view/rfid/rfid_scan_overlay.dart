import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:onlinegroceries/view/rfid/rfid_confirmation_view.dart';

class RFIDScanOverlay extends StatefulWidget {
  final String rfidCode;

  const RFIDScanOverlay({super.key, required this.rfidCode});

  @override
  State<RFIDScanOverlay> createState() => _RFIDScanOverlayState();
}

class _RFIDScanOverlayState extends State<RFIDScanOverlay> {
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _startScanSequence();
  }

  Future<void> _startScanSequence() async {
    //  Loop the scanning sound
    await _audioPlayer.setReleaseMode(ReleaseMode.loop);
    await _audioPlayer.play(AssetSource('audio/scanner.mp3'));

    //  Wait for scanning to complete (5 sec or your preferred duration)
    await Future.delayed(const Duration(seconds: 5));

    //  Stop the looped sound
    await _audioPlayer.stop();

    //  Close the overlay
    // 4. Navigate to confirmation screen (replacing overlay)
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => RFIDConfirmationView(rfidCode: widget.rfidCode),
        ),
      );
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
                width: 300,
                height: 300,
                repeat: true,
              ),
              const SizedBox(height: 20),
              const Text(
                'Scanning RFID...',
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
              const SizedBox(height: 10),
              Text(
                widget.rfidCode,
                style: const TextStyle(
                  color: Colors.greenAccent,
                  fontSize: 25,
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
