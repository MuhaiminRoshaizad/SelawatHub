import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:selawathub/core/services/counter_service.dart';
import 'package:selawathub/core/services/settings_service.dart';
import 'package:selawathub/core/services/supabase_service.dart';
import 'package:selawathub/features/counter/models/dhikr.dart';

/// Today's counts per dhikr (Map of dhikrId → count).
final todayCountsProvider = FutureProvider<Map<String, int>>((ref) async {
  if (!SupabaseService.isAuthenticated) return {};
  return CounterService.getTodayCounts();
});

/// Counter settings from SharedPreferences.
class CounterSettings {
  final bool hapticEnabled;
  final int hapticIntensity;
  final int counterStyle;
  final int colorThemeIndex;
  final Map<String, int> customTargets;

  const CounterSettings({
    this.hapticEnabled = true,
    this.hapticIntensity = 1,
    this.counterStyle = 0,
    this.colorThemeIndex = 0,
    this.customTargets = const {},
  });
}

final counterSettingsProvider = Provider<CounterSettings>((ref) {
  return CounterSettings(
    hapticEnabled: SettingsService.hapticEnabled,
    hapticIntensity: SettingsService.hapticIntensity,
    counterStyle: SettingsService.counterStyle,
    colorThemeIndex: SettingsService.colorThemeIndex,
    customTargets: SettingsService.getAllCustomTargets(
      Dhikr.all.map((d) => d.id).toList(),
    ),
  );
});
