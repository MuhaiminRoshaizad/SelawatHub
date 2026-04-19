import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:selawathub/core/services/supabase_service.dart';
import 'package:selawathub/core/services/auth_service.dart';

/// Stream of auth state changes.
final authStateProvider = StreamProvider<AuthState>((ref) {
  return AuthService.onAuthStateChange;
});

/// Whether the user is currently authenticated.
final isAuthenticatedProvider = Provider<bool>((ref) {
  return SupabaseService.isAuthenticated;
});

/// Current user or null.
final currentUserProvider = Provider<User?>((ref) {
  // Watch auth state to auto-update when user signs in/out
  ref.watch(authStateProvider);
  return SupabaseService.currentUser;
});
