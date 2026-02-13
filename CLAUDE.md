# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**Merge Chain Blast** is a hybrid puzzle game mobile application combining Tetris-style block dropping with 2048-style number merging. Built with Flutter (frontend) and Supabase (backend). Deployed on **iOS (App Store)** and **Android (Google Play)**.

- **App name**: Merge Chain Blast
- **Bundle ID**: `cc.liftinnovations.mcb`
- **Current version**: 1.0.0+7

## Language Convention

- Communicate with the user in **Korean (한국어)**
- All code, variable names, comments, commit messages, and technical identifiers must be in **English**

## Tech Stack

- **Frontend**: Flutter, Dart
- **Backend**: Supabase (PostgreSQL, RLS)
- **State Management**: Riverpod (flutter_riverpod + riverpod_generator)
- **Routing**: go_router
- **Ads**: Google Mobile Ads (banner, interstitial, rewarded)
- **IAP**: in_app_purchase
- **Audio**: just_audio (BGM + SFX)
- **Testing**: flutter_test (unit tests), integration_test (E2E)
- **Deployment**: App Store (iOS), Google Play (Android)

## Flutter Architecture

The Flutter project lives in `izak_app/` and follows a **feature-first** structure:
```
izak_app/lib/
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
│   │   ├── models/           # Board, FallingBlock, GameState, ItemType, etc.
│   │   ├── providers/        # GameNotifier (game state machine)
│   │   ├── widgets/          # GameBoard, ScoreDisplay, ItemButtons, overlays
│   │   └── game_screen.dart  # Main game screen with gesture handling
│   ├── settings/
│   │   ├── models/           # SettingsState (prefs + item inventory)
│   │   └── providers/        # SettingsNotifier (SharedPreferences persistence)
│   ├── leaderboard/          # Online leaderboard (Supabase)
│   ├── home/                 # Home screen, countdown overlay
│   ├── tutorial/             # Interactive tutorial
│   └── splash/               # Splash screen
├── shared/
│   └── widgets/              # Banner ad widget
└── l10n/
    ├── app_en.arb            # English localization
    └── app_ko.arb            # Korean localization
```

Key rules:
- Use `ConsumerWidget` / `ConsumerStatefulWidget` for widgets that read providers
- Prefer code generation with `@riverpod` annotation over manual provider definitions
- One widget per file, co-locate related files (widget, test, model)
- Feature directories must be self-contained — avoid cross-feature imports
- Composition over inheritance for widget construction
- Use `const` constructors wherever possible for performance

## Game Architecture

- **Board**: 12 rows x 6 columns grid (`List<List<int?>>`)
- **Block types**: single, pair, lShape, jShape, tShape
- **Merge logic**: Pure static functions in `Board` class (no side effects)
- **Animation pipeline**: Highlight → Slide → Merge → Gravity → Chain repeat
- **Chain multipliers**: [1x, 3x, 7x, 15x]
- **Lock delay**: 500ms with 2000ms hard cap
- **DAS**: 170ms delay, 50ms auto-repeat
- **Game modes**: Classic (reach 2048) and Time Attack (180 seconds)
- **Items**: NumberPurge, MaxKeep, Shuffle (stored in SharedPreferences via SettingsNotifier)

## Build Commands

```bash
cd izak_app

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

- Release keystore: `izak_app/android/app/upload-keystore.jks`
- Config: `izak_app/android/key.properties` (gitignored)
- Both files are excluded from git via `.gitignore`

## Verification

- 검증은 `flutter analyze`, `flutter test`, `flutter run`까지 실행할 것 (izak_app/ 디렉토리에서)
- 시뮬레이터에서 스크린샷 캡처나 터치 시뮬레이션 등 수동 UI 테스트는 하지 않는다 — 사용자가 직접 수행

## Dart Standards

- Analysis options: `strict-casts: true`, `strict-raw-types: true`
- Never use `dynamic` (document why if unavoidable)
- All function parameters and return types must be explicitly typed
- Use `final` for local variables that are not reassigned
- Use `const` for compile-time constants
- Prefer immutable data models (use `freezed` or `@immutable` annotation)
- Follow effective Dart style: https://dart.dev/effective-dart

## Custom Agents

Two specialized agents are configured in `.claude/agents/`:
- **react-senior-dev**: For React frontend work, games, interactive UIs
- **nestjs-supabase-senior-dev**: For NestJS backend, Supabase integration, DB design, RLS policies
