import 'package:flutter/material.dart';

class AppColors {
  static const Color mint = Color(0xFFD4AF37);
  static const Color sky = Color(0xFFF2E5B8);
  static const Color ocean = Color(0xFFB9891E);
  static const Color ink = Color(0xFF111111);
  static const Color slate = Color(0xFF595042);
  static const Color card = Color(0xFFFCF7EA);
  static const Color white = Color(0xFFFFFFFF);
  static const Color transparent = Color(0x00000000);
  static const Color darkInk = Color(0xFFF6E8C3);
  static const Color darkSlate = Color(0xFFC9B78A);
  static const Color darkSurface = Color(0xFF080808);
  static const Color darkCard = Color(0xFF14110A);
  static const Color danger = Color(0xFFFF3B30);
  static const Color navGlassLight = Color(0xCCFFF9EB);
  static const Color navGlassDark = Color(0xCC171209);
  static const Color navBorderLight = Color(0xD9FFFFFF);
  static const Color navBorderDark = Color(0x66E0C98C);

  static const LinearGradient lightGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFFCF4), Color(0xFFF8F1DE), Color(0xFFF1E4C1)],
  );

  static const LinearGradient darkGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF060606), Color(0xFF0F0C07), Color(0xFF181208)],
  );

  static LinearGradient backgroundGradientFor(Brightness brightness) {
    return brightness == Brightness.dark ? darkGradient : lightGradient;
  }
}
