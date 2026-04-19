import 'package:flutter/material.dart';
import 'package:selawathub/core/animations/fade_in.dart';
import 'package:selawathub/core/constants.dart';
import 'package:selawathub/core/theme/colors.dart';
import 'package:selawathub/features/group/models/group_role.dart';

class MemberTile extends StatelessWidget {
  const MemberTile({
    super.key,
    required this.name,
    required this.count,
    required this.rank,
    required this.role,
    required this.isYou,
    required this.animationDelay,
    this.avatarUrl,
  });

  final String name;
  final int count;
  final int rank;
  final GroupRole role;
  final bool isYou;
  final Duration animationDelay;
  final String? avatarUrl;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final tt = Theme.of(context).textTheme;

    return FadeIn(
      delay: animationDelay,
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
                backgroundImage: avatarUrl != null && avatarUrl!.isNotEmpty
                    ? NetworkImage(avatarUrl!)
                    : null,
                child: avatarUrl != null && avatarUrl!.isNotEmpty
                    ? null
                    : Text(
                        name.isNotEmpty ? name[0] : '?',
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
