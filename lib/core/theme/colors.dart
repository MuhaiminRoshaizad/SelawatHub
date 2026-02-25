import 'package:flutter/material.dart';

class AppColors {
  static const Color mint = Color(0xFFE5B93D);
  static const Color sky = Color(0xFFF6DE95);
  static const Color ocean = Color(0xFFC7921F);
  static const Color ink = Color(0xFF0A1222);
  static const Color slate = Color(0xFF6A7891);
  static const Color card = Color(0xFFF2F7FF);
  static const Color white = Color(0xFFFFFFFF);
  static const Color transparent = Color(0x00000000);
  static const Color darkInk = Color(0xFFF0F5FF);
  static const Color darkSlate = Color(0xFFA6B5CC);
  static const Color darkSurface = Color(0xFF070E1A);
  static const Color darkCard = Color(0xFF111D2E);
  static const Color danger = Color(0xFFFF3B30);
  static const Color navGlassLight = Color(0xCCFFFFFF);
  static const Color navGlassDark = Color(0xB3122135);
  static const Color navBorderLight = Color(0x99FFFFFF);
  static const Color navBorderDark = Color(0x5938506C);

  static const LinearGradient lightGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFF8E6), Color(0xFFFFFDF5), Color(0xFFFFF4D9)],
  );

  static const LinearGradient darkGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF120D04), Color(0xFF1B1408), Color(0xFF241A0B)],
  );

  static LinearGradient backgroundGradientFor(Brightness brightness) {
    return brightness == Brightness.dark ? darkGradient : lightGradient;
  }
}
