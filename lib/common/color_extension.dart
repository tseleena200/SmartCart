import 'package:flutter/material.dart';

class TColor {
  // Palette
  static const Color moss = Color(0xFF2C3424);      // Deep green
  static const Color cypress = Color(0xFF4C583E);   // Earthy olive
  static const Color olive = Color(0xFF768064);     // Midtone green-gray
  static const Color cedar = Color(0xFF959581);     // Muted beige
  static const Color aloe = Color(0xFFDADED8);      // Very light mint

  // ✅ Theme Usage Mapping

  // Primary
  static Color get primary => moss;

  // Backgrounds
  static Color get backgroundLight => aloe;
  static Color get backgroundDark => moss;
  static Color get cardLight => Colors.white;
  static Color get cardDark => cypress;

  // Text
  static Color get primaryText => const Color(0xFF030303); // Deep black for strong text
  static Color get secondaryText => const Color(0xFF828282); // General subtitle
  static Color get textTitle => const Color(0xFF7C7C7C); // List titles / section heads
  static Color get placeholder => const Color(0xFFB1B1B1); // Input hints
  static Color get darkGrey => const Color(0xFF030303); // Reuse for icons / fallback

  // Feedback
  static Color get success => olive;
  static Color get error => Color(0xFF8B0000); // Dark red
}
