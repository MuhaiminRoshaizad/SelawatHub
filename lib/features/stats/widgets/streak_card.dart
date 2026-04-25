import 'package:flutter/material.dart';
import 'package:selawathub/core/animations/fire_emoji.dart';
import 'package:selawathub/core/constants.dart';
import 'package:selawathub/core/theme/colors.dart';
import 'package:selawathub/features/stats/stats_utils.dart';

class StreakCard extends StatelessWidget {
  const StreakCard({
    super.key,
    required this.dark,
    required this.tt,
    required this.streakDays,
    required this.todayTotal,
    required this.dailyGoal,
    this.streakActive = true,
    this.onGoalTap,
  });
  final bool dark;
  final TextTheme tt;
  final int streakDays;
  final int todayTotal;
  final int dailyGoal;
  final bool streakActive;
  final VoidCallback? onGoalTap;

  @override
  Widget build(BuildContext context) {
    // When today's goal isn't met yet we still show the existing streak
    // count (TikTok-style — it isn't lost until the day rolls over) but the
    // fire is shown as "off" until the user qualifies today.
    final liveTier = streakTierFromDays(streakDays);
    final tier = streakActive ? liveTier : StreakTier.dead;

    final String tierLabel;
    final String subtitle;
    if (streakDays == 0) {
      tierLabel = 'No Streak';
      subtitle = dailyGoal > 0
          ? 'Hit ${fmtNum(dailyGoal)} today to start your streak'
          : 'Start reciting today!';
    } else if (!streakActive) {
      tierLabel = '$streakDays Day Streak';
      subtitle = dailyGoal > 0
          ? 'Hit ${fmtNum(dailyGoal)} today to keep it alive'
          : 'Recite today to keep it alive';
    } else {
      tierLabel = switch (liveTier) {
        StreakTier.dead => '$streakDays Day Streak',
        StreakTier.burning => '$streakDays Day Streak',
        StreakTier.blazing => '$streakDays Day Streak 🔥',
        StreakTier.legendary => '$streakDays Day Streak ⚡',
      };
      subtitle = switch (liveTier) {
        StreakTier.dead => 'Keep it going!',
        StreakTier.burning => 'Keep it going!',
        StreakTier.blazing => 'You\'re on fire!',
        StreakTier.legendary => 'Legendary status!',
      };
    }

    final progress = dailyGoal > 0
        ? (todayTotal / dailyGoal).clamp(0.0, 1.0)
        : 0.0;

    return Container(
      padding: const EdgeInsets.all(S.s20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: dark ? [C.primaryMuted, C.dark3] : [C.primary, C.primarySoft],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            children: [
              FireEmoji(size: 36, tier: tier),
              const SizedBox(width: S.s12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tierLabel,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: C.white,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: C.white.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: S.s20),
          GestureDetector(
            onTap: onGoalTap,
            behavior: HitTestBehavior.opaque,
            child: Column(
              children: [
                Row(
                  children: [
                    Text(
                      'Today',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: C.white.withValues(alpha: 0.7),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${fmtNum(todayTotal)} / ${fmtNum(dailyGoal)}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: C.white,
                      ),
                    ),
                    if (onGoalTap != null) ...[
                      const SizedBox(width: 4),
                      Icon(
                        Icons.edit_rounded,
                        size: 12,
                        color: C.white.withValues(alpha: 0.6),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: S.s8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 6,
                    backgroundColor: C.white.withValues(alpha: 0.15),
                    valueColor: AlwaysStoppedAnimation(
                      C.white.withValues(alpha: 0.9),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
