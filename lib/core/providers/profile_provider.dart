import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:selawathub/core/services/profile_service.dart';
import 'package:selawathub/core/services/supabase_service.dart';
import 'package:selawathub/core/providers/auth_provider.dart';

/// Profile data model.
class ProfileData {
  final String name;
  final String bio;
  final String? avatarUrl;
  final String email;
  final DateTime? memberSince;
  final int totalDhikr;
  final int streak;
  final bool streakActive;
  final int daysActive;

  const ProfileData({
    this.name = '',
    this.bio = '',
    this.avatarUrl,
    this.email = '',
    this.memberSince,
    this.totalDhikr = 0,
    this.streak = 0,
    this.streakActive = false,
    this.daysActive = 0,
  });
}

/// Fetches and caches profile data. Returns defaults for guests.
final profileProvider = FutureProvider<ProfileData>((ref) async {
  ref.watch(authStateProvider); // re-fetch on auth changes
  if (!SupabaseService.isAuthenticated) {
    return const ProfileData();
  }

  final profile = await ProfileService.getProfile();
  final stats = await ProfileService.getProfileStats();
  final user = SupabaseService.currentUser;

  return ProfileData(
    name: profile?['name'] ?? '',
    bio: profile?['bio'] ?? '',
    avatarUrl: profile?['avatar_url'],
    email: user?.email ?? '',
    memberSince: user?.createdAt != null
        ? DateTime.tryParse(user!.createdAt)
        : null,
    totalDhikr: (stats['total_dhikr'] as num?)?.toInt() ?? 0,
    streak: (stats['streak'] as num?)?.toInt() ?? 0,
    streakActive: (stats['streak_active'] as bool?) ?? false,
    daysActive: (stats['days_active'] as num?)?.toInt() ?? 0,
  );
});
