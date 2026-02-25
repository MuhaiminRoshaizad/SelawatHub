# SelawatHub

SelawatHub is a Flutter app for group selawat tracking. Members contribute daily counts through a built-in counter, and leaders can monitor group progress.

## MVP Features
- Firebase Auth
- Create group or join with code
- Built-in tasbih counter
- Personal daily counts
- Group daily totals
- Basic analytics cards

## Planned Features
- Join request approval workflow (leader)
- Public/private group settings
- Full analytics dashboard
- Notifications

## Current App Structure

```text
lib/
  app/
    app.dart
    app_shell.dart
  core/
    theme/
      app_colors.dart
      app_theme.dart
    widgets/
      app_background.dart
      blur_card.dart
  features/
    auth/presentation/pages/auth_gate_page.dart
    counter/presentation/pages/counter_page.dart
    group/presentation/pages/group_page.dart
    analytics/presentation/pages/analytics_page.dart
    profile/presentation/pages/profile_page.dart
  main.dart
```

## UX Flow (Current Scaffold)
1. App loads into a bottom-tab shell.
2. Tabs: Counter, Group, Analytics, Profile.
3. Counter is the primary action surface.
4. Group tab shows daily total and membership-related sections.
5. Analytics tab holds trends, streaks, and contribution insights.
6. Profile tab holds account and group identity settings.

## Design Direction
- Modern iOS-style visual language
- Soft gradients and light glass cards
- Clean spacing and rounded surfaces
- Cupertino iconography with Material 3 foundation

## Next Build Steps
1. Wire Firebase Auth in `auth_gate_page.dart`.
2. Implement Firestore group + member schema.
3. Connect counter writes to daily entries.
4. Aggregate group totals and analytics from Firestore.
5. Add leader-only approval actions in Group tab.

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

