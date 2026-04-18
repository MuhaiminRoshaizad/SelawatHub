import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:selawathub/core/theme/colors.dart';

/// A translucent bar with backdrop blur — content that scrolls
/// underneath appears frosted, like Telegram / YouTube app bars.
class FrostedBar extends StatelessWidget {
  const FrostedBar({
    super.key,
    required this.child,
    this.sigmaX = 24,
    this.sigmaY = 24,
  });

  final Widget child;
  final double sigmaX;
  final double sigmaY;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: sigmaX, sigmaY: sigmaY),
        child: Container(
          decoration: BoxDecoration(
            color: dark
                ? C.dark1.withValues(alpha: 0.75)
                : C.light1.withValues(alpha: 0.8),
            border: Border(
              bottom: BorderSide(
                color: dark
                    ? C.dark4.withValues(alpha: 0.5)
                    : C.lightDivider.withValues(alpha: 0.5),
                width: 0.5,
              ),
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: child,
          ),
        ),
      ),
    );
  }
}
