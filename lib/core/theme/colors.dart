import 'package:flutter/material.dart';

class AppColors {
  static const Color mint = Color(0xFF15B79E);
  static const Color sky = Color(0xFF6AA9FF);
  static const Color ocean = Color(0xFF2D6CDF);
  static const Color ink = Color(0xFF0D1B2A);
  static const Color slate = Color(0xFF5D6B82);
  static const Color card = Color(0xFFF7FAFF);
  static const Color white = Color(0xFFFFFFFF);
  static const Color transparent = Color(0x00000000);
  static const Color darkInk = Color(0xFFEBF2FF);
  static const Color darkSlate = Color(0xFFAAB6CC);
  static const Color darkSurface = Color(0xFF08121F);
  static const Color darkCard = Color(0xFF101D2C);

  static const LinearGradient lightGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFEAF8FF), Color(0xFFF9FCFF), Color(0xFFEAF4FF)],
  );

  static const LinearGradient darkGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF060D17), Color(0xFF0A1524), Color(0xFF0D1C2F)],
  );

  static LinearGradient backgroundGradientFor(Brightness brightness) {
    return brightness == Brightness.dark ? darkGradient : lightGradient;
  }
}

