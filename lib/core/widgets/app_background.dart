import 'package:flutter/material.dart';
import 'package:selawathub/core/theme/colors.dart';

class AppBackground extends StatelessWidget {
  const AppBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    final bool isDark = brightness == Brightness.dark;

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: AppColors.backgroundGradientFor(brightness),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.white.withValues(alpha: isDark ? 0.03 : 0.24),
                    AppColors.transparent.withValues(alpha: 0.0),
                    AppColors.ocean.withValues(alpha: isDark ? 0.06 : 0.03),
                  ],
                  stops: const [0.0, 0.55, 1.0],
                ),
              ),
            ),
          ),
          Positioned(
            top: -120,
            right: -90,
            child: _blurBubble(
              diameter: 280,
              color: AppColors.sky.withValues(alpha: isDark ? 0.1 : 0.34),
            ),
          ),
          Positioned(
            top: 220,
            left: -140,
            child: _blurBubble(
              diameter: 280,
              color: AppColors.ocean.withValues(alpha: isDark ? 0.08 : 0.1),
            ),
          ),
          Positioned(
            bottom: -180,
            right: -70,
            child: _blurBubble(
              diameter: 340,
              color: AppColors.mint.withValues(alpha: isDark ? 0.1 : 0.14),
            ),
          ),
          SafeArea(child: child),
        ],
      ),
    );
  }

  Widget _blurBubble({required double diameter, required Color color}) {
    return Container(
      width: diameter,
      height: diameter,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }
}
