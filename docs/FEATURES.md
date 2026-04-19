# Features

Detailed documentation of every feature in SelawatHub.

---

## 1. Tasbih Counter

**Location:** `lib/features/counter/`

The core feature — a digital tasbih (prayer bead counter) for counting selawat and zikir.

### Dhikr Library

17 pre-built dhikr items split into two categories:

**Selawat (10 items, default target: 100 each)**
| ID | Name | Arabic |
|----|------|--------|
| `salawat_ibrahimiyyah` | Salawat Ibrahimiyyah | اللَّهُمَّ صَلِّ عَلَى مُحَمَّدٍ... |
| `salawat_fatih` | Salawat al-Fatih | اللَّهُمَّ صَلِّ وَسَلِّمْ... |
| ... | *(10 total)* | |

**Zikir (7 items, targets: 33–100)**
| ID | Name | Arabic |
|----|------|--------|
| `subhanallah` | SubhanAllah | سُبْحَانَ اللهِ |
| `alhamdulillah` | Alhamdulillah | الْحَمْدُ لِلّهِ |
| `allahu_akbar` | Allahu Akbar | اللهُ أَكْبَرُ |
| ... | *(7 total)* | |

### Counter Styles

Three visualization modes (user selectable in settings):

1. **Digital** — Circular arc with count in center (CustomPaint)
2. **Bead** — Rosary-style circle with filled/empty beads
3. **Minimal** — Clean text-only display

### Counter Behaviour

- **Tap anywhere** on the counter area to increment
- **Haptic feedback** — 3 intensity levels (light, medium, heavy), toggleable
- **Auto-save** — Debounced: saves after 2 seconds idle or every 5 taps
- **Dual persistence** — Supabase (cloud) + SharedPreferences (offline backup)
- **Target tracking** — Progress shown relative to custom or default target
- **Round tracking** — Counts rounds when target is reached, resets to 0

### Counter Settings

| Setting | Options | Storage |
|---------|---------|---------|
| Haptic feedback | On/Off | SharedPreferences |
| Haptic intensity | Light, Medium, Heavy | SharedPreferences |
| Counter style | Digital, Bead, Minimal | SharedPreferences |
| Color theme | 6 themes (Emerald, Gold, Ocean, Rose, Lavender, Ivory) | SharedPreferences |
| Custom target | Per-dhikr (digits only, must be > 0) | SharedPreferences |

---

## 2. Groups

**Location:** `lib/features/group/`

Community feature allowing users to track dhikr together.

### Group Creation
- Any registered user can create a group
- Requires: Group name (required), description (optional)
- Auto-generates a unique invite code: `SLWT-XXXX` (4 random alphanumeric chars)
- Creator becomes the group **leader**

### Group Membership
- Join via invite code (case-sensitive)
- One group per user at a time
- Members see each other's daily counts on the leaderboard

### Role Hierarchy

| Role | Permissions |
|------|-------------|
| **Leader** | All admin actions + transfer leadership + cannot be removed |
| **Co-Leader** | Edit group info, manage members, remove members |
| **Member** | View group, contribute counts, leave group |

### Admin Actions
- Edit group name, description, daily goal
- Copy or share invite code (native share sheet)
- Promote member → co-leader
- Demote co-leader → member
- Remove members
- Transfer leadership to another member

### Group Statistics
- **Leaderboard** — Members sorted by today's count (via RPC function)
- **Period totals** — Weekly and monthly aggregate counts
- **Yearly chart** — 12-month bar chart of group activity

### Views
- **No group** — Create or join CTA
- **Guest** — Sign-in prompt (groups require authentication)
- **Group view** — Leaderboard + stats + settings access

---

## 3. Statistics

**Location:** `lib/features/stats/`

Personal analytics dashboard with multiple visualisation components.

### Components

| Component | Description |
|-----------|-------------|
| **Streak Card** | Current streak + best streak with fire emoji tier animation |
| **Daily Goal Progress** | Configurable goal with progress bar (tap to edit) |
| **Summary Card** | 3-stat grid: total dhikr, days active, current streak |
| **Category Breakdown** | Selawat vs zikir split (ratio visualization) |
| **Heatmap** | 52-week GitHub-style activity grid (5 intensity levels) |
| **Weekly Chart** | Last 7 days stacked bar chart (selawat + zikir) |
| **Top Dhikr** | Top 7 most-counted dhikrs with percentages |
| **Day Detail** | Tap a heatmap cell to see that day's breakdown |

