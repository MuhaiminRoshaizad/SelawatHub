import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:selawathub/core/animations/bounce_tap.dart';
import 'package:selawathub/core/constants.dart';
import 'package:selawathub/core/services/custom_dhikr_service.dart';
import 'package:selawathub/core/services/supabase_service.dart';
import 'package:selawathub/core/theme/colors.dart';
import 'package:selawathub/core/widgets/app_snackbar.dart';
import 'package:selawathub/features/counter/models/dhikr.dart';
import 'package:selawathub/l10n/generated/app_localizations.dart';

/// Result returned by the manual-add sheet.
typedef ManualCountResult = ({Dhikr dhikr, int amount});

/// Bottom sheet for users with a physical tasbih who want to log counts
/// after the fact. Supports built-in dhikr as well as user-defined custom
/// dhikr (selawat/zikir not in our built-in list).
class ManualCountSheet {
  static Future<ManualCountResult?> show(
    BuildContext context,
    Dhikr initial, {
    VoidCallback? onOpenTodayLog,
  }) {
    return showModalBottomSheet<ManualCountResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _ManualCountBody(
        initial: initial,
        onOpenTodayLog: onOpenTodayLog,
      ),
    );
  }
}

enum _View { amount, pick, addNew }

class _ManualCountBody extends StatefulWidget {
  const _ManualCountBody({required this.initial, this.onOpenTodayLog});
  final Dhikr initial;
  final VoidCallback? onOpenTodayLog;

  @override
  State<_ManualCountBody> createState() => _ManualCountBodyState();
}

class _ManualCountBodyState extends State<_ManualCountBody> {
  late Dhikr _dhikr = widget.initial;
  _View _view = _View.amount;
  bool _subtract = false;

  // Amount view state
  final _amountCtrl = TextEditingController();
  final _amountFocus = FocusNode();
  static const _presets = [33, 100, 1000];

  // Add-new view state
  final _nameCtrl = TextEditingController();
  final _nameFocus = FocusNode();
  DhikrCategory _newCategory = DhikrCategory.selawat;
  bool _saving = false;

