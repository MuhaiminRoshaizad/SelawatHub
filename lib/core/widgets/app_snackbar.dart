import 'package:flutter/material.dart';
import 'package:selawathub/core/theme/colors.dart';

/// Shows a floating toast above everything (including bottom sheets).
///
/// If [actionLabel] and [onAction] are provided, a tappable label is
/// rendered on the right of the toast and the auto-dismiss timer is
/// extended to 6 seconds to give the user time to react.
void showAppSnackBar(
  BuildContext context,
  String message, {
  Color? backgroundColor,
  String? actionLabel,
  VoidCallback? onAction,
}) {
  final overlay = Overlay.of(context, rootOverlay: true);
  late final OverlayEntry entry;
  entry = OverlayEntry(
    builder: (_) => _OverlayToast(
      message: message,
      backgroundColor: backgroundColor,
      actionLabel: actionLabel,
      onAction: onAction,
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
    this.actionLabel,
    this.onAction,
  });
  final String message;
  final Color? backgroundColor;
  final String? actionLabel;
  final VoidCallback? onAction;
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
    final hold = widget.actionLabel != null
        ? const Duration(seconds: 6)
        : const Duration(seconds: 3);
    Future.delayed(hold, _dismiss);
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
    final hasAction = widget.actionLabel != null && widget.onAction != null;

    return Positioned(
      top: top,
      left: 16,
      right: 16,
      child: SlideTransition(
        position: _slide,
        child: FadeTransition(
          opacity: _fade,
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: EdgeInsets.only(
                left: 16,
                right: hasAction ? 6 : 16,
                top: 14,
                bottom: 14,
              ),
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
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: _dismiss,
                      behavior: HitTestBehavior.opaque,
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
                  if (hasAction) ...[
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: () {
                        widget.onAction!();
                        _dismiss();
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        child: Text(
                          widget.actionLabel!.toUpperCase(),
                          style: const TextStyle(
                            color: C.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
