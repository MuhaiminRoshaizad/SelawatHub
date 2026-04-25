import 'package:flutter/material.dart';
import 'package:selawathub/core/theme/colors.dart';
import 'package:selawathub/core/widgets/app_snackbar.dart';
import 'package:selawathub/l10n/generated/app_localizations.dart';

/// Shows a confirmation dialog with loading state on the action button.
///
/// [onConfirm] is called when the user taps the action button. If it throws,
/// an error snackbar is shown and the dialog stays open.
Future<void> showConfirmDialog({
  required BuildContext context,
  required String title,
  required String message,
  required String actionLabel,
  required Future<void> Function() onConfirm,
  bool isDestructive = true,
  String? errorMessage,
}) async {
  final dark = Theme.of(context).brightness == Brightness.dark;
  final l = AppL10n.of(context);
  bool loading = false;

  await showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setDialogState) => AlertDialog(
        backgroundColor: dark ? C.dark3 : C.light2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: dark ? C.onDark1 : C.onLight1,
          ),
        ),
        content: Text(
          message,
          style: TextStyle(color: dark ? C.onDark2 : C.onLight2),
        ),
        actions: [
          TextButton(
            onPressed: loading ? null : () => Navigator.of(ctx).pop(),
            child: Text(
              l.commonCancel,
              style: TextStyle(
                color: loading
                    ? (dark ? C.onDark3 : C.onLight3)
                    : (dark ? C.primarySoft : C.primary),
              ),
            ),
          ),
          TextButton(
            onPressed: loading
                ? null
                : () async {
                    setDialogState(() => loading = true);
                    try {
                      await onConfirm();
                      if (ctx.mounted) Navigator.of(ctx).pop();
                    } catch (_) {
                      setDialogState(() => loading = false);
                      if (ctx.mounted) {
                        showAppSnackBar(
                          ctx,
                          errorMessage ?? l.commonSomethingWentWrong,
                          backgroundColor: C.error,
                        );
                      }
                    }
                  },
            child: loading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(
                    actionLabel,
                    style: TextStyle(
                      color: isDestructive
                          ? C.error
                          : (dark ? C.primarySoft : C.primary),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ],
      ),
    ),
  );
}
