import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:selawathub/core/animations/bounce_tap.dart';
import 'package:selawathub/core/animations/fade_in.dart';
import 'package:selawathub/core/constants.dart';
import 'package:selawathub/core/services/profile_service.dart';
import 'package:selawathub/core/theme/colors.dart';
import 'package:selawathub/core/widgets/app_snackbar.dart';
import 'package:selawathub/core/widgets/frosted_bar.dart';

// ─────────────────────────────────────────────────────────
//  Edit Profile Page — Instagram / WhatsApp style
// ─────────────────────────────────────────────────────────

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({
    super.key,
    required this.name,
    required this.bio,
    this.avatarUrl,
  });

  final String name;
  final String bio;
  final String? avatarUrl;

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _bioCtrl;
  late final FocusNode _nameFocus;
  late final FocusNode _bioFocus;

  static const _bioMax = 80;
  static const _maxImageBytes = 2 * 1024 * 1024; // 2 MB

  bool _hasChanges = false;
  bool _saving = false;
  String? _avatarUrl;
  bool _uploadingAvatar = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.name);
    _bioCtrl = TextEditingController(text: widget.bio);
    _nameFocus = FocusNode();
    _bioFocus = FocusNode();
    _avatarUrl = widget.avatarUrl;

    _nameCtrl.addListener(_onChanged);
    _bioCtrl.addListener(_onChanged);
  }

  void _onChanged() {
    final changed = _nameCtrl.text.trim() != widget.name ||
        _bioCtrl.text.trim() != widget.bio ||
        _avatarUrl != widget.avatarUrl;
    if (changed != _hasChanges) {
      setState(() => _hasChanges = changed);
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _bioCtrl.dispose();
    _nameFocus.dispose();
    _bioFocus.dispose();
    super.dispose();
  }

  String get _initials {
    final parts = _nameCtrl.text.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picked = await ImagePicker().pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );
      if (picked == null) return;

      final bytes = await picked.readAsBytes();
      if (bytes.length > _maxImageBytes) {
        if (!mounted) return;
        showAppSnackBar(context, 'Image must be under 2 MB',
            backgroundColor: C.error);
        return;
      }

      final ext = picked.path.split('.').last.toLowerCase();
      if (!['jpg', 'jpeg', 'png', 'webp'].contains(ext)) {
        if (!mounted) return;
        showAppSnackBar(context, 'Only JPG, PNG, or WebP allowed',
            backgroundColor: C.error);
        return;
      }

      setState(() => _uploadingAvatar = true);
      final url = await ProfileService.uploadAvatar(bytes, ext);
      if (!mounted) return;

      if (url != null) {
        setState(() {
          _avatarUrl = '$url?t=${DateTime.now().millisecondsSinceEpoch}';
          _uploadingAvatar = false;
        });
        _onChanged();
        showAppSnackBar(context, 'Photo updated');
      } else {
        setState(() => _uploadingAvatar = false);
        showAppSnackBar(context, 'Failed to upload photo',
            backgroundColor: C.error);
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _uploadingAvatar = false);
      showAppSnackBar(context, 'Failed to upload photo',
          backgroundColor: C.error);
    }
  }

  void _showImageSourcePicker() {
    final dark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: dark ? C.dark2 : C.light1,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: S.s16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: dark ? C.onDark3 : C.onLight3,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: S.s16),
              ListTile(
                leading: Icon(CupertinoIcons.camera,
                    color: dark ? C.onDark1 : C.onLight1),
                title: Text('Take Photo',
                    style: TextStyle(color: dark ? C.onDark1 : C.onLight1)),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: Icon(CupertinoIcons.photo,
                    color: dark ? C.onDark1 : C.onLight1),
                title: Text('Choose from Gallery',
                    style: TextStyle(color: dark ? C.onDark1 : C.onLight1)),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(ImageSource.gallery);
                },
              ),
              if (_avatarUrl != null && _avatarUrl!.isNotEmpty)
                ListTile(
                  leading: const Icon(CupertinoIcons.trash, color: C.error),
                  title:
                      const Text('Remove Photo', style: TextStyle(color: C.error)),
                  onTap: () {
                    Navigator.pop(ctx);
                    setState(() => _avatarUrl = null);
                    _onChanged();
                    showAppSnackBar(context, 'Photo removed');
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _save() async {
    if (!_hasChanges || _saving) return;
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      _nameFocus.requestFocus();
      showAppSnackBar(context, 'Name cannot be empty', backgroundColor: C.error);
      return;
    }
    setState(() => _saving = true);
    try {
      await ProfileService.updateProfile(
        name: name,
        bio: _bioCtrl.text.trim(),
      );
      if (!mounted) return;
      showAppSnackBar(context, 'Profile updated');
      Navigator.of(context).pop({
        'name': name,
        'bio': _bioCtrl.text.trim(),
        if (_avatarUrl != widget.avatarUrl) 'avatar_url': _avatarUrl ?? '',
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      showAppSnackBar(context, 'Failed to save profile', backgroundColor: C.error);
    }
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
      canPop: !_hasChanges && !_saving,
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
                            onTap: _uploadingAvatar ? null : _showImageSourcePicker,
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
                                  child: _uploadingAvatar
                                      ? const Center(
                                          child: SizedBox(
                                            width: 28,
                                            height: 28,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2.5,
                                            ),
                                          ),
                                        )
                                      : ListenableBuilder(
                                          listenable: _nameCtrl,
                                          builder: (context, _) => Center(
                                            child: _avatarUrl != null && _avatarUrl!.isNotEmpty
                                                ? ClipOval(
                                                    child: Image.network(
                                                      _avatarUrl!,
                                                      width: 96,
                                                      height: 96,
                                                      fit: BoxFit.cover,
                                                      errorBuilder: (c, e, s) => Text(
                                                        _initials,
                                                        style: TextStyle(
                                                          fontSize: 30,
                                                          fontWeight: FontWeight.w700,
                                                          color: accent,
                                                        ),
                                                      ),
                                                    ),
                                                  )
                                                : Text(
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
                            onTap: _uploadingAvatar ? null : _showImageSourcePicker,
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
                            keyboardType: TextInputType.name,
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
                                textInputAction: TextInputAction.done,
                                onSubmitted: (_) => _save(),
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
                          onTap: _hasChanges && !_saving ? _save : null,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: S.s8),
                            child: AnimatedOpacity(
                              opacity: _hasChanges && !_saving ? 1.0 : 0.35,
                              duration:
                                  const Duration(milliseconds: 200),
                              child: _saving
                                  ? SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: accent,
                                      ),
                                    )
                                  : Text(
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
