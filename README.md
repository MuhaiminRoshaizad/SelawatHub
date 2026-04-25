# SelawatHub

A beautiful Flutter app for counting selawat and zikir — individually or together as a group. Track your daily dhikr, build streaks, and stay connected with your community.

Built with **Flutter** + **Supabase** (Auth, Database, Storage).

## Screenshots

*Coming soon — dark & light mode previews*

## Features

| Feature | Description |
|---------|-------------|
| 🧿 **Tasbih Counter** | 17 built-in dhikr items (10 selawat, 7 zikir) plus user-defined custom entries, manual count entry, 3 visualisation styles, 6 color themes, haptic feedback & tick sound |
| 📊 **Statistics** | 52-week heatmap, streaks with fire tiers, weekly chart, daily goal tracking |
| 👥 **Groups** | Create/join groups, leaderboard, role hierarchy (leader/co-leader/member) |
| 📖 **Daily Content** | Nawawi hadiths, duas, adkar, and post-salaah zikr |
| 👤 **Profile** | Editable profile with avatar, bio, and account management |
| 🌙 **Dark/Light Mode** | Full theme support with system toggle |
| 👻 **Guest Mode** | Use the counter and stats without creating an account |

## Design

- **Minimal + Bold + Premium** — clean whitespace, punchy typography, dark luxe feel
- **Palette** — Deep emerald (`#4A7C5C`) + warm gold (`#C4A44E`) + cream neutrals
- **Dark & Light** modes with smooth toggle

## Quick Start

### Prerequisites
- Flutter SDK ≥ 3.7.0
- Dart ≥ 3.7.0
- Android Studio / VS Code
- A Supabase project (see [docs/SETUP.md](docs/SETUP.md))

### Install & Run

```bash
flutter pub get

flutter run \
  --dart-define=SUPABASE_URL=your_supabase_url \
  --dart-define=SUPABASE_ANON_KEY=your_anon_key
```

### Build APK

```bash
flutter build apk \
  --dart-define=SUPABASE_URL=your_supabase_url \
  --dart-define=SUPABASE_ANON_KEY=your_anon_key
```

## Project Structure

```
lib/
├── app/
│   ├── app.dart              # Root MaterialApp, routing, auth listener
│   └── app_shell.dart        # Bottom tab navigation (5 tabs)
├── core/
│   ├── constants.dart        # Spacing scale (S class)
│   ├── providers/            # Riverpod providers
│   ├── services/             # 8 static service classes
│   ├── theme/                # Colors (C class), themes
│   └── widgets/              # Shared components (BounceTap, FadeIn, etc.)
├── features/
│   ├── auth/                 # Login, sign-up, welcome, password reset
│   ├── counter/              # Tasbih counter + dhikr models
│   ├── group/                # Group management + settings
│   ├── hadith/               # Daily content (hadiths, duas, adkar)
│   ├── profile/              # Profile, about, legal pages, FAQ
│   └── stats/                # Statistics dashboard
└── main.dart
```

## Documentation

Detailed documentation lives in the [`docs/`](docs/) folder:

| Document | Description |
|----------|-------------|
| [Architecture](docs/ARCHITECTURE.md) | System design, data flows, design decisions |
| [Setup](docs/SETUP.md) | Development environment setup guide |
| [Database](docs/DATABASE.md) | Supabase schema, RLS policies, RPC functions |
| [Features](docs/FEATURES.md) | Feature-by-feature documentation |
| [API Reference](docs/API.md) | Services, providers, and external APIs |
| [Design System](docs/DESIGN_SYSTEM.md) | Colors, spacing, typography, components |
| [Contributing](docs/CONTRIBUTING.md) | Code style, commit format, conventions |
| [Roadmap](docs/ROADMAP.md) | Current status and planned features |

## Tech Stack

| Layer | Technology |
|-------|------------|
| Framework | Flutter 3.7+ |
| State Management | Riverpod |
| Backend | Supabase (PostgreSQL + Auth + Storage) |
| External API | [Naikiyah Dua Data API](https://dua-data-api.vercel.app/api) |
| Local Storage | SharedPreferences |
| Audio | audioplayers |
| Sharing | share_plus |

## License

MIT License — Copyright (c) 2025 Muhammad Muhaimin Bin Roshaizad.
See [LICENSE](./LICENSE) for the full text.

