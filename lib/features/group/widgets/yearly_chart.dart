import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:selawathub/core/constants.dart';
import 'package:selawathub/core/services/group_service.dart';
import 'package:selawathub/core/theme/colors.dart';

class YearlyChart extends StatefulWidget {
  const YearlyChart({super.key, required this.groupId});
  final String groupId;

  @override
  State<YearlyChart> createState() => _YearlyChartState();
}

class _YearlyChartState extends State<YearlyChart> {
  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  final Map<int, List<int>> _yearData = {};
  late int _selectedYear = DateTime.now().year;
  int? _tappedMonth;
  final _pageCtrl = PageController();
  int _currentPage = 0;
  bool _loading = true;

  List<int> get _data => _yearData[_selectedYear] ?? List.filled(12, 0);
  int get _maxVal {
    final m = _data.reduce((a, b) => a > b ? a : b);
    return m > 0 ? m : 1;
  }

  @override
  void initState() {
    super.initState();
    _loadYear(_selectedYear);
  }

  Future<void> _loadYear(int year) async {
    if (_yearData.containsKey(year)) {
      setState(() => _loading = false);
      return;
    }
    setState(() => _loading = true);
    final data = await GroupService.getGroupYearlyTotals(widget.groupId, year);
    if (mounted) {
      setState(() {
        _yearData[year] = data;
        _loading = false;
      });
    }
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final tt = Theme.of(context).textTheme;
    final currentYear = DateTime.now().year;
    final canGoBack = _selectedYear > 2024;
    final canGoForward = _selectedYear < currentYear;

    return Container(
      padding: const EdgeInsets.all(S.s20),
      decoration: BoxDecoration(
        color: dark ? C.dark3 : C.light2,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with year navigation
          Row(
            children: [
              Expanded(
                child: Text(
                  'Yearly Summary',
                  style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              GestureDetector(
                onTap: canGoBack
                    ? () {
                        setState(() {
                          _selectedYear--;
                          _tappedMonth = null;
                          _pageCtrl.jumpToPage(0);
                          _currentPage = 0;
                        });
                        _loadYear(_selectedYear);
                      }
                    : null,
                child: Icon(
                  CupertinoIcons.chevron_left,
                  size: 14,
                  color: canGoBack
                      ? (dark ? C.onDark2 : C.onLight2)
                      : (dark ? C.onDark3 : C.onLight3)
                          .withValues(alpha: 0.3),
                ),
              ),
              const SizedBox(width: S.s8),
              Text(
                '$_selectedYear',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: dark ? C.onDark1 : C.onLight1,
                ),
              ),
              const SizedBox(width: S.s8),
              GestureDetector(
                onTap: canGoForward
                    ? () {
                        setState(() {
                          _selectedYear++;
                          _tappedMonth = null;
                          _pageCtrl.jumpToPage(0);
                          _currentPage = 0;
                        });
                        _loadYear(_selectedYear);
                      }
                    : null,
                child: Icon(
                  CupertinoIcons.chevron_right,
                  size: 14,
                  color: canGoForward
                      ? (dark ? C.onDark2 : C.onLight2)
                      : (dark ? C.onDark3 : C.onLight3)
                          .withValues(alpha: 0.3),
                ),
              ),
            ],
          ),

          const SizedBox(height: S.s20),

          // Bar chart
          if (_loading)
            const SizedBox(
              height: 160,
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            )
          else
          SizedBox(
            height: 160,
            child: Column(
              children: [
                Expanded(
                  child: PageView.builder(
                    controller: _pageCtrl,
                    itemCount: 2,
                    onPageChanged: (p) => setState(() => _currentPage = p),
                    itemBuilder: (ctx, page) {
                      final startMonth = page * 6;
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: List.generate(6, (i) {
                          final monthIdx = startMonth + i;
                          final val = _data[monthIdx];
                          final ratio = val / _maxVal;
                          final isActive = _tappedMonth == monthIdx;
                          final hasData = val > 0;

                          return Expanded(
                            child: GestureDetector(
                              onTap: hasData
                                  ? () => setState(() => _tappedMonth =
                                      _tappedMonth == monthIdx ? null : monthIdx)
                                  : null,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 2),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    if (isActive)
                                      Padding(
                                        padding: const EdgeInsets.only(bottom: 4),
                                        child: Text(
                                          _fmtCompact(val),
                                          style: TextStyle(
                                            fontSize: 8,
                                            fontWeight: FontWeight.w700,
                                            color: dark ? C.primarySoft : C.primary,
                                          ),
                                        ),
                                      ),
                                    Flexible(
                                      child: FractionallySizedBox(
                                        heightFactor: hasData ? ratio.clamp(0.05, 1.0) : 0.05,
                                        child: AnimatedContainer(
                                          duration: const Duration(milliseconds: 200),
                                          decoration: BoxDecoration(
                                            color: !hasData
                                                ? (dark ? C.dark4 : C.light3)
                                                : isActive
                                                    ? (dark ? C.primarySoft : C.primary)
                                                    : (dark
                                                        ? C.primarySoft.withValues(alpha: 0.3)
                                                        : C.primary.withValues(alpha: 0.2)),
                                            borderRadius: const BorderRadius.vertical(
                                              top: Radius.circular(4),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: S.s6),
                                    Text(
                                      _months[monthIdx],
                                      style: TextStyle(
                                        fontSize: 9,
                                        fontWeight:
                                            isActive ? FontWeight.w700 : FontWeight.w400,
                                        color: isActive
                                            ? (dark ? C.onDark1 : C.onLight1)
                                            : (dark ? C.onDark3 : C.onLight3),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),
                      );
                    },
                  ),
                ),
                const SizedBox(height: S.s8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(2, (i) => Container(
                    width: 6,
                    height: 6,
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _currentPage == i
                          ? (dark ? C.primarySoft : C.primary)
                          : (dark ? C.dark4 : C.lightDivider),
                    ),
                  )),
                ),
              ],
            ),
          ),

          // Total for year
          const SizedBox(height: S.s16),
          Center(
            child: Text(
              'Total: ${_fmtNum(_data.fold(0, (a, b) => a + b))} selawat',
              style: tt.bodySmall?.copyWith(
                color: dark ? C.onDark3 : C.onLight3,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String _fmtNum(int n) {
  if (n < 1000) return '$n';
  final s = n.toString();
  final b = StringBuffer();
  for (int i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) b.write(',');
    b.write(s[i]);
  }
  return b.toString();
}

String _fmtCompact(int n) {
  if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
  if (n >= 1000) return '${(n / 1000).toStringAsFixed(n % 1000 == 0 ? 0 : 1)}k';
  return '$n';
}
