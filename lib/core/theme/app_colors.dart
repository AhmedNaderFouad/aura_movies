// App color definitions for AuraMovies
import 'package:flutter/material.dart';

class AppColors {
  // Primary & Secondary
  static const Color primary = Color(0xFF00FFB0);
  static const Color secondary = Color(0xFF00C3FF);

  // Backgrounds
  static const Color background = Color(0xFF0D0F14);
  static const Color surface = Color(0xFF1E1E1E);
  static const Color darkGradientStart = Color(0xFF0D0F14);
  static const Color darkGradientEnd = Color(0xFF001F1A); // Dark green tint

  // Text
  static const Color text = Colors.white;
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFF8E9297);
  static const Color textFaded = Color(0x99FFFFFF);
  static const Color hintColor = Color(0xFF5C6066);
  static const Color buttonText = Color(0xFF0D0F14);

  // Borders & Accents
  static const Color border = Color(0x33FFFFFF);
  static const Color accent = Color(0xFF00FFB0);
  static const Color glow = Color(0x4D00FFB0);

  // Gradients
  static const List<Color> primaryGradient = [primary, secondary];

  static const List<Color> backgroundGradient = [
    darkGradientStart,
    darkGradientEnd,
  ];
}
