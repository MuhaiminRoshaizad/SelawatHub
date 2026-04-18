import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:selawathub/core/animations/fade_in.dart';
import 'package:selawathub/core/constants.dart';
import 'package:selawathub/core/theme/colors.dart';

class HadithPage extends StatefulWidget {
  const HadithPage({super.key});

  @override
  State<HadithPage> createState() => _HadithPageState();
}

class _HadithPageState extends State<HadithPage> {
  int _index = 0;

  static const _hadiths = [
    (
      text: 'Whoever sends blessings upon me once, Allah will send blessings upon him tenfold.',
      source: 'Sahih Muslim 408',
      topic: 'Virtue of Selawat',
    ),
    (
      text: 'The closest people to me on the Day of Resurrection will be those who sent the most blessings upon me.',
      source: 'Sunan al-Tirmidhi 484',
      topic: 'Closeness to the Prophet ﷺ',
    ),
    (
      text: 'No people sit in a gathering in which they do not remember Allah and send blessings upon the Prophet ﷺ, except it will be a source of regret for them.',
      source: 'Sunan al-Tirmidhi 3380',
      topic: 'Gatherings of Remembrance',
    ),
    (
      text: 'Beautify your gatherings by sending blessings upon me, for your blessings upon me will be a light for you on the Day of Resurrection.',
      source: 'Al-Firdaws 921',
      topic: 'Light on Judgement Day',
    ),
  ];

  void _next() {
    if (_index < _hadiths.length - 1) setState(() => _index++);
  }

  void _prev() {
    if (_index > 0) setState(() => _index--);
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final tt = Theme.of(context).textTheme;
    final h = _hadiths[_index];

    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: S.page),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: S.s16),

            // Header
            FadeIn(
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Daily Hadith', style: tt.headlineLarge),
                        const SizedBox(height: S.s4),
                        Text('Reflections on selawat', style: tt.bodyMedium),
                      ],
                    ),
                  ),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: dark ? C.dark3 : C.light3,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      CupertinoIcons.share,
                      size: 16,
                      color: dark ? C.onDark2 : C.onLight2,
                    ),
                  ),
                ],
              ),
            ),

            const Spacer(flex: 2),

            // Hadith card
            FadeIn(
              delay: const Duration(milliseconds: 100),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _HadithCard(
                  key: ValueKey(_index),
                  hadith: h,
                  dark: dark,
                  tt: tt,
                ),
              ),
            ),

            const SizedBox(height: S.s32),

            // Navigation dots + arrows
            FadeIn(
              delay: const Duration(milliseconds: 200),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: _prev,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: dark ? C.dark3 : C.light3,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        CupertinoIcons.chevron_left,
                        size: 16,
                        color: _index > 0
                            ? (dark ? C.onDark1 : C.onLight1)
                            : (dark ? C.onDark3 : C.onLight3),
                      ),
                    ),
                  ),
                  const SizedBox(width: S.s20),
                  // Dots
                  ...List.generate(_hadiths.length, (i) {
                    final active = i == _index;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: active ? 20 : 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: active
                            ? (dark ? C.primarySoft : C.primary)
                            : (dark ? C.dark4 : C.lightDivider),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    );
                  }),
                  const SizedBox(width: S.s20),
                  GestureDetector(
                    onTap: _next,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: dark ? C.dark3 : C.light3,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        CupertinoIcons.chevron_right,
                        size: 16,
                        color: _index < _hadiths.length - 1
                            ? (dark ? C.onDark1 : C.onLight1)
                            : (dark ? C.onDark3 : C.onLight3),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const Spacer(flex: 3),
          ],
        ),
      ),
    );
  }
}

class _HadithCard extends StatelessWidget {
  const _HadithCard({
    super.key,
    required this.hadith,
    required this.dark,
    required this.tt,
  });

  final ({String text, String source, String topic}) hadith;
  final bool dark;
  final TextTheme tt;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(S.s32),
      decoration: BoxDecoration(
        color: dark
            ? C.primaryMuted.withValues(alpha: 0.12)
            : C.primary.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: dark
              ? C.primarySoft.withValues(alpha: 0.1)
              : C.primary.withValues(alpha: 0.08),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Topic label
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: C.primaryGlow,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              hadith.topic,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: dark ? C.primarySoft : C.primary,
              ),
            ),
          ),

          const SizedBox(height: S.s24),

          // Quote mark
          Text(
            '"',
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.w800,
              color: dark ? C.primarySoft.withValues(alpha: 0.3) : C.primary.withValues(alpha: 0.15),
              height: 0.6,
            ),
          ),

          const SizedBox(height: S.s8),

          // Hadith text
          Text(
            hadith.text,
            style: tt.bodyLarge?.copyWith(
              color: dark ? C.onDark1 : C.onLight1,
              fontStyle: FontStyle.italic,
              height: 1.7,
              fontSize: 17,
            ),
          ),

          const SizedBox(height: S.s20),

          // Source
          Text(
            '— ${hadith.source}',
            style: tt.bodySmall?.copyWith(
              color: dark ? C.onDark2 : C.onLight2,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
