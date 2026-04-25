import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:selawathub/core/animations/bounce_tap.dart';
import 'package:selawathub/core/animations/fade_in.dart';
import 'package:selawathub/core/constants.dart';
import 'package:selawathub/core/theme/colors.dart';
import 'package:selawathub/core/widgets/language_picker_sheet.dart';
import 'package:selawathub/features/auth/login_page.dart';
import 'package:selawathub/app/app_shell.dart';
import 'package:selawathub/l10n/generated/app_localizations.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final tt = Theme.of(context).textTheme;
    final l = AppL10n.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: S.page),
          child: Column(
            children: [
              // Top: language picker
              Align(
                alignment: Alignment.centerLeft,
                child: GestureDetector(
                  onTap: () => showLanguagePickerSheet(context),
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: S.s8, vertical: S.s12),
                    child: Icon(
                      CupertinoIcons.globe,
                      size: 22,
                      color: dark ? C.onDark2 : C.onLight2,
                    ),
                  ),
                ),
              ),
              const Spacer(flex: 3),

              // Icon
              FadeIn(
                child: Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    color: C.primaryGlow,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '🕌',
                      style: TextStyle(fontSize: 40),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: S.s32),

              // Title
              FadeIn(
                delay: const Duration(milliseconds: 100),
                child: Text(
                  'SelawatHub',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: dark ? C.onDark1 : C.onLight1,
                    letterSpacing: -1,
                  ),
                ),
              ),

              const SizedBox(height: S.s12),

              // Tagline
              FadeIn(
                delay: const Duration(milliseconds: 200),
                child: Text(
                  l.welcomeTagline,
                  style: tt.bodyLarge?.copyWith(
                    color: dark ? C.onDark2 : C.onLight2,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              const Spacer(flex: 4),

              // Sign in button
              FadeIn(
                delay: const Duration(milliseconds: 400),
                offset: const Offset(0, 30),
                child: SizedBox(
                  width: double.infinity,
                  child: BounceTap(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginPage()),
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: dark ? C.primarySoft : C.primary,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Center(
                        child: Text(
                          l.welcomeSignIn,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: C.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: S.s12),

              // Create account
              FadeIn(
                delay: const Duration(milliseconds: 500),
                offset: const Offset(0, 30),
                child: SizedBox(
                  width: double.infinity,
                  child: BounceTap(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginPage(isSignUp: true)),
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: dark ? C.darkDivider : C.lightDivider,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          l.welcomeCreateAccount,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: dark ? C.onDark1 : C.onLight1,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: S.s20),

              // Skip
              FadeIn(
                delay: const Duration(milliseconds: 600),
                child: GestureDetector(
                  onTap: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const AppShell(isGuest: true)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(S.s8),
                    child: Text(
                      l.welcomeContinueGuest,
                      style: tt.bodySmall?.copyWith(
                        color: dark ? C.onDark3 : C.onLight3,
                        decoration: TextDecoration.underline,
                        decorationColor: dark ? C.onDark3 : C.onLight3,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: S.s32),
            ],
          ),
        ),
      ),
    );
  }
}
