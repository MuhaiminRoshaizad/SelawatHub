import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:selawathub/core/services/supabase_service.dart';

/// Handles authentication operations via Supabase Auth.
class AuthService {
  AuthService._();

  static final _auth = SupabaseService.auth;

  /// Sign up with email, password, and name.
  /// Name is stored in user metadata and auto-copied to profiles via trigger.
  static Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    return _auth.signUp(
      email: email,
      password: password,
      data: {'name': name},
      emailRedirectTo: 'io.supabase.selawathub://login-callback',
    );
  }

  /// Sign in with email and password.
  static Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return _auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  /// Sign out the current user.
  static Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Send a password reset email.
  static Future<void> sendPasswordReset(String email) async {
    await _auth.resetPasswordForEmail(
      email,
      redirectTo: 'io.supabase.selawathub://login-callback',
    );
  }

  /// Verify the current password by re-authenticating.
  /// Throws [AuthException] if the password is wrong.
  static Future<void> verifyPassword(String currentPassword) async {
    final email = _auth.currentUser?.email;
    if (email == null) throw AuthException('No user email found');
    await _auth.signInWithPassword(email: email, password: currentPassword);
  }

  /// Update the current user's password (must be authenticated).
  static Future<void> updatePassword(String newPassword) async {
    await _auth.updateUser(UserAttributes(password: newPassword));
  }

  /// Get the current user's email.
  static String? get currentEmail => _auth.currentUser?.email;

  /// Listen to auth state changes.
  static Stream<AuthState> get onAuthStateChange => _auth.onAuthStateChange;
}
