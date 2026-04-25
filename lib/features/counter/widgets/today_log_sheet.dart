import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:selawathub/core/animations/bounce_tap.dart';
import 'package:selawathub/core/constants.dart';
import 'package:selawathub/core/theme/colors.dart';
import 'package:selawathub/features/counter/models/dhikr.dart';
import 'package:selawathub/l10n/generated/app_localizations.dart';

/// Callback signature for committing an edit. Returns true on success.
typedef TodayLogEdit = Future<bool> Function(Dhikr dhikr, int newCount);

/// Bottom sheet listing today's per-dhikr totals with a tap-to-edit row
/// for each. Used as the "direct correction" path — lets the user set
/// any dhikr's today total to an exact number (not a delta).
class TodayLogSheet {
  static Future<void> show(
    BuildContext context, {
    required Map<String, int> counts,
    required List<Dhikr> customs,
    required TodayLogEdit onEdit,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _TodayLogBody(
        counts: counts,
        customs: customs,
        onEdit: onEdit,
      ),
    );
  }
}

class _TodayLogBody extends StatefulWidget {
  const _TodayLogBody({
    required this.counts,
    required this.customs,
    required this.onEdit,
  });
  final Map<String, int> counts;
  final List<Dhikr> customs;
  final TodayLogEdit onEdit;

  @override
  State<_TodayLogBody> createState() => _TodayLogBodyState();
}

class _TodayLogBodyState extends State<_TodayLogBody> {
  late final Map<String, int> _counts = Map.of(widget.counts);

  Dhikr _resolveDhikr(String id) {
    for (final d in Dhikr.all) {
      if (d.id == id) return d;
    }
    for (final d in widget.customs) {
      if (d.id == id) return d;
    }
    // Unknown — synthesize a placeholder so we can still render.
    final name = id.startsWith('custom:')
        ? _prettify(id.substring(7))
        : _prettify(id);
    return Dhikr.custom(
      id: id,
      name: name,
      category: DhikrCategory.selawat,
    );
  }

  String _prettify(String raw) => raw
      .replaceAll('-', ' ')
      .replaceAll('_', ' ')
      .split(' ')
      .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
      .join(' ');

  Future<void> _editRow(Dhikr dhikr, int currentCount) async {
    final newCount = await _EditCountSheet.show(
      context: context,
      dhikr: dhikr,
      initialCount: currentCount,
    );
    if (newCount == null || newCount == currentCount) return;
    final ok = await widget.onEdit(dhikr, newCount);
    if (ok && mounted) {
      setState(() => _counts[dhikr.id] = newCount);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final tt = Theme.of(context).textTheme;
    final accent = dark ? C.primarySoft : C.primary;
    final l = AppL10n.of(context);

    final entries = _counts.entries
        .where((e) => e.value > 0)
        .toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Container(
      decoration: BoxDecoration(
        color: dark ? C.dark2 : C.light2,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(S.page, S.s12, S.page, S.s20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: dark ? C.dark4 : C.lightDivider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: S.s20),
              Text(
                l.todayLogTitle,
                style: tt.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: dark ? C.onDark1 : C.onLight1,
                ),
              ),
              const SizedBox(height: S.s4),
              Text(
                l.todayLogTapHint,
                style: tt.bodySmall?.copyWith(
                  color: dark ? C.onDark3 : C.onLight3,
                ),
              ),
              const SizedBox(height: S.s16),

              if (entries.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: S.s32),
                  child: Text(
                    l.todayLogEmpty,
                    style: tt.bodyMedium?.copyWith(
                      color: dark ? C.onDark3 : C.onLight3,
                    ),
                  ),
                )
              else
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.55,
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: entries.length,
                    separatorBuilder: (_, _) => const SizedBox(height: S.s6),
                    itemBuilder: (_, i) {
                      final e = entries[i];
                      final dhikr = _resolveDhikr(e.key);
                      return _Row(
                        dhikr: dhikr,
                        count: e.value,
                        dark: dark,
                        accent: accent,
                        onTap: () => _editRow(dhikr, e.value),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({
    required this.dhikr,
    required this.count,
    required this.dark,
    required this.accent,
    required this.onTap,
  });
  final Dhikr dhikr;
  final int count;
  final bool dark;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return BounceTap(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: S.s16,
          vertical: S.s12,
        ),
        decoration: BoxDecoration(
          color: dark ? C.dark3 : C.light3,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            if (dhikr.isCustom)
              Padding(
                padding: const EdgeInsets.only(right: S.s8),
                child: Icon(
                  CupertinoIcons.person_crop_circle,
                  size: 14,
                  color: dark ? C.onDark3 : C.onLight3,
                ),
              ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dhikr.name,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: dark ? C.onDark1 : C.onLight1,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    dhikr.category.name,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: dark ? C.onDark3 : C.onLight3,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '$count',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: accent,
              ),
            ),
            const SizedBox(width: S.s8),
            Icon(
              CupertinoIcons.pencil,
              size: 14,
              color: dark ? C.onDark3 : C.onLight3,
            ),
          ],
        ),
      ),
    );
  }
}

