import 'package:flutter/material.dart';
import 'package:selawathub/core/animations/bounce_tap.dart';
import 'package:selawathub/core/constants.dart';
import 'package:selawathub/core/services/group_service.dart';
import 'package:selawathub/core/theme/colors.dart';
import 'package:selawathub/core/widgets/app_snackbar.dart';
import 'package:selawathub/core/widgets/frosted_app_bar.dart';
import 'package:selawathub/features/group/models/group_role.dart';
import 'package:selawathub/l10n/generated/app_localizations.dart';

// ─────────────────────────────────────────────────────────
//  Manage Roles Page (leader only)
// ─────────────────────────────────────────────────────────

class ManageRolesPage extends StatefulWidget {
  const ManageRolesPage({super.key, required this.groupId, required this.members});
  final String groupId;
  final List<GroupMember> members;

  @override
  State<ManageRolesPage> createState() => _ManageRolesPageState();
}

class _ManageRolesPageState extends State<ManageRolesPage> {
  late final Map<String, GroupRole> _roles;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _roles = {
      for (final m in widget.members) m.$5: m.$4,
    };
  }

  void _toggleRole(String userId) {
    setState(() {
      _roles[userId] = _roles[userId] == GroupRole.coLeader
          ? GroupRole.member
          : GroupRole.coLeader;
    });
  }

  Future<void> _saveChanges() async {
    setState(() => _saving = true);
    try {
      for (final m in widget.members) {
        final userId = m.$5;
        final newRole = _roles[userId]!;
        if (newRole != m.$4) {
          final roleStr = newRole == GroupRole.coLeader ? 'co_leader' : 'member';
          await GroupService.updateMemberRole(widget.groupId, userId, roleStr);
        }
      }
      if (mounted) {
        Navigator.pop(context);
        showAppSnackBar(context, AppL10n.of(context).manageRolesUpdated);
      }
    } catch (_) {
      if (mounted) {
        setState(() => _saving = false);
        showAppSnackBar(context, AppL10n.of(context).manageRolesFailed, backgroundColor: C.error);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final tt = Theme.of(context).textTheme;
    final l = AppL10n.of(context);

    return Scaffold(
      backgroundColor: dark ? C.dark1 : C.light1,
      body: Stack(
        children: [
          ListView(
            padding: EdgeInsets.zero,
            children: [
              SizedBox(height: MediaQuery.of(context).padding.top + 56),
              const SizedBox(height: S.s24),

              // Instruction
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: S.page),
                child: Text(
                  l.manageRolesIntro,
                  style: tt.bodyMedium?.copyWith(
                    color: dark ? C.onDark2 : C.onLight2,
                  ),
                ),
              ),
              const SizedBox(height: S.s16),

              // Member list
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: S.page),
                child: Container(
                  decoration: BoxDecoration(
                    color: dark ? C.dark3 : C.light2,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      for (var i = 0; i < widget.members.length; i++) ...[
                        if (i > 0)
                          Divider(
                            height: 1,
                            indent: 56,
                            color: dark ? C.darkDivider : C.lightDivider,
                          ),
                        _ManageRoleRow(
                          name: widget.members[i].$1,
                          count: widget.members[i].$2,
                          role: _roles[widget.members[i].$5]!,
                          dark: dark,
                          onTap: () => _toggleRole(widget.members[i].$5),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              const SizedBox(height: S.s32),

              // Save button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: S.page),
                child: BounceTap(
                  onTap: _saving ? null : _saveChanges,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: S.s16),
                    decoration: BoxDecoration(
                      color: dark ? C.primarySoft : C.primary,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: _saving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: C.white),
                            )
                          : Text(
                              l.groupSaveChanges,
                              style: tt.bodyLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: C.white,
                              ),
                            ),
                    ),
                  ),
                ),
              ),

              SizedBox(
                  height: MediaQuery.of(context).padding.bottom + S.s32),
            ],
          ),

          // ── Frosted app bar ──
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: FrostedAppBar(title: l.groupManageRolesTitle),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────

class _ManageRoleRow extends StatelessWidget {
  const _ManageRoleRow({
    required this.name,
    required this.count,
    required this.role,
    required this.dark,
    required this.onTap,
  });

  final String name;
  final int count;
  final GroupRole role;
  final bool dark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final l = AppL10n.of(context);
    final isCoLeader = role == GroupRole.coLeader;
    return BounceTap(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: S.s16, vertical: S.s12),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: dark
                    ? C.primaryMuted.withValues(alpha: 0.3)
                    : C.primary.withValues(alpha: 0.1),
              ),
              child: Center(
                child: Text(
                  name[0].toUpperCase(),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: dark ? C.primarySoft : C.primary,
                  ),
                ),
              ),
            ),
            const SizedBox(width: S.s12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        name,
                        style: tt.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: dark ? C.onDark1 : C.onLight1,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '$count selawat',
                    style: tt.bodySmall?.copyWith(
                      color: dark ? C.onDark3 : C.onLight3,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            // Role badge chip
            Container(
              padding: const EdgeInsets.symmetric(horizontal: S.s8, vertical: S.s4),
              decoration: BoxDecoration(
                color: isCoLeader
                    ? (dark
                        ? C.primaryMuted.withValues(alpha: 0.3)
                        : C.primary.withValues(alpha: 0.1))
                    : (dark ? C.dark4 : C.light3),
                borderRadius: BorderRadius.circular(S.s8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isCoLeader ? '⭐' : '👤',
                    style: const TextStyle(fontSize: 12),
                  ),
                  const SizedBox(width: S.s4),
                  Text(
                    isCoLeader ? l.groupRoleCoLeader : l.groupRoleMember,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isCoLeader
                          ? (dark ? C.primarySoft : C.primary)
                          : (dark ? C.onDark3 : C.onLight3),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
