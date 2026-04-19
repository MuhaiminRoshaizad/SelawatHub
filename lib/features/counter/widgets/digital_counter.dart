import 'dart:math';
import 'package:flutter/material.dart';
import 'package:selawathub/core/theme/colors.dart';

class DigitalCounter extends StatelessWidget {
  const DigitalCounter({
    super.key,
    required this.total,
    required this.filled,
    this.size = 280,
    this.accentColor = C.primarySoft,
  });

  final int total;
  final int filled;
  final double size;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _RingPainter(
          total: total,
          filled: filled,
          filledColor: accentColor,
          trackColor:
              dark ? C.white.withValues(alpha: 0.06) : C.black.withValues(alpha: 0.06),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.total,
    required this.filled,
    required this.filledColor,
    required this.trackColor,
  });

  final int total;
  final int filled;
  final Color filledColor;
  final Color trackColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - 16;
    const strokeWidth = 4.0;

    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);

    if (total <= 0 || filled <= 0) return;

    final sweep = (filled / total).clamp(0.0, 1.0) * 2 * pi;
    final filledPaint = Paint()
      ..color = filledColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      sweep,
      false,
      filledPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) =>
      old.filled != filled || old.total != total || old.filledColor != filledColor;
}
