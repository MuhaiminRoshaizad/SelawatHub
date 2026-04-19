import 'package:flutter/material.dart';
import 'package:selawathub/core/animations/bounce_tap.dart';
import 'package:selawathub/core/animations/fade_in.dart';
import 'package:selawathub/core/constants.dart';
import 'package:selawathub/core/theme/colors.dart';
import 'package:selawathub/features/auth/welcome_page.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final _controller = PageController();
  int _page = 0;

  static const _slides = [
    (
      emoji: '🕌',
      title: 'Count Your Selawat',
      subtitle: 'Track your daily selawat and zikir\nwith a beautiful tasbih counter',
    ),
    (
      emoji: '📊',
      title: 'Track Your Progress',
      subtitle: 'See your streaks, heatmaps, and\ndetailed statistics over time',
    ),
    (
      emoji: '🤝',
      title: 'Grow Together',
      subtitle: 'Join groups, count together, and\nmotivate each other',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      final page = _controller.page?.round() ?? 0;
      if (page != _page) setState(() => _page = page);
    });
  }

  @override
  void dispose() {
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
    final isLast = _page == _slides.length - 1;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(top: S.s12, right: S.s16),
                child: GestureDetector(
                  onTap: _goToWelcome,
                  child: Padding(
                    padding: const EdgeInsets.all(S.s8),
                    child: Text(
                      'Skip',
                      style: tt.bodyMedium?.copyWith(
                        color: dark ? C.onDark3 : C.onLight3,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // PageView
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _slides.length,
                itemBuilder: (context, index) {
                  final slide = _slides[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: S.page),
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
                children: List.generate(_slides.length, (i) {
                  final active = i == _page;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: S.s4),
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
                  padding: const EdgeInsets.symmetric(horizontal: S.page),
                  child: SizedBox(
                    width: double.infinity,
                    child: BounceTap(
                      onTap: _goToWelcome,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: dark ? C.primarySoft : C.primary,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Center(
                          child: Text(
                            'Get Started',
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
    );
  }
}
