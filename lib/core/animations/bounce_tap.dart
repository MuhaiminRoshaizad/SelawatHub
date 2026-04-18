import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Press-down scale + spring-back animation for interactive elements.
class BounceTap extends StatefulWidget {
  const BounceTap({
    super.key,
    required this.child,
    this.onTap,
    this.scale = 0.95,
    this.haptic = false,
  });

  final Widget child;
  final VoidCallback? onTap;
  final double scale;
  final bool haptic;

  @override
  State<BounceTap> createState() => _BounceTapState();
}

class _BounceTapState extends State<BounceTap>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      reverseDuration: const Duration(milliseconds: 280),
    );
    _scale = Tween(begin: 1.0, end: widget.scale).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut, reverseCurve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        _ctrl.reverse();
        if (widget.haptic) HapticFeedback.lightImpact();
      },
      onTapCancel: () => _ctrl.reverse(),
      onTap: widget.onTap,
      behavior: HitTestBehavior.opaque,
      child: ScaleTransition(scale: _scale, child: widget.child),
    );
  }
}
