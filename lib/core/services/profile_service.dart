import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:selawathub/core/services/supabase_service.dart';

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

  /// Get profile stats: total dhikr count, streak, days active
  static Future<Map<String, int>> getProfileStats() async {
    final uid = SupabaseService.userId;
    if (uid == null) return {'total_dhikr': 0, 'streak': 0, 'days_active': 0};

    final rows = await _db
        .from('counter_sessions')
        .select('date, count')
        .eq('user_id', uid)
        .order('date', ascending: false);

    int total = 0;
    final activeDates = <String>{};
    for (final row in rows) {
      total += (row['count'] as int?) ?? 0;
      activeDates.add(row['date'] as String);
    }

    // Calculate streak
    int streak = 0;
    final today = DateTime.now();
    for (int i = 0; i < 365; i++) {
      final d = today.subtract(Duration(days: i));
      final key = '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
      if (activeDates.contains(key)) {
        streak++;
      } else if (i > 0) {
        break;
      }
    }

    return {
      'total_dhikr': total,
      'streak': streak,
      'days_active': activeDates.length,
    };
  }
}
