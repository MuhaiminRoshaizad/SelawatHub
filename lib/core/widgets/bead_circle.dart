import 'dart:math';
import 'package:flutter/material.dart';
import 'package:selawathub/core/theme/colors.dart';

class BeadCircle extends StatelessWidget {
  const BeadCircle({
    super.key,
    required this.total,
    required this.filled,
    this.size = 280,
    this.beadRadius = 8,
  });

  final int total;
  final int filled;
  final double size;
  final double beadRadius;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _Painter(
          total: total,
          filled: filled,
          beadRadius: beadRadius,
          filledColor: C.primarySoft,
          emptyColor: dark ? C.white.withValues(alpha: 0.06) : C.black.withValues(alpha: 0.06),
          threadColor: dark ? C.white.withValues(alpha: 0.03) : C.black.withValues(alpha: 0.04),
          glowColor: C.primaryGlow,
        ),
      ),
    );
  }
}

class _Painter extends CustomPainter {
  _Painter({
    required this.total,
    required this.filled,
    required this.beadRadius,
    required this.filledColor,
    required this.emptyColor,
    required this.threadColor,
    required this.glowColor,
  });

  final int total;
  final int filled;
  final double beadRadius;
  final Color filledColor;
  final Color emptyColor;
  final Color threadColor;
  final Color glowColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final ringR = (size.width / 2) - beadRadius - 6;

    // Thread
    canvas.drawCircle(center, ringR, Paint()
      ..color = threadColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5);

    final step = (2 * pi) / total;
    for (int i = 0; i < total; i++) {
      final angle = -pi / 2 + i * step;
      final pos = Offset(center.dx + ringR * cos(angle), center.dy + ringR * sin(angle));
      final on = i < filled;

      if (on) {
        canvas.drawCircle(pos, beadRadius + 3, Paint()
          ..color = glowColor
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5));
      }

      canvas.drawCircle(pos, beadRadius, Paint()..color = on ? filledColor : emptyColor);
    }
  }

  @override
  bool shouldRepaint(covariant _Painter old) =>
      old.filled != filled || old.total != total;
}
