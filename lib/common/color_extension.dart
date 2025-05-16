import 'package:flutter/material.dart';

class TColor {
  // Primary color theme
  static Color get primary => const Color(0xFF03452C); // Your main green
  static Color get primaryText => const Color(0xFF030303);
  static Color get secondaryText => const Color(0xFF828282);
  static Color get textTitle => const Color(0xFF7C7C7C);
  static Color get placeholder => const Color(0xFFB1B1B1);
  static Color get darkGrey => const Color(0xff030303);

  // Backgrounds
  static Color get background => const Color(0xFFF5F5F5);
  static Color get card => const Color(0xFFFFFFFF);

  // Snackbar / feedback colors
  static Color get success => const Color(0xFF03452C); // same as primary
  static Color get error => const Color(0xFF450303);   // your dark red
}
