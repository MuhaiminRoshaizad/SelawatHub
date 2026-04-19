# Design System

SelawatHub's visual language — colors, typography, spacing, components, and theming conventions.

---

## Philosophy

**Minimal + Bold + Premium** — clean whitespace, punchy typography, dark luxe feel. The design draws from Islamic architectural aesthetics with a warm, spiritual color palette of deep emeralds, warm golds, and cream neutrals.

---

## Color Palette

**File:** `lib/core/theme/colors.dart` — All colors accessed via the `C` class.

### Brand Colors

| Token | Hex | Usage |
|-------|-----|-------|
| `C.primary` | `#4A7C5C` | Primary actions, active states, icons |
| `C.primarySoft` | `#6B9E7E` | Hover/pressed states, secondary elements |
| `C.primaryMuted` | `#3A6148` | Darker variant for contrast |
| `C.primaryGlow` | `#334A7C5C` | Translucent glow backgrounds (33% opacity) |

### Gold Accent

| Token | Hex | Usage |
|-------|-----|-------|
| `C.gold` | `#C4A44E` | Premium accents, streaks, highlights |
| `C.goldSoft` | `#D4BA6F` | Softer gold for secondary accents |
| `C.goldGlow` | `#33C4A44E` | Translucent gold backgrounds |

### Dark Mode Surfaces

| Token | Hex | Usage |
|-------|-----|-------|
| `C.dark1` | `#0E0D0B` | Page background |
| `C.dark2` | `#161513` | Elevated surface (cards) |
| `C.dark3` | `#1F1E1A` | Higher elevation (modals, sheets) |
| `C.dark4` | `#28261F` | Highest elevation |
| `C.darkDivider` | `#332F27` | Borders and separators |

### Light Mode Surfaces

| Token | Hex | Usage |
|-------|-----|-------|
| `C.light1` | `#F7F3EB` | Page background (warm cream) |
| `C.light2` | `#FFFFFF` | Cards and elevated surfaces |
| `C.light3` | `#F0EBE1` | Subtle background variation |
| `C.lightDivider` | `#E5DFD3` | Borders and separators |

### Text Colors

| Token | Dark Mode | Light Mode | Usage |
|-------|-----------|------------|-------|
| `onDark1` / `onLight1` | `#EDE8DD` | `#1C1B17` | Primary text |
| `onDark2` / `onLight2` | `#A09882` | `#6B6558` | Secondary text |
| `onDark3` / `onLight3` | `#635D50` | `#A8A196` | Tertiary/muted text |

### Utility Colors

| Token | Hex | Usage |
|-------|-----|-------|
| `C.error` | `#C75050` | Error states, destructive actions |
| `C.success` | `#5CA06B` | Success states, confirmations |

### Important Convention

```dart
// ✅ Correct — use withValues for opacity
color.withValues(alpha: 0.5)

// ❌ Wrong — do NOT use withOpacity
color.withOpacity(0.5)
```

---

## Spacing Scale

**File:** `lib/core/constants.dart` — All spacing accessed via the `S` class.

| Token | Value | Common Usage |
|-------|-------|-------------|
| `S.s2` | 2 | Micro gaps |
| `S.s4` | 4 | Tight spacing |
| `S.s6` | 6 | Small gap |
| `S.s8` | 8 | Compact padding |
| `S.s12` | 12 | Default gap between items |
| `S.s16` | 16 | Standard padding |
| `S.s20` | 20 | Medium padding |
| `S.s24` | 24 | Section spacing |
| `S.s32` | 32 | Large section gaps |
| `S.s40` | 40 | Major section separation |
| `S.s48` | 48 | Hero/header spacing |
| `S.s64` | 64 | Extra large |
| `S.s80` | 80 | Maximum spacing |
| `S.page` | 24 | Horizontal page padding |

**Note:** There are no `s10`, `s14`, or `s18` tokens. Use the nearest available value.

---

## Typography

**File:** `lib/core/theme/theme.dart`

Material 3 text theme with custom sizing. All text styles should be accessed via `Theme.of(context).textTheme` or the `context.tt` extension.

