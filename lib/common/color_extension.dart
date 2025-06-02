import 'package:flutter/material.dart';

class TColor {
  // 🎨 Base Pink Accent
  static const Color moss = Color(0xFF87486E); // Your primary pink

  // 🌸 Soft Pastel Pinks
  static const Color blush = Color(0xFFFFE9F0);     // Light pink background
  static const Color roseMist = Color(0xFFFFD1DC);  // Section background
  static const Color petal = Color(0xFFFFF4F8);     // Card bg
  static const Color bubble = Color(0xFFFFC4D6);    // Border / subtle bg

  //  Theme Usage Mapping

  // Primary color for buttons, icons, highlights
  static Color get primary => moss;

  // Backgrounds
  static Color get backgroundLight => blush;       // App background
  static Color get backgroundDark => moss;         // DO NOT CHANGE
  static Color get cardLight => petal;             // Product cards
  static Color get cardSoft => roseMist;           // Section containers
  static Color get cardBorder => bubble;           // Accent border

  // Text
  static Color get primaryText => const Color(0xFF1A1A1A);  // Near black
  static Color get secondaryText => const Color(0xFF6D6D6D); // Softer gray
  static Color get textTitle => moss;                        // Use moss as highlight
  static Color get placeholder => const Color(0xFFB195A5);   // Pink-gray hint
  static Color get darkGrey => const Color(0xFF2F2F2F);      // Fallback

  // Feedback
  static Color get success => const Color(0xFFB7E4C7);       // Pastel green
  static Color get error => const Color(0xFFE57373);         // Warm red
}
