# Architecture

## Overview

SelawatHub is a Flutter mobile application for Islamic devotional tracking (selawat and zikir counting) with community group features. It follows a **feature-first** project structure with a shared core layer, backed by **Supabase** for authentication, database, and storage.

## Tech Stack

| Layer | Technology |
|-------|-----------|
| **Framework** | Flutter (Dart) |
| **State Management** | Riverpod (flutter_riverpod) |
| **Backend** | Supabase (Auth, PostgreSQL, Storage, Edge Functions) |
| **Local Storage** | SharedPreferences |
| **Image Caching** | cached_network_image |
| **Animations** | Lottie, Custom AnimationControllers |
| **External API** | Naikiyah Dua Data API (hadith/dua content) |

## Project Structure

```
lib/
├── main.dart                          # Entry point
├── app/
│   ├── app.dart                       # Root MaterialApp, theme, auth routing
│   └── app_shell.dart                 # Bottom navigation (5 tabs)
├── core/
│   ├── animations/
│   │   ├── bounce_tap.dart            # Tap scale animation wrapper
│   │   ├── fade_in.dart               # Fade + slide-up entrance animation
│   │   └── fire_emoji.dart            # Lottie streak tier visualization
│   ├── constants.dart                 # Spacing scale (S class)
│   ├── extensions/
│   │   └── build_context_x.dart       # Context helpers (isDark, tt, accent)
│   ├── providers/
│   │   ├── auth_providers.dart        # Auth state stream + user providers
│   │   ├── counter_providers.dart     # Today's counts + counter settings
│   │   ├── group_providers.dart       # Group + members providers
│   │   ├── profile_providers.dart     # Profile data provider
│   │   └── stats_providers.dart       # Stats aggregation provider
│   ├── services/
│   │   ├── auth_service.dart          # Auth operations (sign up/in/out, password)
│   │   ├── counter_service.dart       # Dhikr count CRUD + aggregation
│   │   ├── doa_api_service.dart       # External hadith/dua API client (persistent cache)
│   │   ├── group_service.dart         # Group CRUD + membership + stats
│   │   ├── profile_service.dart       # Profile CRUD + avatar upload
│   │   ├── settings_service.dart      # Local preferences + profile cache persistence
│   │   ├── stats_cache.dart           # In-memory stats cache (invalidated on counter save)
│   │   └── supabase_service.dart      # Supabase client singleton
│   ├── theme/
│   │   ├── colors.dart                # Color palette (C class)
│   │   └── theme.dart                 # Material 3 themes + ThemeController
│   └── widgets/                       # Shared reusable widgets
│       ├── action_buttons.dart        # Cancel/Save button pair
│       ├── app_bottom_sheet.dart       # Bottom sheet helpers
│       ├── app_snackbar.dart          # Overlay-based toast notification
│       ├── app_text_field.dart        # Input decoration helper
│       ├── bead_circle.dart           # Circular rosary visualization
│       ├── confirmation_dialog.dart   # Confirm action modal
│       ├── frosted_app_bar.dart       # Frosted glass app bar
│       ├── frosted_bar.dart           # BackdropFilter blur bar
│       ├── progress_ring.dart         # Circular progress indicator
│       └── section_header.dart        # Section label widget
└── features/
    ├── auth/
    │   ├── login_page.dart            # Sign in/up + forgot password
    │   ├── onboarding_page.dart       # First-time flow
    │   ├── reset_password_page.dart   # Deep-linked password reset
    │   └── welcome_page.dart          # Landing screen
    ├── counter/
    │   ├── counter_page.dart          # Main tasbih counter
    │   ├── counter_settings_page.dart # Counter customization
    │   ├── models/
    │   │   └── dhikr.dart             # Dhikr data model (17 items)
    │   └── widgets/
    │       ├── bead_counter.dart       # Rosary bead visualization
    │       ├── dhikr_selector_sheet.dart # Dhikr picker bottom sheet
    │       ├── digital_counter.dart   # Arc-style counter
    │       └── minimal_counter.dart   # Simple text counter
    ├── group/
    │   ├── group_page.dart            # Group hub
    │   ├── group_settings_page.dart   # Admin controls
    │   ├── manage_roles_page.dart     # Promote/demote members
    │   ├── remove_member_page.dart    # Remove member
    │   ├── transfer_leadership_page.dart # Transfer admin
    │   ├── models/
    │   │   └── group_role.dart        # Role enum + GroupMember typedef
    │   └── widgets/
    │       ├── member_tile.dart       # Member list item
    │       ├── no_group_view.dart     # Create/join CTA
    │       └── yearly_chart.dart      # 12-month bar chart
    ├── hadith/
    │   ├── hadith_page.dart           # Daily Islamic content hub
    │   ├── doa_category_page.dart     # Category browser
    │   ├── sources_page.dart          # API attribution
    │   ├── models/
    │   │   └── doa_models.dart        # Doa, NawawiHadith, DailyAdkar, PostSalaahZikr
    │   └── widgets/                   # Content cards + loading/error views
    ├── profile/
    │   ├── profile_page.dart          # Account hub + settings
    │   ├── edit_profile_page.dart     # Edit name/bio/avatar
    │   ├── about_page.dart            # App info + legal links
    │   ├── help_faq_page.dart         # Stacked accordion FAQ
    │   ├── privacy_policy_page.dart   # Privacy policy
    │   ├── terms_of_service_page.dart # Terms of service
    │   └── widgets/
    │       ├── profile_banner.dart    # Avatar + name header
    │       ├── profile_rows.dart      # MenuRow + ToggleRow components
    │       └── profile_stats_row.dart # Stats summary grid
    └── stats/
        ├── stats_page.dart            # Analytics dashboard
        └── widgets/
            ├── category_breakdown.dart # Selawat vs zikir ratio
            ├── stats_heatmap.dart      # 52-week activity grid
            ├── streak_card.dart        # Streak + daily goal progress
            ├── summary_card.dart       # Total stats grid
            ├── top_dhikr_list.dart     # Top 7 ranked dhikrs
            └── weekly_chart.dart       # 7-day stacked bar chart
```

