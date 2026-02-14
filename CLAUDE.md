# CLAUDE.md — Merge Chain Blast

## Project Overview

Hybrid puzzle game combining Tetris-style block dropping with 2048-style number merging. Deployed on **iOS (App Store)** and **Android (Google Play)**.

- **App name**: Merge Chain Blast
- **Bundle ID**: `cc.liftinnovations.mcb`
- **Current version**: 1.0.0+7

## Tech Stack (project-specific)

- **Backend**: Supabase (PostgreSQL, RLS)
- **Ads**: Google Mobile Ads (banner, interstitial, rewarded)
- **IAP**: in_app_purchase
- **Audio**: just_audio (BGM + SFX)
- **Localization**: Flutter ARB (`l10n/`)
- **Testing**: flutter_test (unit), integration_test (E2E)

## Architecture

```
lib/
├── main.dart                 # Entry point (ProviderScope)
├── app.dart                  # MaterialApp.router + GoRouter setup
├── core/
│   ├── config/               # Supabase configuration
│   ├── constants/            # Game constants, ad constants
│   ├── providers/            # Ad, purchase, BGM, SFX providers
│   ├── theme/                # App theme (colors, typography)
│   └── utils/                # Device ID, country code
├── features/
│   ├── game/
│   │   ├── models/           # Board, FallingBlock, GameState, ItemType
│   │   ├── providers/        # GameNotifier (game state machine)
│   │   ├── widgets/          # GameBoard, ScoreDisplay, ItemButtons, overlays
│   │   └── game_screen.dart  # Main game screen with gesture handling
│   ├── settings/             # SettingsState + SettingsNotifier (SharedPreferences)
│   ├── leaderboard/          # Online leaderboard (Supabase)
│   ├── home/                 # Home screen, countdown overlay
│   ├── tutorial/             # Interactive tutorial
│   └── splash/               # Splash screen
├── shared/widgets/           # Banner ad widget
└── l10n/                     # app_en.arb, app_ko.arb
```

## Game Architecture

- **Board**: 12 rows x 6 columns grid (`List<List<int?>>`)
- **Block types**: single, pair, lShape, jShape, tShape
- **Merge logic**: Pure static functions in `Board` class (no side effects)
- **Animation pipeline**: Highlight -> Slide -> Merge -> Gravity -> Chain repeat
- **Chain multipliers**: [1x, 3x, 7x, 15x]
- **Lock delay**: 500ms with 2000ms hard cap
- **DAS**: 170ms delay, 50ms auto-repeat
- **Game modes**: Classic (reach 2048) and Time Attack (180 seconds)
- **Items**: NumberPurge, MaxKeep, Shuffle (stored in SharedPreferences via SettingsNotifier)

## Build Commands

```bash
# Code generation (after modifying @riverpod annotated files)
dart run build_runner build --delete-conflicting-outputs

# Localization (after modifying .arb files)
flutter gen-l10n

# Verification
flutter analyze
flutter test

# iOS build
flutter build ios --release

# Android build (AAB for Play Store)
flutter build appbundle --release

# Android build (APK for testing)
flutter build apk --release
```

## Android Signing

- Release keystore: `android/app/upload-keystore.jks`
- Config: `android/key.properties` (gitignored)
- Both files are excluded from git via `.gitignore`
