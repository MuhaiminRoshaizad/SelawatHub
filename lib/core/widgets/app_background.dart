import 'package:flutter/material.dart';
import 'package:selawathub/core/theme/app_colors.dart';

class AppBackground extends StatelessWidget {
  const AppBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(gradient: AppColors.appGradient),
      child: Stack(
        children: [
          Positioned(
            top: -80,
            right: -40,
            child: _blurBubble(
              diameter: 220,
              color: AppColors.sky.withValues(alpha: 0.18),
            ),
          ),
          Positioned(
            bottom: -110,
            left: -50,
            child: _blurBubble(
              diameter: 260,
              color: AppColors.mint.withValues(alpha: 0.15),
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

