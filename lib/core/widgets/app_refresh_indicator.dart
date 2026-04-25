import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:flutter/material.dart';
import 'package:selawathub/core/theme/colors.dart';
import 'package:selawathub/l10n/generated/app_localizations.dart';

/// App-wide pull-to-refresh with a text indicator.
///
/// Behaviour:
///  - While dragging under the armed threshold: shows "Pull to refresh".
///  - Past the armed threshold: shows "Release to refresh".
///  - After release: shows a small spinner + "Refreshing…".
///  - Keeps tracking the drag past the armed threshold (infinite pull feel —
///    the indicator content stays pinned once armed while the list continues
///    to follow the finger).
///
/// [topOffset] pushes the indicator text below frosted/transparent app bars
/// so it isn't hidden under the blur. Use the app-bar height (e.g. 100 + top
/// safe-area padding) on pages with a pinned frosted header; leave at 0 on
/// pages without one.
class AppRefreshIndicator extends StatelessWidget {
  const AppRefreshIndicator({
    super.key,
    required this.onRefresh,
    required this.child,
    this.topOffset = 0,
  });

  final Future<void> Function() onRefresh;
  final Widget child;
  final double topOffset;

  static const double _armedOffset = 80.0;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final accent = dark ? C.primarySoft : C.primary;
    final textColor = dark ? C.onDark2 : C.onLight2;
    final l = AppL10n.of(context);

    return CustomRefreshIndicator(
      onRefresh: onRefresh,
      offsetToArmed: _armedOffset,
      // Keep the scrollable glued to the finger past the armed point so the
      // user can "pull infinitely". The indicator itself caps at the armed
      // position (handled inside the builder).
      autoRebuild: false,
      builder: (context, scrollChild, controller) {
        return AnimatedBuilder(
          animation: controller,
          builder: (context, _) {
            final value = controller.value;
            final armed = value >= 1.0;

            // Visible drag distance of the indicator — caps at the armed
            // offset so the text stays pinned once the user has pulled far
            // enough, but the list keeps following the finger.
            final indicatorOffset = (value.clamp(0.0, 1.0)) * _armedOffset;

            final String label;
            if (controller.state == IndicatorState.loading) {
              label = l.refreshRefreshing;
            } else if (armed) {
              label = l.refreshReleaseToRefresh;
            } else {
              label = l.refreshPullToRefresh;
            }

            final showSpinner = controller.state == IndicatorState.loading;

            return Stack(
              clipBehavior: Clip.hardEdge,
              children: [
                // The scroll view itself — we translate it by the full
                // controller value so the user gets the "infinite" stretch
                // feeling even after the indicator text has pinned.
                Transform.translate(
                  offset: Offset(0, value * _armedOffset),
                  child: scrollChild,
                ),
                // Indicator content, positioned below any frosted app bar.
                Positioned(
                  top: topOffset,
                  left: 0,
                  right: 0,
                  height: indicatorOffset,
                  child: ClipRect(
                    child: OverflowBox(
                      minHeight: 0,
                      maxHeight: _armedOffset,
                      alignment: Alignment.center,
                      child: Opacity(
                        opacity: value.clamp(0.0, 1.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (showSpinner)
                              SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor:
                                      AlwaysStoppedAnimation<Color>(accent),
                                ),
                              )
                            else
                              AnimatedRotation(
                                turns: armed ? 0.5 : 0,
                                duration: const Duration(milliseconds: 180),
                                child: Icon(
                                  Icons.arrow_downward_rounded,
                                  size: 16,
                                  color: accent,
                                ),
                              ),
                            const SizedBox(width: 8),
                            Text(
                              label,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: textColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
          child: scrollChild,
        );
      },
      child: child,
    );
  }
}
