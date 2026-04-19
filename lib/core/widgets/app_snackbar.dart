import 'package:flutter/material.dart';
import 'package:selawathub/core/theme/colors.dart';

/// Shows a floating toast above everything (including bottom sheets).
void showAppSnackBar(BuildContext context, String message,
    {Color? backgroundColor}) {
  final overlay = Overlay.of(context, rootOverlay: true);
  late final OverlayEntry entry;
  entry = OverlayEntry(
    builder: (_) => _OverlayToast(
      message: message,
      backgroundColor: backgroundColor,
      onDismiss: () => entry.remove(),
    ),
  );
  overlay.insert(entry);
}

class _OverlayToast extends StatefulWidget {
  const _OverlayToast({
    required this.message,
    required this.onDismiss,
    this.backgroundColor,
  });
  final String message;
  final Color? backgroundColor;
  final VoidCallback onDismiss;

  @override
  State<_OverlayToast> createState() => _OverlayToastState();
}

class _OverlayToastState extends State<_OverlayToast>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<Offset> _slide;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
      reverseDuration: const Duration(milliseconds: 200),
    );
    _slide = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    _ctrl.forward();
    Future.delayed(const Duration(seconds: 3), _dismiss);
  }

  void _dismiss() {
    if (!mounted) return;
    _ctrl.reverse().then((_) {
      if (mounted) widget.onDismiss();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final bg = widget.backgroundColor ??
        (dark ? C.primarySoft : C.primary);
    final top = MediaQuery.of(context).padding.top + 12;

    return Positioned(
      top: top,
      left: 16,
      right: 16,
      child: SlideTransition(
        position: _slide,
        child: FadeTransition(
          opacity: _fade,
          child: GestureDetector(
            onTap: _dismiss,
            child: Material(
              color: Colors.transparent,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Text(
                  widget.message,
                  style: const TextStyle(
                    color: C.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
