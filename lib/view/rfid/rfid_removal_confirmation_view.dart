import 'package:flutter/material.dart';

class RFIDRemovalConfirmationView extends StatelessWidget {
  final String rfidCode;

  const RFIDRemovalConfirmationView({super.key, required this.rfidCode});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle_outline, size: 100, color: Colors.green),
            const SizedBox(height: 20),
            const Text(
              'Item Removed',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              'RFID: $rfidCode',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Return to Cart'),
            ),
          ],
        ),
      ),
    );
  }
}
