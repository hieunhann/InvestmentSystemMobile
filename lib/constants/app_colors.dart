import 'package:flutter/material.dart';

/// App-wide color constants
class AppColors {
  AppColors._(); // Private constructor to prevent instantiation

  // Primary (gold) colors - inspired by provided UI
  static const Color primary = Color(0xFFF7CD7A);
  static const Color primaryVariant = Color(0xFFEAB95B);
  static const Color secondary = Color(0xFF1F1F1F);
  static const Color secondaryVariant = Color(0xFF2A2A2A);

  // Background colors
  static const Color background = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color appBackground = Color(0xFFF2F2F6);
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color error = Color(0xFFB00020);

  // Text colors
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onSecondary = Color(0xFF000000);
  static const Color onBackground = Color(0xFF000000);
  static const Color onSurface = Color(0xFF000000);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color textMuted = Color(0xFF9E9E9E);
  static const Color fieldBorder = Color(0xFFEDEDED);

  // Additional colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color info = Color(0xFF2196F3);
}
