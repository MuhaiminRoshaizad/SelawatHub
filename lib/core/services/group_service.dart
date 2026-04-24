import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:selawathub/core/services/supabase_service.dart';

class GroupService {
  GroupService._();
  static final _db = SupabaseService.client;

  /// Create a new group. Current user becomes leader.
  static Future<Map<String, dynamic>?> createGroup({
    required String name,
    String description = '',
    int dailyGoal = 0,
  }) async {
    final uid = SupabaseService.userId;
    if (uid == null) return null;

    try {
      final code = await _generateUniqueCode();

      final group = await _db.from('groups').insert({
        'name': name,
        'description': description,
        'invite_code': code,
        'daily_goal': dailyGoal,
      }).select().single();

      // Add creator as leader
      await _db.from('group_members').insert({
        'group_id': group['id'],
        'user_id': uid,
        'role': 'leader',
      });

      return group;
    } catch (e) {
      debugPrint('[GroupService] createGroup error: $e');
      rethrow;
    }
  }

  /// Join a group by invite code. Returns group data or null if not found.
  static Future<Map<String, dynamic>?> joinGroup(String inviteCode) async {
    final uid = SupabaseService.userId;
    if (uid == null) return null;

    final group = await _db
        .from('groups')
        .select()
        .eq('invite_code', inviteCode.toUpperCase().trim())
        .maybeSingle();
    if (group == null) return null;

    // Check if already a member
    final existing = await _db
        .from('group_members')
        .select()
        .eq('group_id', group['id'])
        .eq('user_id', uid)
        .maybeSingle();
    if (existing != null) return group; // already in

    await _db.from('group_members').insert({
      'group_id': group['id'],
      'user_id': uid,
      'role': 'member',
    });

    return group;
  }

  /// Leave a group.
  static Future<void> leaveGroup(String groupId) async {
    final uid = SupabaseService.userId;
    if (uid == null) return;
    await _db.from('group_members').delete().eq('group_id', groupId).eq('user_id', uid);
  }

  /// Get the current user's group (first one found).
  /// Returns null if not in any group.
  static Future<Map<String, dynamic>?> getMyGroup() async {
    final uid = SupabaseService.userId;
    if (uid == null) return null;
    try {
      final membership = await _db
          .from('group_members')
          .select('group_id, role, groups(*)')
          .eq('user_id', uid)
          .maybeSingle();
      if (membership == null) return null;
      final group = membership['groups'] as Map<String, dynamic>;
      group['my_role'] = membership['role'];
      return group;
    } catch (e) {
      debugPrint('[GroupService] getMyGroup error: $e');
      return null;
    }
  }

  /// Get members of a group with their profiles and today's count.
  /// Uses an RPC function to avoid RLS recursion and N+1 queries.
  static Future<List<Map<String, dynamic>>> getGroupMembers(String groupId) async {
    final today = _todayStr();

    try {
      final result = await _db.rpc('get_group_members_with_counts', params: {
        'p_group_id': groupId,
        'p_date': today,
      });

      final members = (result as List).cast<Map<String, dynamic>>();
      final uid = SupabaseService.userId;

      return members.map((m) => {
        'user_id': m['user_id'],
        'role': m['role'],
        'name': m['name'] ?? 'Unknown',
        'avatar_url': m['avatar_url'],
        'today_count': (m['today_count'] as num?)?.toInt() ?? 0,
        'is_me': m['user_id'] == uid,
      }).toList()
        ..sort((a, b) => (b['today_count'] as int).compareTo(a['today_count'] as int));
    } catch (_) {
      // Fallback: fetch without counts if RPC doesn't exist yet
      final members = await _db
          .from('group_members')
          .select('user_id, role, profiles(name, avatar_url)')
          .eq('group_id', groupId);

      return members.map((m) {
        final profile = m['profiles'] as Map<String, dynamic>?;
        return {
          'user_id': m['user_id'],
          'role': m['role'],
          'name': profile?['name'] ?? 'Unknown',
          'avatar_url': profile?['avatar_url'],
          'today_count': 0,
          'is_me': m['user_id'] == SupabaseService.userId,
        };
      }).toList();
    }
  }

