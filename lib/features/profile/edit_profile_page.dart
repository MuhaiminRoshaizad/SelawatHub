import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:selawathub/core/animations/bounce_tap.dart';
import 'package:selawathub/core/animations/fade_in.dart';
import 'package:selawathub/core/constants.dart';
import 'package:selawathub/core/theme/colors.dart';
import 'package:selawathub/core/widgets/frosted_bar.dart';

// ─────────────────────────────────────────────────────────
//  Edit Profile Page — Instagram / WhatsApp style
// ─────────────────────────────────────────────────────────

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({
    super.key,
    required this.name,
    required this.bio,
    required this.email,
  });

  final String name;
  final String bio;
  final String email;

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _bioCtrl;
  late final TextEditingController _emailCtrl;
  late final FocusNode _nameFocus;
  late final FocusNode _bioFocus;
  late final FocusNode _emailFocus;

  static const _bioMax = 80;

  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.name);
    _bioCtrl = TextEditingController(text: widget.bio);
    _emailCtrl = TextEditingController(text: widget.email);
    _nameFocus = FocusNode();
    _bioFocus = FocusNode();
    _emailFocus = FocusNode();

    _nameCtrl.addListener(_onChanged);
    _bioCtrl.addListener(_onChanged);
    _emailCtrl.addListener(_onChanged);
  }

  void _onChanged() {
    final changed = _nameCtrl.text.trim() != widget.name ||
        _bioCtrl.text.trim() != widget.bio ||
        _emailCtrl.text.trim() != widget.email;
    if (changed != _hasChanges) {
      setState(() => _hasChanges = changed);
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _bioCtrl.dispose();
    _emailCtrl.dispose();
    _nameFocus.dispose();
    _bioFocus.dispose();
    _emailFocus.dispose();
    super.dispose();
  }

  String get _initials {
    final parts = _nameCtrl.text.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  void _save() {
    if (!_hasChanges) return;
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      _nameFocus.requestFocus();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Name cannot be empty'),
          backgroundColor: C.error,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }
    Navigator.of(context).pop({
      'name': name,
      'bio': _bioCtrl.text.trim(),
      'email': _emailCtrl.text.trim(),
    });
  }

  void _confirmDiscard() {
    if (!_hasChanges) {
      Navigator.of(context).pop();
      return;
    }
    final dark = Theme.of(context).brightness == Brightness.dark;
    showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: dark ? C.dark3 : C.light2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Discard changes?',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: dark ? C.onDark1 : C.onLight1,
          ),
        ),
        content: Text(
          'You have unsaved changes that will be lost.',
          style: TextStyle(color: dark ? C.onDark2 : C.onLight2),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(
              'Keep Editing',
              style: TextStyle(color: dark ? C.primarySoft : C.primary),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop(true);
              Navigator.of(context).pop();
            },
            child: Text('Discard', style: TextStyle(color: C.error)),
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
    final muted = dark ? C.onDark3 : C.onLight3;

    return PopScope(
      canPop: !_hasChanges,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _confirmDiscard();
      },
      child: Scaffold(
        backgroundColor: dark ? C.dark1 : C.light1,
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Stack(
            children: [
              ListView(
                padding: EdgeInsets.zero,
                children: [
                  // Space for frosted bar
                  SizedBox(
                      height: MediaQuery.of(context).padding.top + 56),

                  const SizedBox(height: S.s24),

                  // ── Avatar + "Edit photo" ──
                  FadeIn(
                    child: Center(
                      child: Column(
                        children: [
                          BounceTap(
                            onTap: () {
                              // TODO: image picker
                            },
                            child: Stack(
                              children: [
                                Container(
                                  width: 96,
                                  height: 96,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        accent.withValues(alpha: 0.15),
                                        C.goldGlow,
                                      ],
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color:
                                            C.black.withValues(alpha: 0.08),
                                        blurRadius: 20,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: ListenableBuilder(
                                    listenable: _nameCtrl,
                                    builder: (context, _) => Center(
                                      child: Text(
                                        _initials,
                                        style: TextStyle(
                                          fontSize: 30,
                                          fontWeight: FontWeight.w700,
                                          color: accent,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  right: 0,
                                  bottom: 0,
                                  child: Container(
                                    width: 28,
                                    height: 28,
                                    decoration: BoxDecoration(
                                      color: accent,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: dark ? C.dark1 : C.light1,
                                        width: 2.5,
                                      ),
                                    ),
                                    child: const Center(
                                      child: Icon(
                                        CupertinoIcons.camera_fill,
                                        size: 12,
                                        color: C.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: S.s8),
                          BounceTap(
                            onTap: () {
                              // TODO: image picker
                            },
                            child: Text(
                              'Edit photo',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: accent,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: S.s32),

                  // ── Fields ──
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: S.page),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Name
                        FadeIn(
                          delay: const Duration(milliseconds: 80),
                          child: _Field(
                            label: 'Full Name',
                            hint: 'Enter your name',
                            icon: CupertinoIcons.person,
                            controller: _nameCtrl,
                            focusNode: _nameFocus,
                            dark: dark,
                            textInputAction: TextInputAction.next,
                            onSubmitted: (_) => FocusScope.of(context)
                                .requestFocus(_bioFocus),
                          ),
                        ),
                        const SizedBox(height: S.s16),

                        // Bio
                        FadeIn(
                          delay: const Duration(milliseconds: 140),
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              _Field(
                                label: 'Bio',
                                hint: 'Write something about yourself...',
                                icon: CupertinoIcons.pencil,
                                controller: _bioCtrl,
                                focusNode: _bioFocus,
                                dark: dark,
                                maxLength: _bioMax,
                                textInputAction: TextInputAction.next,
                                onSubmitted: (_) =>
                                    FocusScope.of(context)
                                        .requestFocus(_emailFocus),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                    right: 4, top: S.s6),
                                child: ListenableBuilder(
                                  listenable: _bioCtrl,
                                  builder: (context, _) {
                                    final warn = _bioMax -
                                            _bioCtrl.text.length <=
                                        10;
                                    return Align(
                                      alignment:
                                          Alignment.centerRight,
                                      child: Text(
                                        '${_bioCtrl.text.length}/$_bioMax',
                                        style:
                                            tt.bodySmall?.copyWith(
                                          fontSize: 11,
                                          color: warn
                                              ? C.error.withValues(
                                                  alpha: 0.8)
                                              : muted,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: S.s16),

                        // Email
                        FadeIn(
                          delay: const Duration(milliseconds: 200),
                          child: _Field(
                            label: 'Email',
                            hint: 'Enter your email',
                            icon: CupertinoIcons.mail,
                            controller: _emailCtrl,
                            focusNode: _emailFocus,
                            dark: dark,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.done,
                            onSubmitted: (_) => _save(),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(
                    height:
                        MediaQuery.of(context).padding.bottom + S.s32,
                  ),
                ],
              ),

              // ── Frosted app bar ──
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: FrostedBar(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: S.s8, vertical: S.s8),
                    child: Row(
                      children: [
                        // Cancel
                        BounceTap(
                          onTap: _confirmDiscard,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: S.s8),
                            child: Text(
                              'Cancel',
                              style: TextStyle(
                                fontSize: 15,
                                color: dark ? C.onDark1 : C.onLight1,
                              ),
                            ),
                          ),
                        ),
                        const Spacer(),
                        // Title
                        Text(
                          'Edit Profile',
                          style: tt.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        // Done
                        BounceTap(
                          onTap: _hasChanges ? _save : null,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: S.s8),
                            child: AnimatedOpacity(
                              opacity: _hasChanges ? 1.0 : 0.35,
                              duration:
                                  const Duration(milliseconds: 200),
                              child: Text(
                                'Done',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: accent,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
//  Field — same style as login page (label above, filled, icon)
// ─────────────────────────────────────────────────────────

class _Field extends StatelessWidget {
  const _Field({
    required this.label,
    required this.hint,
    required this.icon,
    required this.controller,
    required this.focusNode,
    required this.dark,
    this.keyboardType,
    this.textInputAction,
    this.onSubmitted,
    this.maxLength,
  });

  final String label;
  final String hint;
  final IconData icon;
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool dark;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;
  final int? maxLength;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: S.s8),
          child: Text(label, style: tt.titleSmall),
        ),
        TextField(
          controller: controller,
          focusNode: focusNode,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          onSubmitted: onSubmitted,
          maxLength: maxLength,
          style: tt.bodyMedium?.copyWith(
            color: dark ? C.onDark1 : C.onLight1,
          ),
          cursorColor: dark ? C.primarySoft : C.primary,
          decoration: InputDecoration(
            hintText: hint,
            counterText: '',
            prefixIcon: Padding(
              padding: const EdgeInsets.only(left: 16, right: 12),
              child: Icon(icon,
                  size: 18, color: dark ? C.onDark3 : C.onLight3),
            ),
            prefixIconConstraints:
                const BoxConstraints(minWidth: 0, minHeight: 0),
          ),
        ),
      ],
    );
  }
}
