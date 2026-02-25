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
    final Color panelBase = isDark
        ? const Color(0xCC15120C)
        : const Color(0xE6FFF9EC);
    final Color panelEdge = isDark
        ? AppColors.white.withValues(alpha: 0.22)
        : AppColors.white.withValues(alpha: 0.9);
    final Color panelShadow = (isDark ? Colors.black : AppColors.ink)
        .withValues(alpha: isDark ? 0.46 : 0.12);

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              panelBase.withValues(alpha: isDark ? 0.96 : 0.9),
              panelBase.withValues(alpha: isDark ? 0.82 : 0.78),
            ],
          ),
          border: Border.all(
            color: panelEdge,
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: panelShadow,
              blurRadius: 26,
              spreadRadius: -6,
              offset: const Offset(0, 12),
            ),
            BoxShadow(
              color: AppColors.mint.withValues(alpha: isDark ? 0.08 : 0.05),
              blurRadius: 30,
              spreadRadius: -12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(radius),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.white.withValues(alpha: isDark ? 0.05 : 0.22),
                      AppColors.transparent,
                      AppColors.ocean.withValues(alpha: isDark ? 0.06 : 0.03),
                    ],
                    stops: const [0.0, 0.45, 1.0],
                  ),
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              top: 0,
              child: IgnorePointer(
                child: Container(
                  height: 56,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(radius),
                    ),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AppColors.white.withValues(
                          alpha: isDark ? 0.24 : 0.5,
                        ),
                        AppColors.white.withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 16,
              right: 16,
              top: 1,
              child: IgnorePointer(
                child: Container(
                  height: 1.2,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999),
                    color: AppColors.white.withValues(alpha: isDark ? 0.45 : 0.85),
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
    );
  }
}
