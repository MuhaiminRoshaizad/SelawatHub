import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:selawathub/core/animations/bounce_tap.dart';
import 'package:selawathub/core/constants.dart';
import 'package:selawathub/core/services/group_service.dart';
import 'package:selawathub/core/theme/colors.dart';
import 'package:selawathub/core/widgets/app_snackbar.dart';
import 'package:selawathub/core/widgets/frosted_bar.dart';
import 'package:selawathub/features/group/models/group_role.dart';

// ─────────────────────────────────────────────────────────
//  Transfer Leadership Page (single-select)
// ─────────────────────────────────────────────────────────

class TransferLeadershipPage extends StatefulWidget {
  const TransferLeadershipPage({super.key, required this.groupId, required this.members});

  final String groupId;
  final List<GroupMember> members;

  @override
  State<TransferLeadershipPage> createState() =>
      _TransferLeadershipPageState();
}

class _TransferLeadershipPageState extends State<TransferLeadershipPage> {
  String? _selectedId;

  String? get _selectedName {
    if (_selectedId == null) return null;
    return widget.members.firstWhere((m) => m.$5 == _selectedId).$1;
  }

  void _confirmTransfer() {
    if (_selectedId == null) return;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final name = _selectedName;
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
          'Leadership will be transferred to $name. You will become a co-leader.',
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
                await GroupService.updateMemberRole(widget.groupId, _selectedId!, 'leader');
                if (mounted) {
                  Navigator.of(context).pop();
                  showAppSnackBar(context, 'Leadership transferred to $name');
                }
              } catch (_) {
                if (mounted) showAppSnackBar(context, 'Failed to transfer leadership', backgroundColor: C.error);
              }
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
                          selected: _selectedId == widget.members[i].$5,
                          dark: dark,
                          onTap: () => setState(
                              () => _selectedId = widget.members[i].$5),
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
                      color: _selectedId != null
                          ? (dark ? C.primarySoft : C.primary)
                          : (dark ? C.dark4 : C.light3),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Text(
                        _selectedId == null
                            ? 'Select a member'
                            : 'Transfer to $_selectedName',
                        style: tt.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: _selectedId != null
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
