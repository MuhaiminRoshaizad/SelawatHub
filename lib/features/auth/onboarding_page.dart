import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:selawathub/core/animations/bounce_tap.dart';
import 'package:selawathub/core/animations/fade_in.dart';
import 'package:selawathub/core/constants.dart';
import 'package:selawathub/core/theme/colors.dart';
import 'package:selawathub/core/widgets/language_picker_sheet.dart';
import 'package:selawathub/features/auth/welcome_page.dart';
import 'package:selawathub/l10n/generated/app_localizations.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage>
    with SingleTickerProviderStateMixin {
  final _controller = PageController();
  int _page = 0;
  late final AnimationController _gradientCtrl;

  static const _emojis = ['🕌', '📊', '🤝'];

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      final page = _controller.page?.round() ?? 0;
      if (page != _page) setState(() => _page = page);
    });
    _gradientCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
  }

  @override
  void dispose() {
    _gradientCtrl.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _goToWelcome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const WelcomePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final tt = Theme.of(context).textTheme;
    final l = AppL10n.of(context);
    final slides = [
      (emoji: _emojis[0], title: l.onboardingTitle1, subtitle: l.onboardingSubtitle1),
      (emoji: _emojis[1], title: l.onboardingTitle2, subtitle: l.onboardingSubtitle2),
      (emoji: _emojis[2], title: l.onboardingTitle3, subtitle: l.onboardingSubtitle3),
    ];
    final isLast = _page == slides.length - 1;

    return Scaffold(
      body: Stack(
        children: [
          // ── Animated gradient background ──
          AnimatedBuilder(
            animation: _gradientCtrl,
            builder: (context, _) {
              final t = _gradientCtrl.value;
              final angle = t * 2 * math.pi;
              final cx = 0.5 + 0.3 * math.cos(angle);
              final cy = 0.5 + 0.3 * math.sin(angle);
              final cx2 = 0.5 + 0.3 * math.cos(angle + math.pi * 0.7);
              final cy2 = 0.5 + 0.3 * math.sin(angle + math.pi * 0.7);

              return Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment(cx * 2 - 1, cy * 2 - 1),
                    radius: 1.2,
                    colors: [
                      (dark ? C.primary : C.primarySoft)
                          .withValues(alpha: dark ? 0.15 : 0.10),
                      Colors.transparent,
                    ],
                  ),
                ),
                foregroundDecoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment(cx2 * 2 - 1, cy2 * 2 - 1),
                    radius: 1.0,
                    colors: [
                      (dark
                              ? const Color(0xFFC4A44E)
                              : const Color(0xFFD4B96E))
                          .withValues(alpha: dark ? 0.10 : 0.07),
                      Colors.transparent,
                    ],
                  ),
                ),
              );
            },
          ),

          // ── Content ──
          SafeArea(
            child: Column(
              children: [
                // Top row: language picker (left) + Skip (right)
                Padding(
                  padding: const EdgeInsets.fromLTRB(S.s8, S.s12, S.s8, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => showLanguagePickerSheet(context),
                        behavior: HitTestBehavior.opaque,
                        child: Padding(
                          padding: const EdgeInsets.all(S.s8),
                          child: Icon(
                            CupertinoIcons.globe,
                            size: 22,
                            color: dark ? C.onDark2 : C.onLight2,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: _goToWelcome,
                        child: Padding(
                          padding: const EdgeInsets.all(S.s8),
                          child: Text(
                            l.commonSkip,
                            style: tt.bodyMedium?.copyWith(
                              color: dark ? C.onDark3 : C.onLight3,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // PageView
                Expanded(
                  child: PageView.builder(
                    controller: _controller,
                    itemCount: slides.length,
                    itemBuilder: (context, index) {
                      final slide = slides[index];
                      return Padding(
                        padding:
                            const EdgeInsets.symmetric(horizontal: S.page),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            FadeIn(
                              child: Text(
                                slide.emoji,
                                style: const TextStyle(fontSize: 56),
                              ),
                            ),
                            const SizedBox(height: S.s32),
                            FadeIn(
                              delay: const Duration(milliseconds: 100),
                              child: Text(
                                slide.title,
                                style: tt.headlineLarge?.copyWith(
                                  color: dark ? C.onDark1 : C.onLight1,
                                  fontWeight: FontWeight.w800,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const SizedBox(height: S.s12),
                            FadeIn(
                              delay: const Duration(milliseconds: 200),
                              child: Text(
                                slide.subtitle,
                                style: tt.bodyMedium?.copyWith(
                                  color: dark ? C.onDark2 : C.onLight2,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                // Dot indicator
                Padding(
                  padding: const EdgeInsets.only(bottom: S.s24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(slides.length, (i) {
                      final active = i == _page;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin:
                            const EdgeInsets.symmetric(horizontal: S.s4),
                        width: active ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: active
                              ? C.primary
                              : (dark ? C.onDark3 : C.onLight3),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  ),
                ),

                // Get Started button (last slide only)
                if (isLast)
                  FadeIn(
                    offset: const Offset(0, 30),
                    child: Padding(
                      padding:
                          const EdgeInsets.symmetric(horizontal: S.page),
                      child: SizedBox(
                        width: double.infinity,
                        child: BounceTap(
                          onTap: _goToWelcome,
                          child: Container(
                            padding:
                                const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              color: dark ? C.primarySoft : C.primary,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Center(
                              child: Text(
                                l.commonGetStarted,
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
                  ),

                SizedBox(height: isLast ? S.s32 : S.s64),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
