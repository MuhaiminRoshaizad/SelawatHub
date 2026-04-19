import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:selawathub/core/animations/bounce_tap.dart';
import 'package:selawathub/core/constants.dart';
import 'package:selawathub/core/theme/colors.dart';

// ─────────────────────────────────────────────────────────
//  Info row (label + value)
// ─────────────────────────────────────────────────────────

class InfoRow extends StatelessWidget {
  const InfoRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final tt = Theme.of(context).textTheme;
    final accent = dark ? C.primarySoft : C.primary;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: S.s20, vertical: S.s16),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Icon(icon, size: 16, color: accent),
            ),
          ),
          const SizedBox(width: S.s12),
          Expanded(
            child: Text(
              label,
              style: tt.bodyMedium?.copyWith(
                color: dark ? C.onDark2 : C.onLight2,
              ),
            ),
          ),
          Text(
            value,
            style: tt.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: valueColor ?? (dark ? C.onDark1 : C.onLight1),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
//  Menu row (tappable with chevron)
// ─────────────────────────────────────────────────────────

class MenuRow extends StatelessWidget {
  const MenuRow({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.trailing,
    this.trailingWidget,
    this.isDestructive = false,
    this.compact = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final String? trailing;
  final Widget? trailingWidget;
  final bool isDestructive;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final tt = Theme.of(context).textTheme;
    final accent = dark ? C.primarySoft : C.primary;

    if (compact) {
      final color = isDestructive ? C.error : (dark ? C.onDark1 : C.onLight1);
      final iconColor =
          isDestructive ? C.error : (dark ? C.onDark2 : C.onLight2);
      return BounceTap(
        onTap: onTap,
        child: Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: S.s16, vertical: S.s12),
          child: Row(
            children: [
              Icon(icon, size: 18, color: iconColor),
              const SizedBox(width: S.s12),
              Expanded(
                child: Text(
                  label,
                  style: tt.bodyMedium?.copyWith(color: color),
                ),
              ),
              ?trailingWidget,
              if (!isDestructive && trailingWidget == null)
                Icon(
                  CupertinoIcons.chevron_right,
                  size: 14,
                  color: dark ? C.onDark3 : C.onLight3,
                ),
            ],
          ),
        ),
      );
    }

    return BounceTap(
      onTap: onTap,
      child: Padding(
        padding:
            const EdgeInsets.symmetric(horizontal: S.s20, vertical: S.s16),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Icon(icon, size: 16, color: accent),
              ),
            ),
            const SizedBox(width: S.s12),
            Expanded(
              child: Text(label, style: tt.titleSmall),
            ),
            if (trailing != null) ...[
              Text(
                trailing!,
                style: tt.bodySmall?.copyWith(
                  color: dark ? C.onDark3 : C.onLight3,
                ),
              ),
              const SizedBox(width: S.s4),
            ],
            if (trailingWidget != null) ...[
              trailingWidget!,
              const SizedBox(width: S.s4),
            ],
            if (!isDestructive)
              Icon(
                CupertinoIcons.chevron_right,
                size: 14,
                color: dark ? C.onDark3 : C.onLight3,
              ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
//  Toggle row (switch)
// ─────────────────────────────────────────────────────────

class ToggleRow extends StatelessWidget {
  const ToggleRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final tt = Theme.of(context).textTheme;
    final accent = dark ? C.primarySoft : C.primary;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: S.s20, vertical: S.s8),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Icon(icon, size: 16, color: accent),
            ),
          ),
          const SizedBox(width: S.s12),
          Expanded(child: Text(label, style: tt.titleSmall)),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeTrackColor: accent.withValues(alpha: 0.4),
            activeThumbColor: accent,
          ),
        ],
      ),
    );
  }
}
