import 'package:flutter/foundation.dart';
import 'package:selawathub/core/services/stats_cache.dart';
import 'package:selawathub/core/services/supabase_service.dart';

class CounterService {
  CounterService._();
  static final _db = SupabaseService.client;

  /// Upsert a count for a dhikr on today's date.
  /// Uses ON CONFLICT to add to existing count.
  static Future<void> upsertCount({
    required String dhikrId,
    required String category,
    required int count,
  }) async {
    // Invalidate stats cache — counts changed so any derived view is stale.
    // Profile stats scalars refresh naturally the next time ProfilePage opens.
    StatsCache.invalidate();
    final uid = SupabaseService.userId;
    if (uid == null) return;
    final today = _todayStr();
    try {
      await _db.from('counter_sessions').upsert({
        'user_id': uid,
        'dhikr_id': dhikrId,
        'category': category,
        'count': count,
        'date': today,
      }, onConflict: 'user_id,dhikr_id,date');
    } catch (e) {
      debugPrint('[CounterService] upsertCount error: $e');
    }
  }

  /// Atomically add [amount] to today's count for [dhikrId] via the
  /// `add_to_count` Postgres RPC. Used by the "Add manually" sheet for
  /// users logging counts from a physical tasbih. Safe against races
  /// because the add is performed in a single SQL statement.
  static Future<void> addManualCount({
    required String dhikrId,
    required String category,
    required int amount,
  }) async {
    if (amount <= 0) return;
    StatsCache.invalidate();
    if (!SupabaseService.isAuthenticated) return;
    try {
      await _db.rpc('add_to_count', params: {
        'p_dhikr_id': dhikrId,
        'p_category': category,
        'p_amount': amount,
      });
    } catch (e) {
      debugPrint('[CounterService] addManualCount error: $e');
      rethrow;
    }
  }

  /// Get today's counts for all dhikr for current user.
  /// Returns a map of dhikrId to count.
  static Future<Map<String, int>> getTodayCounts() async {
    final uid = SupabaseService.userId;
    if (uid == null) return {};
    final today = _todayStr();
    final rows = await _db
        .from('counter_sessions')
        .select('dhikr_id, count')
        .eq('user_id', uid)
        .eq('date', today);
    final map = <String, int>{};
    for (final row in rows) {
      map[row['dhikr_id'] as String] = (row['count'] as int?) ?? 0;
    }
    return map;
  }

  /// Get all counter sessions for a date range (for stats/heatmap).
  /// Returns list of {dhikr_id, category, count, date}.
  static Future<List<Map<String, dynamic>>> getSessionsInRange({
    required DateTime start,
    required DateTime end,
  }) async {
    final uid = SupabaseService.userId;
    if (uid == null) return [];
    return await _db
        .from('counter_sessions')
        .select('dhikr_id, category, count, date')
        .eq('user_id', uid)
        .gte('date', _dateStr(start))
        .lte('date', _dateStr(end))
        .order('date', ascending: true);
  }

  /// Get total counts grouped by date for a user (for heatmap).
  static Future<Map<String, int>> getDailyTotals({
    required DateTime start,
    required DateTime end,
  }) async {
    final sessions = await getSessionsInRange(start: start, end: end);
    final totals = <String, int>{};
    for (final s in sessions) {
      final date = s['date'] as String;
      totals[date] = (totals[date] ?? 0) + ((s['count'] as int?) ?? 0);
    }
    return totals;
  }

  /// Get weekly breakdown (last 7 days) with selawat/zikir split.
  static Future<List<Map<String, dynamic>>> getWeeklyBreakdown() async {
    final now = DateTime.now();
    final start = now.subtract(const Duration(days: 6));
    final sessions = await getSessionsInRange(start: start, end: now);
    
    final result = <String, Map<String, int>>{};
    for (int i = 0; i < 7; i++) {
      final d = start.add(Duration(days: i));
      result[_dateStr(d)] = {'selawat': 0, 'zikir': 0};
    }
    for (final s in sessions) {
      final date = s['date'] as String;
      final cat = s['category'] as String;
      if (result.containsKey(date)) {
        result[date]![cat] = (result[date]![cat] ?? 0) + ((s['count'] as int?) ?? 0);
      }
    }
    return result.entries
        .map((e) => {'date': e.key, ...e.value})
        .toList();
  }

  static String _todayStr() => _dateStr(DateTime.now());
  static String _dateStr(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}
