import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:selawathub/core/animations/bounce_tap.dart';
import 'package:selawathub/core/animations/fade_in.dart';
import 'package:selawathub/core/constants.dart';
import 'package:selawathub/core/services/group_service.dart';
import 'package:selawathub/core/theme/colors.dart';
import 'package:selawathub/core/widgets/app_bottom_sheet.dart';
import 'package:selawathub/core/widgets/app_snackbar.dart';
import 'package:selawathub/core/widgets/frosted_bar.dart';
import 'package:selawathub/features/group/manage_roles_page.dart';
import 'package:selawathub/features/group/models/group_role.dart';
import 'package:selawathub/features/group/remove_member_page.dart';
import 'package:selawathub/features/group/transfer_leadership_page.dart';

export 'package:selawathub/features/group/models/group_role.dart';

// ─────────────────────────────────────────────────────────
//  Group Settings Page
// ─────────────────────────────────────────────────────────

class GroupSettingsPage extends StatefulWidget {
  const GroupSettingsPage({
    super.key,
    required this.groupId,
    required this.groupName,
    required this.groupDescription,
    required this.inviteCode,
    required this.dailyGoal,
    required this.memberCount,
    required this.userRole,
    required this.members,
    required this.onLeave,
  });

  final String groupId;
  final String groupName;
  final String groupDescription;
  final String inviteCode;
  final int dailyGoal;
  final int memberCount;
  final GroupRole userRole;
  final List<GroupMember> members;
  final VoidCallback onLeave;

  @override
  State<GroupSettingsPage> createState() => _GroupSettingsPageState();
}

class _GroupSettingsPageState extends State<GroupSettingsPage> {
  bool _muteNotifications = false;
  late String _groupName = widget.groupName;
  late int _dailyGoal = widget.dailyGoal;

  bool get _isLeader => widget.userRole == GroupRole.leader;
  bool get _isCoLeader => widget.userRole == GroupRole.coLeader;
  bool get _canManage => _isLeader || _isCoLeader;

  // Other members (not the current user)
  List<GroupMember> get _otherMembers =>
      widget.members.where((m) => !m.$3).toList();

  bool get _hasCoLeader =>
      widget.members.any((m) => m.$4 == GroupRole.coLeader && !m.$3);

  void _copyInviteCode() {
    Clipboard.setData(ClipboardData(text: widget.inviteCode));
    showAppSnackBar(context, 'Invite code copied!');
  }