## Architectural Layers

```
┌─────────────────────────────────────────────┐
│                    UI Layer                  │
│  Pages, Widgets, Animations, Theme          │
├─────────────────────────────────────────────┤
│               State Layer (Riverpod)         │
│  Providers: auth, counter, group, profile,  │
│  stats, counterSettings                     │
├─────────────────────────────────────────────┤
│              Service Layer                   │
│  AuthService, CounterService, GroupService,  │
│  ProfileService, SettingsService,            │
│  DoaApiService, SupabaseService             │
├─────────────────────────────────────────────┤
│              Data Layer                      │
│  Supabase (PostgreSQL + Auth + Storage)     │
│  SharedPreferences (local)                  │
│  Naikiyah API (external, read-only)         │
└─────────────────────────────────────────────┘
```

### UI Layer
- **Pages** — Full-screen views under `features/*/`
- **Widgets** — Reusable components in `core/widgets/` and `features/*/widgets/`
- **Animations** — `FadeIn`, `BounceTap`, `FireEmoji` in `core/animations/`
- **Theme** — `C` (colors), `S` (spacing), Material 3 theming in `core/theme/`

### State Layer (Riverpod)
- **StreamProvider** for real-time auth state
- **FutureProvider** for async data fetching (profile, stats, group members)
- **Provider** for synchronous derived state (isAuthenticated, counterSettings)
- **FutureProvider.family** for parameterised queries (group members by ID)

### Service Layer
All services are **static utility classes** (no instantiation needed):
- Each service wraps a single data source (Supabase table, API, SharedPreferences)
- Services return raw `Map<String, dynamic>` or primitive types
- No business logic — services are pure data access