  // Picker state
  List<Dhikr> _customs = const [];
  bool _loadedCustoms = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _amountFocus.requestFocus();
    });
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _amountFocus.dispose();
    _nameCtrl.dispose();
    _nameFocus.dispose();
    super.dispose();
  }

  int get _parsed => int.tryParse(_amountCtrl.text.trim()) ?? 0;

  void _addPreset(int n) {
    _amountCtrl.text = '${_parsed + n}';
    _amountCtrl.selection = TextSelection.fromPosition(
      TextPosition(offset: _amountCtrl.text.length),
    );
    setState(() {});
  }

  void _submit() {
    final amount = _parsed;
    if (amount <= 0) return;
    final signed = _subtract ? -amount : amount;
    Navigator.pop(context, (dhikr: _dhikr, amount: signed));
  }

  Future<void> _openPicker() async {
    _amountFocus.unfocus();
    if (!_loadedCustoms) {
      _customs = await CustomDhikrService.list();
      _loadedCustoms = true;
    }
    if (!mounted) return;
    setState(() => _view = _View.pick);
  }

  void _pickDhikr(Dhikr d) {
    setState(() {
      _dhikr = d;
      _view = _View.amount;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _amountFocus.requestFocus();
    });
  }

  void _startAddNew() {
    setState(() => _view = _View.addNew);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _nameFocus.requestFocus();
    });
  }

  Future<void> _saveNew() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty || _saving) return;
    setState(() => _saving = true);
    final created = await CustomDhikrService.create(
      name: name,
      category: _newCategory,
    );
    if (!mounted) return;
    setState(() => _saving = false);
    if (created == null) {
      showAppSnackBar(
        context,
        AppL10n.of(context).manualSaveCustomFailed(_newCategory.name),
        backgroundColor: C.error,
      );
      return;
    }
    _customs = await CustomDhikrService.list();
    if (!mounted) return;
    showAppSnackBar(
      context,
      AppL10n.of(context).manualAddedCustomToast(created.name, _newCategory.name),
    );
    _pickDhikr(created);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final dark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        decoration: BoxDecoration(
          color: dark ? C.dark2 : C.light2,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(S.page, S.s12, S.page, S.s20),
            child: AnimatedSize(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOut,
              alignment: Alignment.topCenter,
              child: _buildView(dark),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildView(bool dark) {
    switch (_view) {
      case _View.amount:
        return _amountView(dark);
      case _View.pick:
        return _pickView(dark);
      case _View.addNew:
        return _addNewView(dark);
    }
  }

  // ─────────────────── Amount view ───────────────────

  Widget _amountView(bool dark) {
    final tt = Theme.of(context).textTheme;
    final accent = dark ? C.primarySoft : C.primary;
    final canSubmit = _parsed > 0;
    final l = AppL10n.of(context);
    final titleText = _subtract ? l.manualSubtractTitle : l.manualAddTitle;

    return Column(
      key: const ValueKey('amount'),
      mainAxisSize: MainAxisSize.min,
      children: [
        _dragHandle(dark),
        const SizedBox(height: S.s20),
        Text(
          titleText,
          style: tt.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: dark ? C.onDark1 : C.onLight1,
          ),
        ),
        const SizedBox(height: S.s12),

        // Mode toggle: Add / Subtract
        _modeToggle(dark, accent),
        const SizedBox(height: S.s12),

        // Dhikr pill (tappable → picker)
        BounceTap(
          onTap: _openPicker,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: S.s16,
              vertical: S.s12,
            ),
            decoration: BoxDecoration(
              color: dark ? C.dark3 : C.light3,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: accent.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _dhikr.isCustom
                      ? CupertinoIcons.person_crop_circle
                      : CupertinoIcons.book,
                  size: 14,
                  color: accent,
                ),
                const SizedBox(width: S.s8),
                Flexible(
                  child: Text(
                    _dhikr.name,
                    overflow: TextOverflow.ellipsis,
                    style: tt.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: dark ? C.onDark1 : C.onLight1,
                    ),
                  ),
                ),
                const SizedBox(width: S.s6),
                Icon(
                  CupertinoIcons.chevron_down,
                  size: 12,
                  color: dark ? C.onDark3 : C.onLight3,
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: S.s20),

        // Number input
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: S.s20,
            vertical: S.s12,
          ),
          decoration: BoxDecoration(
            color: dark ? C.dark3 : C.light3,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color:
                  dark ? C.dark4.withValues(alpha: 0.6) : C.lightDivider,
            ),
          ),
          child: TextField(
            controller: _amountCtrl,
            focusNode: _amountFocus,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(6),
            ],
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w700,
              color: dark ? C.onDark1 : C.onLight1,
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              isDense: true,
              hintText: '0',
              hintStyle: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.w700,
                color: dark ? C.onDark3 : C.onLight3,
              ),
            ),
            onChanged: (_) => setState(() {}),
            onSubmitted: (_) => _submit(),
          ),
        ),

        const SizedBox(height: S.s16),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (int i = 0; i < _presets.length; i++) ...[
              if (i > 0) const SizedBox(width: S.s8),
              Expanded(
                child: BounceTap(
                  onTap: () => _addPreset(_presets[i]),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: S.s12),
                    decoration: BoxDecoration(
                      color: dark
                          ? C.primaryMuted.withValues(alpha: 0.15)
                          : C.primary.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: accent.withValues(alpha: 0.2),
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '+${_presets[i]}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: accent,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),

        const SizedBox(height: S.s24),

        BounceTap(
          onTap: canSubmit ? _submit : null,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: S.s16),
            decoration: BoxDecoration(
              color: canSubmit
                  ? (_subtract ? C.error : accent)
                  : (_subtract ? C.error : accent).withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(16),
            ),
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _subtract
                      ? CupertinoIcons.minus
                      : CupertinoIcons.check_mark,
                  size: 16,
                  color: dark ? C.onDark1 : Colors.white,
                ),
                const SizedBox(width: S.s8),
                Text(
                  canSubmit
                      ? (_subtract
                          ? l.manualSubtractCta(_parsed)
                          : l.manualAddCta(_parsed))
                      : l.manualEnterAmount,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: dark ? C.onDark1 : Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),

        if (widget.onOpenTodayLog != null) ...[
          const SizedBox(height: S.s12),
          BounceTap(
            onTap: () {
              Navigator.pop(context);
              widget.onOpenTodayLog!();
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: S.s4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    CupertinoIcons.list_bullet,
                    size: 12,
                    color: dark ? C.onDark3 : C.onLight3,
                  ),
                  const SizedBox(width: S.s6),
                  Text(
                    l.counterMenuTodayLog,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: dark ? C.onDark3 : C.onLight3,
                      decoration: TextDecoration.underline,
                      decorationColor: dark ? C.onDark3 : C.onLight3,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  // ─────────────────── Picker view ───────────────────

  Widget _pickView(bool dark) {
    final tt = Theme.of(context).textTheme;
    final accent = dark ? C.primarySoft : C.primary;
    final l = AppL10n.of(context);
    final selawatBuiltIns =
        Dhikr.selawatList.where((d) => d.category == DhikrCategory.selawat);
    final zikirBuiltIns =
        Dhikr.zikirList.where((d) => d.category == DhikrCategory.zikir);
    final customSelawat =
        _customs.where((d) => d.category == DhikrCategory.selawat);
    final customZikir =
        _customs.where((d) => d.category == DhikrCategory.zikir);

    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.7,
      child: Column(
        key: const ValueKey('pick'),
        mainAxisSize: MainAxisSize.min,
        children: [
          _dragHandle(dark),
          const SizedBox(height: S.s12),
          Row(
            children: [
              BounceTap(
                onTap: () => setState(() => _view = _View.amount),
                child: Padding(
                  padding: const EdgeInsets.all(S.s4),
                  child: Icon(
                    CupertinoIcons.chevron_left,
                    size: 18,
                    color: dark ? C.onDark2 : C.onLight2,
                  ),
                ),
              ),
              const SizedBox(width: S.s8),
              Text(
                l.manualWhatReciting,
                style: tt.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: dark ? C.onDark1 : C.onLight1,
                ),
              ),
            ],
          ),
          const SizedBox(height: S.s12),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(bottom: S.s24),
              children: [
                if (SupabaseService.isAuthenticated)
                  _addNewButton(dark, accent),
                _sectionHeader(l.manualCategorySelawat, dark),
                ...customSelawat.map((d) => _dhikrRow(d, dark, accent)),
                ...selawatBuiltIns.map((d) => _dhikrRow(d, dark, accent)),
                const SizedBox(height: S.s12),
                _sectionHeader(l.manualCategoryZikir, dark),
                ...customZikir.map((d) => _dhikrRow(d, dark, accent)),
                ...zikirBuiltIns.map((d) => _dhikrRow(d, dark, accent)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(String text, bool dark) => Padding(
        padding: const EdgeInsets.fromLTRB(S.s4, S.s12, S.s4, S.s8),
        child: Text(
          text.toUpperCase(),
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
            color: dark ? C.onDark3 : C.onLight3,
          ),
        ),
      );

  Widget _addNewButton(bool dark, Color accent) {
    final l = AppL10n.of(context);
    return Padding(
        padding: const EdgeInsets.only(bottom: S.s8),
        child: BounceTap(
          onTap: _startAddNew,
          child: Container(
            padding: const EdgeInsets.all(S.s16),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: accent.withValues(alpha: 0.3),
                style: BorderStyle.solid,
              ),
            ),
            child: Row(
              children: [
                Icon(CupertinoIcons.add_circled, size: 18, color: accent),
                const SizedBox(width: S.s12),
                Text(
                  l.manualAddYourOwn,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: accent,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
  }

  Widget _dhikrRow(Dhikr d, bool dark, Color accent) {
    final selected = d.id == _dhikr.id;
    return Padding(
      padding: const EdgeInsets.only(bottom: S.s6),
      child: BounceTap(
        onTap: () => _pickDhikr(d),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: S.s16,
            vertical: S.s12,
          ),
          decoration: BoxDecoration(
            color: selected
                ? accent.withValues(alpha: dark ? 0.18 : 0.08)
                : (dark ? C.dark3 : C.light3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? accent : C.transparent,
              width: 1.2,
            ),
          ),
          child: Row(
            children: [
              if (d.isCustom) ...[
                Icon(
                  CupertinoIcons.person_crop_circle,
                  size: 14,
                  color: dark ? C.onDark3 : C.onLight3,
                ),
                const SizedBox(width: S.s8),
              ],
              Expanded(
                child: Text(
                  d.name,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: selected
                        ? accent
                        : (dark ? C.onDark1 : C.onLight1),
                  ),
                ),
              ),
              if (selected)
                Icon(Icons.check_circle_rounded, size: 18, color: accent),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────── Add-new view ───────────────────

  Widget _addNewView(bool dark) {
    final tt = Theme.of(context).textTheme;
    final accent = dark ? C.primarySoft : C.primary;
    final canSave = _nameCtrl.text.trim().isNotEmpty && !_saving;
    final l = AppL10n.of(context);

    return Column(
      key: const ValueKey('addNew'),
      mainAxisSize: MainAxisSize.min,
      children: [
        _dragHandle(dark),
        const SizedBox(height: S.s12),
        Row(
          children: [
            BounceTap(
              onTap: () => setState(() => _view = _View.pick),
              child: Padding(
                padding: const EdgeInsets.all(S.s4),
                child: Icon(
                  CupertinoIcons.chevron_left,
                  size: 18,
                  color: dark ? C.onDark2 : C.onLight2,
                ),
              ),
            ),
            const SizedBox(width: S.s8),
            Text(
              l.manualAddYourOwn,
              style: tt.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: dark ? C.onDark1 : C.onLight1,
              ),
            ),
          ],
        ),
        const SizedBox(height: S.s16),

        // Name input
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: S.s16,
            vertical: S.s4,
          ),
          decoration: BoxDecoration(
            color: dark ? C.dark3 : C.light3,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: dark ? C.dark4.withValues(alpha: 0.6) : C.lightDivider,
            ),
          ),
          child: TextField(
            controller: _nameCtrl,
            focusNode: _nameFocus,
            textCapitalization: TextCapitalization.words,
            inputFormatters: [LengthLimitingTextInputFormatter(50)],
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: dark ? C.onDark1 : C.onLight1,
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: l.manualNameHintExample,
              hintStyle: TextStyle(
                fontSize: 15,
                color: dark ? C.onDark3 : C.onLight3,
              ),
            ),
            onChanged: (_) => setState(() {}),
          ),
        ),

        const SizedBox(height: S.s16),

        // Category toggle
        Row(
          children: [
            Expanded(
              child: _catToggle(
                label: l.manualCategorySelawat,
                selected: _newCategory == DhikrCategory.selawat,
                onTap: () =>
                    setState(() => _newCategory = DhikrCategory.selawat),
                dark: dark,
                accent: accent,
              ),
            ),
            const SizedBox(width: S.s8),
            Expanded(
              child: _catToggle(
                label: l.manualCategoryZikir,
                selected: _newCategory == DhikrCategory.zikir,
                onTap: () =>
                    setState(() => _newCategory = DhikrCategory.zikir),
                dark: dark,
                accent: accent,
              ),
            ),
          ],
        ),

        const SizedBox(height: S.s20),

        BounceTap(
          onTap: canSave ? _saveNew : null,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: S.s16),
            decoration: BoxDecoration(
              color: canSave ? accent : accent.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(14),
            ),
            alignment: Alignment.center,
            child: _saving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(Colors.white),
                    ),
                  )
                : Text(
                    l.manualSaveAndContinue,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: dark ? C.onDark1 : Colors.white,
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _catToggle({
    required String label,
    required bool selected,
    required VoidCallback onTap,
    required bool dark,
    required Color accent,
  }) {
    return BounceTap(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: S.s12),
        decoration: BoxDecoration(
          color: selected
              ? accent.withValues(alpha: dark ? 0.2 : 0.1)
              : (dark ? C.dark3 : C.light3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? accent : C.transparent,
            width: 1.2,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: selected ? accent : (dark ? C.onDark2 : C.onLight2),
          ),
        ),
      ),
    );
  }

  Widget _dragHandle(bool dark) => Container(
        width: 36,
        height: 4,
        decoration: BoxDecoration(
          color: dark ? C.dark4 : C.lightDivider,
          borderRadius: BorderRadius.circular(2),
        ),
      );

  Widget _modeToggle(bool dark, Color accent) {
    final l = AppL10n.of(context);
    Widget seg(String label, IconData icon, bool selected, VoidCallback onTap,
        Color activeColor) {
      return Expanded(
        child: BounceTap(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: selected ? activeColor : C.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 13,
                  color: selected
                      ? Colors.white
                      : (dark ? C.onDark3 : C.onLight3),
                ),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: selected
                        ? Colors.white
                        : (dark ? C.onDark3 : C.onLight3),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: dark ? C.dark3 : C.light3,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          seg(l.manualSegmentAdd, CupertinoIcons.plus, !_subtract,
              () => setState(() => _subtract = false), accent),
          seg(l.manualSegmentSubtract, CupertinoIcons.minus, _subtract,
              () => setState(() => _subtract = true), C.error),
        ],
      ),
    );
  }
}
