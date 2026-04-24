import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:selawathub/core/animations/bounce_tap.dart';
import 'package:selawathub/core/animations/fade_in.dart';
import 'package:selawathub/core/constants.dart';
import 'package:selawathub/core/services/group_service.dart';
import 'package:selawathub/core/services/supabase_service.dart';
import 'package:selawathub/core/theme/colors.dart';
import 'package:selawathub/core/widgets/app_bottom_sheet.dart';
import 'package:selawathub/core/widgets/app_snackbar.dart';
import 'package:selawathub/core/widgets/frosted_bar.dart';
import 'package:selawathub/features/group/group_settings_page.dart';
import 'package:selawathub/features/group/widgets/member_tile.dart';
import 'package:selawathub/features/group/widgets/no_group_view.dart';
import 'package:selawathub/features/group/widgets/yearly_chart.dart';
import 'package:skeletonizer/skeletonizer.dart';

class GroupPage extends StatefulWidget {
  const GroupPage({super.key, this.isGuest = false});
  final bool isGuest;

  @override
  State<GroupPage> createState() => _GroupPageState();
}

class _GroupPageState extends State<GroupPage> {
  bool _loading = true;
  Map<String, dynamic>? _group;

  @override
  void initState() {
    super.initState();
    if (widget.isGuest || !SupabaseService.isAuthenticated) {
      _loading = false;
    } else {
      _loadGroup();
    }
  }

