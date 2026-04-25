import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:selawathub/core/constants.dart';
import 'package:selawathub/core/theme/colors.dart';

// ─────────────────────────────────────────────────────────
//  Stats row — Total Dhikr / Streak / Days Active
// ─────────────────────────────────────────────────────────

class ProfileStatsRow extends StatelessWidget {
  const ProfileStatsRow({
    super.key,
    required this.accent,
    required this.totalDhikr,
    required this.streak,
    required this.daysActive,
    this.streakActive = true,
  });

  final Color accent;
  final String totalDhikr;
  final String streak;
  final String daysActive;
  final bool streakActive;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final mutedFlame = dark ? C.onDark3 : C.onLight3;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: S.s20),
      decoration: BoxDecoration(
        color: dark ? C.dark3 : C.light2,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: dark ? C.darkDivider : C.lightDivider,
          width: 0.5,
        ),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            StatItem(
              value: totalDhikr,
              label: 'Total Dhikr',
              icon: CupertinoIcons.heart_fill,
              iconColor: accent,
            ),
            VerticalDivider(
                width: 1,
                color: dark ? C.darkDivider : C.lightDivider),
            StatItem(
              value: streak,
              label: 'Day Streak',
              icon: streakActive
                  ? CupertinoIcons.flame_fill
                  : CupertinoIcons.flame,
              iconColor: streakActive ? C.gold : mutedFlame,
            ),
            VerticalDivider(
                width: 1,
                color: dark ? C.darkDivider : C.lightDivider),
            StatItem(
              value: daysActive,
              label: 'Days Active',
              icon: CupertinoIcons.calendar,
              iconColor: accent,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
//  Stat item with icon
// ─────────────────────────────────────────────────────────

class StatItem extends StatelessWidget {
  const StatItem({
    super.key,
    required this.value,
    required this.label,
    required this.icon,
    required this.iconColor,
  });
  final String value;
  final String label;
  final IconData icon;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: iconColor),
          const SizedBox(height: S.s6),
          Text(
            value,
            style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: S.s2),
          Text(label, style: tt.bodySmall),
        ],
      ),
    );
  }
}
