import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:selawathub/core/animations/bounce_tap.dart';
import 'package:selawathub/core/animations/fade_in.dart';
import 'package:selawathub/core/constants.dart';
import 'package:selawathub/core/theme/colors.dart';
import 'package:selawathub/core/widgets/frosted_bar.dart';
import 'package:selawathub/features/group/group_settings_page.dart';

class GroupPage extends StatefulWidget {
  const GroupPage({super.key});

  @override
  State<GroupPage> createState() => _GroupPageState();
}

class _GroupPageState extends State<GroupPage> {
  bool _hasGroup = true; // mock: user has a group

  @override
  Widget build(BuildContext context) {
    return _hasGroup ? _GroupView(onLeave: () => setState(() => _hasGroup = false)) : SafeArea(bottom: false, child: _NoGroupView(onJoined: () => setState(() => _hasGroup = true)));
  }
}

// ── Group view (when user is in a group) ──
class _GroupView extends StatelessWidget {
  const _GroupView({required this.onLeave});
  final VoidCallback onLeave;

  static const _members = [
    ('Amin', 4120, true, GroupRole.leader),
    ('Sarah', 3891, false, GroupRole.coLeader),
    ('Ahmad', 3450, false, GroupRole.member),
    ('Fatimah', 2987, false, GroupRole.member),
    ('Yusuf', 2654, false, GroupRole.member),
    ('Khadijah', 2210, false, GroupRole.member),
  ];

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
                ],
              ),
            ),
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
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Invite code copied!'),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                );
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

        // Members header
        FadeIn(
          delay: const Duration(milliseconds: 200),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: S.page),
            child: Text('Members', style: tt.titleMedium),
          ),
        ),
        const SizedBox(height: S.s12),

        // Members list
        ...List.generate(_members.length, (i) {
          final (name, count, isYou, role) = _members[i];
          return FadeIn(
            delay: Duration(milliseconds: 240 + i * 40),
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
                      '${i + 1}',
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
        }),

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
                                  .firstWhere((m) => m.$3)
                                  .$4;
                              return GroupSettingsPage(
                                groupName: 'SelawatHub Family',
                                inviteCode: 'SLWT-7861',
                                memberCount: _members.length,
                                userRole: userRole,
                                members: _members,
                                onLeave: onLeave,
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
class _NoGroupView extends StatelessWidget {
  const _NoGroupView({required this.onJoined});
  final VoidCallback onJoined;

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
                onTap: onJoined,
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
                onTap: onJoined,
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
