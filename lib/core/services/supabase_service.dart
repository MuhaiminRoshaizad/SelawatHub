import 'package:supabase_flutter/supabase_flutter.dart';

/// Centralized Supabase client access.
class SupabaseService {
  SupabaseService._();

  static SupabaseClient get client => Supabase.instance.client;
  static GoTrueClient get auth => client.auth;

  static Future<void> init() async {
    const url = String.fromEnvironment('SUPABASE_URL');
    const anonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
    assert(url.isNotEmpty, 'SUPABASE_URL not set. Use --dart-define=SUPABASE_URL=...');
    assert(anonKey.isNotEmpty, 'SUPABASE_ANON_KEY not set. Use --dart-define=SUPABASE_ANON_KEY=...');
    await Supabase.initialize(url: url, anonKey: anonKey);
  }

  /// Whether a user is currently authenticated.
  static bool get isAuthenticated => auth.currentSession != null;

  /// Current user or null.
  static User? get currentUser => auth.currentUser;

  /// Current user ID or null.
  static String? get userId => currentUser?.id;
}
