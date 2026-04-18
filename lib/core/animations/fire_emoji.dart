import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

enum StreakTier {
  dead,      // 0 days
  burning,   // 1–29 days
  blazing,   // 30–99 days
  legendary, // 100+ days
}

StreakTier streakTierFromDays(int days) {
  if (days <= 0) return StreakTier.dead;
  if (days < 30) return StreakTier.burning;
  if (days < 100) return StreakTier.blazing;
  return StreakTier.legendary;
}

/// Animated fire using Lottie, with tier-based visuals.
class FireEmoji extends StatelessWidget {
  const FireEmoji({super.key, this.size = 32, this.tier = StreakTier.burning});
  final double size;
  final StreakTier tier;

  String get _asset => switch (tier) {
    StreakTier.dead      => 'assets/animations/fire_dead.json',
    StreakTier.burning   => 'assets/animations/fire.json',
    StreakTier.blazing   => 'assets/animations/fire_blaze.json',
    StreakTier.legendary => 'assets/animations/fire_legendary.json',
  };

  /// Each Lottie file may have a different canvas size, so we scale
  /// non-burning tiers up to visually match.
  double get _scaledSize => switch (tier) {
    StreakTier.dead      => size * 1.4,
    StreakTier.burning   => size,
    StreakTier.blazing   => size * 1.4,
    StreakTier.legendary => size * 1.4,
  };

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: OverflowBox(
        maxWidth: _scaledSize,
        maxHeight: _scaledSize,
        child: Lottie.asset(
          _asset,
          fit: BoxFit.contain,
          repeat: true,
        ),
      ),
    );
  }
}
