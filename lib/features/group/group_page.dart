import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:selawathub/core/animations/bounce_tap.dart';
import 'package:selawathub/core/animations/fade_in.dart';
import 'package:selawathub/core/constants.dart';
import 'package:selawathub/core/theme/colors.dart';
import 'package:selawathub/core/widgets/action_buttons.dart';
import 'package:selawathub/core/widgets/app_snackbar.dart';
import 'package:selawathub/core/widgets/frosted_bar.dart';
import 'package:selawathub/features/group/group_settings_page.dart';

class GroupPage extends StatefulWidget {
  const GroupPage({super.key, this.isGuest = false});
  final bool isGuest;

  @override
  State<GroupPage> createState() => _GroupPageState();
}

class _GroupPageState extends State<GroupPage> {
  late bool _hasGroup = !widget.isGuest; // guests start with no group

  @override
  Widget build(BuildContext context) {
    return _hasGroup ? _GroupView(onLeave: () => setState(() => _hasGroup = false)) : SafeArea(bottom: false, child: _NoGroupView(onJoined: () => setState(() => _hasGroup = true)));
  }
}

// ── Group view (when user is in a group) ──
class _GroupView extends StatefulWidget {
  const _GroupView({required this.onLeave});
  final VoidCallback onLeave;

  @override
  State<_GroupView> createState() => _GroupViewState();
}

class _GroupViewState extends State<_GroupView> {
  // (name, isYou, role, today, week, month)
  static const _members = [
    ('Amin', true, GroupRole.leader, 4120, 18400, 72300),
    ('Sarah', false, GroupRole.coLeader, 3891, 16200, 68100),
    ('Ahmad', false, GroupRole.member, 3450, 14800, 58900),
    ('Fatimah', false, GroupRole.member, 2987, 13500, 51200),
    ('Yusuf', false, GroupRole.member, 2654, 11900, 45600),
    ('Khadijah', false, GroupRole.member, 2210, 9800, 38400),
  ];

  static const _periods = ['Today', 'This Week', 'This Month'];
  int _periodIdx = 0;

