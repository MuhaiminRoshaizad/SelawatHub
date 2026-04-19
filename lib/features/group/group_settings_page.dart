import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:selawathub/core/animations/bounce_tap.dart';
import 'package:selawathub/core/animations/fade_in.dart';
import 'package:selawathub/core/constants.dart';
import 'package:selawathub/core/theme/colors.dart';
import 'package:selawathub/core/widgets/action_buttons.dart';
import 'package:selawathub/core/widgets/frosted_bar.dart';

enum GroupRole { leader, coLeader, member }

// Member tuple: (name, count, isYou, role)
typedef GroupMember = (String, int, bool, GroupRole);

// ─────────────────────────────────────────────────────────
//  Group Settings Page
// ─────────────────────────────────────────────────────────

class GroupSettingsPage extends StatefulWidget {
  const GroupSettingsPage({
    super.key,
    required this.groupName,
    required this.inviteCode,
    required this.memberCount,
    required this.userRole,
    required this.members,
    required this.onLeave,
  });

  final String groupName;
  final String inviteCode;
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
  int _dailyGoal = 25000; // mock default

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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Invite code copied!'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _editGroupName() {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final tt = Theme.of(context).textTheme;
    final controller = TextEditingController(text: _groupName);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: dark ? C.dark3 : C.light2,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            left: S.s24,
            right: S.s24,
            top: S.s24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + S.s24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            // Drag handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: (dark ? C.onDark3 : C.onLight3)
                      .withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: S.s20),
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
            ActionButtons(
              onCancel: () => Navigator.of(ctx).pop(),
              onConfirm: () {
                final name = controller.text.trim();
                if (name.isNotEmpty) {
                  setState(() => _groupName = name);
                }
                Navigator.of(ctx).pop();
              },
            ),
          ],
        ),
      ),
      ),
    );
  }

  void _editDailyGoal() {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final tt = Theme.of(context).textTheme;
    final controller = TextEditingController(text: _dailyGoal.toString());
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: dark ? C.dark3 : C.light2,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            left: S.s24,
            right: S.s24,
            top: S.s24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + S.s24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: (dark ? C.onDark3 : C.onLight3)
                        .withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: S.s20),
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
              ActionButtons(
                onCancel: () => Navigator.of(ctx).pop(),
                onConfirm: () {
                  final val =
                      int.tryParse(controller.text.trim()) ?? 0;
                  if (val > 0) {
                    setState(() => _dailyGoal = val);
                  }
                  Navigator.of(ctx).pop();
                },
              ),
            ],
          ),
        ),
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
        builder: (_) => _RemoveMemberPage(
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
        builder: (_) => _TransferLeadershipPage(members: _otherMembers),
      ),
    );
  }

  void _openManageRoles() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _ManageRolesPage(members: _otherMembers),
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
            onPressed: () {
              Navigator.of(ctx).pop();
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
            onPressed: () {
              Navigator.of(ctx).pop();
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
                  padding: const EdgeInsets.symmetric(horizontal: S.page),
                  child: Container(
                    decoration: BoxDecoration(
                      color: dark ? C.dark3 : C.light2,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: S.s16, vertical: S.s4),
                      child: Row(
                        children: [
                          Icon(
                            _muteNotifications
                                ? CupertinoIcons.bell_slash
                                : CupertinoIcons.bell,
                            size: 18,
                            color: dark ? C.onDark2 : C.onLight2,
                          ),
                          const SizedBox(width: S.s12),
                          Expanded(
                            child: Text(
                              'Mute Notifications',
                              style: tt.bodyMedium?.copyWith(
                                color: dark ? C.onDark1 : C.onLight1,
                              ),
                            ),
                          ),
                          Switch.adaptive(
                            value: _muteNotifications,
                            onChanged: (v) =>
                                setState(() => _muteNotifications = v),
                            activeTrackColor:
                                dark ? C.primarySoft : C.primary,
                            activeThumbColor: C.white,
                          ),
                        ],
                      ),
                    ),
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
//  Manage Roles Page (leader only)
// ─────────────────────────────────────────────────────────

class _ManageRolesPage extends StatefulWidget {
  const _ManageRolesPage({required this.members});
  final List<GroupMember> members;

  @override
  State<_ManageRolesPage> createState() => _ManageRolesPageState();
}

class _ManageRolesPageState extends State<_ManageRolesPage> {
  late final Map<String, GroupRole> _roles;

  @override
  void initState() {
    super.initState();
    _roles = {
      for (final m in widget.members) m.$1: m.$4,
    };
  }

  void _toggleRole(String name) {
    setState(() {
      _roles[name] = _roles[name] == GroupRole.coLeader
          ? GroupRole.member
          : GroupRole.coLeader;
    });
  }

  void _saveChanges() {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Roles updated'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final tt = Theme.of(context).textTheme;

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
                  'Tap a member to toggle between co-leader and member.',
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
                          role: _roles[widget.members[i].$1]!,
                          dark: dark,
                          onTap: () => _toggleRole(widget.members[i].$1),
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
                  onTap: _saveChanges,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: S.s16),
                    decoration: BoxDecoration(
                      color: dark ? C.primarySoft : C.primary,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Text(
                        'Save Changes',
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
                        'Manage Roles',
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
//  Manage role row (toggle co-leader / member)
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
                    isCoLeader ? 'Co-leader' : 'Member',
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

// ─────────────────────────────────────────────────────────
//  Remove Member Page (multi-select)
// ─────────────────────────────────────────────────────────

class _RemoveMemberPage extends StatefulWidget {
  const _RemoveMemberPage({
    required this.members,
    required this.userRole,
  });
  final List<GroupMember> members;
  final GroupRole userRole;

  @override
  State<_RemoveMemberPage> createState() => _RemoveMemberPageState();
}

class _RemoveMemberPageState extends State<_RemoveMemberPage> {
  final Set<String> _selected = {};

  void _confirmRemove() {
    if (_selected.isEmpty) return;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final count = _selected.length;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: dark ? C.dark3 : C.light2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Remove $count member${count > 1 ? 's' : ''}?',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: dark ? C.onDark1 : C.onLight1,
          ),
        ),
        content: Text(
          'The following will be removed:\n${_selected.join(', ')}',
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
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('$count member${count > 1 ? 's' : ''} removed'),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              );
            },
            child: Text('Remove', style: TextStyle(color: C.error)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final tt = Theme.of(context).textTheme;

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
                  'Select members to remove from the group.',
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
                        _MemberCheckRow(
                          name: widget.members[i].$1,
                          count: widget.members[i].$2,
                          role: widget.members[i].$4,
                          selected:
                              _selected.contains(widget.members[i].$1),
                          dark: dark,
                          onTap: () {
                            setState(() {
                              final name = widget.members[i].$1;
                              if (_selected.contains(name)) {
                                _selected.remove(name);
                              } else {
                                _selected.add(name);
                              }
                            });
                          },
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              const SizedBox(height: S.s32),

              // Remove button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: S.page),
                child: BounceTap(
                  onTap: _confirmRemove,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: S.s16),
                    decoration: BoxDecoration(
                      color: _selected.isNotEmpty
                          ? C.error
                          : (dark ? C.dark4 : C.light3),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Text(
                        _selected.isEmpty
                            ? 'Select members'
                            : 'Remove ${_selected.length} member${_selected.length > 1 ? 's' : ''}',
                        style: tt.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: _selected.isNotEmpty
                              ? C.white
                              : (dark ? C.onDark3 : C.onLight3),
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
                        'Remove Member',
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
//  Transfer Leadership Page (single-select)
// ─────────────────────────────────────────────────────────

class _TransferLeadershipPage extends StatefulWidget {
  const _TransferLeadershipPage({required this.members});

  final List<GroupMember> members;

  @override
  State<_TransferLeadershipPage> createState() =>
      _TransferLeadershipPageState();
}

class _TransferLeadershipPageState extends State<_TransferLeadershipPage> {
  String? _selected;

  void _confirmTransfer() {
    if (_selected == null) return;
    final dark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: dark ? C.dark3 : C.light2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Transfer leadership?',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: dark ? C.onDark1 : C.onLight1,
          ),
        ),
        content: Text(
          'Leadership will be transferred to $_selected. You will become a co-leader.',
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
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content:
                      Text('Leadership transferred to $_selected'),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              );
            },
            child: Text(
              'Transfer',
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

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final tt = Theme.of(context).textTheme;

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
                  'Choose a member to become the new group leader.',
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
                        _MemberRadioRow(
                          name: widget.members[i].$1,
                          count: widget.members[i].$2,
                          selected: _selected == widget.members[i].$1,
                          dark: dark,
                          onTap: () => setState(
                              () => _selected = widget.members[i].$1),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              const SizedBox(height: S.s32),

              // Transfer button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: S.page),
                child: BounceTap(
                  onTap: _confirmTransfer,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: S.s16),
                    decoration: BoxDecoration(
                      color: _selected != null
                          ? (dark ? C.primarySoft : C.primary)
                          : (dark ? C.dark4 : C.light3),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Text(
                        _selected == null
                            ? 'Select a member'
                            : 'Transfer to $_selected',
                        style: tt.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: _selected != null
                              ? C.white
                              : (dark ? C.onDark3 : C.onLight3),
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
                        'Transfer Leadership',
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
//  Member row with checkbox (for remove member)
// ─────────────────────────────────────────────────────────

class _MemberCheckRow extends StatelessWidget {
  const _MemberCheckRow({
    required this.name,
    required this.count,
    required this.role,
    required this.selected,
    required this.dark,
    required this.onTap,
  });

  final String name;
  final int count;
  final GroupRole role;
  final bool selected;
  final bool dark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
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
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                color: selected
                    ? C.error
                    : (dark ? C.dark4 : C.light3),
                border: Border.all(
                  color: selected
                      ? C.error
                      : (dark ? C.onDark3 : C.onLight3)
                          .withValues(alpha: 0.3),
                  width: 1.5,
                ),
              ),
              child: selected
                  ? const Icon(Icons.check, size: 16, color: C.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
//  Member row with radio (for transfer leadership)
// ─────────────────────────────────────────────────────────

class _MemberRadioRow extends StatelessWidget {
  const _MemberRadioRow({
    required this.name,
    required this.count,
    required this.selected,
    required this.dark,
    required this.onTap,
  });

  final String name;
  final int count;
  final bool selected;
  final bool dark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
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
                  Text(
                    name,
                    style: tt.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: dark ? C.onDark1 : C.onLight1,
                    ),
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
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected
                    ? (dark ? C.primarySoft : C.primary)
                    : Colors.transparent,
                border: Border.all(
                  color: selected
                      ? (dark ? C.primarySoft : C.primary)
                      : (dark ? C.onDark3 : C.onLight3)
                          .withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
              child: selected
                  ? const Center(
                      child: Icon(Icons.check, size: 14, color: C.white))
                  : null,
            ),
          ],
        ),
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
