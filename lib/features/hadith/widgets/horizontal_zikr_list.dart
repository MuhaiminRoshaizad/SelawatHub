import 'dart:async';

import 'package:flutter/material.dart';
import 'package:selawathub/core/constants.dart';
import 'package:selawathub/core/theme/colors.dart';
import 'package:selawathub/features/hadith/models/doa.dart';
import 'package:selawathub/features/hadith/widgets/hadith_bottom_sheets.dart';
import 'package:selawathub/features/hadith/widgets/zikr_preview_card.dart';

// ─────────────────────────────────────────────────────────────────────────
//  Auto-scrolling horizontal zikr lists
//
//  Behaviour:
//   • Auto-scrolls to the right at ~40 px/sec.
//   • User can freely swipe left/right — we pause the ticker during
//     interaction so the drag never competes with programmatic motion.
//   • 3 seconds after the user stops interacting (fling + settle), the
//     ticker resumes.
//   • Tapping a card opens its detail sheet regardless of scroll state —
//     because we advance via `jumpTo` per frame (not `animateTo`), there's
//     no DrivenScrollActivity to steal the tap.
//   • Infinite feel via `items.length * _kRepeat` virtual items; when the
//     offset reaches the end we snap back to 0, which is visually identical
//     because every item repeats every `items.length`.
// ─────────────────────────────────────────────────────────────────────────

const int _kRepeat = 200;
const double _kGap = 12.0;
// Pixels advanced per millisecond. ~40 px/s feels gentle but alive.
const double _kPxPerMs = 0.04;
// Frame budget — close enough to 60fps for a smooth perceived glide.
const Duration _kTickInterval = Duration(milliseconds: 16);
// Pause length after the user stops scrolling before auto-scroll resumes.
const Duration _kResumeDelay = Duration(seconds: 3);

mixin _AutoScrollMixin<T extends StatefulWidget> on State<T> {
  final ScrollController _sc = ScrollController();
  Timer? _tick;
  Timer? _resumeTimer;
  bool _userInteracting = false;
  bool _disposed = false;

  @override
  void initState() {
    super.initState();
    // Kick the ticker off on the next frame so the ScrollController has a
    // position attached. The ticker itself is idempotent against unattached
    // controllers so this is just an optimization.
    WidgetsBinding.instance.addPostFrameCallback((_) => _startTicker());
  }

  @override
  void dispose() {
    _disposed = true;
    _tick?.cancel();
    _resumeTimer?.cancel();
    _sc.dispose();
    super.dispose();
  }

  void _startTicker() {
    _tick?.cancel();
    _tick = Timer.periodic(_kTickInterval, (_) {
      if (_disposed || _userInteracting) return;
      if (!_sc.hasClients) return;
      final max = _sc.position.maxScrollExtent;
      if (max <= 0) return;
      final step = _kPxPerMs * _kTickInterval.inMilliseconds;
      final next = _sc.offset + step;
      if (next >= max) {
        // Seamless loop: offset 0 renders the same item as offset max since
        // we render items.length * _kRepeat copies of the list.
        _sc.jumpTo(0);
      } else {
        _sc.jumpTo(next);
      }
    });
  }

  /// Pauses the ticker while the user is dragging/flinging, then resumes
  /// [_kResumeDelay] after the scroll settles.
  bool _handleScrollNotification(ScrollNotification n) {
    // Only finger drags count as "user interaction" — our own jumpTo calls
    // emit ScrollUpdateNotifications but never ScrollStartNotifications
    // with drag details.
    if (n is ScrollStartNotification && n.dragDetails != null) {
      _userInteracting = true;
      _resumeTimer?.cancel();
    } else if (n is ScrollEndNotification && _userInteracting) {
      _resumeTimer?.cancel();
      _resumeTimer = Timer(_kResumeDelay, () {
        if (_disposed) return;
        _userInteracting = false;
      });
    }
    return false;
  }
}

// ─────────────────────────────────────────────────────────
//  Horizontal Adkar List
// ─────────────────────────────────────────────────────────

class HorizontalAdkarList extends StatefulWidget {
  const HorizontalAdkarList({
    super.key,
    required this.items,
    required this.dark,
    required this.tt,
  });

  final List<DailyAdkar> items;
  final bool dark;
  final TextTheme tt;

  @override
  State<HorizontalAdkarList> createState() => _HorizontalAdkarListState();
}

class _HorizontalAdkarListState extends State<HorizontalAdkarList>
    with _AutoScrollMixin<HorizontalAdkarList> {
  @override
  Widget build(BuildContext context) {
    final count = widget.items.length;
    if (count == 0) return const SizedBox(height: 160);

    return SizedBox(
      height: 160,
      child: NotificationListener<ScrollNotification>(
        onNotification: _handleScrollNotification,
        child: ListView.separated(
          controller: _sc,
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: S.page),
          clipBehavior: Clip.none,
          itemCount: count * _kRepeat,
          separatorBuilder: (context, index) => const SizedBox(width: _kGap),
          itemBuilder: (context, index) {
            final item = widget.items[index % count];
            return ZikrPreviewCard(
              title: item.title,
              arabic: item.arabic,
              times: item.times,
              dark: widget.dark,
              tt: widget.tt,
              accentColor: C.primary,
              accentSoft: C.primarySoft,
              accentGlow: C.primaryGlow,
              onTap: () => showZikrDetailSheet(
                context: context,
                title: item.title,
                arabic: item.arabic,
                translation: item.translation,
                transliteration: item.transliteration,
                times: item.times,
                benefit: item.benefit,
                accentColor: C.primary,
                accentSoft: C.primarySoft,
                accentGlow: C.primaryGlow,
              ),
            );
          },
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
//  Horizontal Post-Salaah List
// ─────────────────────────────────────────────────────────

class HorizontalPostSalaahList extends StatefulWidget {
  const HorizontalPostSalaahList({
    super.key,
    required this.items,
    required this.dark,
    required this.tt,
  });

  final List<PostSalaahZikr> items;
  final bool dark;
  final TextTheme tt;

  @override
  State<HorizontalPostSalaahList> createState() =>
      _HorizontalPostSalaahListState();
}

class _HorizontalPostSalaahListState extends State<HorizontalPostSalaahList>
    with _AutoScrollMixin<HorizontalPostSalaahList> {
  @override
  Widget build(BuildContext context) {
    final count = widget.items.length;
    if (count == 0) return const SizedBox(height: 160);

    return SizedBox(
      height: 160,
      child: NotificationListener<ScrollNotification>(
        onNotification: _handleScrollNotification,
        child: ListView.separated(
          controller: _sc,
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: S.page),
          clipBehavior: Clip.none,
          itemCount: count * _kRepeat,
          separatorBuilder: (context, index) => const SizedBox(width: _kGap),
          itemBuilder: (context, index) {
            final item = widget.items[index % count];
            return ZikrPreviewCard(
              title: item.title,
              arabic: item.arabic,
              times: item.times,
              dark: widget.dark,
              tt: widget.tt,
              accentColor: C.gold,
              accentSoft: C.goldSoft,
              accentGlow: C.goldGlow,
              onTap: () => showZikrDetailSheet(
                context: context,
                title: item.title,
                arabic: item.arabic,
                translation: item.translation,
                transliteration: item.transliteration,
                times: item.times,
                benefit: item.benefit,
                accentColor: C.gold,
                accentSoft: C.goldSoft,
                accentGlow: C.goldGlow,
              ),
            );
          },
        ),
      ),
    );
  }
}