  /// Get members with their aggregated counts for an arbitrary date range.
  /// Used by the "Today / This Week / This Month" toggle so each period
  /// shows the correct per-member contribution (not just today's).
  ///
  /// Backed by the `get_group_members_with_period_counts(group_id, start, end)`
  /// Postgres RPC (see SQL migration). Inclusive on both bounds.
  static Future<List<Map<String, dynamic>>> getGroupMembersForPeriod(
    String groupId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final result = await _db.rpc(
        'get_group_members_with_period_counts',
        params: {
          'p_group_id': groupId,
          'p_start_date': _dateStr(startDate),
          'p_end_date': _dateStr(endDate),
        },
      );
      final members = (result as List).cast<Map<String, dynamic>>();
      final uid = SupabaseService.userId;
      final mapped = members.map((m) => {
        'user_id': m['user_id'],
        'role': m['role'],
        'name': m['name'] ?? 'Unknown',
        'avatar_url': m['avatar_url'],
        // Reuses the existing 'today_count' key so MemberTile stays agnostic
        // to which period it's rendering. The UI label above the list tells
        // the user what the period is.
        'today_count': (m['period_count'] as num?)?.toInt() ?? 0,
        'is_me': m['user_id'] == uid,
      }).toList()
        ..sort((a, b) =>
            (b['today_count'] as int).compareTo(a['today_count'] as int));
      return mapped;
    } catch (e) {
      debugPrint('[GroupService] getGroupMembersForPeriod error: $e');
      // Graceful fallback: return today's data so the list isn't empty.
      return getGroupMembers(groupId);
    }
  }

  /// Update group settings (name, description, daily_goal). Leader only.
  static Future<void> updateGroup(String groupId, {String? name, String? description, int? dailyGoal}) async {
    final updates = <String, dynamic>{};
    if (name != null) updates['name'] = name;
    if (description != null) updates['description'] = description;
    if (dailyGoal != null) updates['daily_goal'] = dailyGoal;
    if (updates.isEmpty) return;
    await _db.from('groups').update(updates).eq('id', groupId);
  }

  /// Update a member's role. Leader only.
  static Future<void> updateMemberRole(String groupId, String userId, String role) async {
    await _db.from('group_members').update({'role': role}).eq('group_id', groupId).eq('user_id', userId);
  }

  /// Remove a member from group. Leader only.
  static Future<void> removeMember(String groupId, String userId) async {
    await _db.from('group_members').delete().eq('group_id', groupId).eq('user_id', userId);
  }

  /// Generate a unique invite code.
  static Future<String> _generateUniqueCode() async {
    final rng = Random();
    while (true) {
      final code = 'SLWT-${rng.nextInt(10000).toString().padLeft(4, '0')}';
      final existing = await _db
          .from('groups')
          .select('id')
          .eq('invite_code', code)
          .maybeSingle();
      if (existing == null) return code;
    }
  }

  /// Get weekly and monthly totals for the group.
  /// Returns `{week: int, month: int}`.
  static Future<Map<String, int>> getGroupPeriodTotals(String groupId) async {
    try {
      final now = DateTime.now();
      final weekStart = now.subtract(Duration(days: now.weekday - 1));
      final monthStart = DateTime(now.year, now.month, 1);

      final result = await _db.rpc('get_group_period_totals', params: {
        'p_group_id': groupId,
        'p_week_start': _dateStr(weekStart),
        'p_month_start': _dateStr(monthStart),
        'p_end': _dateStr(now),
      });

      debugPrint('[GroupService] getGroupPeriodTotals raw result: $result (${result.runtimeType})');

      if (result is Map<String, dynamic>) {
        return {
          'week': (result['week_total'] as num?)?.toInt() ?? 0,
          'month': (result['month_total'] as num?)?.toInt() ?? 0,
        };
      }
      // If result is a list with one element (some RPC wrappers do this)
      if (result is List && result.isNotEmpty && result[0] is Map) {
        final row = result[0] as Map<String, dynamic>;
        return {
          'week': (row['week_total'] as num?)?.toInt() ?? 0,
          'month': (row['month_total'] as num?)?.toInt() ?? 0,
        };
      }
      return {'week': 0, 'month': 0};
    } catch (e) {
      debugPrint('[GroupService] getGroupPeriodTotals error: $e');
      return {'week': 0, 'month': 0};
    }
  }

  static String _dateStr(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  /// Get monthly totals for the group in a given year.
  /// Returns a list of 12 ints (one per month).
  static Future<List<int>> getGroupYearlyTotals(String groupId, int year) async {
    try {
      final startDate = '$year-01-01';
      final endDate = '$year-12-31';

      final rows = await _db
          .rpc('get_group_monthly_totals', params: {
        'p_group_id': groupId,
        'p_start_date': startDate,
        'p_end_date': endDate,
      });

      final monthly = List<int>.filled(12, 0);
      for (final row in (rows as List)) {
        final month = row['month'] as int;
        monthly[month - 1] = (row['total'] as num).toInt();
      }
      return monthly;
    } catch (e) {
      debugPrint('[GroupService] getGroupYearlyTotals error: $e');
      // Fallback: return zeros
      return List<int>.filled(12, 0);
    }
  }

  static String _todayStr() => _dateStr(DateTime.now());
}