| Style | Size | Weight | Usage |
|-------|------|--------|-------|
| `headlineLarge` | 28 | w800 | Page titles, hero text |
| `headlineSmall` | 22 | w700 | Section titles |
| `titleLarge` | 18 | w600 | Card titles, sheet headers |
| `titleMedium` | 16 | w600 | Sub-section headers |
| `titleSmall` | 14 | w600 | List item titles |
| `bodyLarge` | 16 | w400 | Primary body text |
| `bodyMedium` | 14 | w400 | Standard body text |
| `bodySmall` | 12 | w400 | Captions, helper text |
| `labelSmall` | 10 | w500 | Badges, tiny labels |

---

## Components

### Shared Widgets (`lib/core/widgets/`)

#### BounceTap
Tap animation wrapper — scales to 0.95 on press, springs back with elastic curve.
```dart
BounceTap(
  onTap: () => ...,
  child: MyWidget(),
)
```

#### FadeIn
Entrance animation — fade + slide up. Supports staggered delays.
```dart
FadeIn(
  delay: Duration(milliseconds: 200),
  child: MyWidget(),
)
```

#### showAppSnackBar
Overlay-based toast notification. Renders **above** bottom sheets and modals.
```dart
showAppSnackBar(context, 'Message here');
showAppSnackBar(context, 'Error!', backgroundColor: C.error);
```

#### showAppFormSheet
Standardised bottom sheet with drag handle and SafeArea.
```dart
showAppFormSheet(
  context: context,
  title: 'Edit Goal',
  builder: (ctx) => Column(children: [...]),
);
```

#### showConfirmDialog
Confirmation modal with loading state on the action button.
```dart
showConfirmDialog(
  context: context,
  title: 'Leave group?',
  message: 'You will lose access to group features.',
  actionLabel: 'Leave',
  isDestructive: true,
  onConfirm: () async => await GroupService.leaveGroup(id),
);
```

#### ActionButtons
Cancel/Save button pair for forms.
```dart
ActionButtons(
  onCancel: () => Navigator.pop(context),
  onConfirm: _save,
  confirmLabel: 'Save Changes',
  loading: _saving,
)
```

#### FrostedBar / FrostedAppBar
Frosted glass effect using `BackdropFilter` with blur. Used for the bottom navigation bar and page app bars.

#### ProgressRing
Animated circular progress indicator with customisable size, stroke, and color.

#### BeadCircle
Custom-painted rosary bead circle showing filled/empty beads with connecting thread.

---

## Counter Color Themes

6 selectable color themes for the counter page:

| Index | Name | Primary | Accent |
|-------|------|---------|--------|
| 0 | Emerald | `#4A7C5C` | `#6B9E7E` |
| 1 | Gold | `#C4A44E` | `#D4BA6F` |
| 2 | Ocean | `#4A6F7C` | `#6B8E9E` |
| 3 | Rose | `#7C4A5C` | `#9E6B7E` |
| 4 | Lavender | `#5C4A7C` | `#7E6B9E` |
| 5 | Ivory | `#7C6B4A` | `#9E8E6B` |

---

## Layout Conventions

### Page Structure
```dart
Scaffold(
  backgroundColor: dark ? C.dark1 : C.light1,
  appBar: AppBar(title: Text('Title')),
  body: SingleChildScrollView(
    padding: EdgeInsets.only(
      left: S.page,
      right: S.page,
      top: S.s24,
      bottom: S.s24 + MediaQuery.of(context).padding.bottom,
    ),
    child: Column(...),
  ),
)
```

### Bottom Safe Area
All scrollable pages must account for the system navigation bar:
```dart
bottom: S.s24 + MediaQuery.of(context).padding.bottom
```

Bottom sheets handle this automatically via `SafeArea(top: false)` in `showAppFormSheet`.

### Card Pattern
```dart
Container(
  decoration: BoxDecoration(
    color: dark ? C.dark3 : C.light2,
    borderRadius: BorderRadius.circular(20),
    border: Border.all(
      color: dark ? C.darkDivider : C.lightDivider,
      width: 0.5,
    ),
  ),
  child: ...,
)
```

### Input Fields
- Number-only inputs: Add `FilteringTextInputFormatter.digitsOnly`
- Always validate: empty check, minimum values, range checks
- Use `appInputDecoration()` for consistent styling
