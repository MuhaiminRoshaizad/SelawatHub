import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:selawathub/core/services/group_service.dart';
import 'package:selawathub/core/services/supabase_service.dart';
import 'package:selawathub/core/providers/auth_provider.dart';

/// Current user's group data (null if not in any group).
final groupProvider = FutureProvider<Map<String, dynamic>?>((ref) async {
  ref.watch(authStateProvider);
  if (!SupabaseService.isAuthenticated) return null;
  return GroupService.getMyGroup();
});

/// Members of the current group.
final groupMembersProvider =
    FutureProvider.family<List<Map<String, dynamic>>, String>(
        (ref, groupId) async {
  if (!SupabaseService.isAuthenticated) return [];
  return GroupService.getGroupMembers(groupId);
});
