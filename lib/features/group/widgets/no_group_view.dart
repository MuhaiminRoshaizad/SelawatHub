import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:selawathub/core/animations/bounce_tap.dart';
import 'package:selawathub/core/animations/fade_in.dart';
import 'package:selawathub/core/constants.dart';
import 'package:selawathub/core/services/group_service.dart';
import 'package:selawathub/core/theme/colors.dart';
import 'package:selawathub/core/widgets/app_bottom_sheet.dart';
import 'package:selawathub/core/widgets/app_snackbar.dart';
import 'package:selawathub/l10n/generated/app_localizations.dart';

class NoGroupView extends StatefulWidget {
  const NoGroupView({super.key, required this.onJoined});
  final VoidCallback onJoined;

  @override
  State<NoGroupView> createState() => _NoGroupViewState();
}

class _NoGroupViewState extends State<NoGroupView> {
  final _codeCtrl = TextEditingController();
  bool _joining = false;

  @override
  void dispose() {
    _codeCtrl.dispose();
    super.dispose();
  }

  Future<void> _joinGroup() async {
    final l = AppL10n.of(context);
    if (_codeCtrl.text.trim().isEmpty) {
      showAppSnackBar(context, l.noGroupEnterCode);
      return;
    }
    if (_joining) return;
    setState(() => _joining = true);
    try {
      final group = await GroupService.joinGroup(_codeCtrl.text.trim());
      if (!mounted) return;
      if (group == null) {
        setState(() => _joining = false);
        showAppSnackBar(context, l.noGroupInvalidCode);
        return;
      }
      final groupName = group['name'] as String? ?? l.groupGroupFallback;
      final dark = Theme.of(context).brightness == Brightness.dark;
      final tt = Theme.of(context).textTheme;
      final onJoined = widget.onJoined;

      showAppFormSheet(
        context: context,
        isScrollControlled: false,
        builder: (ctx) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(S.page, S.s8, S.page, S.page),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(CupertinoIcons.checkmark_circle_fill, size: 56, color: C.success),
                const SizedBox(height: S.s16),
                Text(l.noGroupJoinedTitle, style: tt.titleLarge),
                const SizedBox(height: S.s8),
                Text(
                  l.noGroupWelcomeTo(groupName),
                  style: tt.bodyMedium?.copyWith(color: dark ? C.onDark2 : C.onLight2),
                ),
                const SizedBox(height: S.s24),
                SizedBox(
                  width: double.infinity,
                  child: BounceTap(
                    onTap: () {
                      Navigator.pop(ctx);
                      onJoined();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: dark ? C.primarySoft : C.primary,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Center(
                        child: Text(
                          l.commonContinue,
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: C.white),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } catch (e) {
      debugPrint('[JoinGroup] error: $e');
      if (mounted) {
        setState(() => _joining = false);
        showAppSnackBar(context, l.noGroupJoinFailed);
      }
    }
  }

  Future<void> _createGroup() async {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final tt = Theme.of(context).textTheme;
    final l = AppL10n.of(context);

    showAppFormSheet(
      context: context,
      builder: (ctx) {
        final nameCtrl = TextEditingController();
        final descCtrl = TextEditingController();
        bool sheetCreating = false;
        return StatefulBuilder(
          builder: (ctx, setSheetState) => Padding(
            padding: EdgeInsets.only(
              left: S.page,
              right: S.page,
              top: S.s8,
              bottom: MediaQuery.of(ctx).viewInsets.bottom +
                  MediaQuery.of(ctx).padding.bottom +
                  S.page,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l.noGroupCreateTitle,
                  style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: S.s24),
                TextField(
                  controller: nameCtrl,
                  decoration: InputDecoration(hintText: l.noGroupNameHint),
                ),
                const SizedBox(height: S.s16),
                TextField(
                  controller: descCtrl,
                  maxLines: 3,
                  decoration: InputDecoration(hintText: l.noGroupDescHint),
                ),
                const SizedBox(height: S.s24),
                Row(
                  children: [
                    Expanded(
                      child: BounceTap(
                        onTap: sheetCreating ? null : () => Navigator.pop(ctx),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: dark ? C.darkDivider : C.lightDivider),
                          ),
                          child: Center(
                            child: Text(
                              l.commonCancel,
                              style: TextStyle(
                                fontSize: 14,
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
                        onTap: sheetCreating
                            ? null
                            : () async {
                                if (nameCtrl.text.trim().isEmpty) {
                                  showAppSnackBar(ctx, l.noGroupNameRequired);
                                  return;
                                }
                                setSheetState(() => sheetCreating = true);
                                try {
                                  final group = await GroupService.createGroup(
                                    name: nameCtrl.text.trim(),
                                    description: descCtrl.text.trim(),
                                  );
                                  if (!ctx.mounted) return;
                                  if (group != null) {
                                    Navigator.pop(ctx);
                                    if (mounted) {
                                      showAppSnackBar(context, l.noGroupCreated);
                                    }
                                    widget.onJoined();
                                  } else {
                                    setSheetState(() => sheetCreating = false);
                                    showAppSnackBar(ctx, l.noGroupCreateFailed);
                                  }
                                } catch (e) {
                                  debugPrint('[CreateGroup] error: $e');
                                  if (ctx.mounted) {
                                    setSheetState(() => sheetCreating = false);
                                    showAppSnackBar(ctx, '${l.commonError}: ${e.toString()}');
                                  }
                                }
                              },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: sheetCreating
                                ? (dark ? C.primarySoft.withValues(alpha: 0.5) : C.primary.withValues(alpha: 0.5))
                                : (dark ? C.primarySoft : C.primary),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: sheetCreating
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: C.white),
                                  )
                                : Text(
                                    l.commonCreate,
                                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: C.white),
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final tt = Theme.of(context).textTheme;
    final l = AppL10n.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: S.page),
      child: Column(
        children: [
          const Spacer(flex: 2),

          FadeIn(child: Text('🤝', style: TextStyle(fontSize: 56))),
          const SizedBox(height: S.s24),

          FadeIn(
            delay: const Duration(milliseconds: 80),
            child: Text(l.noGroupJoinTitle, style: tt.headlineLarge, textAlign: TextAlign.center),
          ),
          const SizedBox(height: S.s8),

          FadeIn(
            delay: const Duration(milliseconds: 120),
            child: Text(
              l.noGroupJoinSubtitle,
              style: tt.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ),

          const SizedBox(height: S.s40),

          // Join with code
          FadeIn(
            delay: const Duration(milliseconds: 200),
            child: TextField(
              controller: _codeCtrl,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: dark ? C.onDark1 : C.onLight1,
                letterSpacing: 3,
              ),
              decoration: InputDecoration(
                hintText: l.noGroupCodePlaceholder,
                hintStyle: TextStyle(fontSize: 14, letterSpacing: 3, color: dark ? C.onDark3 : C.onLight3),
              ),
            ),
          ),

          const SizedBox(height: S.s16),

          // Join button with loading spinner
          FadeIn(
            delay: const Duration(milliseconds: 260),
            child: SizedBox(
              width: double.infinity,
              child: BounceTap(
                onTap: _joining ? null : _joinGroup,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: _joining
                        ? (dark ? C.primarySoft.withValues(alpha: 0.5) : C.primary.withValues(alpha: 0.5))
                        : (dark ? C.primarySoft : C.primary),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: _joining
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: C.white),
                          )
                        : Text(
                            l.noGroupJoinCta,
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: C.white),
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

          // Create button
          FadeIn(
            delay: const Duration(milliseconds: 380),
            child: SizedBox(
              width: double.infinity,
              child: BounceTap(
                onTap: _createGroup,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: dark ? C.darkDivider : C.lightDivider),
                  ),
                  child: Center(
                    child: Text(
                      l.noGroupCreateTitle,
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
