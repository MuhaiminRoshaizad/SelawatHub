import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:selawathub/core/animations/fade_in.dart';
import 'package:selawathub/core/constants.dart';
import 'package:selawathub/core/theme/colors.dart';
import 'package:selawathub/core/widgets/bead_circle.dart';
import 'package:selawathub/features/counter/counter_settings_page.dart';
import 'package:selawathub/features/counter/models/dhikr.dart';
import 'package:selawathub/features/counter/widgets/dhikr_selector_sheet.dart';
import 'package:selawathub/features/counter/widgets/digital_counter.dart';
import 'package:selawathub/features/counter/widgets/minimal_counter.dart';

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
  Dhikr _dhikr = Dhikr.selawatList.first;
  bool _arabicExpanded = false;
  bool _hapticEnabled = true;
  int _hapticIntensity = 1;
  int _counterStyle = 0;
  Map<String, int> _customTargets = {};
  int _colorThemeIndex = 0;

  late final AnimationController _pulse;

  Color get _accentColor => colorThemes[_colorThemeIndex].$2;

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

  int get _target => _customTargets[_dhikr.id] ?? _dhikr.defaultTarget;

  void _tap() {
    if (_hapticEnabled) {
      switch (_hapticIntensity) {
        case 0: HapticFeedback.lightImpact();
        case 1: HapticFeedback.mediumImpact();
        default: HapticFeedback.heavyImpact();
      }
    }
    _pulse.forward(from: 0);
    setState(() {
      _count++;
      _total++;
      if (_count >= _target) {
        _count = 0;
        _round++;
        if (_hapticEnabled) HapticFeedback.heavyImpact();
      }
    });
  }

  void _openSettings() async {
    final result = await Navigator.push<(bool, int, int, Map<String, int>, int)>(
      context,
      MaterialPageRoute(
        builder: (_) => CounterSettingsPage(
          hapticEnabled: _hapticEnabled,
          hapticIntensity: _hapticIntensity,
          counterStyle: _counterStyle,
          customTargets: Map.of(_customTargets),
          colorThemeIndex: _colorThemeIndex,
        ),
      ),
    );
    if (result != null) {
      setState(() {
        _hapticEnabled = result.$1;
        _hapticIntensity = result.$2;
        _counterStyle = result.$3;
        _customTargets = result.$4;
        _colorThemeIndex = result.$5;
      });
    }
  }

  void _openSelector() async {
    final picked = await DhikrSelectorSheet.show(context, _dhikr);
    if (picked != null && picked.id != _dhikr.id) {
      setState(() {
        _dhikr = picked;
        _count = 0;
        _round = 0;
        _total = 0;
        _arabicExpanded = false;
      });
    }
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

    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          // ── Compact dhikr selector ──
          FadeIn(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(S.page, S.s12, S.page, 0),
              child: Row(
                children: [
                  const SizedBox(width: 36),
                  Expanded(
                    child: GestureDetector(
                      onTap: _openSelector,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: Text(
                              _dhikr.name,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: dark ? C.onDark1 : C.onLight1,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: S.s8),
                          Icon(
                            CupertinoIcons.chevron_down,
                            size: 14,
                            color: dark ? C.onDark3 : C.onLight3,
                          ),
                        ],
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: _openSettings,
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: dark ? C.dark3 : C.light3,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        CupertinoIcons.gear,
                        size: 16,
                        color: dark ? C.onDark2 : C.onLight2,
                      ),
                    ),
                  ),
                ],
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
                  delay: const Duration(milliseconds: 100),
                  offset: const Offset(0, 30),
                  child: AnimatedBuilder(
                    animation: _pulse,
                    builder: (_, child) {
                      final scale = 1.0 + _pulse.value * 0.025;
                      return Transform.scale(scale: scale, child: child);
                    },
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final maxDim = constraints.maxWidth < constraints.maxHeight
                            ? constraints.maxWidth
                            : constraints.maxHeight;
                        final beadSize = (maxDim * 0.8).clamp(220.0, 320.0);
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
                            if (_counterStyle == 0)
                              BeadCircle(
                                total: _target,
                                filled: _count,
                                size: beadSize,
                                accentColor: _accentColor,
                              )
                            else if (_counterStyle == 1)
                              DigitalCounter(
                                total: _target,
                                filled: _count,
                                size: beadSize,
                                accentColor: _accentColor,
                              )
                            else
                              MinimalCounter(
                                total: _target,
                                filled: _count,
                                size: beadSize,
                                accentColor: _accentColor,
                              ),
                            // Center: count only
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
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
                                      fontSize: 60,
                                      fontWeight: FontWeight.w800,
                                      color: _accentColor,
                                      letterSpacing: -2,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: S.s4),
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

          // ── Arabic text (expandable only if truncated) ──
          FadeIn(
            delay: const Duration(milliseconds: 150),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: S.page),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                switchInCurve: Curves.easeOut,
                switchOutCurve: Curves.easeIn,
                transitionBuilder: (child, anim) => FadeTransition(
                  opacity: anim,
                  child: child,
                ),
                child: LayoutBuilder(
                  key: ValueKey(_dhikr.id),
                  builder: (context, constraints) {
                    final textSpan = TextSpan(
                      text: _dhikr.arabic,
                      style: TextStyle(
                        fontSize: 18,
                        fontFamily: 'serif',
                        height: 1.8,
                        color: dark ? C.onDark1 : C.onLight1,
                      ),
                    );
                    final tp = TextPainter(
                      text: textSpan,
                      maxLines: 3,
                      textDirection: TextDirection.rtl,
                    )..layout(maxWidth: constraints.maxWidth - S.s20 * 2);
                    final isOverflowing = tp.didExceedMaxLines;

                    return GestureDetector(
                      onTap: isOverflowing
                          ? () => setState(() => _arabicExpanded = !_arabicExpanded)
                          : null,
                      child: AnimatedSize(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: S.s20,
                            vertical: S.s12,
                          ),
                          decoration: BoxDecoration(
                            color: dark ? C.dark3 : C.light3,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            children: [
                              Text(
                                _dhikr.arabic,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontFamily: 'serif',
                                  height: 1.8,
                                  color: dark ? C.onDark1 : C.onLight1,
                                ),
                                textAlign: TextAlign.center,
                                textDirection: TextDirection.rtl,
                                maxLines: _arabicExpanded ? null : 3,
                                overflow: _arabicExpanded ? null : TextOverflow.ellipsis,
                              ),
                              if (isOverflowing) ...[
                                const SizedBox(height: S.s4),
                                AnimatedRotation(
                                  turns: _arabicExpanded ? 0.5 : 0,
                                  duration: const Duration(milliseconds: 200),
                                  child: Icon(
                                    CupertinoIcons.chevron_down,
                                    size: 12,
                                    color: dark ? C.onDark3 : C.onLight3,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),

          const SizedBox(height: S.s12),

          // ── Bottom stats bar ──
          FadeIn(
            delay: const Duration(milliseconds: 200),
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                S.page, 0, S.page,
                MediaQuery.of(context).padding.bottom + 56 + S.s16,
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
