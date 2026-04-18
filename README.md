# SelawatHub

SelawatHub is a Flutter app for group selawat tracking. Members contribute daily counts through a built-in counter, and leaders can monitor group progress.

## Design Direction
- **Minimal + Bold + Premium** — clean whitespace, punchy typography, dark luxe feel
- **Palette** — Deep emerald + warm gold accents + clean neutrals
- **Modes** — Dark & Light with system toggle
- **Typography** — Bold headlines, generous letter-spacing, layered hierarchy

## Current Tabs
1. **Home** — Personal dashboard: today's count, streak, group snapshot, rank
2. **Counter** — Immersive tasbih counter with tap animation and progress tracking
3. **Community** — Group leaderboard, member activity, invite code, pending requests
4. **Profile** — Account info, group details, settings (dark mode, language), sign out

## MVP Features
- Firebase Auth (placeholder ready)
- Create group or join with code
- Built-in tasbih counter with pulse animation
- Personal daily counts with target tracking
- Group daily totals and leaderboard
- Streak tracking
- Dark/light mode toggle

## Planned Features
- Join request approval workflow (leader)
- Public/private group settings
- Full analytics dashboard
- Notifications
- Multilingual support (English + Malay)

## App Structure

```text
lib/
  app/
    app.dart                  # Root MaterialApp with theme switching
    app_shell.dart            # Bottom tab navigation shell
  core/
    theme/
      colors.dart             # Emerald + gold color system
      app_theme.dart          # Material 3 light/dark themes
      theme_controller.dart   # InheritedNotifier for theme access
    widgets/
      app_background.dart     # Clean background wrapper
      blur_card.dart          # SurfaceCard — clean bordered card
  features/
    auth/presentation/pages/auth_gate_page.dart
    home/presentation/pages/home_page.dart
    counter/presentation/pages/counter_page.dart
    community/presentation/pages/community_page.dart
    profile/presentation/pages/profile_page.dart
    settings/presentation/pages/settings_page.dart
  main.dart
```

## Next Build Steps
1. Wire Firebase Auth in `auth_gate_page.dart`
2. Implement Firestore group + member schema
3. Connect counter writes to daily entries
4. Aggregate group totals and leaderboard from Firestore
5. Add leader-only approval actions in Community tab
6. Implement i18n (English + Malay)

## Getting Started
1. Install Flutter: https://flutter.dev/docs/get-started/install
2. Install dependencies:
   ```bash
   flutter pub get
   ```
3. Run the app:
   ```bash
   flutter run
   ```

