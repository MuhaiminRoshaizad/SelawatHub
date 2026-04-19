import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:selawathub/core/animations/bounce_tap.dart';
import 'package:selawathub/core/animations/fade_in.dart';
import 'package:selawathub/core/constants.dart';
import 'package:selawathub/core/services/group_service.dart';
import 'package:selawathub/core/services/supabase_service.dart';
import 'package:selawathub/core/theme/colors.dart';
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
  List<Map<String, dynamic>> _members = [];
  bool _loading = true;
  int _weekTotal = 0;
  int _monthTotal = 0;
  static const _periods = ['Today', 'This Week', 'This Month'];
  int _periodIdx = 0;

  @override
  void initState() {
    super.initState();
    _loadMembers();
  }

  Future<void> _loadMembers() async {
    try {
      final members = await GroupService.getGroupMembers(widget.group['id']);
      // Also load week/month totals
      final periodTotals = await GroupService.getGroupPeriodTotals(widget.group['id'] as String);
      if (mounted) {
        setState(() {
          _members = members;
          _weekTotal = periodTotals['week'] ?? 0;
          _monthTotal = periodTotals['month'] ?? 0;
          _loading = false;
        });
      }
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

