import 'package:shared_preferences/shared_preferences.dart';

/// Persists counter settings locally via SharedPreferences.
class SettingsService {
  SettingsService._();

  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Keys
  static const _kHapticEnabled = 'haptic_enabled';
  static const _kHapticIntensity = 'haptic_intensity';
  static const _kCounterStyle = 'counter_style';
  static const _kColorThemeIndex = 'color_theme_index';
  static const _kThemeMode = 'theme_mode';
  static const _kCustomTargetsPrefix = 'custom_target_';

  static bool get hapticEnabled => _prefs?.getBool(_kHapticEnabled) ?? true;
  static set hapticEnabled(bool v) => _prefs?.setBool(_kHapticEnabled, v);

  static int get hapticIntensity => _prefs?.getInt(_kHapticIntensity) ?? 1;
  static set hapticIntensity(int v) => _prefs?.setInt(_kHapticIntensity, v);

  static int get counterStyle => _prefs?.getInt(_kCounterStyle) ?? 0;
  static set counterStyle(int v) => _prefs?.setInt(_kCounterStyle, v);

  static int get colorThemeIndex => _prefs?.getInt(_kColorThemeIndex) ?? 0;
  static set colorThemeIndex(int v) => _prefs?.setInt(_kColorThemeIndex, v);

  /// Theme mode: 0 = system, 1 = light, 2 = dark
  static int get themeMode => _prefs?.getInt(_kThemeMode) ?? 0;
  static set themeMode(int v) => _prefs?.setInt(_kThemeMode, v);

  /// Get custom target for a dhikr ID, or null if not set.
  static int? getCustomTarget(String dhikrId) =>
      _prefs?.getInt('$_kCustomTargetsPrefix$dhikrId');

  /// Set custom target for a dhikr ID.
  static void setCustomTarget(String dhikrId, int target) =>
      _prefs?.setInt('$_kCustomTargetsPrefix$dhikrId', target);

  /// Get all custom targets as a map of dhikrId to target.
  static Map<String, int> getAllCustomTargets(List<String> dhikrIds) {
    final map = <String, int>{};
    for (final id in dhikrIds) {
      final t = getCustomTarget(id);
      if (t != null) map[id] = t;
    }
    return map;
  }

  /// Save all custom targets from a map.
  static void saveAllCustomTargets(Map<String, int> targets) {
    for (final e in targets.entries) {
      setCustomTarget(e.key, e.value);
    }
  }

  // ── Local counter storage ──

  static String _dateStr(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  /// Saves a counter session locally.
  static void saveLocalCount(String dhikrId, String category, int count, String date) {
    _prefs?.setInt('counter_${dhikrId}_$date', count);
    _prefs?.setString('counter_cat_$dhikrId', category);
  }

  /// Returns locally stored count for a dhikr on a given date, or 0.
  static int getLocalCount(String dhikrId, String date) =>
      _prefs?.getInt('counter_${dhikrId}_$date') ?? 0;

  /// Returns a map of dhikrId → count for today from local storage.
  static Map<String, int> getLocalTodayCounts(List<String> dhikrIds) {
    final today = _dateStr(DateTime.now());
    final map = <String, int>{};
    for (final id in dhikrIds) {
      final count = _prefs?.getInt('counter_${id}_$today');
      if (count != null && count > 0) {
        map[id] = count;
      }
    }
    return map;
  }

  /// Returns local sessions in [start, end] range, same format as
  /// `CounterService.getSessionsInRange()`.
  static List<Map<String, dynamic>> getLocalSessionsInRange(
    List<String> dhikrIds,
    DateTime start,
    DateTime end,
  ) {
    final results = <Map<String, dynamic>>[];
    final days = end.difference(start).inDays + 1;
    for (int i = 0; i < days; i++) {
      final d = start.add(Duration(days: i));
      final dateStr = _dateStr(d);
      for (final dhikrId in dhikrIds) {
        final key = 'counter_${dhikrId}_$dateStr';
        final count = _prefs?.getInt(key);
        if (count != null && count > 0) {
          final category = _prefs?.getString('counter_cat_$dhikrId') ?? '';
          results.add({
            'dhikr_id': dhikrId,
            'category': category,
            'count': count,
            'date': dateStr,
          });
        }
      }
    }
    return results;
  }
}
