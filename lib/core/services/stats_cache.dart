/// In-memory, per-session cache for the Stats page.
///
/// The stats page loads 364 days of counter sessions on every visit,
/// which is cheap on the Supabase side but noticeable on tab switches.
/// This cache keeps the computed lists and nullifies on counter save so
/// the next stats open is instant while still showing fresh data.
///
/// We deliberately do NOT persist this to prefs — the data is derived
/// from `counter_sessions` which is the source of truth, and prefs
/// persistence would add a stale-data risk. In-memory is enough to make
/// tab switches feel instant.
class StatsCache {
  StatsCache._();

  static List<dynamic>? _heatmap;
  static List<dynamic>? _weeklyData;
  static List<dynamic>? _breakdown;
  static int _totalToday = 0;
  static DateTime? _cachedAt;

  static bool get hasData => _heatmap != null;

  /// True when the cache was populated today. Used by the stats page to
  /// decide whether to skip the skeleton on repeat visits.
  static bool get isFreshForToday {
    final t = _cachedAt;
    if (t == null) return false;
    final now = DateTime.now();
    return t.year == now.year && t.month == now.month && t.day == now.day;
  }

  static List<T> heatmap<T>() => (_heatmap ?? const []).cast<T>();
  static List<T> weeklyData<T>() => (_weeklyData ?? const []).cast<T>();
  static List<T> breakdown<T>() => (_breakdown ?? const []).cast<T>();
  static int get totalToday => _totalToday;

  static void store({
    required List<dynamic> heatmap,
    required List<dynamic> weeklyData,
    required List<dynamic> breakdown,
    required int totalToday,
  }) {
    _heatmap = heatmap;
    _weeklyData = weeklyData;
    _breakdown = breakdown;
    _totalToday = totalToday;
    _cachedAt = DateTime.now();
  }

  /// Invalidate the cache. Call this after each counter save so the
  /// stats page reflects new counts on the next visit.
  static void invalidate() {
    _heatmap = null;
    _weeklyData = null;
    _breakdown = null;
    _cachedAt = null;
  }
}