/// Bottom sheet for setting a dhikr's today total to an exact number.
/// Presented on top of [TodayLogSheet] when a row is tapped; matches the
/// rest of the correction surfaces (manual add sheet, today log sheet)
/// instead of the old AlertDialog which felt out-of-place on mobile.
class _EditCountSheet extends StatefulWidget {
  const _EditCountSheet({required this.dhikr, required this.initialCount});
  final Dhikr dhikr;
  final int initialCount;

  static Future<int?> show({
    required BuildContext context,
    required Dhikr dhikr,
    required int initialCount,
  }) {
    return showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _EditCountSheet(
        dhikr: dhikr,
        initialCount: initialCount,
      ),
    );
  }

  @override
  State<_EditCountSheet> createState() => _EditCountSheetState();
}

class _EditCountSheetState extends State<_EditCountSheet> {
  late final _ctrl = TextEditingController(text: '${widget.initialCount}');
  final _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focus.requestFocus();
      _ctrl.selection = TextSelection(
        baseOffset: 0,
        extentOffset: _ctrl.text.length,
      );
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _save() {
    final n = int.tryParse(_ctrl.text.trim());
    if (n == null || n < 0) return;
    Navigator.pop(context, n);
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final accent = dark ? C.primarySoft : C.primary;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final l = AppL10n.of(context);

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        decoration: BoxDecoration(
          color: dark ? C.dark2 : C.light1,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: EdgeInsets.fromLTRB(
          S.page,
          S.s12,
          S.page,
          MediaQuery.of(context).padding.bottom + S.s16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: dark ? C.dark4 : C.lightDivider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: S.s16),
            Text(
              l.todayLogEditCount,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: dark ? C.onDark1 : C.onLight1,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              widget.dhikr.name,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: dark ? C.onDark3 : C.onLight3,
              ),
            ),
            const SizedBox(height: S.s16),
            TextField(
              controller: _ctrl,
              focusNode: _focus,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(6),
              ],
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w700,
                color: dark ? C.onDark1 : C.onLight1,
              ),
              decoration: InputDecoration(
                filled: true,
                fillColor: dark ? C.dark3 : C.light3,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
              onSubmitted: (_) => _save(),
            ),
            const SizedBox(height: S.s16),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      backgroundColor: dark ? C.dark3 : C.light3,
                    ),
                    child: Text(
                      l.commonCancel,
                      style: TextStyle(
                        color: dark ? C.onDark2 : C.onLight2,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: S.s12),
                Expanded(
                  child: FilledButton(
                    onPressed: _save,
                    style: FilledButton.styleFrom(
                      backgroundColor: accent,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      l.commonSave,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
