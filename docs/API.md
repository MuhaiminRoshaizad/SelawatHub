# Services & API Reference

Documentation of the service layer, Riverpod providers, and external APIs.

---

## Service Layer

All services are **static utility classes** — no instantiation, no state. Each service wraps a single data concern.

### SupabaseService

**File:** `lib/core/services/supabase_service.dart`

Singleton access to the Supabase client.

```dart
class SupabaseService {
  static Future<void> init()              // Initialize with dart-define credentials
  static SupabaseClient get client        // Raw Supabase client
  static GoTrueClient get auth            // Auth client shortcut
  static bool get isAuthenticated         // Check current session
  static User? get currentUser            // Current auth user
  static String get userId                // Current user ID (throws if not authed)
}
```

### AuthService

**File:** `lib/core/services/auth_service.dart`

Authentication operations.

```dart
class AuthService {
  static Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String name,
  })
  static Future<AuthResponse> signIn({
    required String email,
    required String password,
  })
  static Future<void> signOut()
  static Future<void> sendPasswordReset(String email)
  static Future<void> verifyPassword(String currentPassword)  // Re-auth check
  static Future<void> updatePassword(String newPassword)
  static String? get currentEmail
  static Stream<AuthState> get onAuthStateChange
}
```

**Notes:**
- `signUp` stores `name` in `raw_user_meta_data` which triggers profile creation
- `verifyPassword` works by attempting `signInWithPassword` — throws `AuthException` if wrong
- `sendPasswordReset` uses redirect URL: `io.supabase.selawathub://login-callback`

### CounterService

**File:** `lib/core/services/counter_service.dart`

Dhikr count persistence and aggregation.

```dart
class CounterService {
  static Future<void> upsertCount(String dhikrId, String category, int count)
  static Future<Map<String, int>> getTodayCounts()
  static Future<List<Map<String, dynamic>>> getSessionsInRange(DateTime start, DateTime end)
  static Future<Map<String, int>> getDailyTotals(DateTime start, DateTime end)
  static Future<List<Map<String, dynamic>>> getWeeklyBreakdown()
}
```

**Notes:**
- `upsertCount` uses `ON CONFLICT` for idempotent daily updates
- `getSessionsInRange` returns raw rows for heatmap/breakdown calculations
- `getWeeklyBreakdown` returns last 7 days split by selawat/zikir

### GroupService

**File:** `lib/core/services/group_service.dart`

Group CRUD, membership management, and group statistics.

```dart
class GroupService {
  static Future<Map<String, dynamic>?> createGroup({
    required String name,
    String? description,
    int dailyGoal = 0,
  })
  static Future<Map<String, dynamic>?> joinGroup(String inviteCode)
  static Future<void> leaveGroup(String groupId)
  static Future<Map<String, dynamic>?> getMyGroup()
  static Future<List<Map<String, dynamic>>> getGroupMembers(String groupId)
  static Future<void> updateGroup(String groupId, {String? name, String? description, int? dailyGoal})
  static Future<void> updateMemberRole(String groupId, String userId, String role)
  static Future<void> removeMember(String groupId, String userId)
  static Future<Map<String, int>> getGroupPeriodTotals(String groupId)
  static Future<List<int>> getGroupYearlyTotals(String groupId, int year)
}
```

**Notes:**
- `createGroup` auto-generates `SLWT-XXXX` invite codes, retries on collision
- `getGroupMembers` calls RPC `get_group_members_with_counts` with today's date
- `getMyGroup` returns the first group the user belongs to (one group per user)

### ProfileService

**File:** `lib/core/services/profile_service.dart`

User profile management and avatar uploads.

```dart
class ProfileService {
  static Future<Map<String, dynamic>?> getProfile()
  static Future<void> updateProfile({String? name, String? bio})
  static Future<String?> uploadAvatar(List<int> bytes, String fileExt)
  static String? getAvatarUrl(String userId)
  static Future<Map<String, int>> getProfileStats()
}
```

**Notes:**
- `getProfile` auto-creates from auth metadata if profile doesn't exist yet
- `uploadAvatar` uploads to `avatars/{userId}/avatar.{ext}` and updates `profiles.avatar_url`
- `getProfileStats` returns `{total_dhikr, streak, days_active}`

### SettingsService

**File:** `lib/core/services/settings_service.dart`

Local preferences persistence via SharedPreferences.