### Data Layer
- **Supabase PostgreSQL** — Main persistence (counter_sessions, groups, group_members, profiles)
- **Supabase Auth** — Email/password authentication with JWT tokens
- **Supabase Storage** — Avatar image uploads (public `avatars` bucket)
- **SharedPreferences** — Local settings, guest data, profile cache, doa/hadith content cache (24h TTL)
- **Naikiyah API** — Read-only external API for hadith/dua content (persisted to SharedPreferences, stale-while-revalidate)

## Data Flow

### Counter Tap Flow
```
User taps counter
  → CounterPage._increment()
  → setState (update _count, _round, _total)
  → Debounced save (2s idle or 5 taps)
  → CounterService.upsertCount() → Supabase INSERT ON CONFLICT
  → SettingsService.saveLocalCount() → SharedPreferences (offline backup)
```

### Authentication Flow
```
App launch
  → SupabaseService.init()
  → Check SupabaseService.isAuthenticated (one-shot at boot)
  → Authenticated: AppShell (5 tabs)
  → Not authenticated: OnboardingPage
    → Sign In/Up: LoginPage → AuthService.signIn/signUp
      → Navigator.pushAndRemoveUntil(AppShell)
    → Guest: AppShell(isGuest: true)

Sign out (from ProfilePage)
  → showConfirmDialog → AuthService.signOut()
  → SettingsService.clearCachedProfile()
  → Scheduled on next frame (post-frame callback) so the confirm
    dialog pops itself cleanly first:
    SelawatHubApp.navKey.currentState.pushAndRemoveUntil(WelcomePage)
```

**Navigation pattern:** sign-in and sign-out both navigate imperatively
from the callsite instead of reacting to `onAuthStateChange`. This
mirrors the canonical Flutter + Supabase pattern, survives hot-reload,
and sidesteps the gotrue 2.20+ regression where `signOut()` with local
scope no longer emits `AuthChangeEvent.signedOut`
(see https://github.com/supabase/gotrue-js/issues/648). The only auth
event the app still listens for is `passwordRecovery`, used to push
`ResetPasswordPage` on email deep-link returns.

### Password Reset Flow
```
User taps "Forgot Password"
  → AuthService.sendPasswordReset(email)
  → Email sent with deep link (io.supabase.selawathub://login-callback)
  → User opens link → App receives AuthChangeEvent.passwordRecovery
  → Navigate to ResetPasswordPage
  → AuthService.updatePassword(newPassword)
  → Navigate to AppShell
```

### Group Data Flow
```
GroupPage loads
  → groupProvider.future → GroupService.getMyGroup()
  → If group exists: groupMembersProvider(groupId)
    → GroupService.getGroupMembers() → RPC get_group_members_with_counts
  → Display MemberTile list sorted by today's count
```

## Key Design Decisions

1. **Feature-first structure** — Each feature is self-contained with its own pages, widgets, and models. Core layer provides shared infrastructure.

2. **Static services** — No dependency injection or service locators. Services are stateless utility classes with static methods, keeping the architecture simple.

3. **Riverpod over BLoC/Cubit** — Chosen for its compile-time safety, auto-disposal, and clean provider composition. No boilerplate event/state classes.

4. **Supabase over Firebase** — PostgreSQL provides relational data modeling (groups ↔ members ↔ counter_sessions), RLS policies for row-level security, and RPC functions for complex queries.

5. **Overlay-based toasts** — Custom `showAppSnackBar` renders via `Overlay` instead of `ScaffoldMessenger`, ensuring visibility above bottom sheets and modals.

6. **Dual persistence** — Counter data saves to both Supabase (cloud sync) and SharedPreferences (offline fallback). Settings are local-only (SharedPreferences).

7. **Guest mode** — Full counter + stats experience without authentication. Data stored locally only. Group features require sign-in.
