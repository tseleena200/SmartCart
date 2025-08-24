import 'package:flutter/material.dart';

class HelpView extends StatelessWidget {
  const HelpView({super.key});

  @override
  Widget build(BuildContext context) {
    final Color themeColor = const Color(0xFF03452C); // Match your app's theme

    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & Support'),
        backgroundColor: themeColor,
      ),
      backgroundColor: Colors.white,
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Welcome to Smart Cart!',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          const Text(
            'This app simulates a smart shopping experience using RFID-based product scanning, cart management, and AI-powered recommendations — without needing real hardware.',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 24),
          _buildHelpSection(
            title: '🛒 Add Items to Cart',
            content:
            'Tap the “Scan” or “+” button on any product to simulate adding it to your cart. Each tap represents a virtual RFID scan.',
          ),
          _buildHelpSection(
            title: '🧾 Checkout & Receipt',
            content:
            'Go to the cart and tap “Checkout”. You can apply available discounts and choose a payment method. A digital receipt will be shown at the end — you can email it to yourself.',
          ),
          _buildHelpSection(
            title: '⭐ Smart Recommendations',
            content:
            'After using the app, you’ll receive recommendations based on your activity — like “You May Also Like”, “Buy Again”, and top categories.',
          ),
          _buildHelpSection(
            title: '📦 View Past Transactions',
            content:
            'Go to your account > Transaction History to view and revisit your past orders.',
          ),
          _buildHelpSection(
            title: '📄 View or Edit Your Profile',
            content:
            'Go to “My Details” to update your name, phone, birthday, or preferred store branch.',
          ),
          _buildHelpSection(
            title: '💳 Manage Payment Methods',
            content:
            'Save your card details securely for quick checkout. This is optional and can be changed anytime.',
          ),
          _buildHelpSection(
            title: '📥 Facing issues?',
            content:
            'If you have questions or experience problems, contact our support team at: \n\nsupport@smartcart.lk',
          ),
        ],
      ),
    );
  }

  Widget _buildHelpSection({required String title, required String content}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style:
              const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 8),
          Text(content, style: const TextStyle(fontSize: 15)),
        ],
      ),
    );
  }
}
