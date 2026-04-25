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
  static const _kSoundEnabled = 'sound_enabled';
  static const _kSoundStyle = 'sound_style';
  static const _kHapticHintShown = 'haptic_hint_shown';
  static const _kCounterStyle = 'counter_style';
  static const _kColorThemeIndex = 'color_theme_index';
  static const _kThemeMode = 'theme_mode';
  static const _kCustomTargetsPrefix = 'custom_target_';

  static bool get hapticEnabled => _prefs?.getBool(_kHapticEnabled) ?? true;
  static set hapticEnabled(bool v) => _prefs?.setBool(_kHapticEnabled, v);

  static int get hapticIntensity => _prefs?.getInt(_kHapticIntensity) ?? 1;
  static set hapticIntensity(int v) => _prefs?.setInt(_kHapticIntensity, v);

  /// Tick sound on each tap. Off by default — most users prefer haptic only.
  /// Useful as a fallback when the OS-level vibration toggle is disabled,
  /// since the audio plays via the media channel and bypasses the system
  /// "Touch sounds" toggle on Android.
  static bool get soundEnabled => _prefs?.getBool(_kSoundEnabled) ?? false;
  static set soundEnabled(bool v) => _prefs?.setBool(_kSoundEnabled, v);

  /// 0 = light click, 1 = wood click, 2 = soft tap.
  static int get soundStyle => _prefs?.getInt(_kSoundStyle) ?? 0;
  static set soundStyle(int v) => _prefs?.setInt(_kSoundStyle, v);

  /// Tracks whether we've shown the one-time "haptics not buzzing?" nudge.
  static bool get hapticHintShown => _prefs?.getBool(_kHapticHintShown) ?? false;
  static set hapticHintShown(bool v) => _prefs?.setBool(_kHapticHintShown, v);

  static int get counterStyle => _prefs?.getInt(_kCounterStyle) ?? 0;
  static set counterStyle(int v) => _prefs?.setInt(_kCounterStyle, v);

  static int get colorThemeIndex => _prefs?.getInt(_kColorThemeIndex) ?? 0;
  static set colorThemeIndex(int v) => _prefs?.setInt(_kColorThemeIndex, v);

  static const _kDailyGoal = 'daily_goal';

  /// Theme mode: 0 = system, 1 = light, 2 = dark
  static int get themeMode => _prefs?.getInt(_kThemeMode) ?? 0;
  static set themeMode(int v) => _prefs?.setInt(_kThemeMode, v);

  /// Daily goal for stats progress bar (default 500).
  /// Also used as the streak threshold: a day only counts toward the
  /// current/best streak if the user hits this goal.
  static int get dailyGoal => _prefs?.getInt(_kDailyGoal) ?? 500;
  static set dailyGoal(int v) => _prefs?.setInt(_kDailyGoal, v);

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

  // ── Cached profile (stale-while-revalidate) ──

  static const _kCachedName = 'cached_profile_name';
  static const _kCachedBio = 'cached_profile_bio';
  static const _kCachedAvatarUrl = 'cached_profile_avatar_url';
  static const _kCachedEmail = 'cached_profile_email';
  static const _kCachedTotalDhikr = 'cached_profile_total_dhikr';
  static const _kCachedStreak = 'cached_profile_streak';
  static const _kCachedStreakActive = 'cached_profile_streak_active';
  static const _kCachedDaysActive = 'cached_profile_days_active';
  static const _kCachedProfileUserId = 'cached_profile_user_id';

  /// Returns cached profile for [userId] or null if none cached / different user.
  /// Lets the profile page render real data on first build without waiting
  /// for a network round-trip.
  static Map<String, dynamic>? getCachedProfile(String? userId) {
    if (_prefs == null || userId == null) return null;
    if (_prefs!.getString(_kCachedProfileUserId) != userId) return null;
    return {
      'name': _prefs!.getString(_kCachedName) ?? '',
      'bio': _prefs!.getString(_kCachedBio) ?? '',
      'avatar_url': _prefs!.getString(_kCachedAvatarUrl),
      'email': _prefs!.getString(_kCachedEmail) ?? '',
      'total_dhikr': _prefs!.getInt(_kCachedTotalDhikr) ?? 0,
      'streak': _prefs!.getInt(_kCachedStreak) ?? 0,
      'streak_active': _prefs!.getBool(_kCachedStreakActive) ?? false,
      'days_active': _prefs!.getInt(_kCachedDaysActive) ?? 0,
    };
  }

  static void setCachedProfile({
    required String userId,
    String? name,
    String? bio,
    String? avatarUrl,
    String? email,
    int? totalDhikr,
    int? streak,
    bool? streakActive,
    int? daysActive,
  }) {
    final p = _prefs;
    if (p == null) return;
    p.setString(_kCachedProfileUserId, userId);
    if (name != null) p.setString(_kCachedName, name);
    if (bio != null) p.setString(_kCachedBio, bio);
    if (avatarUrl != null) {
      p.setString(_kCachedAvatarUrl, avatarUrl);
    } else {
      p.remove(_kCachedAvatarUrl);
    }
    if (email != null) p.setString(_kCachedEmail, email);
    if (totalDhikr != null) p.setInt(_kCachedTotalDhikr, totalDhikr);
    if (streak != null) p.setInt(_kCachedStreak, streak);
    if (streakActive != null) p.setBool(_kCachedStreakActive, streakActive);
    if (daysActive != null) p.setInt(_kCachedDaysActive, daysActive);
  }

  /// Clears the cached profile — called on sign-out so the next user
  /// doesn't briefly see the previous user's data.
  static void clearCachedProfile() {
    final p = _prefs;
    if (p == null) return;
    p.remove(_kCachedProfileUserId);
    p.remove(_kCachedName);
    p.remove(_kCachedBio);
    p.remove(_kCachedAvatarUrl);
    p.remove(_kCachedEmail);
    p.remove(_kCachedTotalDhikr);
    p.remove(_kCachedStreak);
    p.remove(_kCachedStreakActive);
    p.remove(_kCachedDaysActive);
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
