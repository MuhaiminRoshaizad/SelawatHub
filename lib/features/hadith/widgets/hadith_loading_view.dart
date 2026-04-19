import 'package:flutter/material.dart';
import 'package:selawathub/core/constants.dart';
import 'package:selawathub/core/theme/colors.dart';

// ─────────────────────────────────────────────────────────
//  Loading skeleton
// ─────────────────────────────────────────────────────────

class HadithLoadingView extends StatelessWidget {
  const HadithLoadingView({super.key, required this.dark});
  final bool dark;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: S.page),
        child: ListView(
          children: [
            const SizedBox(height: S.s16),
            SkeletonBox(width: 120, height: 28, dark: dark),
            const SizedBox(height: S.s4),
            SkeletonBox(width: 180, height: 16, dark: dark),
            const SizedBox(height: S.s24),
            SkeletonBox(width: double.infinity, height: 200, dark: dark),
            const SizedBox(height: S.s12),
            SkeletonBox(width: double.infinity, height: 180, dark: dark),
            const SizedBox(height: S.s32),
            SkeletonBox(width: 140, height: 22, dark: dark),
            const SizedBox(height: S.s12),
            SkeletonBox(width: double.infinity, height: 120, dark: dark),
          ],
        ),
      ),
    );
  }
}

class SkeletonBox extends StatefulWidget {
  const SkeletonBox({
    super.key,
    required this.width,
    required this.height,
    required this.dark,
  });
  final double width;
  final double height;
  final bool dark;

  @override
  State<SkeletonBox> createState() => _SkeletonBoxState();
}

class _SkeletonBoxState extends State<SkeletonBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, _) {
        final opacity = 0.08 + _ctrl.value * 0.08;
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: (widget.dark ? C.onDark1 : C.onLight1)
                .withValues(alpha: opacity),
            borderRadius: BorderRadius.circular(12),
          ),
        );
      },
    );
  }
}
