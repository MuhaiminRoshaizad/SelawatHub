import 'dart:math';
import 'package:flutter/material.dart';
import 'package:selawathub/core/theme/colors.dart';

class MinimalCounter extends StatelessWidget {
  const MinimalCounter({
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
        painter: _TickPainter(
          total: total,
          filled: filled,
          filledColor: accentColor,
          emptyColor: dark
              ? C.white.withValues(alpha: 0.08)
              : C.black.withValues(alpha: 0.08),
        ),
      ),
    );
  }
}

class _TickPainter extends CustomPainter {
  _TickPainter({
    required this.total,
    required this.filled,
    required this.filledColor,
    required this.emptyColor,
  });

  final int total;
  final int filled;
  final Color filledColor;
  final Color emptyColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final outerRadius = (size.width / 2) - 12;

    for (int i = 0; i < total; i++) {
      final angle = -pi / 2 + (2 * pi * i / total);
      final isMajor =
          total >= 20 && i % (total ~/ 10).clamp(1, total) == 0;
      final tickLength = isMajor ? 12.0 : 7.0;
      final strokeWidth = isMajor ? 2.5 : 1.5;

      final outer = Offset(
        center.dx + outerRadius * cos(angle),
        center.dy + outerRadius * sin(angle),
      );
      final inner = Offset(
        center.dx + (outerRadius - tickLength) * cos(angle),
        center.dy + (outerRadius - tickLength) * sin(angle),
      );

      final paint = Paint()
        ..color = i < filled ? filledColor : emptyColor
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      canvas.drawLine(inner, outer, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _TickPainter old) =>
      old.filled != filled || old.total != total;
}
