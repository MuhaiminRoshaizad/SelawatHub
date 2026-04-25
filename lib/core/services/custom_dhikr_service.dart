import 'package:flutter/foundation.dart';
import 'package:selawathub/core/services/supabase_service.dart';
import 'package:selawathub/features/counter/models/dhikr.dart';

/// Manages user-defined custom dhikr (selawat/zikir that aren't in our
/// built-in list). Signed-in only — we persist to `user_custom_dhikr`.
/// Guests don't get this feature.
class CustomDhikrService {
  CustomDhikrService._();
  static final _db = SupabaseService.client;

  static List<Dhikr>? _cache;

  /// Returns the signed-in user's custom dhikr. Cached after the first
  /// successful load; call [invalidate] after create/delete.
  static Future<List<Dhikr>> list() async {
    if (_cache != null) return _cache!;
    final uid = SupabaseService.userId;
    if (uid == null) return const [];
    try {
      final rows = await _db
          .from('user_custom_dhikr')
          .select('dhikr_id, name, category')
          .eq('user_id', uid)
          .order('created_at', ascending: true);
      _cache = [
        for (final r in rows)
          Dhikr.custom(
            id: r['dhikr_id'] as String,
            name: r['name'] as String,
            category: (r['category'] as String) == 'selawat'
                ? DhikrCategory.selawat
                : DhikrCategory.zikir,
          ),
      ];
      return _cache!;
    } catch (e) {
      debugPrint('[CustomDhikrService] list error: $e');
      return const [];
    }
  }

  /// Create a new custom dhikr. Returns the inserted [Dhikr], or an
  /// existing one if the user already has one with the same slug.
  static Future<Dhikr?> create({
    required String name,
    required DhikrCategory category,
  }) async {
    final uid = SupabaseService.userId;
    if (uid == null) return null;
    final trimmed = name.trim();
    if (trimmed.isEmpty) return null;
    final dhikrId = Dhikr.slugify(trimmed);
    if (dhikrId == 'custom:') return null;
    try {
      await _db.from('user_custom_dhikr').upsert(
        {
          'user_id': uid,
          'dhikr_id': dhikrId,
          'name': trimmed,
          'category': category.name,
        },
        onConflict: 'user_id,dhikr_id',
      );
      final d = Dhikr.custom(id: dhikrId, name: trimmed, category: category);
      _cache = [...?_cache, if (!(_cache?.any((x) => x.id == dhikrId) ?? false)) d];
      return d;
    } catch (e) {
      debugPrint('[CustomDhikrService] create error: $e');
      return null;
    }
  }

  static void invalidate() => _cache = null;
}