```dart
class SettingsService {
  static Future<void> init()                     // Must call before use

  // Getters & setters
  static bool get hapticEnabled                  // Default: true
  static set hapticEnabled(bool v)
  static int get hapticIntensity                 // 0=light, 1=medium, 2=heavy. Default: 1
  static set hapticIntensity(int v)
  static int get counterStyle                    // 0=digital, 1=bead, 2=minimal. Default: 0
  static set counterStyle(int v)
  static int get colorThemeIndex                 // 0-5. Default: 0 (Emerald)
  static set colorThemeIndex(int v)
  static int get themeMode                       // 0=system, 1=light, 2=dark. Default: 0
  static set themeMode(int v)
  static int get dailyGoal                       // Default: 100
  static set dailyGoal(int v)

  // Per-dhikr custom targets
  static int? getCustomTarget(String dhikrId)
  static void setCustomTarget(String dhikrId, int target)

  // Local counter data (offline backup)
  static int getLocalCount(String dhikrId)
  static void saveLocalCount(String dhikrId, int count)
}
```

### DoaApiService

**File:** `lib/core/services/doa_api_service.dart`

External API client for Islamic content. Singleton with in-memory caching.

```dart
class DoaApiService {
  static final DoaApiService instance            // Singleton access

  Future<List<Doa>> fetchDuas()
  Future<List<NawawiHadith>> fetchHadiths()
  Future<List<DailyAdkar>> fetchDailyAdkar()
  Future<List<PostSalaahZikr>> fetchPostSalaah()
}
```

**Base URL:** `https://dua-data-api.vercel.app/api`

| Endpoint | Model | Description |
|----------|-------|-------------|
| `/dua` | `Doa` | Collection of duas |
| `/hadith/nawawi` | `NawawiHadith` | 40 Nawawi hadiths |
| `/adkar/daily` | `DailyAdkar` | Daily morning/evening adkar |
| `/adkar/post-salaah` | `PostSalaahZikr` | Post-prayer zikr |

**Caching:** Results are cached in instance fields after first fetch. Cache lives for the app session lifetime.

---

## Riverpod Providers

**Location:** `lib/core/providers/`

| Provider | Type | Returns | Depends On |
|----------|------|---------|------------|
| `authStateProvider` | `StreamProvider<AuthState>` | Auth state changes | AuthService |
| `isAuthenticatedProvider` | `Provider<bool>` | Current auth status | SupabaseService |
| `currentUserProvider` | `Provider<User?>` | Current user object | SupabaseService |
| `todayCountsProvider` | `FutureProvider<Map<String, int>>` | Today's counts by dhikr ID | CounterService |
| `counterSettingsProvider` | `Provider<CounterSettings>` | Haptic, style, targets, color | SettingsService |
| `groupProvider` | `FutureProvider<Map?>` | Current user's group | GroupService |
| `groupMembersProvider` | `FutureProvider.family<List, String>` | Members of a group (by ID) | GroupService |
| `profileProvider` | `FutureProvider<ProfileData>` | Full profile + stats | ProfileService |
| `statsProvider` | `FutureProvider<StatsData>` | 364-day aggregated stats | CounterService |

### Provider Invalidation

Providers are manually invalidated when data changes:
- After counter save → invalidate `todayCountsProvider`
- After profile edit → invalidate `profileProvider`
- After group action → invalidate `groupProvider`, `groupMembersProvider`

---

## Data Models

### Dhikr (`lib/features/counter/models/dhikr.dart`)

```dart
class Dhikr {
  final String id;
  final String arabic;
  final String transliteration;
  final String name;
  final int defaultTarget;
  final String category;  // 'selawat' or 'zikir'

  static List<Dhikr> get all          // All 17 items
  static List<Dhikr> get selawatList  // 10 selawat
  static List<Dhikr> get zikirList    // 7 zikir
}
```

### Group Role (`lib/features/group/models/group_role.dart`)

```dart
enum GroupRole { leader, coLeader, member }

typedef GroupMember = ({
  String name,
  int count,
  bool isYou,
  GroupRole role,
  String userId,
});
```

### Doa Models (`lib/features/hadith/models/doa_models.dart`)

```dart
class Doa { String id, title, description, arabic, transliteration, category; }
class NawawiHadith { int id, number; String title, topic, arabic, translation, narrator, source, explanation; }
class DailyAdkar { String id, title, arabic, translation, transliteration; int times; String benefit; }
class PostSalaahZikr { String id, title, arabic, translation, transliteration; int times; String benefit; }
```

### Stats Models (`lib/features/stats/`)

```dart
class DayData {
  int selawat, zikir;
  List<({String id, String name, int count})> topDhikr;
  int get total;
  int get level;  // 0-4 intensity for heatmap
}

class StatsData {
  Map<String, DayData> heatmapData;   // date → DayData (364 days)
  AllTimeBreakdown allTimeBreakdown;
  List<Map> weeklyData;
  Map<String, int> streaks;           // {current, best}
  Map<String, int> totals;            // {total, days_active}
}
```
