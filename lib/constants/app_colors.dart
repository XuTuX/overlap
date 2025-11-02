import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color background = Color(0xFFF1F5FF);
  static const Color surface = Color(0xFFDCE7FF);
  static const Color surfaceAlt = Color(0xFFC9DAFF);
  static const Color accent = Color(0xFF4C6EF5);
  static const Color accentSecondary = Color(0xFF8B5CF6);
  static const Color accentTertiary = Color(0xFFFF8A3D);
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF475569);
  static const Color divider = Color(0xFFB4C5F9);

  static const List<Color> boardGradient = [
    Color(0xFFE4EDFF),
    Color(0xFFC7D8FF),
  ];

  static const List<Color> highlightGradient = [
    Color(0xFF60A5FA),
    Color(0xFF8B5CF6),
  ];

  static const List<Color> warningGradient = [
    Color(0xFFFFE066),
    Color(0xFFFFA45B),
  ];

  static const List<Color> overlayGradient = [
    Color(0xCCF1F5FF),
    Color(0x99DCE7FF),
  ];
}

extension ColorAlpha on Color {
  Color withFraction(double alphaFraction) {
    final fraction = alphaFraction.clamp(0.0, 1.0);
    return withAlpha((fraction * 255).round());
  }
}
