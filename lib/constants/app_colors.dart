import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color background = Color(0xFF0F172A);
  static const Color surface = Color(0xFF1E293B);
  static const Color surfaceAlt = Color(0xFF27374D);
  static const Color accent = Color(0xFF38BDF8);
  static const Color accentSecondary = Color(0xFF8B5CF6);
  static const Color accentTertiary = Color(0xFFF97316);
  static const Color textPrimary = Color(0xFFE2E8F0);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color divider = Color(0xFF1F2937);

  static const List<Color> boardGradient = [
    Color(0xFF1B263B),
    Color(0xFF0E1C36),
  ];

  static const List<Color> highlightGradient = [
    Color(0xFF38BDF8),
    Color(0xFF8B5CF6),
  ];

  static const List<Color> warningGradient = [
    Color(0xFFFACC15),
    Color(0xFFF97316),
  ];

  static const List<Color> overlayGradient = [
    Color(0xCC0F172A),
    Color(0x990F172A),
  ];
}

extension ColorAlpha on Color {
  Color withFraction(double alphaFraction) {
    final fraction = alphaFraction.clamp(0.0, 1.0);
    return withAlpha((fraction * 255).round());
  }
}
