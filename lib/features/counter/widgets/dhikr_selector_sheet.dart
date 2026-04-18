import 'package:flutter/material.dart';
import 'package:selawathub/core/animations/bounce_tap.dart';
import 'package:selawathub/core/constants.dart';
import 'package:selawathub/core/theme/colors.dart';
import 'package:selawathub/features/counter/models/dhikr.dart';

/// A bottom sheet that lets the user pick a selawat or zikir.
class DhikrSelectorSheet extends StatefulWidget {
  final Dhikr current;
  final ValueChanged<Dhikr> onSelected;

  const DhikrSelectorSheet({
    super.key,
    required this.current,
    required this.onSelected,
  });

  /// Shows the selector as a modal bottom sheet and returns the chosen [Dhikr].
  static Future<Dhikr?> show(BuildContext context, Dhikr current) {
    return showModalBottomSheet<Dhikr>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DhikrSelectorSheet(
        current: current,
        onSelected: (d) => Navigator.pop(ctx, d),
      ),
    );
  }

  @override
  State<DhikrSelectorSheet> createState() => _DhikrSelectorSheetState();
}

class _DhikrSelectorSheetState extends State<DhikrSelectorSheet>
    with SingleTickerProviderStateMixin {
  late final TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    final initialTab =
        widget.current.category == DhikrCategory.selawat ? 0 : 1;
    _tabCtrl = TabController(length: 2, vsync: this, initialIndex: initialTab);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.7,
      ),
      decoration: BoxDecoration(
        color: dark ? C.dark2 : C.light2,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Handle ──
          const SizedBox(height: S.s12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: dark ? C.dark4 : C.lightDivider,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: S.s16),

          // ── Title ──
          Text(
            'Choose Dhikr',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: dark ? C.onDark1 : C.onLight1,
            ),
          ),
          const SizedBox(height: S.s16),

          // ── Tab bar ──
          Container(
            margin: const EdgeInsets.symmetric(horizontal: S.page),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: dark ? C.dark3 : C.light3,
              borderRadius: BorderRadius.circular(14),
            ),
            child: TabBar(
              controller: _tabCtrl,
              indicator: BoxDecoration(
                color: dark ? C.primarySoft : C.primary,
                borderRadius: BorderRadius.circular(11),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerHeight: 0,
              labelColor: C.white,
              unselectedLabelColor: dark ? C.onDark3 : C.onLight3,
              labelStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              tabs: const [
                Tab(text: 'Selawat', height: 38),
                Tab(text: 'Zikir', height: 38),
              ],
            ),
          ),
          const SizedBox(height: S.s12),

          // ── List ──
          Flexible(
            child: TabBarView(
              controller: _tabCtrl,
              children: [
                _DhikrList(
                  items: Dhikr.selawatList,
                  current: widget.current,
                  onSelected: widget.onSelected,
                ),
                _DhikrList(
                  items: Dhikr.zikirList,
                  current: widget.current,
                  onSelected: widget.onSelected,
                ),
              ],
            ),
          ),

          SizedBox(height: bottomPad + S.s8),
        ],
      ),
    );
  }
}

class _DhikrList extends StatelessWidget {
  final List<Dhikr> items;
  final Dhikr current;
  final ValueChanged<Dhikr> onSelected;

  const _DhikrList({
    required this.items,
    required this.current,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: S.page),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final d = items[index];
        final selected = d.id == current.id;

        return Padding(
          padding: const EdgeInsets.only(bottom: S.s8),
          child: BounceTap(
            onTap: () => onSelected(d),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOut,
              padding: const EdgeInsets.all(S.s16),
              decoration: BoxDecoration(
                color: selected
                    ? (dark ? C.primarySoft.withValues(alpha: 0.15) : C.primaryGlow)
                    : (dark ? C.dark3 : C.light3),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: selected
                      ? (dark ? C.primarySoft : C.primary)
                      : C.transparent,
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  // Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Name + target
                        Row(
                          children: [
                            Text(
                              d.name,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: selected
                                    ? (dark ? C.primarySoft : C.primary)
                                    : (dark ? C.onDark2 : C.onLight2),
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: S.s8,
                                vertical: S.s2,
                              ),
                              decoration: BoxDecoration(
                                color: dark
                                    ? C.dark4
                                    : C.lightDivider,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '${d.defaultTarget}×',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: dark ? C.onDark3 : C.onLight3,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: S.s8),

                        // Arabic
                        Text(
                          d.arabic,
                          style: TextStyle(
                            fontSize: 18,
                            fontFamily: 'serif',
                            height: 1.8,
                            color: dark ? C.onDark1 : C.onLight1,
                          ),
                          textDirection: TextDirection.rtl,
                        ),
                        const SizedBox(height: S.s6),

                        // Transliteration
                        Text(
                          d.transliteration,
                          style: TextStyle(
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                            color: dark ? C.onDark3 : C.onLight3,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Check mark
                  if (selected) ...[
                    const SizedBox(width: S.s12),
                    Icon(
                      Icons.check_circle_rounded,
                      color: dark ? C.primarySoft : C.primary,
                      size: 22,
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
