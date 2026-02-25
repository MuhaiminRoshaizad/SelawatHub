import 'package:flutter/material.dart';

class AppColors {
  static const Color mint = Color(0xFF15B79E);
  static const Color sky = Color(0xFF6AA9FF);
  static const Color ocean = Color(0xFF2D6CDF);
  static const Color ink = Color(0xFF0D1B2A);
  static const Color slate = Color(0xFF5D6B82);
  static const Color card = Color(0xFFF7FAFF);
  static const Color white = Colors.white;

  static const LinearGradient appGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFEAF8FF), Color(0xFFF9FCFF), Color(0xFFEAF4FF)],
  );
}

