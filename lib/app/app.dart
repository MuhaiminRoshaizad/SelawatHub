import 'dart:async';
import 'package:flutter/material.dart';
import 'package:selawathub/app/app_shell.dart';
import 'package:selawathub/core/services/auth_service.dart';
import 'package:selawathub/core/services/settings_service.dart';
import 'package:selawathub/core/services/supabase_service.dart';
import 'package:selawathub/core/theme/theme.dart';
import 'package:selawathub/features/auth/onboarding_page.dart';
import 'package:selawathub/features/auth/reset_password_page.dart';
import 'package:selawathub/features/auth/welcome_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SelawatHubApp extends StatefulWidget {
  const SelawatHubApp({super.key});

  // Global key so we can push screens imperatively (password-reset deep link,
  // sign-out navigation) from anywhere in the app.
  static final GlobalKey<NavigatorState> navKey = GlobalKey<NavigatorState>();

  @override
  State<SelawatHubApp> createState() => _SelawatHubAppState();
}

class _SelawatHubAppState extends State<SelawatHubApp> {
  late final ValueNotifier<ThemeMode> _themeMode;
  StreamSubscription<AuthState>? _authSub;

  static const _modeMap = [ThemeMode.system, ThemeMode.light, ThemeMode.dark];

  @override
  void initState() {
    super.initState();
    final saved = SettingsService.themeMode.clamp(0, 2);
    _themeMode = ValueNotifier<ThemeMode>(_modeMap[saved]);
    _themeMode.addListener(_persistTheme);

    // Only one reason to listen to the supabase auth stream: password-reset
    // email deep links. Sign-in / sign-out navigation is handled imperatively
    // at the callsite (login_page.dart / profile_page.dart) — the imperative
    // pattern is simpler, survives hot-reload, and isn't affected by the
    // gotrue 2.20+ regression that drops signedOut events.
    _authSub = AuthService.onAuthStateChange.listen((state) {
      if (state.event == AuthChangeEvent.passwordRecovery) {
        SelawatHubApp.navKey.currentState?.push(
          MaterialPageRoute(builder: (_) => const ResetPasswordPage()),
        );
      }
    });
  }

  void _persistTheme() {
    SettingsService.themeMode = _modeMap.indexOf(_themeMode.value);
  }

  @override
  void dispose() {
    _authSub?.cancel();
    _themeMode.removeListener(_persistTheme);
    _themeMode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ThemeController(
      notifier: _themeMode,
      child: ValueListenableBuilder<ThemeMode>(
        valueListenable: _themeMode,
        builder: (context, mode, child) => MaterialApp(
          navigatorKey: SelawatHubApp.navKey,
          title: 'SelawatHub',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: mode,
          themeAnimationDuration: const Duration(milliseconds: 400),
          themeAnimationCurve: Curves.easeInOutCubic,
          // Single decision at boot time: authed users go straight to the
          // app, new/signed-out users see onboarding. Transitions between
          // these two states are done imperatively via Navigator from the
          // login/logout handlers.
          home: SupabaseService.isAuthenticated
              ? const AppShell()
              : const OnboardingPage(),
          routes: {
            '/welcome': (_) => const WelcomePage(),
          },
        ),
      ),
    );
  }
}
