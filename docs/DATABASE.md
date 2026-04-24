# Database Schema

SelawatHub uses **Supabase** (hosted PostgreSQL) for all persistent data. This document covers the schema, Row Level Security (RLS) policies, storage buckets, and RPC functions.

## Tables

### `profiles`

User profile information. Auto-created via database trigger when a new auth user signs up.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | UUID | PK, FK → auth.users(id) | User ID (matches auth) |
| `name` | TEXT | | Display name |
| `bio` | TEXT | | Short bio |
| `avatar_url` | TEXT | | Public URL to avatar image |
| `created_at` | TIMESTAMPTZ | DEFAULT now() | Account creation time |
| `updated_at` | TIMESTAMPTZ | DEFAULT now() | Last profile update |

**Trigger:** On `auth.users` INSERT → auto-creates a profile row with `name` from `raw_user_meta_data->>'name'`.

### `groups`

Group information.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | UUID | PK, DEFAULT gen_random_uuid() | Group ID |
| `name` | TEXT | NOT NULL | Group name |
| `description` | TEXT | | Optional description |
| `invite_code` | TEXT | UNIQUE, NOT NULL | Format: `SLWT-XXXX` (alphanumeric) |
| `daily_goal` | INTEGER | DEFAULT 0 | Group daily target (0 = no goal) |
| `created_at` | TIMESTAMPTZ | DEFAULT now() | Creation time |
| `updated_at` | TIMESTAMPTZ | DEFAULT now() | Last update |

### `group_members`

Group membership and roles.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `group_id` | UUID | FK → groups(id), PK (composite) | Group reference |
| `user_id` | UUID | FK → auth.users(id), PK (composite) | User reference |
| `role` | TEXT | NOT NULL, DEFAULT 'member' | `leader`, `coLeader`, or `member` |
| `joined_at` | TIMESTAMPTZ | DEFAULT now() | Join timestamp |

**Composite PK:** `(group_id, user_id)` — a user can only be in a group once.

### `counter_sessions`

Daily dhikr count records. One row per user per dhikr per day.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `user_id` | UUID | FK → auth.users(id), PK (composite) | User reference |
| `dhikr_id` | TEXT | NOT NULL, PK (composite) | Dhikr identifier (e.g., `salawat_ibrahimiyyah`) |
| `date` | DATE | NOT NULL, PK (composite) | Calendar date |
| `category` | TEXT | NOT NULL | `selawat` or `zikir` |
| `count` | INTEGER | NOT NULL, DEFAULT 0 | Total count for the day |

**Composite PK:** `(user_id, dhikr_id, date)` — one record per dhikr per day per user.

**Upsert strategy:** `INSERT ... ON CONFLICT (user_id, dhikr_id, date) DO UPDATE SET count = EXCLUDED.count`

## Row Level Security (RLS)

All tables have RLS enabled. Policies ensure users can only access their own data, with exceptions for group-related reads.

### RLS Helper Functions

To prevent infinite recursion in RLS policies (group_members policies referencing group_members), two `SECURITY DEFINER` helper functions are used:

```sql
-- Check if a user is a member of a specific group (bypasses RLS)
CREATE OR REPLACE FUNCTION is_group_member(check_group_id UUID, check_user_id UUID)
RETURNS BOOLEAN
LANGUAGE sql SECURITY DEFINER STABLE
AS $$
  SELECT EXISTS (
    SELECT 1 FROM group_members
    WHERE group_id = check_group_id AND user_id = check_user_id
  );
$$;

-- Get all group IDs for the current user (bypasses RLS)
CREATE OR REPLACE FUNCTION get_my_group_ids()
RETURNS SETOF UUID
LANGUAGE sql SECURITY DEFINER STABLE
AS $$
  SELECT group_id FROM group_members WHERE user_id = auth.uid();
$$;
```

### Policy Summary

