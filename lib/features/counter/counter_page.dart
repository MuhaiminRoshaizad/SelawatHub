import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:selawathub/core/animations/fade_in.dart';
import 'package:selawathub/core/constants.dart';
import 'package:selawathub/core/theme/colors.dart';
import 'package:selawathub/core/widgets/bead_circle.dart';

class CounterPage extends StatefulWidget {
  const CounterPage({super.key});

  @override
  State<CounterPage> createState() => _CounterPageState();
}

class _CounterPageState extends State<CounterPage>
    with SingleTickerProviderStateMixin {
  int _count = 0;
  int _round = 0;
  int _total = 0;
  int _dhikr = 0;

  static const _dhikrList = [
    (ar: 'سُبْحَانَ ٱللَّٰهِ', en: 'Subhanallah', target: 33),
    (ar: 'ٱلْحَمْدُ لِلَّٰهِ', en: 'Alhamdulillah', target: 33),
    (ar: 'ٱللَّٰهُ أَكْبَرُ', en: 'Allahu Akbar', target: 34),
  ];

  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  int get _target => _dhikrList[_dhikr].target;

  void _tap() {
    HapticFeedback.lightImpact();
    _pulse.forward(from: 0);
    setState(() {
      _count++;
      _total++;
      if (_count >= _target) {
        _count = 0;
        _round++;
        HapticFeedback.mediumImpact();
      }
    });
  }

  void _reset() async {
    if (_total == 0) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset Session?'),
        content: const Text('This will clear your current session count.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Reset', style: TextStyle(color: C.error)),
          ),
        ],
      ),
    );
    if (ok == true) {
      setState(() {
        _count = 0;
        _round = 0;
        _total = 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final tt = Theme.of(context).textTheme;
    final d = _dhikrList[_dhikr];

    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          // ── Top bar: streak + daily progress ──
          FadeIn(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(S.page, S.s12, S.page, 0),
              child: Row(
                children: [
                  // Streak
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: S.s12, vertical: S.s6),
                    decoration: BoxDecoration(
                      color: C.goldGlow,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('🔥', style: TextStyle(fontSize: 14)),
                        const SizedBox(width: S.s4),
                        Text(
                          '19 days',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: C.gold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  // Daily progress
                  Text(
                    '1,240 / 2,000',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: dark ? C.onDark3 : C.onLight3,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: S.s8),

          // ── Daily progress bar ──
          FadeIn(
            delay: const Duration(milliseconds: 50),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: S.page),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: 0.62,
                  minHeight: 3,
                  backgroundColor: dark ? C.dark4 : C.lightDivider,
                  valueColor: AlwaysStoppedAnimation(dark ? C.primarySoft : C.primary),
                ),
              ),
            ),
          ),

          // ── Dhikr selector pills ──
          FadeIn(
            delay: const Duration(milliseconds: 100),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(S.s16, S.s20, S.s16, 0),
              child: Row(
                children: List.generate(3, (i) {
                  final sel = i == _dhikr;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () {
                        if (i != _dhikr) setState(() { _dhikr = i; _count = 0; });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.symmetric(horizontal: S.s4),
                        padding: const EdgeInsets.symmetric(vertical: S.s12),
                        decoration: BoxDecoration(
                          color: sel
                              ? (dark ? C.primarySoft : C.primary)
                              : C.transparent,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Center(
                          child: Text(
                            _dhikrList[i].en,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: sel ? FontWeight.w700 : FontWeight.w500,
                              color: sel
                                  ? C.white
                                  : (dark ? C.onDark3 : C.onLight3),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),

          // ── Bead circle + counter (tap area) ──
          Expanded(
            child: GestureDetector(
              onTap: _tap,
              behavior: HitTestBehavior.opaque,
              child: Center(
                child: FadeIn(
                  delay: const Duration(milliseconds: 150),
                  offset: const Offset(0, 30),
                  child: AnimatedBuilder(
                    animation: _pulse,
                    builder: (_, child) {
                      final scale = 1.0 + _pulse.value * 0.025;
                      return Transform.scale(scale: scale, child: child);
                    },
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final beadSize = constraints.maxWidth.clamp(220.0, 300.0);
                        return Stack(
                          alignment: Alignment.center,
                          children: [
                            // Ambient glow
                            Container(
                              width: beadSize * 0.6,
                              height: beadSize * 0.6,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: C.primaryGlow,
                                    blurRadius: 80,
                                    spreadRadius: 20,
                                  ),
                                ],
                              ),
                            ),
                            BeadCircle(
                              total: _target,
                              filled: _count,
                              size: beadSize,
                            ),
                            // Center content
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  d.ar,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: dark ? C.onDark2 : C.onLight2,
                                  ),
                                ),
                                const SizedBox(height: S.s8),
                                AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 150),
                                  transitionBuilder: (child, anim) =>
                                      FadeTransition(
                                    opacity: anim,
                                    child: SlideTransition(
                                      position: Tween(
                                        begin: const Offset(0, 0.3),
                                        end: Offset.zero,
                                      ).animate(anim),
                                      child: child,
                                    ),
                                  ),
                                  child: Text(
                                    '$_count',
                                    key: ValueKey(_count),
                                    style: TextStyle(
                                      fontSize: 52,
                                      fontWeight: FontWeight.w800,
                                      color: C.primarySoft,
                                      letterSpacing: -2,
                                    ),
                                  ),
                                ),
                                Text('of $_target', style: tt.bodySmall),
                              ],
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ── Bottom stats bar ──
          FadeIn(
            delay: const Duration(milliseconds: 200),
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                S.page, 0, S.page,
                MediaQuery.of(context).padding.bottom + S.s16,
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: S.s16, horizontal: S.s24),
                decoration: BoxDecoration(
                  color: dark ? C.dark3 : C.light3,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: IntrinsicHeight(
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('$_round', style: tt.titleLarge),
                            Text('Rounds', style: tt.bodySmall),
                          ],
                        ),
                      ),
                      VerticalDivider(
                        width: 1,
                        color: dark ? C.darkDivider : C.lightDivider,
                      ),
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('$_total', style: tt.titleLarge),
                            Text('Total', style: tt.bodySmall),
                          ],
                        ),
                      ),
                      VerticalDivider(
                        width: 1,
                        color: dark ? C.darkDivider : C.lightDivider,
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: _reset,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                CupertinoIcons.arrow_counterclockwise,
                                size: 18,
                                color: _total > 0
                                    ? C.error
                                    : (dark ? C.onDark3 : C.onLight3),
                              ),
                              const SizedBox(height: S.s2),
                              Text('Reset', style: tt.bodySmall),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
