import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:selawathub/core/theme/colors.dart';

class BlurCard extends StatelessWidget {
  const BlurCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    final bool isDark = brightness == Brightness.dark;

    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 7, sigmaY: 7),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: (isDark ? AppColors.darkCard : AppColors.white)
                .withValues(alpha: isDark ? 0.76 : 0.7),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: (isDark ? AppColors.darkSlate : AppColors.white)
                  .withValues(alpha: isDark ? 0.34 : 0.9),
              width: 1.1,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