| Table | Policy | Rule |
|-------|--------|------|
| **profiles** | SELECT own | `auth.uid() = id` |
| **profiles** | UPDATE own | `auth.uid() = id` |
| **profiles** | INSERT own | `auth.uid() = id` |
| **counter_sessions** | SELECT own | `auth.uid() = user_id` |
| **counter_sessions** | INSERT own | `auth.uid() = user_id` |
| **counter_sessions** | UPDATE own | `auth.uid() = user_id` |
| **counter_sessions** | Group reads | `group_id IN get_my_group_ids()` via RPC |
| **groups** | SELECT | Members can read their group |
| **groups** | UPDATE | Leaders/co-leaders can update |
| **group_members** | SELECT | Members can see co-members |
| **group_members** | INSERT | Authenticated users can join |
| **group_members** | DELETE own | Users can leave their group |
| **group_members** | DELETE by leader | Leaders can remove members |
| **group_members** | UPDATE | Leaders can change roles |

## RPC Functions

### `get_group_members_with_period_counts`

Returns group members with their dhikr count for an arbitrary date range, used for the Today / Week / Month leaderboard tabs. Requires `SECURITY DEFINER` because `counter_sessions` RLS blocks cross-user reads.

```sql
get_group_members_with_period_counts(p_group_id UUID, p_start_date DATE, p_end_date DATE)
→ TABLE (user_id UUID, role TEXT, name TEXT, avatar_url TEXT, period_count BIGINT)
```

**Usage:** `GroupService.getGroupMembersForPeriod(groupId, start, end)`

### `get_group_members_with_counts`

Returns group members with their today's dhikr count, used for the leaderboard.

```sql
get_group_members_with_counts(p_group_id UUID, p_date DATE)
→ TABLE (user_id UUID, name TEXT, avatar_url TEXT, role TEXT, today_count BIGINT)
```

**Usage:** `GroupService.getGroupMembers(groupId)`

### `get_group_period_totals`

Returns aggregate group totals for week and month periods.

```sql
get_group_period_totals(p_group_id UUID, p_week_start DATE, p_month_start DATE, p_end DATE)
→ TABLE (week_total BIGINT, month_total BIGINT)
```

**Usage:** `GroupService.getGroupPeriodTotals(groupId)`

### `get_group_monthly_totals`

Returns monthly totals for a group over a date range (used for yearly chart).

```sql
get_group_monthly_totals(p_group_id UUID, p_start_date DATE, p_end_date DATE)
→ TABLE (month INTEGER, total BIGINT)
```

**Usage:** `GroupService.getGroupYearlyTotals(groupId, year)`

## Storage Buckets

### `avatars` (Public)

Stores user profile pictures.

- **Path format:** `{userId}/avatar.{ext}` (e.g., `abc123/avatar.jpg`)
- **Access:** Public read (via `getPublicUrl`)
- **Upload:** Authenticated users can upload to their own path
- **Supported formats:** JPEG, PNG (via `image_picker`)

**Upload flow:**
```
image_picker → bytes + extension
  → ProfileService.uploadAvatar(bytes, ext)
  → Supabase Storage upload (upsert)
  → Get public URL
  → Update profiles.avatar_url
```

## Entity Relationship Diagram

```
auth.users (Supabase Auth)
    │
    ├──── 1:1 ──── profiles
    │                 id (PK, FK)
    │                 name, bio, avatar_url
    │
    ├──── 1:N ──── counter_sessions
    │                 user_id (FK)
    │                 dhikr_id, date, category, count
    │
    └──── N:M ──── groups (via group_members)
                     group_members.user_id (FK)
                     group_members.group_id (FK)
                     group_members.role

groups
    id (PK)
    name, description, invite_code, daily_goal
```

## Migrations

Database schema changes are managed directly through the Supabase Dashboard SQL editor. There is no automated migration system. Key schema files:

- **`fix-rls.sql`** — Fixes RLS infinite recursion by introducing `SECURITY DEFINER` helper functions. Located in session state (not committed to repo).

## Data Lifecycle

| Event | Action |
|-------|--------|
| User signs up | Auth row created → trigger creates profile row |
| User counts dhikr | Upsert into counter_sessions (one row per dhikr per day) |
| User creates group | Insert group + insert group_members (role: leader) |
| User joins group | Insert group_members (role: member) |
| User uploads avatar | Upload to storage → update profiles.avatar_url |
| User leaves group | Delete from group_members |
| Leader removes member | Delete from group_members (RLS: leader only) |
