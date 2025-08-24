import 'package:flutter/material.dart';

class AboutView extends StatelessWidget {
  const AboutView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About Smart Cart'),
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '🛒 What is Smart Cart?',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              'Smart Cart is a mobile-based prototype of an automated shopping cart system. '
                  'It simulates how RFID-based item scanning and billing would work in a real-world supermarket environment.',
              style: TextStyle(fontSize: 16, height: 1.5),
            ),
            const SizedBox(height: 24),

            const Text(
              '🔍 Why a Simulation?',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              'This app was designed for demonstration and research purposes. Instead of using real RFID hardware, '
                  'the system simulates scans using buttons and interactions. This helps test all functionality without the cost of physical sensors.',
              style: TextStyle(fontSize: 16, height: 1.5),
            ),
            const SizedBox(height: 24),

            const Text(
              '💡 Future Integration',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              'The app is built with future expansion in mind. It can easily be integrated with RFID readers and IoT devices, '
                  'enabling real-time, contactless item detection, route guidance, and automated billing in physical retail environments.',
              style: TextStyle(fontSize: 16, height: 1.5),
            ),
            const SizedBox(height: 24),

            const Text(
              '✨ Features in this Simulation',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              '• Simulated RFID scanning and cart operations\n'
                  '• Product recommendation system using machine learning\n'
                  '• Smart route navigation inside store layout\n'
                  '• Favorites, reviews, checkout and receipt features\n'
                  '• Admin panel for managing products, users, and transactions',
              style: TextStyle(fontSize: 16, height: 1.6),
            ),
            const SizedBox(height: 24),

            const Text(
              '📍 Developed For',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              'This app was developed as a final-year software engineering project at Cardiff Metropolitan University. '
                  'It showcases how mobile-first design and AI can modernize retail experiences in developing countries like Sri Lanka.',
              style: TextStyle(fontSize: 16, height: 1.5),
            ),
            const SizedBox(height: 24),

            const Divider(),
            Center(
              child: Text(
                'Version 1.0.0 • © 2025 Smart Cart',
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