  Future<void> _loadGroup() async {
    setState(() => _loading = true);
    try {
      final group = await GroupService.getMyGroup();
      debugPrint('[GroupPage] _loadGroup result: ${group != null ? 'found group' : 'no group'}');
      if (mounted) setState(() { _group = group; _loading = false; });
    } catch (e) {
      debugPrint('[GroupPage] _loadGroup error: $e');
      if (mounted) setState(() { _group = null; _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return _GroupViewSkeleton();
    }
    if (_group != null) {
      return _GroupView(
        group: _group!,
        onLeave: () => setState(() => _group = null),
        onReload: _loadGroup,
      );
    }
    if (widget.isGuest) {
      return _GuestGroupView();
    }
    return SafeArea(
      bottom: false,
      child: NoGroupView(onJoined: _loadGroup),
    );
  }
}

// ── Guest view (sign in required) ──
class _GuestGroupView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final tt = Theme.of(context).textTheme;
    return SafeArea(
      bottom: false,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: S.page),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                CupertinoIcons.person_3_fill,
                size: 64,
                color: dark ? C.onDark3 : C.onLight3,
              ),
              const SizedBox(height: S.s16),
              Text(
                'Groups',
                style: tt.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: S.s8),
              Text(
                'Sign in to create or join a group\nand track dhikr together.',
                style: tt.bodyMedium?.copyWith(
                  color: dark ? C.onDark2 : C.onLight2,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Group view (when user is in a group) ──
class _GroupView extends StatefulWidget {
  const _GroupView({required this.group, required this.onLeave, required this.onReload});
  final Map<String, dynamic> group;
  final VoidCallback onLeave;
  final VoidCallback onReload;

  @override
  State<_GroupView> createState() => _GroupViewState();
}

class _GroupViewState extends State<_GroupView> {
  // Per-period member lists, populated once on load and swapped on tab tap.
  // Null means "not yet loaded" — only the current tab's list shows a
  // skeleton during the initial fetch; switching tabs is instant afterwards.
  List<Map<String, dynamic>>? _todayMembers;
  List<Map<String, dynamic>>? _weekMembers;
  List<Map<String, dynamic>>? _monthMembers;

  bool _loading = true;
  int _weekTotal = 0;
  int _monthTotal = 0;
  static const _periods = ['Today', 'This Week', 'This Month'];
  int _periodIdx = 0;

  List<Map<String, dynamic>> get _members {
    switch (_periodIdx) {
      case 1:
        return _weekMembers ?? _todayMembers ?? const [];
      case 2:
        return _monthMembers ?? _todayMembers ?? const [];
      default:
        return _todayMembers ?? const [];
    }
  }

  @override
  void initState() {
    super.initState();
    _loadMembers();
  }

  Future<void> _loadMembers() async {
    try {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final monday = today.subtract(Duration(days: today.weekday - 1));
      final firstOfMonth = DateTime(now.year, now.month, 1);
      final groupId = widget.group['id'] as String;

      // Fire all four calls in parallel so the tab toggle is instant once
      // the group page finishes loading.
      final results = await Future.wait([
        GroupService.getGroupMembers(groupId),
        GroupService.getGroupMembersForPeriod(groupId, monday, today),
        GroupService.getGroupMembersForPeriod(groupId, firstOfMonth, today),
        GroupService.getGroupPeriodTotals(groupId),
      ]);

      if (!mounted) return;
      setState(() {
        _todayMembers = results[0] as List<Map<String, dynamic>>;
        _weekMembers = results[1] as List<Map<String, dynamic>>;
        _monthMembers = results[2] as List<Map<String, dynamic>>;
        final periodTotals = results[3] as Map<String, int>;
        _weekTotal = periodTotals['week'] ?? 0;
        _monthTotal = periodTotals['month'] ?? 0;
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  int get _groupTotal => _members.fold(0, (sum, m) => sum + (m['today_count'] as int? ?? 0));

  GroupRole _parseRole(String? role) {
    if (role == 'leader') return GroupRole.leader;
    if (role == 'co_leader') return GroupRole.coLeader;
    return GroupRole.member;
  }

  void _showGroupInfo(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final tt = Theme.of(context).textTheme;
    final groupName = widget.group['name'] as String? ?? 'Group';
    final description = widget.group['description'] as String? ?? '';
    final inviteCode = widget.group['invite_code'] as String? ?? '';
    final createdAt = widget.group['created_at'] as String?;

    String formattedDate = '';
    if (createdAt != null) {
      try {
        final date = DateTime.parse(createdAt);
        formattedDate = DateFormat('d MMM yyyy').format(date);
      } catch (_) {}
    }

    showAppFormSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(S.page, S.s8, S.page, S.page),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Group name
              Text(
                groupName,
                style: tt.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: S.s16),

              // Description
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(S.s16),
                decoration: BoxDecoration(
                  color: dark ? C.dark3 : C.light3,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Description',
                      style: tt.labelSmall?.copyWith(
                        color: dark ? C.onDark3 : C.onLight3,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: S.s6),
                    Text(
                      description.isEmpty ? 'No description' : description,
                      style: tt.bodyMedium?.copyWith(
                        color: description.isEmpty
                            ? (dark ? C.onDark3 : C.onLight3)
                            : (dark ? C.onDark1 : C.onLight1),
                        fontStyle: description.isEmpty ? FontStyle.italic : null,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: S.s12),

              // Info row: members + created date
              Row(
                children: [
                  _InfoChip(
                    icon: CupertinoIcons.person_2_fill,
                    label: '${_members.length} members',
                    dark: dark,
                  ),
                  const SizedBox(width: S.s8),
                  if (formattedDate.isNotEmpty)
                    _InfoChip(
                      icon: CupertinoIcons.calendar,
                      label: 'Created $formattedDate',
                      dark: dark,
                    ),
                ],
              ),

              const SizedBox(height: S.s16),

              // Invite code row
              BounceTap(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: inviteCode));
                  showAppSnackBar(ctx, 'Invite code copied!');
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: S.s16,
                    vertical: S.s12,
                  ),
                  decoration: BoxDecoration(
                    color: dark
                        ? C.primaryMuted.withValues(alpha: 0.2)
                        : C.primary.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        CupertinoIcons.ticket,
                        size: 16,
                        color: dark ? C.primarySoft : C.primary,
                      ),
                      const SizedBox(width: S.s12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Invite Code',
                            style: tt.labelSmall?.copyWith(
                              color: dark ? C.onDark3 : C.onLight3,
                            ),
                          ),
                          const SizedBox(height: S.s2),
                          Text(
                            inviteCode,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: dark ? C.primarySoft : C.primary,
                              letterSpacing: 2,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Icon(
                        CupertinoIcons.doc_on_clipboard,
                        size: 14,
                        color: dark ? C.onDark3 : C.onLight3,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final tt = Theme.of(context).textTheme;
    final groupName = widget.group['name'] as String? ?? 'Group';
    final inviteCode = widget.group['invite_code'] as String? ?? '';
    final dailyGoal = widget.group['daily_goal'] as int? ?? 0;
    final groupTotal = _groupTotal;

    if (_loading) {
      return _GroupViewSkeleton();
    }

    return Stack(
      children: [
        RefreshIndicator(
          color: dark ? C.primarySoft : C.primary,
          onRefresh: () async {
            await _loadMembers();
          },
          child: ListView(
      physics: const AlwaysScrollableScrollPhysics(),
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
                    _fmtNum(groupTotal),
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
                  if (dailyGoal > 0) ...[
                    const SizedBox(height: S.s16),
                    _GoalProgressBar(
                      current: groupTotal,
                      goal: dailyGoal,
                      dark: dark,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),

        const SizedBox(height: S.s12),

        // Period stat cards (week & month)
        FadeIn(
          delay: const Duration(milliseconds: 120),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: S.page),
            child: Row(
              children: [
                Expanded(
                  child: _PeriodStatCard(
                    label: 'This Week',
                    value: _weekTotal,
                    dark: dark,
                  ),
                ),
                const SizedBox(width: S.s12),
                Expanded(
                  child: _PeriodStatCard(
                    label: 'This Month',
                    value: _monthTotal,
                    dark: dark,
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: S.s16),
        FadeIn(
          delay: const Duration(milliseconds: 160),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: S.page),
            child: YearlyChart(groupId: widget.group['id'] as String),
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
                Clipboard.setData(ClipboardData(text: inviteCode));
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
                          inviteCode,
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

        // Members header with period toggle
        FadeIn(
          delay: const Duration(milliseconds: 200),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: S.page),
            child: Row(
              children: [
                Text('Members', style: tt.titleMedium),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: dark ? C.dark4 : C.light3,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: List.generate(_periods.length, (i) {
                      final active = i == _periodIdx;
                      return GestureDetector(
                        onTap: () {
                          if (i == _periodIdx) return;
                          // Tabs are cached — no reload, no skeleton.
                          setState(() => _periodIdx = i);
                        },
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
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            _periods[i],
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: active ? FontWeight.w700 : FontWeight.w500,
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

        // Members list (sorted by today_count)
        ..._members.asMap().entries.map((entry) {
          final i = entry.key;
          final m = entry.value;
          final rank = i + 1;
          return MemberTile(
            name: m['name'] as String? ?? 'Unknown',
            count: m['today_count'] as int? ?? 0,
            rank: rank,
            role: _parseRole(m['role'] as String?),
            isYou: m['is_me'] as bool? ?? false,
            avatarUrl: m['avatar_url'] as String?,
            animationDelay: Duration(milliseconds: 240 + rank * 40),
          );
        }),

        SizedBox(height: MediaQuery.of(context).padding.bottom + 56 + S.s24),
      ],
    ),
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
                      child: GestureDetector(
                        onTap: () => _showGroupInfo(context),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(groupName, style: tt.headlineLarge),
                                  const SizedBox(height: S.s4),
                                  Text(
                                    '${_members.length} members',
                                    style: tt.bodyMedium,
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              CupertinoIcons.chevron_right,
                              size: 14,
                              color: dark ? C.onDark3 : C.onLight3,
                            ),
                            const SizedBox(width: S.s12),
                          ],
                        ),
                      ),
                    ),
                    BounceTap(
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) {
                              final myRole = _parseRole(widget.group['my_role'] as String?);
                              final asGroupMembers = _members
                                  .map((m) => (
                                    m['name'] as String? ?? 'Unknown',
                                    m['today_count'] as int? ?? 0,
                                    m['is_me'] as bool? ?? false,
                                    _parseRole(m['role'] as String?),
                                    m['user_id'] as String? ?? '',
                                  ))
                                  .toList();
                              return GroupSettingsPage(
                                groupId: widget.group['id'] as String,
                                groupName: groupName,
                                groupDescription: widget.group['description'] as String? ?? '',
                                inviteCode: inviteCode,
                                dailyGoal: dailyGoal,
                                memberCount: _members.length,
                                userRole: myRole,
                                members: asGroupMembers,
                                onLeave: widget.onLeave,
                              );
                            },
                          ),
                        );
                        widget.onReload();
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
            label,
            style: tt.labelSmall?.copyWith(
              color: dark ? C.onDark3 : C.onLight3,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: S.s6),
          Text(
            _fmtNum(value),
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: dark ? C.onDark1 : C.onLight1,
            ),
          ),
        ],
      ),
    );
  }
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

// ── Info chip for group info sheet ──
class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.icon,
    required this.label,
    required this.dark,
  });

  final IconData icon;
  final String label;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: S.s12, vertical: S.s8),
      decoration: BoxDecoration(
        color: dark ? C.dark3 : C.light3,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: dark ? C.onDark3 : C.onLight3),
          const SizedBox(width: S.s6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: dark ? C.onDark2 : C.onLight2,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Skeleton placeholder shown while group data loads ──
class _GroupViewSkeleton extends StatelessWidget {
  const _GroupViewSkeleton();

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final tt = Theme.of(context).textTheme;

    return Skeletonizer(
      enabled: true,
      child: Stack(
        children: [
          ListView(
            padding: EdgeInsets.zero,
            children: [
              SizedBox(height: MediaQuery.of(context).padding.top + 100),

              // Group total placeholder
              Padding(
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
                        '1,234',
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.w800,
                          color: dark ? C.onDark1 : C.onLight1,
                          letterSpacing: -1.5,
                        ),
                      ),
                      const SizedBox(height: S.s4),
                      Text('selawat', style: tt.bodySmall),
                      const SizedBox(height: S.s16),
                      _GoalProgressBar(current: 1234, goal: 10000, dark: dark),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: S.s16),

              // Yearly chart placeholder
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: S.page),
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: dark ? C.dark3 : C.light3,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),

              const SizedBox(height: S.s32),

              // Invite code placeholder
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: S.page),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: S.s20, vertical: S.s16),
                  decoration: BoxDecoration(
                    color: dark ? C.dark3 : C.light3,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Icon(CupertinoIcons.ticket,
                          size: 18, color: dark ? C.onDark3 : C.onLight3),
                      const SizedBox(width: S.s12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Invite Code', style: tt.bodySmall),
                          const SizedBox(height: S.s2),
                          Text(
                            'ABC123',
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
                      Icon(CupertinoIcons.doc_on_clipboard,
                          size: 16, color: dark ? C.onDark3 : C.onLight3),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: S.s32),

              // Members header placeholder
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: S.page),
                child: Row(
                  children: [
                    Text('Members', style: tt.titleMedium),
                    const Spacer(),
                    Text(
                      'Today',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: dark ? C.onDark3 : C.onLight3,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: S.s12),

              // Placeholder member tiles
              for (int i = 0; i < 4; i++)
                MemberTile(
                  name: 'Member Name',
                  count: 100,
                  rank: i + 1,
                  role: i == 0 ? GroupRole.leader : GroupRole.member,
                  isYou: i == 0,
                  animationDelay: Duration.zero,
                ),

              SizedBox(
                  height:
                      MediaQuery.of(context).padding.bottom + 56 + S.s24),
            ],
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: FrostedBar(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: S.page, vertical: S.s16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('My Group', style: tt.headlineLarge),
                    const SizedBox(height: S.s4),
                    Text('3 members', style: tt.bodyMedium),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

