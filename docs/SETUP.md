# Development Setup

## Prerequisites

| Tool | Version | Purpose |
|------|---------|---------|
| **Flutter SDK** | ≥ 3.10.3 | Framework |
| **Dart SDK** | Included with Flutter | Language |
| **Android Studio** or **VS Code** | Latest | IDE |
| **Android SDK** | API 21+ (minSdk) | Android builds |
| **Xcode** | 14+ (macOS only) | iOS builds |
| **Supabase account** | — | Backend services |

## Quick Start

```bash
# 1. Clone the repository
git clone <repo-url>
cd SelawatHub

# 2. Install dependencies
flutter pub get

# 3. Copy environment template
cp .env.example .env
# Edit .env with your Supabase credentials (for reference only — values are passed via --dart-define)

# 4. Run the app
flutter run \
  --dart-define=SUPABASE_URL=https://your-project.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=your-anon-key
```

## Environment Variables

Credentials are passed at build/run time via `--dart-define` flags. They are **never** hardcoded in source.

| Variable | Description | Example |
|----------|-------------|---------|
| `SUPABASE_URL` | Your Supabase project URL | `https://abcdef.supabase.co` |
| `SUPABASE_ANON_KEY` | Supabase publishable anon key | `eyJhbGciOiJIUz...` |

These are read in `lib/core/services/supabase_service.dart`:
```dart
static const _url = String.fromEnvironment('SUPABASE_URL');
static const _anonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
```

## Build Commands

### Debug
```bash
flutter run --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...
```

### Release APK
```bash
flutter build apk --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...
```

### Release App Bundle (Play Store)
```bash
flutter build appbundle --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...
```

### iOS (macOS only)
```bash
flutter build ipa --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...
```

## Android Configuration

- **Application ID:** `com.example.selawathub`
- **Min SDK:** Flutter default (API 21 / Android 5.0)
- **Target SDK:** Flutter default
- **Java/Kotlin target:** VERSION_17
- **Build system:** Gradle (Kotlin DSL — `build.gradle.kts`)

### Permissions (AndroidManifest.xml)
```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.CAMERA" />
```

### Deep Link Configuration
```xml
<intent-filter>
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />
    <data android:scheme="io.supabase.selawathub" android:host="login-callback" />
</intent-filter>
```

## Dependencies

### Core
| Package | Version | Purpose |
|---------|---------|---------|
| `flutter_riverpod` | ^3.3.1 | State management |
| `supabase_flutter` | ^2.12.4 | Backend (auth, DB, storage) |
| `shared_preferences` | ^2.5.5 | Local key-value storage |

### UI & Animation
| Package | Version | Purpose |
|---------|---------|---------|
| `lottie` | ^3.3.3 | Lottie animation playback |
| `skeletonizer` | ^2.1.3 | Loading skeleton placeholders |
| `cupertino_icons` | ^1.0.8 | iOS-style icons |

### Utilities
| Package | Version | Purpose |
|---------|---------|---------|
| `http` | ^1.4.0 | HTTP client for external APIs |
| `url_launcher` | ^6.3.2 | Open external URLs |
| `image_picker` | ^1.2.1 | Camera/gallery image selection |
| `share_plus` | ^13.0.0 | Native share sheet |
| `intl` | ^0.19.0 | Date/number formatting |

## Static Analysis

```bash
flutter analyze
```

The project uses the default `analysis_options.yaml` from `flutter_lints`. All code must pass `flutter analyze` with zero issues before committing.

## Troubleshooting

### "Improperly formatted define flag"
Ensure `--dart-define` flags use `KEY=VALUE` format with no spaces around `=`:
```bash
# ✅ Correct
--dart-define=SUPABASE_URL=https://...

# ❌ Wrong
--dart-define SUPABASE_URL=https://...
```

### Multi-line shell commands
On Windows (Git Bash / PowerShell), ensure line continuations don't break the command:
```bash
# Git Bash — use backslash
flutter build apk \
  --dart-define=SUPABASE_URL=... \
  --dart-define=SUPABASE_ANON_KEY=...

# PowerShell — use backtick
flutter build apk `
  --dart-define=SUPABASE_URL=... `
  --dart-define=SUPABASE_ANON_KEY=...
```

### Guest mode data loss
Guest data is stored in SharedPreferences (device-local). Uninstalling the app or clearing app data will permanently delete guest counts and settings.
