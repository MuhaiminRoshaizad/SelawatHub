# Roadmap

Current status, completed features, and planned future work.

---

## Current Version: v1.0.0

### ✅ Completed Features

#### Core
- [x] Digital tasbih counter with 17 dhikr items (10 selawat, 7 zikir)
- [x] Three counter visualisation styles (digital, bead, minimal)
- [x] 6 counter color themes (Emerald, Gold, Ocean, Rose, Lavender, Ivory)
- [x] Haptic feedback with 3 intensity levels
- [x] Custom per-dhikr target counts
- [x] Dual persistence (Supabase cloud + local SharedPreferences)

#### Statistics
- [x] 52-week GitHub-style activity heatmap
- [x] Current and best streak tracking with fire emoji tiers
- [x] Configurable daily goal with progress bar
- [x] Weekly stacked bar chart (selawat vs zikir)
- [x] Category breakdown (selawat/zikir ratio)
- [x] Top 7 most-counted dhikrs
- [x] Day detail view (tap heatmap cell)
- [x] Summary card (total dhikr, days active, streak)

#### Groups
- [x] Create group with auto-generated invite code (SLWT-XXXX)
- [x] Join group via invite code
- [x] Role hierarchy (leader, co-leader, member)
- [x] Member leaderboard sorted by daily count
- [x] Group statistics (weekly/monthly totals)
- [x] Yearly activity chart (12-month bar chart)
- [x] Share invite code via native share sheet
- [x] Copy invite code to clipboard
- [x] Manage roles (promote/demote co-leaders)
- [x] Remove members
- [x] Transfer leadership
- [x] Leave group

#### Authentication
- [x] Email/password sign up with display name
- [x] Email/password sign in
- [x] Guest mode (local-only, no account required)
- [x] Forgot password (email reset link)
- [x] Deep-linked password reset flow
- [x] Change password with current password verification
- [x] "Forgot current password?" link for logged-in users
- [x] Sign out with confirmation

#### Profile
- [x] Edit display name and bio
- [x] Upload/remove profile picture (Supabase Storage)
- [x] Fullscreen profile picture view (Hero animation)
- [x] Member profile pictures in group leaderboard
- [x] Profile stats row (total, streak, days active)

#### Daily Content
- [x] 40 Nawawi hadiths (Arabic + English)
- [x] Daily duas collection
- [x] Daily adkar (morning/evening)
- [x] Post-salaah zikr
- [x] Category browser pages
- [x] Source attribution page

#### UX & Polish
- [x] Dark/light mode toggle (persisted)
- [x] Frosted glass bottom navigation bar
- [x] Overlay-based toast notifications (visible above bottom sheets)
- [x] SafeArea handling for system navigation bar
- [x] Staggered FadeIn animations throughout
- [x] BounceTap micro-interactions
- [x] Skeleton loading placeholders
- [x] Digits-only input enforcement on number fields
- [x] Comprehensive error handling with user-friendly messages
- [x] Toast feedback on every user action

#### Documentation & Legal
- [x] Privacy Policy (8 sections)
- [x] Terms of Service (12 sections)
- [x] Help & FAQ (stacked accordion, 5 categories, 14 questions)
- [x] About page with feature list
- [x] Project documentation (docs/ folder)

---

## Phase 2 — Planned Features

### 🔔 Push Notifications

**Priority:** High

| Notification Type | Trigger | Implementation |
|-------------------|---------|----------------|
| Daily dhikr reminder | User-configured time | `flutter_local_notifications` + `timezone` |
| Streak at risk | End of day, goal not met | Local scheduled notification |
| Group member joined | New member joins | FCM via Supabase Edge Functions |
| Group goal reached | Daily target achieved | FCM via Supabase Edge Functions |

**Approach:**
- **Phase 2a:** Local notifications (reminders, streak warnings) — no backend changes
- **Phase 2b:** Push notifications (group events) — requires Firebase Cloud Messaging setup, Supabase Edge Functions, FCM token storage

**Group settings:** Mute notifications toggle already exists in group settings UI (currently non-functional, to be wired when notifications are implemented).

### 🌍 Multi-Language Support (i18n)

**Priority:** Medium

**Languages:**
- English (current, default)
- Bahasa Melayu (primary target)
- Arabic (future consideration)

**Approach:**
- Flutter `intl` package (already a dependency)
- ARB files for string localisation
- Language selector already exists in profile settings (currently placeholder)
- RTL layout support needed for Arabic

### 📱 Additional Planned Features

| Feature | Priority | Description |
|---------|----------|-------------|
| Account deletion | High | Full data deletion flow (GDPR compliance) |
| Offline sync queue | Medium | Queue counter writes when offline, sync on reconnect |
| Export data | Low | Export personal stats as PDF/CSV |
| Widget | Low | Home screen widget showing today's count |
| Onboarding tutorial | Low | Interactive walkthrough for new users |
| App Store listing | High | Prepare store assets and publish |

---

## Technical Debt

| Item | Priority | Description |
|------|----------|-------------|
| Application ID | High | Change from `com.example.selawathub` to production ID |
| CI/CD pipeline | Medium | GitHub Actions for automated analysis + build |
| Automated testing | Medium | Unit tests for services, widget tests for key flows |
| Error reporting | Medium | Crash analytics (Sentry or Firebase Crashlytics) |
| Performance profiling | Low | Optimise heatmap rendering, counter animations |
