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
      if (mounted) setState(() { _group = group; _loading = false; });
    } catch (_) {
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
    return SafeArea(
      bottom: false,
      child: NoGroupView(onJoined: _loadGroup),
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

  @override
  void initState() {
    super.initState();
    _loadMembers();
  }

  Future<void> _loadMembers() async {
    try {
      final members = await GroupService.getGroupMembers(widget.group['id']);
      if (mounted) setState(() { _members = members; _loading = false; });
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
    final dailyGoal = widget.group['daily_goal'] as int? ?? 10000;
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
                  const SizedBox(height: S.s16),
                  _GoalProgressBar(
                    current: groupTotal,
                    goal: dailyGoal,
                    dark: dark,
                  ),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(height: S.s16),

        // Yearly summary chart
        FadeIn(
          delay: const Duration(milliseconds: 160),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: S.page),
            child: YearlyChart(),
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

        // Members header
        FadeIn(
          delay: const Duration(milliseconds: 200),
          child: Padding(
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

