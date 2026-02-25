import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:selawathub/core/theme/colors.dart';

class BlurCard extends StatelessWidget {
  const BlurCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.radius = 22,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    final bool isDark = brightness == Brightness.dark;

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [
                      AppColors.white.withValues(alpha: 0.09),
                      AppColors.darkCard.withValues(alpha: 0.48),
                    ]
                  : [
                      AppColors.white.withValues(alpha: 0.86),
                      AppColors.white.withValues(alpha: 0.56),
                    ],
            ),
            border: Border.all(
              color: (isDark ? AppColors.white : AppColors.white)
                  .withValues(alpha: isDark ? 0.18 : 0.85),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: (isDark ? AppColors.ink : AppColors.ocean)
                    .withValues(alpha: isDark ? 0.24 : 0.1),
                blurRadius: 26,
                spreadRadius: -8,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                left: 0,
                right: 0,
                top: 0,
                child: IgnorePointer(
                  child: Container(
                    height: 54,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(radius),
                      ),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppColors.white.withValues(
                            alpha: isDark ? 0.16 : 0.42,
                          ),
                          AppColors.white.withValues(alpha: 0.0),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Container(
                padding: padding,
                child: child,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
