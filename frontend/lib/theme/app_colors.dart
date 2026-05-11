import 'package:flutter/material.dart';

class AppColors {
  AppColors._(); // Private constructor to prevent instantiation

  // Primary
  static const Color primaryBlue = Color(0xFF60A5FA); // Softer blue
  static const Color lightBlue = Color(0xFFDBEAFE); // Very light blue for backgrounds/accents

  // Background
  static const Color background = Color(0xFFF5F7FA);
  static const Color cardBackground = Color(0xFFFFFFFF);

  // Text
  static const Color primaryText = Color(0xFF1C1C1E);
  static const Color secondaryText = Color(0xFF6B7280);

  // Status
  static const Color success = Color(0xFF22C55E);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);

  // Extras
  static const Color border = Color(0xFFE5E7EB);
  static const Color shadow = Colors.black12;

  // Student Theme Colors (Greens)
  static const Color studentPrimary = Color(0xFF386641);
  static const Color studentSecondary = Color(0xFF6A994E);

  // Admin Theme Colors (Red & Cream)
  static const Color adminPrimary = Color(0xFFBC4749);
  static const Color adminBackground = Color(0xFFF2E8CF);
}
