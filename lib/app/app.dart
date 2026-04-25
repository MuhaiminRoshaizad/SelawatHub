import 'dart:async';
import 'package:flutter/material.dart';
import 'package:selawathub/app/app_shell.dart';
import 'package:selawathub/core/services/auth_service.dart';
import 'package:selawathub/core/services/settings_service.dart';
import 'package:selawathub/core/services/supabase_service.dart';
import 'package:selawathub/core/theme/theme.dart';
import 'package:selawathub/features/auth/login_page.dart';
import 'package:selawathub/features/auth/onboarding_page.dart';
import 'package:selawathub/features/auth/reset_password_page.dart';
import 'package:selawathub/features/auth/welcome_page.dart';
import 'package:selawathub/core/widgets/app_snackbar.dart';
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

    // Listen to the supabase auth stream for deep-link events:
    //   - `passwordRecovery`: user clicked the password-reset email link.
    //   - `signedIn`: user clicked the email-verification link (Supabase
    //     auto-creates a session). We force them to sign in manually so
    //     they can confirm credentials, matching the standard pattern used
    //     by most banking / consumer apps.
    //
    // Sign-in / sign-out triggered from inside the app sets
    // `AuthService.expectingManualAuth = true` so we ignore those events
    // here (the originating screen handles its own navigation).
    _authSub = AuthService.onAuthStateChange.listen((state) {
      if (state.event == AuthChangeEvent.passwordRecovery) {
        SelawatHubApp.navKey.currentState?.push(
          MaterialPageRoute(builder: (_) => const ResetPasswordPage()),
        );
        return;
      }
      if (state.event == AuthChangeEvent.signedIn) {
        if (AuthService.expectingManualAuth) {
          // This signedIn was triggered by an in-app form — consume the flag
          // and let the login page handle its own navigation.
          AuthService.expectingManualAuth = false;
          return;
        }
        _handleVerificationDeepLink(state.session?.user.email);
      }
    });
  }

  Future<void> _handleVerificationDeepLink(String? email) async {
    // Sign the just-auto-signed-in user out so they have to enter their
    // password — this confirms ownership of the device and avoids surprises
    // (e.g. someone else clicking the verification link on a shared phone).
    await AuthService.signOut();
    final nav = SelawatHubApp.navKey.currentState;
    if (nav == null) return;
    nav.pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => LoginPage(initialEmail: email),
      ),
      (_) => false,
    );
    // Toast after the new page is on screen so it lands in the right overlay.
    final ctx = SelawatHubApp.navKey.currentContext;
    if (ctx != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (ctx.mounted) {
          showAppSnackBar(ctx, 'Email verified · Please sign in to continue');
        }
      });
    }
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
