import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:selawathub/core/animations/fade_in.dart';
import 'package:selawathub/core/constants.dart';
import 'package:selawathub/core/services/counter_service.dart';
import 'package:selawathub/core/services/custom_dhikr_service.dart';
import 'package:selawathub/core/services/settings_service.dart';
import 'package:selawathub/core/services/supabase_service.dart';
import 'package:selawathub/core/theme/colors.dart';
import 'package:selawathub/core/widgets/app_snackbar.dart';
import 'package:selawathub/core/widgets/bead_circle.dart';
import 'package:selawathub/features/counter/counter_settings_page.dart';
import 'package:selawathub/features/counter/models/dhikr.dart';
import 'package:selawathub/features/counter/widgets/dhikr_selector_sheet.dart';
import 'package:selawathub/features/counter/widgets/digital_counter.dart';
import 'package:selawathub/features/counter/widgets/manual_count_sheet.dart';
import 'package:selawathub/features/counter/widgets/minimal_counter.dart';
import 'package:selawathub/features/counter/widgets/today_log_sheet.dart';

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

  Map<String, int> _todayCounts = {};
  Timer? _saveTimer;
  int _tapsSinceLastSave = 0;

  late final AnimationController _pulse;

  Color get _accentColor => colorThemes[_colorThemeIndex].$2;

  @override
  void initState() {
    super.initState();
    // Read all UI settings synchronously BEFORE the first build so we never
    // flash the default style/color to the user. SharedPreferences is already
    // primed in main.dart, so these getters are non-blocking.
    _hapticEnabled = SettingsService.hapticEnabled;
    _hapticIntensity = SettingsService.hapticIntensity;
    _counterStyle = SettingsService.counterStyle;
    _colorThemeIndex = SettingsService.colorThemeIndex;
    _customTargets = SettingsService.getAllCustomTargets(
      Dhikr.all.map((d) => d.id).toList(),
    );

    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _loadCounts();
  }

  /// Loads today's per-dhikr counts. Kept separate from the sync settings
  /// read above because Supabase IO is genuinely async.
  Future<void> _loadCounts() async {
    Map<String, int> todayCounts;
    if (SupabaseService.isAuthenticated) {
      todayCounts = await CounterService.getTodayCounts();
    } else {
      todayCounts = SettingsService.getLocalTodayCounts(
        Dhikr.all.map((d) => d.id).toList(),
      );
    }

    if (!mounted) return;
    setState(() {
      _todayCounts = todayCounts;
      _total = _todayCounts[_dhikr.id] ?? 0;
    });
  }

  void _scheduleSave() {
    _saveTimer?.cancel();
    _saveTimer = Timer(const Duration(seconds: 2), _persistCount);
  }

  void _persistCount() {
    _tapsSinceLastSave = 0;
    // Always save locally
    final now = DateTime.now();
    final today = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    SettingsService.saveLocalCount(_dhikr.id, _dhikr.category.name, _total, today);
    // Also save to Supabase if authenticated
    if (!SupabaseService.isAuthenticated) return;
    CounterService.upsertCount(
      dhikrId: _dhikr.id,
      category: _dhikr.category.name,
      count: _total,
    );
  }

  @override
  void dispose() {
    _saveTimer?.cancel();
    _persistCount();
    _pulse.dispose();
    super.dispose();
  }

  int get _target => _customTargets[_dhikr.id] ?? _dhikr.defaultTarget;

  /// Safely triggers haptic feedback. Wraps `HapticFeedback` calls in a
  /// try/catch so that platforms that disallow haptics (web, desktop, or
  /// certain Android configurations) don't crash the tap handler.
  ///
  /// intensity: 0 = light, 1 = medium, 2+ = heavy.
  void _triggerHaptic(int intensity) {
    if (!_hapticEnabled) return;
    try {
      switch (intensity) {
        case 0:
          HapticFeedback.lightImpact();
        case 1:
          HapticFeedback.mediumImpact();
        default:
          HapticFeedback.heavyImpact();
      }
    } catch (_) {
      // Silently ignore — the OS-level vibration toggle and platform support
      // decide whether anything actually fires.
    }
  }

  void _tap() {
    // Haptic is best-effort. On Android the OS silently no-ops if the user
    // has disabled vibration system-wide (e.g. Pixel vibration toggle), so
    // we just guard against unexpected platform exceptions.
    _triggerHaptic(_hapticIntensity);
    _pulse.forward(from: 0);
    setState(() {
      _count++;
      _total++;
      if (_count >= _target) {
        _count = 0;
        _round++;
        _triggerHaptic(2); // heavy on round completion
      }
    });
    _todayCounts[_dhikr.id] = _total;
    _tapsSinceLastSave++;
    if (_tapsSinceLastSave >= 5) {
      _saveTimer?.cancel();
      _persistCount();
    } else {
      _scheduleSave();
    }
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
      SettingsService.hapticEnabled = _hapticEnabled;
      SettingsService.hapticIntensity = _hapticIntensity;
      SettingsService.counterStyle = _counterStyle;
      SettingsService.colorThemeIndex = _colorThemeIndex;
      SettingsService.saveAllCustomTargets(_customTargets);
    }
  }

  void _openSelector() async {
    final picked = await DhikrSelectorSheet.show(context, _dhikr);
    if (picked != null && picked.id != _dhikr.id) {
      _saveTimer?.cancel();
      _persistCount();
      setState(() {
        _dhikr = picked;
        _count = 0;
        _round = 0;
        _total = _todayCounts[picked.id] ?? 0;
        _arabicExpanded = false;
      });
    }
  }

  Future<void> _openManualAdd() async {
    final result = await ManualCountSheet.show(
      context,
      _dhikr,
      onOpenTodayLog: _openTodayLog,
    );
    if (result == null || result.amount == 0) return;
    await _applyManualAdjust(result.dhikr, result.amount, allowUndo: true);
  }

  /// Applies a signed manual adjustment (positive = add, negative = subtract)
  /// against [picked] and persists it. When [allowUndo] is true, the success
  /// toast offers an Undo action that reverses the change by calling this
  /// method again with the inverted delta.
  Future<void> _applyManualAdjust(
    Dhikr picked,
    int delta, {
    bool allowUndo = false,
  }) async {
    if (delta == 0) return;
    final isCurrent = picked.id == _dhikr.id;

    _saveTimer?.cancel();

    final prevTotalForPicked = _todayCounts[picked.id] ?? 0;
    // Clamp at 0 — we don't allow negative daily totals.
    final newTotalForPicked = (prevTotalForPicked + delta).clamp(0, 1 << 31);
    final effectiveDelta = newTotalForPicked - prevTotalForPicked;
    if (effectiveDelta == 0) {
      if (mounted) {
        showAppSnackBar(
          context,
          "Can't subtract below 0",
          backgroundColor: C.error,
        );
      }
      return;
    }

    setState(() {
      _todayCounts[picked.id] = newTotalForPicked;
      if (isCurrent) _total = newTotalForPicked;
    });

    final now = DateTime.now();
    final today =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    SettingsService.saveLocalCount(
      picked.id,
      picked.category.name,
      newTotalForPicked,
      today,
    );

    if (!SupabaseService.isAuthenticated) {
      if (mounted) {
        _showManualAdjustToast(
          picked,
          effectiveDelta,
          newTotalForPicked,
          allowUndo: allowUndo,
        );
      }
      return;
    }

    try {
      if (isCurrent && _tapsSinceLastSave > 0 && effectiveDelta > 0) {
        await CounterService.upsertCount(
          dhikrId: _dhikr.id,
          category: _dhikr.category.name,
          count: _total - effectiveDelta,
        );
        _tapsSinceLastSave = 0;
      }

      await CounterService.addManualCount(
        dhikrId: picked.id,
        category: picked.category.name,
        amount: effectiveDelta,
      );
      if (mounted) {
        _showManualAdjustToast(
          picked,
          effectiveDelta,
          newTotalForPicked,
          allowUndo: allowUndo,
        );
      }
    } catch (_) {
      setState(() {
        _todayCounts[picked.id] = prevTotalForPicked;
        if (isCurrent) _total = prevTotalForPicked;
      });
      if (mounted) {
        showAppSnackBar(
          context,
          'Failed to save. Please try again.',
          backgroundColor: C.error,
        );
      }
    }
  }

  void _showManualAdjustToast(
    Dhikr dhikr,
    int delta,
    int newTotal, {
    required bool allowUndo,
  }) {
    final verb = delta >= 0 ? 'Added' : 'Removed';
    final mag = delta.abs();
    showAppSnackBar(
      context,
      '$verb $mag · ${dhikr.name} · Today: $newTotal',
      actionLabel: allowUndo ? 'Undo' : null,
      onAction: allowUndo
          ? () => _applyManualAdjust(dhikr, -delta, allowUndo: false)
          : null,
    );
  }

  /// Opens the counter's overflow action menu — the single ⋮ entry point
  /// in the header. Surfaces the three discrete actions (manual add,
  /// today's log, counter settings) as discoverable list rows so users
  /// don't have to remember icon meanings.
  Future<void> _openCounterMenu() async {
    final dark = Theme.of(context).brightness == Brightness.dark;
    HapticFeedback.lightImpact();
    final choice = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) => _CounterMenuSheet(dark: dark),
    );
    if (!mounted || choice == null) return;
    switch (choice) {
      case 'manual':
        await _openManualAdd();
      case 'today':
        await _openTodayLog();
      case 'settings':
        _openSettings();
    }
  }

  /// Opens the "Today's log" sheet — lets the user view all of today's
  /// per-dhikr totals and edit any one to an exact number. Used as the
  /// direct-correction path for mistakes the user notices later.
  Future<void> _openTodayLog() async {
    final customs = SupabaseService.isAuthenticated
        ? await CustomDhikrService.list()
        : const <Dhikr>[];
    if (!mounted) return;
    HapticFeedback.lightImpact();
    await TodayLogSheet.show(
      context,
      counts: _todayCounts,
      customs: customs,
      onEdit: (dhikr, newCount) => _setExactCount(dhikr, newCount),
    );
  }

  /// Overwrite today's count for [dhikr] to exactly [newCount]. Returns
  /// true on success. Keeps the local UI in sync (including the active
  /// counter's `_total` if it matches).
  Future<bool> _setExactCount(Dhikr dhikr, int newCount) async {
    if (newCount < 0) return false;
    final isCurrent = dhikr.id == _dhikr.id;

    _saveTimer?.cancel();
    final prev = _todayCounts[dhikr.id] ?? 0;

    setState(() {
      _todayCounts[dhikr.id] = newCount;
      if (isCurrent) {
        _total = newCount;
        _tapsSinceLastSave = 0;
      }
    });

    final now = DateTime.now();
    final today =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    SettingsService.saveLocalCount(
      dhikr.id,
      dhikr.category.name,
      newCount,
      today,
    );

    if (!SupabaseService.isAuthenticated) {
      if (mounted) {
        showAppSnackBar(
          context,
          'Updated · ${dhikr.name} · $prev → $newCount',
        );
      }
      return true;
    }

    try {
      await CounterService.upsertCount(
        dhikrId: dhikr.id,
        category: dhikr.category.name,
        count: newCount,
      );
      if (mounted) {
        showAppSnackBar(
          context,
          'Updated · ${dhikr.name} · $prev → $newCount',
        );
      }
      return true;
    } catch (_) {
      if (!mounted) return false;
      setState(() {
        _todayCounts[dhikr.id] = prev;
        if (isCurrent) _total = prev;
      });
      if (mounted) {
        showAppSnackBar(
          context,
          'Failed to update. Please try again.',
          backgroundColor: C.error,
        );
      }
      return false;
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
      _todayCounts[_dhikr.id] = 0;
      _saveTimer?.cancel();
      _persistCount();
      if (mounted) showAppSnackBar(context, 'Counter reset · ${_dhikr.name}');
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
          // ── Header: centered dhikr title + single overflow menu ──
          // Title is absolutely centered via Stack; the overflow menu sits
          // alone on the right edge. Tapping it opens an action sheet
          // with manual-add, today's log, and settings — keeps the header
          // clean and lets the title get full width.
          FadeIn(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(S.page, S.s12, S.page, 0),
              child: SizedBox(
                height: 36,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Centered title — small horizontal padding leaves
                    // room for the menu button so long names ellipsize
                    // without overlapping.
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 56),
                      child: GestureDetector(
                        onTap: _openSelector,
                        behavior: HitTestBehavior.opaque,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Flexible(
                              child: Text(
                                _dhikr.name,
                                textAlign: TextAlign.center,
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
                    Positioned(
                      right: 0,
                      top: 0,
                      bottom: 0,
                      child: GestureDetector(
                        onTap: _openCounterMenu,
                        onLongPress: _openTodayLog,
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: dark ? C.dark3 : C.light3,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            CupertinoIcons.ellipsis,
                            size: 16,
                            color: dark ? C.onDark2 : C.onLight2,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
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
                                    color: _accentColor.withValues(alpha: 0.2),
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


/// Action menu shown when the user taps the counter header's ⋮ button.
/// Lists the three discrete page-level actions (manual add, today's log,
/// counter settings) as labeled rows so each is self-documenting; the
/// sheet pops with a string identifier so the parent picks the right
/// flow without needing direct callbacks.
class _CounterMenuSheet extends StatelessWidget {
  const _CounterMenuSheet({required this.dark});
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;
    return Container(
      decoration: BoxDecoration(
        color: dark ? C.dark2 : C.light2,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(0, S.s12, 0, bottomInset + S.s12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: dark ? C.dark4 : C.lightDivider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: S.s16),

          _CounterMenuRow(
            icon: CupertinoIcons.add_circled,
            title: 'Add manual count',
            subtitle: 'Log counts from a physical tasbih',
            dark: dark,
            onTap: () => Navigator.pop(context, 'manual'),
          ),
          _CounterMenuRow(
            icon: CupertinoIcons.list_bullet,
            title: "Edit today's log",
            subtitle: 'Fix a wrong number from earlier today',
            dark: dark,
            onTap: () => Navigator.pop(context, 'today'),
          ),
          _CounterMenuRow(
            icon: CupertinoIcons.gear,
            title: 'Counter settings',
            subtitle: 'Bead style, haptics, and daily goal',
            dark: dark,
            onTap: () => Navigator.pop(context, 'settings'),
          ),
        ],
      ),
    );
  }
}

class _CounterMenuRow extends StatelessWidget {
  const _CounterMenuRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.dark,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool dark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: S.page,
          vertical: S.s12,
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: dark ? C.dark3 : C.light3,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 18,
                color: dark ? C.onDark1 : C.onLight1,
              ),
            ),
            const SizedBox(width: S.s12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: dark ? C.onDark1 : C.onLight1,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: dark ? C.onDark3 : C.onLight3,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              CupertinoIcons.chevron_right,
              size: 14,
              color: dark ? C.onDark3 : C.onLight3,
            ),
          ],
        ),
      ),
    );
  }
}
