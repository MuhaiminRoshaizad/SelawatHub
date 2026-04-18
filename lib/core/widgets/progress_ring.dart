import 'dart:math';
import 'package:flutter/material.dart';
import 'package:selawathub/core/theme/colors.dart';

class ProgressRing extends StatelessWidget {
  const ProgressRing({
    super.key,
    required this.progress,
    this.size = 200,
    this.strokeWidth = 12,
    this.trackColor,
    this.progressColor,
    this.child,
  });

  final double progress;
  final double size;
  final double strokeWidth;
  final Color? trackColor;
  final Color? progressColor;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: progress.clamp(0.0, 1.0)),
            duration: const Duration(milliseconds: 900),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) => CustomPaint(
              size: Size(size, size),
              painter: _RingPainter(
                progress: value,
                strokeWidth: strokeWidth,
                trackColor: trackColor ??
                    (dark
                        ? C.white.withValues(alpha: 0.06)
                        : C.black.withValues(alpha: 0.06)),
                progressColor: progressColor ?? C.primarySoft,
                glowColor: C.primaryGlow,
              ),
            ),
          ),
          ?child,
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.progress,
    required this.strokeWidth,
    required this.trackColor,
    required this.progressColor,
    required this.glowColor,
  });

  final double progress;
  final double strokeWidth;
  final Color trackColor;
  final Color progressColor;
  final Color glowColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = trackColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round,
    );

    if (progress <= 0) return;
    final sweep = 2 * pi * progress;

    // Glow
    canvas.drawArc(
      rect, -pi / 2, sweep, false,
      Paint()
        ..color = glowColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth + 8
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );

    // Arc
    canvas.drawArc(
      rect, -pi / 2, sweep, false,
      Paint()
        ..color = progressColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) => old.progress != progress;
}