  void _editGroupName() {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final tt = Theme.of(context).textTheme;
    final controller = TextEditingController(text: _groupName);
    bool saving = false;
    showAppFormSheet(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) {
          return SafeArea(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                S.page, S.s8, S.page,
                MediaQuery.of(ctx).viewInsets.bottom + S.page,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Edit Group Name',
                    style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: S.s4),
                  Text(
                    'Choose a name that represents your group.',
                    style: tt.bodySmall?.copyWith(
                      color: dark ? C.onDark3 : C.onLight3,
                    ),
                  ),
                  const SizedBox(height: S.s20),
                  TextField(
                    controller: controller,
                    autofocus: true,
                    maxLength: 30,
                    style: TextStyle(color: dark ? C.onDark1 : C.onLight1),
                    decoration: InputDecoration(
                      hintText: 'Enter group name',
                      hintStyle: TextStyle(color: dark ? C.onDark3 : C.onLight3),
                      filled: true,
                      fillColor: dark ? C.dark4 : C.light3,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      counterStyle:
                          TextStyle(color: dark ? C.onDark3 : C.onLight3),
                    ),
                  ),
                  const SizedBox(height: S.s16),
                  _SaveCancelButtons(
                    saving: saving,
                    dark: dark,
                    onCancel: () => Navigator.of(ctx).pop(),
                    onConfirm: () async {
                      final name = controller.text.trim();
                      if (name.isEmpty) return;
                      setSheetState(() => saving = true);
                      try {
                        await GroupService.updateGroup(widget.groupId, name: name);
                        setState(() => _groupName = name);
                        if (ctx.mounted) {
                          Navigator.of(ctx).pop();
                          showAppSnackBar(ctx, 'Group name updated');
                        }
                      } catch (_) {
                        setSheetState(() => saving = false);
                        if (ctx.mounted) showAppSnackBar(ctx, 'Failed to update name', backgroundColor: C.error);
                      }
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _editDailyGoal() {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final tt = Theme.of(context).textTheme;
    final controller = TextEditingController(text: _dailyGoal.toString());
    bool saving = false;
    showAppFormSheet(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) {
          return SafeArea(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                S.page, S.s8, S.page,
                MediaQuery.of(ctx).viewInsets.bottom + S.page,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Set Daily Goal',
                    style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: S.s4),
                  Text(
                    'Set a daily selawat target for your group.',
                    style: tt.bodySmall?.copyWith(
                      color: dark ? C.onDark3 : C.onLight3,
                    ),
                  ),
                  const SizedBox(height: S.s20),
                  TextField(
                    controller: controller,
                    autofocus: true,
                    keyboardType: TextInputType.number,
                    style: TextStyle(color: dark ? C.onDark1 : C.onLight1),
                    decoration: InputDecoration(
                      hintText: 'e.g. 10000',
                      hintStyle:
                          TextStyle(color: dark ? C.onDark3 : C.onLight3),
                      filled: true,
                      fillColor: dark ? C.dark4 : C.light3,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 16),
                      suffixText: 'selawat',
                      suffixStyle:
                          TextStyle(color: dark ? C.onDark3 : C.onLight3),
                    ),
                  ),
                  const SizedBox(height: S.s16),
                  _SaveCancelButtons(
                    saving: saving,
                    dark: dark,
                    onCancel: () => Navigator.of(ctx).pop(),
                    onConfirm: () async {
                      final val = int.tryParse(controller.text.trim()) ?? 0;
                      if (val < 0) return;
                      setSheetState(() => saving = true);
                      try {
                        await GroupService.updateGroup(widget.groupId, dailyGoal: val);
                        setState(() => _dailyGoal = val);
                        if (ctx.mounted) {
                          Navigator.of(ctx).pop();
                          showAppSnackBar(ctx, 'Daily goal updated');
                        }
                      } catch (_) {
                        setSheetState(() => saving = false);
                        if (ctx.mounted) showAppSnackBar(ctx, 'Failed to update goal', backgroundColor: C.error);
                      }
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _openRemoveMember() {
    final members = _isLeader
        ? _otherMembers
        : _otherMembers
            .where((m) => m.$4 == GroupRole.member)
            .toList();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RemoveMemberPage(
          groupId: widget.groupId,
          members: members,
          userRole: widget.userRole,
        ),
      ),
    );
  }

  void _openTransferLeadership() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TransferLeadershipPage(groupId: widget.groupId, members: _otherMembers),
      ),
    );
  }

  void _openManageRoles() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ManageRolesPage(groupId: widget.groupId, members: _otherMembers),
      ),
    );
  }

  void _showNeedCoLeaderDialog() {
    final dark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: dark ? C.dark3 : C.light2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'No co-leader assigned',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: dark ? C.onDark1 : C.onLight1,
          ),
        ),
        content: Text(
          'You must promote a member to co-leader or transfer leadership before leaving the group.',
          style: TextStyle(color: dark ? C.onDark2 : C.onLight2),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(color: dark ? C.primarySoft : C.primary),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _openManageRoles();
            },
            child: Text(
              'Manage Roles',
              style: TextStyle(
                color: dark ? C.primarySoft : C.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmLeave() {
    if (_isLeader && !_hasCoLeader) {
      _showNeedCoLeaderDialog();
      return;
    }
    final dark = Theme.of(context).brightness == Brightness.dark;
    showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: dark ? C.dark3 : C.light2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Leave group?',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: dark ? C.onDark1 : C.onLight1,
          ),
        ),
        content: Text(
          _isLeader
              ? 'Leadership will be automatically transferred to the next co-leader or oldest member.'
              : 'You will no longer see this group\'s progress or contribute to the count.',
          style: TextStyle(color: dark ? C.onDark2 : C.onLight2),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(color: dark ? C.primarySoft : C.primary),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              try {
                await GroupService.leaveGroup(widget.groupId);
              } catch (_) {}
              if (!mounted) return;
              Navigator.of(context).pop();
              widget.onLeave();
            },
            child: Text('Leave', style: TextStyle(color: C.error)),
          ),
        ],
      ),
    );
  }

  void _confirmDelete() {
    final dark = Theme.of(context).brightness == Brightness.dark;
    showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: dark ? C.dark3 : C.light2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Delete group?',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: dark ? C.onDark1 : C.onLight1,
          ),
        ),
        content: Text(
          'This will permanently delete the group for all members. This action cannot be undone.',
          style: TextStyle(color: dark ? C.onDark2 : C.onLight2),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(color: dark ? C.primarySoft : C.primary),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              try {
                await GroupService.leaveGroup(widget.groupId);
              } catch (_) {}
              if (!mounted) return;
              Navigator.of(context).pop();
              widget.onLeave();
            },
            child: Text('Delete', style: TextStyle(color: C.error)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final tt = Theme.of(context).textTheme;
    final accent = dark ? C.primarySoft : C.primary;

    return Scaffold(
      backgroundColor: dark ? C.dark1 : C.light1,
      body: Stack(
        children: [
          ListView(
            padding: EdgeInsets.zero,
            children: [
              SizedBox(height: MediaQuery.of(context).padding.top + 56),

              const SizedBox(height: S.s24),

              // ── Group info card ──
              FadeIn(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: S.page),
                  child: Container(
                    padding: const EdgeInsets.all(S.s20),
                    decoration: BoxDecoration(
                      color: dark
                          ? C.primaryMuted.withValues(alpha: 0.15)
                          : C.primary.withValues(alpha: 0.04),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: dark
                            ? C.primarySoft.withValues(alpha: 0.15)
                            : C.primary.withValues(alpha: 0.08),
                      ),
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: dark
                                ? C.primaryMuted.withValues(alpha: 0.3)
                                : C.primary.withValues(alpha: 0.1),
                          ),
                          child: const Center(
                            child: Text('🕌', style: TextStyle(fontSize: 28)),
                          ),
                        ),
                        const SizedBox(height: S.s12),
                        Text(
                          _groupName,
                          style: tt.titleLarge
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: S.s4),
                        Text(
                          '${widget.memberCount} members',
                          style: tt.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: S.s24),

              // ── General section ──
              _SectionHeader(label: 'GENERAL', dark: dark),
              const SizedBox(height: S.s8),

              FadeIn(
                delay: const Duration(milliseconds: 80),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: S.page),
                  child: Container(
                    decoration: BoxDecoration(
                      color: dark ? C.dark3 : C.light2,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        if (_isLeader)
                          _MenuRow(
                            icon: CupertinoIcons.pencil,
                            label: 'Edit Group Name',
                            dark: dark,
                            onTap: _editGroupName,
                          ),
                        if (_isLeader)
                          Divider(
                            height: 1,
                            indent: 52,
                            color: dark ? C.darkDivider : C.lightDivider,
                          ),
                        if (_canManage)
                          _MenuRow(
                            icon: CupertinoIcons.flag,
                            label: 'Set Daily Goal',
                            trailing: Text(
                              _fmtGoal(_dailyGoal),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: dark ? C.onDark3 : C.onLight3,
                              ),
                            ),
                            dark: dark,
                            onTap: _editDailyGoal,
                          ),
                        if (_canManage)
                          Divider(
                            height: 1,
                            indent: 52,
                            color: dark ? C.darkDivider : C.lightDivider,
                          ),
                        _MenuRow(
                          icon: CupertinoIcons.doc_on_clipboard,
                          label: 'Copy Invite Code',
                          trailing: Text(
                            widget.inviteCode,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: dark ? C.onDark3 : C.onLight3,
                              letterSpacing: 1.5,
                            ),
                          ),
                          dark: dark,
                          onTap: _copyInviteCode,
                        ),
                        Divider(
                          height: 1,
                          indent: 52,
                          color: dark ? C.darkDivider : C.lightDivider,
                        ),
                        _MenuRow(
                          icon: CupertinoIcons.share,
                          label: 'Share Invite Link',
                          dark: dark,
                          onTap: () {
                            // TODO: share invite
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: S.s24),

              // ── Notifications section ──
              _SectionHeader(label: 'NOTIFICATIONS', dark: dark),
              const SizedBox(height: S.s8),

              FadeIn(
                delay: const Duration(milliseconds: 140),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: S.s20, vertical: S.s8),
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: accent.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Icon(
                            _muteNotifications
                                ? CupertinoIcons.bell_slash
                                : CupertinoIcons.bell,
                            size: 16,
                            color: accent,
                          ),
                        ),
                      ),
                      const SizedBox(width: S.s12),
                      Expanded(
                        child: Text('Mute Notifications',
                            style: tt.titleSmall),
                      ),
                      Switch.adaptive(
                        value: _muteNotifications,
                        onChanged: (v) =>
                            setState(() => _muteNotifications = v),
                        activeTrackColor: accent.withValues(alpha: 0.4),
                        activeThumbColor: accent,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: S.s24),

              // ── Roles & Permissions section ──
              _SectionHeader(label: 'ROLES & PERMISSIONS', dark: dark),
              const SizedBox(height: S.s8),

              FadeIn(
                delay: const Duration(milliseconds: 170),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: S.page),
                  child: Container(
                    decoration: BoxDecoration(
                      color: dark ? C.dark3 : C.light2,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        _RoleInfoRow(
                          emoji: '👑',
                          roleName: 'Leader',
                          description:
                              'Full group control. Edit name, manage roles, remove any member, transfer leadership, delete group.',
                          dark: dark,
                        ),
                        Divider(
                          height: 1,
                          indent: S.s16,
                          endIndent: S.s16,
                          color: dark ? C.darkDivider : C.lightDivider,
                        ),
                        _RoleInfoRow(
                          emoji: '⭐',
                          roleName: 'Co-leader',
                          description:
                              'Can remove regular members and manage invites. Auto-promoted to leader if leader leaves.',
                          dark: dark,
                        ),
                        Divider(
                          height: 1,
                          indent: S.s16,
                          endIndent: S.s16,
                          color: dark ? C.darkDivider : C.lightDivider,
                        ),
                        _RoleInfoRow(
                          emoji: '👤',
                          roleName: 'Member',
                          description:
                              'Can participate in group selawat counting and view group progress.',
                          dark: dark,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ── Manage section (leader or co-leader) ──
              if (_canManage) ...[
                const SizedBox(height: S.s24),

                _SectionHeader(label: 'MANAGE', dark: dark),
                const SizedBox(height: S.s8),

                FadeIn(
                  delay: const Duration(milliseconds: 200),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: S.page),
                    child: Container(
                      decoration: BoxDecoration(
                        color: dark ? C.dark3 : C.light2,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          if (_isLeader) ...[
                            _MenuRow(
                              icon: CupertinoIcons.person_2,
                              label: 'Manage Roles',
                              dark: dark,
                              onTap: _openManageRoles,
                            ),
                            Divider(
                              height: 1,
                              indent: 52,
                              color:
                                  dark ? C.darkDivider : C.lightDivider,
                            ),
                          ],
                          _MenuRow(
                            icon: CupertinoIcons.person_badge_minus,
                            label: 'Remove Member',
                            dark: dark,
                            onTap: _openRemoveMember,
                          ),
                          if (_isLeader) ...[
                            Divider(
                              height: 1,
                              indent: 52,
                              color:
                                  dark ? C.darkDivider : C.lightDivider,
                            ),
                            _MenuRow(
                              icon: CupertinoIcons.arrow_right_arrow_left,
                              label: 'Transfer Leadership',
                              dark: dark,
                              onTap: _openTransferLeadership,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ],

              const SizedBox(height: S.s32),

              // ── Danger zone ──
              FadeIn(
                delay: const Duration(milliseconds: 260),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: S.page),
                  child: Container(
                    decoration: BoxDecoration(
                      color: dark ? C.dark3 : C.light2,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        _MenuRow(
                          icon: CupertinoIcons.arrow_left_square,
                          label: 'Leave Group',
                          dark: dark,
                          isDestructive: true,
                          onTap: _confirmLeave,
                        ),
                        if (_isLeader) ...[
                          Divider(
                            height: 1,
                            indent: 52,
                            color:
                                dark ? C.darkDivider : C.lightDivider,
                          ),
                          _MenuRow(
                            icon: CupertinoIcons.trash,
                            label: 'Delete Group',
                            dark: dark,
                            isDestructive: true,
                            onTap: _confirmDelete,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),

              SizedBox(
                  height:
                      MediaQuery.of(context).padding.bottom + S.s32),
            ],
          ),

          // ── Frosted app bar ──
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: FrostedBar(
              child: SizedBox(
                height: 56,
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: S.s16),
                        child: Icon(
                          CupertinoIcons.chevron_left,
                          size: 20,
                          color: dark ? C.onDark1 : C.onLight1,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'Group Settings',
                        style: tt.titleLarge
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ),
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

// ─────────────────────────────────────────────────────────
//  Role info row (for Roles & Permissions card)
// ─────────────────────────────────────────────────────────

class _RoleInfoRow extends StatelessWidget {
  const _RoleInfoRow({
    required this.emoji,
    required this.roleName,
    required this.description,
    required this.dark,
  });

  final String emoji;
  final String roleName;
  final String description;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: S.s16, vertical: S.s12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: S.s12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  roleName,
                  style: tt.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: dark ? C.onDark1 : C.onLight1,
                  ),
                ),
                const SizedBox(height: S.s2),
                Text(
                  description,
                  style: tt.bodySmall?.copyWith(
                    color: dark ? C.onDark3 : C.onLight3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
//  Section header
// ─────────────────────────────────────────────────────────

String _fmtGoal(int n) {
  if (n >= 1000) return '${(n / 1000).toStringAsFixed(n % 1000 == 0 ? 0 : 1)}k';
  return '$n';
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label, required this.dark});
  final String label;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: S.page),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.8,
          color: dark ? C.onDark3 : C.onLight3,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
//  Menu row
// ─────────────────────────────────────────────────────────

class _MenuRow extends StatelessWidget {
  const _MenuRow({
    required this.icon,
    required this.label,
    required this.dark,
    required this.onTap,
    this.trailing,
    this.isDestructive = false,
  });

  final IconData icon;
  final String label;
  final bool dark;
  final VoidCallback onTap;
  final Widget? trailing;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final color = isDestructive
        ? C.error
        : (dark ? C.onDark1 : C.onLight1);
    final iconColor = isDestructive
        ? C.error
        : (dark ? C.onDark2 : C.onLight2);

    return BounceTap(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: S.s16, vertical: S.s12),
        child: Row(
          children: [
            Icon(icon, size: 18, color: iconColor),
            const SizedBox(width: S.s12),
            Expanded(
              child: Text(
                label,
                style: tt.bodyMedium?.copyWith(color: color),
              ),
            ),
            ?trailing,
            if (!isDestructive && trailing == null)
              Icon(
                CupertinoIcons.chevron_right,
                size: 14,
                color: dark ? C.onDark3 : C.onLight3,
              ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
//  Save / Cancel buttons with loading state
// ─────────────────────────────────────────────────────────

class _SaveCancelButtons extends StatelessWidget {
  const _SaveCancelButtons({
    required this.saving,
    required this.dark,
    required this.onCancel,
    required this.onConfirm,
  });

  final bool saving;
  final bool dark;
  final VoidCallback onCancel;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Row(
      children: [
        Expanded(
          child: BounceTap(
            onTap: saving ? null : onCancel,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: S.s12),
              decoration: BoxDecoration(
                color: dark ? C.dark4 : C.light3,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(
                  'Cancel',
                  style: tt.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: dark ? C.onDark2 : C.onLight2,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: S.s12),
        Expanded(
          child: BounceTap(
            onTap: saving ? null : onConfirm,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: S.s12),
              decoration: BoxDecoration(
                color: dark ? C.primarySoft : C.primary,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: saving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: C.white),
                      )
                    : Text(
                        'Save',
                        style: tt.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: C.white,
                        ),
                      ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
