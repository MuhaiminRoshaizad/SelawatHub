import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:selawathub/core/animations/fade_in.dart';
import 'package:selawathub/core/constants.dart';
import 'package:selawathub/core/services/group_service.dart';
import 'package:selawathub/core/theme/colors.dart';
import 'package:selawathub/core/widgets/app_bottom_sheet.dart';
import 'package:selawathub/core/widgets/app_snackbar.dart';
import 'package:selawathub/core/widgets/confirmation_dialog.dart';
import 'package:selawathub/core/widgets/action_buttons.dart';
import 'package:selawathub/core/widgets/app_text_field.dart';
import 'package:selawathub/core/widgets/frosted_app_bar.dart';
import 'package:selawathub/core/widgets/section_header.dart';
import 'package:selawathub/features/profile/widgets/profile_rows.dart';
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
  late String _groupDescription = widget.groupDescription;
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
                    decoration: appInputDecoration(
                      context: ctx,
                      hintText: 'Enter group name',
                      showCounter: true,
                    ),
                  ),
                  const SizedBox(height: S.s16),
                  ActionButtons(
                    saving: saving,
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

  void _editDescription() {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final tt = Theme.of(context).textTheme;
    final controller = TextEditingController(text: _groupDescription);
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
                    'Edit Description',
                    style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: S.s4),
                  Text(
                    'Describe what your group is about.',
                    style: tt.bodySmall?.copyWith(
                      color: dark ? C.onDark3 : C.onLight3,
                    ),
                  ),
                  const SizedBox(height: S.s20),
                  TextField(
                    controller: controller,
                    autofocus: true,
                    maxLength: 150,
                    maxLines: 3,
                    minLines: 2,
                    style: TextStyle(color: dark ? C.onDark1 : C.onLight1),
                    decoration: appInputDecoration(
                      context: ctx,
                      hintText: 'Enter group description',
                      showCounter: true,
                    ),
                  ),
                  const SizedBox(height: S.s16),
                  ActionButtons(
                    saving: saving,
                    onCancel: () => Navigator.of(ctx).pop(),
                    onConfirm: () async {
                      final desc = controller.text.trim();
                      setSheetState(() => saving = true);
                      try {
                        await GroupService.updateGroup(widget.groupId, description: desc);
                        setState(() => _groupDescription = desc);
                        if (ctx.mounted) {
                          Navigator.of(ctx).pop();
                          showAppSnackBar(ctx, 'Description updated');
                        }
                      } catch (_) {
                        setSheetState(() => saving = false);
                        if (ctx.mounted) showAppSnackBar(ctx, 'Failed to update description', backgroundColor: C.error);
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
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    style: TextStyle(color: dark ? C.onDark1 : C.onLight1),
                    decoration: appInputDecoration(
                      context: ctx,
                      hintText: 'e.g. 10000',
                    ).copyWith(
                      suffixText: 'selawat',
                      suffixStyle:
                          TextStyle(color: dark ? C.onDark3 : C.onLight3),
                    ),
                  ),
                  const SizedBox(height: S.s16),
                  ActionButtons(
                    saving: saving,
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
    showConfirmDialog(
      context: context,
      title: 'Leave group?',
      message: _isLeader
          ? 'Leadership will be automatically transferred to the next co-leader or oldest member.'
          : 'You will no longer see this group\'s progress or contribute to the count.',
      actionLabel: 'Leave',
      errorMessage: 'Failed to leave group',
      onConfirm: () async {
        await GroupService.leaveGroup(widget.groupId);
        if (!mounted) return;
        showAppSnackBar(context, 'You left the group');
        Navigator.of(context).pop();
        widget.onLeave();
      },
    );
  }

  void _confirmDelete() {
    showConfirmDialog(
      context: context,
      title: 'Delete group?',
      message: 'This will permanently delete the group for all members. This action cannot be undone.',
      actionLabel: 'Delete',
      errorMessage: 'Failed to delete group',
      onConfirm: () async {
        await GroupService.leaveGroup(widget.groupId);
        if (!mounted) return;
        showAppSnackBar(context, 'Group deleted');
        Navigator.of(context).pop();
        widget.onLeave();
      },
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
              SectionHeader(text: 'GENERAL'),
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
                          MenuRow(compact: true,
                            icon: CupertinoIcons.pencil,
                            label: 'Edit Group Name',
                            onTap: _editGroupName,
                          ),
                        if (_isLeader)
                          Divider(
                            height: 1,
                            indent: 52,
                            color: dark ? C.darkDivider : C.lightDivider,
                          ),
                        if (_isLeader)
                          MenuRow(compact: true,
                            icon: CupertinoIcons.text_alignleft,
                            label: 'Edit Description',
                            trailingWidget: Text(
                              _groupDescription.isEmpty ? 'None' : _groupDescription,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: dark ? C.onDark3 : C.onLight3,
                                overflow: TextOverflow.ellipsis,
                              ),
                              maxLines: 1,
                            ),
                            onTap: _editDescription,
                          ),
                        if (_isLeader)
                          Divider(
                            height: 1,
                            indent: 52,
                            color: dark ? C.darkDivider : C.lightDivider,
                          ),
                        if (_canManage)
                          MenuRow(compact: true,
                            icon: CupertinoIcons.flag,
                            label: 'Set Daily Goal',
                            trailingWidget: Text(
                              _fmtGoal(_dailyGoal),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: dark ? C.onDark3 : C.onLight3,
                              ),
                            ),
                            onTap: _editDailyGoal,
                          ),
                        if (_canManage)
                          Divider(
                            height: 1,
                            indent: 52,
                            color: dark ? C.darkDivider : C.lightDivider,
                          ),
                        MenuRow(compact: true,
                          icon: CupertinoIcons.doc_on_clipboard,
                          label: 'Copy Invite Code',
                          trailingWidget: Text(
                            widget.inviteCode,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: dark ? C.onDark3 : C.onLight3,
                              letterSpacing: 1.5,
                            ),
                          ),
                          onTap: _copyInviteCode,
                        ),
                        Divider(
                          height: 1,
                          indent: 52,
                          color: dark ? C.darkDivider : C.lightDivider,
                        ),
                        MenuRow(compact: true,
                          icon: CupertinoIcons.share,
                          label: 'Share Invite Link',
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
              SectionHeader(text: 'NOTIFICATIONS'),
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
              SectionHeader(text: 'ROLES & PERMISSIONS'),
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
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ── Manage section (leader or co-leader) ──
              if (_canManage) ...[
                const SizedBox(height: S.s24),

                SectionHeader(text: 'MANAGE'),
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
                            MenuRow(compact: true,
                              icon: CupertinoIcons.person_2,
                              label: 'Manage Roles',
                              onTap: _openManageRoles,
                            ),
                            Divider(
                              height: 1,
                              indent: 52,
                              color:
                                  dark ? C.darkDivider : C.lightDivider,
                            ),
                          ],
                          MenuRow(compact: true,
                            icon: CupertinoIcons.person_badge_minus,
                            label: 'Remove Member',
                            onTap: _openRemoveMember,
                          ),
                          if (_isLeader) ...[
                            Divider(
                              height: 1,
                              indent: 52,
                              color:
                                  dark ? C.darkDivider : C.lightDivider,
                            ),
                            MenuRow(compact: true,
                              icon: CupertinoIcons.arrow_right_arrow_left,
                              label: 'Transfer Leadership',
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
                        MenuRow(compact: true,
                          icon: CupertinoIcons.arrow_left_square,
                          label: 'Leave Group',
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
                          MenuRow(compact: true,
                            icon: CupertinoIcons.trash,
                            label: 'Delete Group',
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
            child: FrostedAppBar(title: 'Group Settings'),
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
  });

  final String emoji;
  final String roleName;
  final String description;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
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

// ─────────────────────────────────────────────────────────
//  Menu row