  int _countFor(int memberIdx) {
    final m = _members[memberIdx];
    return switch (_periodIdx) { 0 => m.$4, 1 => m.$5, _ => m.$6 };
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final tt = Theme.of(context).textTheme;

    return Stack(
      children: [
        ListView(
      padding: EdgeInsets.zero,
      children: [
        SizedBox(height: MediaQuery.of(context).padding.top + 100),

        // Group total
        FadeIn(
          delay: const Duration(milliseconds: 80),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: S.page),
            child: Container(
              padding: const EdgeInsets.all(S.s24),
              decoration: BoxDecoration(
                color: dark
                    ? C.primaryMuted.withValues(alpha: 0.2)
                    : C.primary.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Text(
                    'GROUP TOTAL TODAY',
                    style: tt.labelSmall?.copyWith(
                      color: dark ? C.primarySoft : C.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: S.s12),
                  Text(
                    _fmtNum(19312),
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.w800,
                      color: dark ? C.onDark1 : C.onLight1,
                      letterSpacing: -1.5,
                    ),
                  ),
                  const SizedBox(height: S.s4),
                  Text('selawat', style: tt.bodySmall),

                  // Daily goal progress
                  const SizedBox(height: S.s16),
                  _GoalProgressBar(
                    current: 19312,
                    goal: 25000,
                    dark: dark,
                  ),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(height: S.s16),

        // Period stat cards
        FadeIn(
          delay: const Duration(milliseconds: 120),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: S.page),
            child: Row(
              children: [
                Expanded(
                  child: _PeriodStatCard(
                    label: 'This Week',
                    value: 98420,
                    dark: dark,
                  ),
                ),
                const SizedBox(width: S.s12),
                Expanded(
                  child: _PeriodStatCard(
                    label: 'This Month',
                    value: 384650,
                    dark: dark,
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: S.s16),

        // Yearly summary chart
        FadeIn(
          delay: const Duration(milliseconds: 160),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: S.page),
            child: _YearlyChart(),
          ),
        ),

        const SizedBox(height: S.s32),

        // Invite code
        FadeIn(
          delay: const Duration(milliseconds: 140),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: S.page),
            child: BounceTap(
              onTap: () {
                Clipboard.setData(const ClipboardData(text: 'SLWT-7861'));
                showAppSnackBar(context, 'Invite code copied!');
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: S.s20, vertical: S.s16),
                decoration: BoxDecoration(
                  color: dark ? C.dark3 : C.light3,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Icon(
                      CupertinoIcons.ticket,
                      size: 18,
                      color: dark ? C.onDark3 : C.onLight3,
                    ),
                    const SizedBox(width: S.s12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Invite Code', style: tt.bodySmall),
                        const SizedBox(height: S.s2),
                        Text(
                          'SLWT-7861',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: dark ? C.onDark1 : C.onLight1,
                            letterSpacing: 2,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Icon(
                      CupertinoIcons.doc_on_clipboard,
                      size: 16,
                      color: dark ? C.onDark3 : C.onLight3,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: S.s32),

        // Members header + period toggle
        FadeIn(
          delay: const Duration(milliseconds: 200),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: S.page),
            child: Row(
              children: [
                Text('Members', style: tt.titleMedium),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: dark ? C.dark3 : C.light3,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(_periods.length, (i) {
                      final active = i == _periodIdx;
                      return GestureDetector(
                        onTap: () => setState(() => _periodIdx = i),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                            horizontal: S.s8,
                            vertical: S.s4,
                          ),
                          decoration: BoxDecoration(
                            color: active
                                ? (dark ? C.primarySoft : C.primary)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _periods[i],
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight:
                                  active ? FontWeight.w700 : FontWeight.w500,
                              color: active
                                  ? C.white
                                  : (dark ? C.onDark3 : C.onLight3),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: S.s12),

        // Members list (sorted by selected period)
        ...() {
          final indices = List.generate(_members.length, (i) => i)
            ..sort((a, b) => _countFor(b).compareTo(_countFor(a)));
          return indices.map((i) {
            final m = _members[i];
            final (name, isYou, role, _, _, _) = m;
            final count = _countFor(i);
            final rank = indices.indexOf(i) + 1;
            return FadeIn(
              delay: Duration(milliseconds: 240 + rank * 40),
            offset: const Offset(0, 8),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: S.page),
              child: Container(
                margin: const EdgeInsets.only(bottom: S.s8),
                padding: const EdgeInsets.symmetric(horizontal: S.s16, vertical: S.s12),
                decoration: BoxDecoration(
                  color: isYou
                      ? (dark
                          ? C.primaryMuted.withValues(alpha: 0.15)
                          : C.primary.withValues(alpha: 0.04))
                      : (dark ? C.dark3 : C.light2),
                  borderRadius: BorderRadius.circular(16),
                  border: isYou
                      ? Border.all(
                          color: dark
                              ? C.primarySoft.withValues(alpha: 0.2)
                              : C.primary.withValues(alpha: 0.1),
                        )
                      : null,
                ),
                child: Row(
                  children: [
                    Text(
                      '$rank',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: dark ? C.onDark3 : C.onLight3,
                      ),
                    ),
                    const SizedBox(width: S.s12),
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: dark ? C.dark4 : C.light3,
                      child: Text(
                        name[0],
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: dark ? C.onDark2 : C.onLight2,
                        ),
                      ),
                    ),
                    const SizedBox(width: S.s12),
                    Expanded(
                      child: Row(
                        children: [
                          if (role == GroupRole.leader)
                            const Padding(
                              padding: EdgeInsets.only(right: 4),
                              child: Text('👑', style: TextStyle(fontSize: 12)),
                            ),
                          if (role == GroupRole.coLeader)
                            const Padding(
                              padding: EdgeInsets.only(right: 4),
                              child: Text('⭐', style: TextStyle(fontSize: 12)),
                            ),
                          Flexible(
                            child: Text(
                              name,
                              style: tt.titleSmall,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isYou) ...[
                            const SizedBox(width: S.s6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: C.primaryGlow,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'You',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  color: C.primarySoft,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    Text(_fmtNum(count), style: tt.titleSmall),
                  ],
                ),
              ),
            ),
          );
          }).toList();
        }(),

        SizedBox(height: MediaQuery.of(context).padding.bottom + 56 + S.s24),
      ],
    ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: FrostedBar(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: S.page, vertical: S.s16),
              child: FadeIn(
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('SelawatHub Family', style: tt.headlineLarge),
                          const SizedBox(height: S.s4),
                          Text(
                            '${_members.length} members',
                            style: tt.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                    BounceTap(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) {
                              final userRole = _members
                                  .firstWhere((m) => m.$2)
                                  .$3;
                              final asGroupMembers = _members
                                  .map((m) => (m.$1, m.$4, m.$2, m.$3))
                                  .toList();
                              return GroupSettingsPage(
                                groupName: 'SelawatHub Family',
                                inviteCode: 'SLWT-7861',
                                memberCount: _members.length,
                                userRole: userRole,
                                members: asGroupMembers,
                                onLeave: widget.onLeave,
                              );
                            },
                          ),
                        );
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: dark ? C.dark3 : C.light3,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          CupertinoIcons.gear,
                          size: 18,
                          color: dark ? C.onDark2 : C.onLight2,
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
    );
  }
}

// ── No group view ──
class _NoGroupView extends StatefulWidget {
  const _NoGroupView({required this.onJoined});
  final VoidCallback onJoined;

  @override
  State<_NoGroupView> createState() => _NoGroupViewState();
}

class _NoGroupViewState extends State<_NoGroupView> {
  final _codeCtrl = TextEditingController();

  @override
  void dispose() {
    _codeCtrl.dispose();
    super.dispose();
  }

  void _joinGroup() {
    if (_codeCtrl.text.trim().isEmpty) {
      showAppSnackBar(context, 'Please enter an invite code');
      return;
    }

    final dark = Theme.of(context).brightness == Brightness.dark;
    final tt = Theme.of(context).textTheme;
    final onJoined = widget.onJoined;

    showModalBottomSheet(
      context: context,
      backgroundColor: dark ? C.dark2 : C.light1,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(S.page),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
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
              Icon(
                CupertinoIcons.checkmark_circle_fill,
                size: 56,
                color: C.success,
              ),
              const SizedBox(height: S.s16),
              Text("You've joined the group!", style: tt.titleLarge),
              const SizedBox(height: S.s8),
              Text(
                'Welcome to SelawatHub Family',
                style: tt.bodyMedium?.copyWith(
                  color: dark ? C.onDark2 : C.onLight2,
                ),
              ),
              const SizedBox(height: S.s24),
              SizedBox(
                width: double.infinity,
                child: BounceTap(
                  onTap: () {
                    Navigator.pop(ctx);
                    onJoined();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: dark ? C.primarySoft : C.primary,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Center(
                      child: Text(
                        'Continue',
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
            ],
          ),
        ),
      ),
    );
  }

  void _createGroup() {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final tt = Theme.of(context).textTheme;
    final onJoined = widget.onJoined;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: dark ? C.dark2 : C.light1,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        final nameCtrl = TextEditingController();
        final descCtrl = TextEditingController();
        return Padding(
          padding: EdgeInsets.only(
            left: S.page,
            right: S.page,
            top: S.s16,
            bottom: MediaQuery.of(ctx).viewInsets.bottom +
                MediaQuery.of(ctx).padding.bottom +
                S.page,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
              Text(
                'Create New Group',
                style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: S.s24),
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(
                  hintText: 'Enter group name',
                ),
              ),
              const SizedBox(height: S.s16),
              TextField(
                controller: descCtrl,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Add a description (optional)',
                ),
              ),
              const SizedBox(height: S.s24),
              ActionButtons(
                cancelLabel: 'Cancel',
                confirmLabel: 'Create',
                onCancel: () => Navigator.pop(ctx),
                onConfirm: () {
                  if (nameCtrl.text.trim().isEmpty) {
                    showAppSnackBar(ctx, 'Please enter a group name');
                    return;
                  }
                  Navigator.pop(ctx);
                  onJoined();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final tt = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: S.page),
      child: Column(
        children: [
          const Spacer(flex: 2),

          FadeIn(
            child: Text('🤝', style: TextStyle(fontSize: 56)),
          ),
          const SizedBox(height: S.s24),

          FadeIn(
            delay: const Duration(milliseconds: 80),
            child: Text(
              'Join a Group',
              style: tt.headlineLarge,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: S.s8),

          FadeIn(
            delay: const Duration(milliseconds: 120),
            child: Text(
              'Count selawat together with\nyour family, friends, or community',
              style: tt.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ),

          const SizedBox(height: S.s40),

          // Join with code
          FadeIn(
            delay: const Duration(milliseconds: 200),
            child: TextField(
              controller: _codeCtrl,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: dark ? C.onDark1 : C.onLight1,
                letterSpacing: 3,
              ),
              decoration: InputDecoration(
                hintText: 'ENTER CODE',
                hintStyle: TextStyle(
                  fontSize: 14,
                  letterSpacing: 3,
                  color: dark ? C.onDark3 : C.onLight3,
                ),
              ),
            ),
          ),

          const SizedBox(height: S.s16),

          FadeIn(
            delay: const Duration(milliseconds: 260),
            child: SizedBox(
              width: double.infinity,
              child: BounceTap(
                onTap: _joinGroup,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: dark ? C.primarySoft : C.primary,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Text(
                      'Join Group',
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

          const SizedBox(height: S.s20),

          FadeIn(
            delay: const Duration(milliseconds: 320),
            child: Row(
              children: [
                Expanded(child: Divider(color: dark ? C.darkDivider : C.lightDivider)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: S.s16),
                  child: Text('or', style: tt.bodySmall),
                ),
                Expanded(child: Divider(color: dark ? C.darkDivider : C.lightDivider)),
              ],
            ),
          ),

          const SizedBox(height: S.s20),

          FadeIn(
            delay: const Duration(milliseconds: 380),
            child: SizedBox(
              width: double.infinity,
              child: BounceTap(
                onTap: _createGroup,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: dark ? C.darkDivider : C.lightDivider),
                  ),
                  child: Center(
                    child: Text(
                      'Create New Group',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: dark ? C.onDark1 : C.onLight1,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          const Spacer(flex: 3),
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

// ── Yearly summary bar chart ──
class _YearlyChart extends StatefulWidget {
  const _YearlyChart();

  @override
  State<_YearlyChart> createState() => _YearlyChartState();
}

class _YearlyChartState extends State<_YearlyChart> {
  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  // Mock data per year
  static const _yearData = {
    2025: [82000, 91000, 78000, 105000, 96000, 88000, 110000, 102000, 94000, 115000, 98000, 107000],
    2026: [120000, 135000, 112000, 148000, 0, 0, 0, 0, 0, 0, 0, 0],
  };

  late int _selectedYear = _yearData.keys.last;
  int? _tappedMonth;
  final _pageCtrl = PageController();
  int _currentPage = 0;

  List<int> get _data => _yearData[_selectedYear] ?? List.filled(12, 0);
  int get _maxVal {
    final m = _data.reduce((a, b) => a > b ? a : b);
    return m > 0 ? m : 1;
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
    final years = _yearData.keys.toList()..sort();

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
                onTap: _selectedYear > years.first
                    ? () => setState(() {
                        _selectedYear--;
                        _tappedMonth = null;
                        _pageCtrl.jumpToPage(0);
                        _currentPage = 0;
                      })
                    : null,
                child: Icon(
                  CupertinoIcons.chevron_left,
                  size: 14,
                  color: _selectedYear > years.first
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
                onTap: _selectedYear < years.last
                    ? () => setState(() {
                        _selectedYear++;
                        _tappedMonth = null;
                        _pageCtrl.jumpToPage(0);
                        _currentPage = 0;
                      })
                    : null,
                child: Icon(
                  CupertinoIcons.chevron_right,
                  size: 14,
                  color: _selectedYear < years.last
                      ? (dark ? C.onDark2 : C.onLight2)
                      : (dark ? C.onDark3 : C.onLight3)
                          .withValues(alpha: 0.3),
                ),
              ),
            ],
          ),

          const SizedBox(height: S.s20),

          // Bar chart
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

String _fmtCompact(int n) {
  if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
  if (n >= 1000) return '${(n / 1000).toStringAsFixed(n % 1000 == 0 ? 0 : 1)}k';
  return '$n';
}

// ── Goal progress bar ──
class _GoalProgressBar extends StatelessWidget {
  const _GoalProgressBar({
    required this.current,
    required this.goal,
    required this.dark,
  });

  final int current;
  final int goal;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final progress = (current / goal).clamp(0.0, 1.0);
    final pct = (progress * 100).toInt();

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Daily Goal',
              style: tt.bodySmall?.copyWith(
                color: dark ? C.onDark3 : C.onLight3,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '${_fmtNum(current)} / ${_fmtNum(goal)}  ·  $pct%',
              style: tt.bodySmall?.copyWith(
                color: dark ? C.onDark3 : C.onLight3,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: S.s8),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: SizedBox(
            height: 8,
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: dark
                  ? C.dark4.withValues(alpha: 0.5)
                  : C.light3,
              valueColor: AlwaysStoppedAnimation(
                dark ? C.primarySoft : C.primary,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Period stat card (week/month) ──
class _PeriodStatCard extends StatelessWidget {
  const _PeriodStatCard({
    required this.label,
    required this.value,
    required this.dark,
  });

  final String label;
  final int value;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(S.s16),
      decoration: BoxDecoration(
        color: dark ? C.dark3 : C.light2,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: tt.labelSmall?.copyWith(
              color: dark ? C.onDark3 : C.onLight3,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: S.s8),
          Text(
            _fmtNum(value),
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: dark ? C.onDark1 : C.onLight1,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: S.s2),
          Text(
            'selawat',
            style: tt.bodySmall?.copyWith(
              color: dark ? C.onDark3 : C.onLight3,
            ),
          ),
        ],
      ),
    );
  }
}
