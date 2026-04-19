# Contributing

Guidelines for contributing to SelawatHub.

---

## Development Workflow

1. **Pull latest** from `main`
2. **Create a feature branch** (optional for solo development)
3. **Make changes** — ensure `flutter analyze` passes with zero issues
4. **Test on device** — verify dark mode, light mode, guest mode, and authenticated mode
5. **Commit** using conventional commit format
6. **Push** to remote

---

## Code Style

### General Rules

- Follow the default `flutter_lints` analysis rules
- All code must pass `flutter analyze` with **zero issues** before committing
- Use the app's design system tokens — never hardcode colors, spacing, or text styles
- Comments only where clarification is needed — don't comment obvious code

### Dart Conventions

```dart
// ✅ Use the C class for colors
color: C.primary
color: dark ? C.dark3 : C.light2

// ❌ Don't hardcode colors
color: Color(0xFF4A7C5C)
color: Colors.green

// ✅ Use the S class for spacing
padding: EdgeInsets.all(S.s16)
SizedBox(height: S.s12)

// ❌ Don't hardcode spacing
padding: EdgeInsets.all(16)
SizedBox(height: 12)

// ✅ Use withValues for opacity
color.withValues(alpha: 0.5)

// ❌ Don't use withOpacity
color.withOpacity(0.5)
```

### Widget Patterns

```dart
// ✅ Use theme-aware checks
final dark = Theme.of(context).brightness == Brightness.dark;

// ✅ Use text theme
final tt = Theme.of(context).textTheme;

// ✅ Use context extensions (when available)
context.isDark
context.tt
```

### Async & Context Safety

```dart
// ✅ In StatefulWidget methods, use `mounted`
Future<void> _save() async {
  await someAsyncWork();
  if (!mounted) return;
  showAppSnackBar(context, 'Saved');
}

// ❌ In StatefulWidget, don't use `context.mounted`
// The linter flags this as "unrelated mounted check"
```

### Input Validation

- **Number-only fields:** Always add `FilteringTextInputFormatter.digitsOnly`
- **Minimum values:** Validate > 0 for dhikr targets and daily goals (group goal allows 0)
- **Empty checks:** Show error toast, don't silently fail
- **Feedback:** Every action (save, edit, delete, create) must show a toast via `showAppSnackBar`

---

## Commit Messages

Use **Conventional Commits** format:

```
<type>(<scope>): <description>

[optional body]

[optional footer]
```

### Types

| Type | Usage |
|------|-------|
| `feat` | New feature |
| `fix` | Bug fix |
| `refactor` | Code restructuring (no feature change) |
| `style` | Formatting, whitespace (no logic change) |
| `docs` | Documentation changes |
| `chore` | Build, deps, config changes |
| `perf` | Performance improvement |

### Examples

```
feat(counter): add bead counter visualization style

fix(group): prevent RLS recursion in member queries

refactor(auth): extract password verification to AuthService

docs: add comprehensive project documentation

chore(deps): add share_plus package for native sharing
```

### Co-authored Commits

When commits are created with AI assistance:
```
Co-authored-by: Copilot <223556219+Copilot@users.noreply.github.com>
```

---

## File Organisation

### Adding a New Feature

```
lib/features/new_feature/
├── new_feature_page.dart          # Main page
├── new_feature_settings_page.dart # Settings (if needed)
├── models/
│   └── new_model.dart             # Data models
└── widgets/
    ├── widget_a.dart              # Feature-specific widgets
    └── widget_b.dart
```

### Adding a New Service

1. Create `lib/core/services/new_service.dart`
2. Use static methods pattern (no instantiation)
3. If it needs a provider, add to `lib/core/providers/`

### Adding a Shared Widget

1. Create in `lib/core/widgets/`
2. Make it theme-aware (accept `dark` parameter or read from context)
3. Use `C.*` for colors, `S.*` for spacing

---

## Testing Checklist

Before committing, manually verify:

- [ ] `flutter analyze` — zero issues
- [ ] Light mode appearance
- [ ] Dark mode appearance
- [ ] Guest mode (features gracefully disabled)
- [ ] Authenticated mode (all features working)
- [ ] Bottom sheet content not clipped by system nav bar
- [ ] Toast messages visible (including over bottom sheets)
- [ ] Number inputs reject non-digit characters
- [ ] All actions show feedback toast

---

## Environment & Secrets

- **Never** commit Supabase credentials to source code
- Use `--dart-define` flags for runtime configuration
- The `.env.example` file documents required variables (without real values)
- `.gitignore` excludes `.env` and `.env.*` files