### Streak Tiers (Fire Emoji)
| Tier | Days | Animation |
|------|------|-----------|
| Dead | 0 | No flame |
| Burning | 1–29 | Small flame |
| Blazing | 30–99 | Medium flame |
| Legendary | 100+ | Large flame |

### Daily Goal
- Default: 100 counts
- Editable via bottom sheet (digits only, must be > 0)
- Persisted in SharedPreferences (works for both guest and authenticated users)
- Used for streak calculation and progress bar

### Data Source
- **Authenticated users:** Counter sessions from Supabase (last 364 days)
- **Guest users:** Local SharedPreferences data

---

## 4. Daily Content (Hadith)

**Location:** `lib/features/hadith/`

Curated Islamic content hub sourced from the Naikiyah Dua Data API.

### Content Types

| Type | Source Endpoint | Count |
|------|----------------|-------|
| **Forty Nawawi Hadiths** | `/hadith/nawawi` | 42 |
| **Daily Adkar** | `/adkar/daily` | Variable |
| **Duas** | `/dua` | Variable |
| **Post-Salaah Zikr** | `/adkar/post-salaah` | Variable |

### Page Layout
1. **Daily Hadith Card** — Featured hadith with Arabic + English translation + narrator + source
2. **Post-Salaah Zikr List** — Horizontal scrollable preview cards
3. **Daily Dua Card** — Featured dua
4. **Daily Adkar Card** — Featured adkar with times + benefits
5. **Category Browse Cards** — Navigate to full lists
6. **Sources** — API attribution and links

### Data Handling
- All 4 content types fetched in parallel on page load
- In-memory cache (singleton) — fetched once per app session
- Loading state: Skeletonizer placeholders
- Error state: Retry UI with error message

---

## 5. Profile & Account

**Location:** `lib/features/profile/`

User account management, preferences, and app information.

### Profile Information
- **Display name** — Set during sign-up, editable
- **Bio** — Optional, editable
- **Profile picture** — Upload from gallery, viewable fullscreen (Hero animation)
- **Email** — Read-only (from auth)
- **Member since** — Read-only (from profile creation)

### Profile Stats Row
Three tappable stats that navigate to the Stats page:
- Total dhikr count
- Current streak
- Days active

### Preferences
| Setting | Type | Default |
|---------|------|---------|
| Dark mode | Toggle | System |
| Language | Selector | English (placeholder) |

### Account Actions
- **Change password** — Verifies current password first, then updates
- **Forgot password** — Sends reset email from within change password sheet
- **Sign out** — Confirmation dialog, clears session
- **Delete account** — Destructive action (placeholder)

### Support Section
- **Help & FAQ** — Stacked accordion with 5 categories, 14 questions
- **About SelawatHub** — App description, feature list, version
- **Privacy Policy** — Full legal document (8 sections)
- **Terms of Service** — Full legal document (12 sections)

---

## 6. Authentication

**Location:** `lib/features/auth/`

Email/password authentication via Supabase Auth.

### Flows

| Flow | Entry Point | Steps |
|------|-------------|-------|
| **Sign Up** | Welcome → Login (sign up mode) | Name + Email + Password + Confirm → Create account → AppShell |
| **Sign In** | Welcome → Login (sign in mode) | Email + Password → Authenticate → AppShell |
| **Guest** | Welcome → "Continue as Guest" | Skip auth → AppShell(isGuest: true) |
| **Forgot Password** | Login → "Forgot password?" | Enter email → Receive reset link → Open link → ResetPasswordPage → Update password |
| **Change Password** | Profile → "Change Password" | Verify current → Enter new + confirm → Update |

### Validation Rules
- **Email:** Must not be empty
- **Password:** Minimum 6 characters
- **Confirm password:** Must match password
- **Name:** Required for sign-up

### Deep Link
- **Scheme:** `io.supabase.selawathub`
- **Host:** `login-callback`
- **Event:** `AuthChangeEvent.passwordRecovery` → navigates to `ResetPasswordPage`

### Guest Mode Limitations
| Feature | Guest | Authenticated |
|---------|-------|---------------|
| Counter | ✅ (local only) | ✅ (cloud synced) |
| Statistics | ✅ (local data) | ✅ (cloud data) |
| Groups | ❌ (sign-in prompt) | ✅ |
| Profile editing | ❌ | ✅ |
| Daily content | ✅ | ✅ |
