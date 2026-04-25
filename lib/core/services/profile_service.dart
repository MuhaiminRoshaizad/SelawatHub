import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:selawathub/core/services/settings_service.dart';
import 'package:selawathub/core/services/supabase_service.dart';
import 'package:selawathub/core/utils/streak_utils.dart';

class ProfileService {
  ProfileService._();
  static final _db = SupabaseService.client;

  /// Fetch current user's profile. Creates one if it doesn't exist yet.
  static Future<Map<String, dynamic>?> getProfile() async {
    final uid = SupabaseService.userId;
    if (uid == null) return null;
    final res = await _db.from('profiles').select().eq('id', uid).maybeSingle();
    if (res != null) return res;

    // Profile row missing — create it from auth metadata
    final user = SupabaseService.currentUser;
    final name = user?.userMetadata?['name'] as String? ?? '';
    try {
      final created = await _db.from('profiles').insert({
        'id': uid,
        'name': name,
      }).select().single();
      return created;
    } catch (_) {
      // Insert may fail if trigger created it concurrently
      return await _db.from('profiles').select().eq('id', uid).maybeSingle();
    }
  }

  /// Update profile fields (name, bio)
  static Future<void> updateProfile({String? name, String? bio}) async {
    final uid = SupabaseService.userId;
    if (uid == null) return;
    final updates = <String, dynamic>{};
    if (name != null) updates['name'] = name;
    if (bio != null) updates['bio'] = bio;
    if (updates.isEmpty) return;
    await _db.from('profiles').update(updates).eq('id', uid);
  }

  /// Upload avatar image and update profile avatar_url.
  /// Returns the public URL of the uploaded avatar.
  static Future<String?> uploadAvatar(List<int> bytes, String fileExt) async {
    final uid = SupabaseService.userId;
    if (uid == null) return null;
    final path = '$uid/avatar.$fileExt';
    await _db.storage.from('avatars').uploadBinary(
      path,
      Uint8List.fromList(bytes),
      fileOptions: const FileOptions(upsert: true),
    );
    final url = _db.storage.from('avatars').getPublicUrl(path);
    await _db.from('profiles').update({'avatar_url': url}).eq('id', uid);
    return url;
  }

  /// Get avatar public URL for a user
  static String? getAvatarUrl(String userId) {
    // We'll use the URL stored in profile, this is just a helper
    return null;
  }

  /// Get profile stats: total dhikr count, streak, days active.
  ///
  /// Streak is computed using the shared [computeStreak] utility so that the
  /// Profile page and the Stats page always agree. Includes a `streak_active`
  /// flag indicating whether today's daily goal has already been met.
  static Future<Map<String, dynamic>> getProfileStats() async {
    final uid = SupabaseService.userId;
    if (uid == null) {
      return {
        'total_dhikr': 0,
        'streak': 0,
        'streak_active': false,
        'days_active': 0,
      };
    }

    final rows = await _db
        .from('counter_sessions')
        .select('date, count')
        .eq('user_id', uid)
        .order('date', ascending: false);

    int total = 0;
    final dailyTotals = <String, int>{};
    for (final row in rows) {
      final c = (row['count'] as int?) ?? 0;
      final date = row['date'] as String;
      total += c;
      dailyTotals[date] = (dailyTotals[date] ?? 0) + c;
    }

    final goal = SettingsService.dailyGoal;
    final result = computeStreak(
      dailyTotals: dailyTotals,
      dailyGoal: goal,
      today: DateTime.now(),
    );

    final activeDays = dailyTotals.values.where((v) => v > 0).length;

    return {
      'total_dhikr': total,
      'streak': result.days,
      'streak_active': result.todayMet,
      'days_active': activeDays,
    };
  }
}
