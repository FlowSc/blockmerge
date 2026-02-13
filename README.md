# Merge Chain Blast

A hybrid puzzle game combining Tetris-style block dropping with 2048-style number merging. Built with Flutter.

## Game Features

- **Block Dropping**: 5 block types (single, pair, L, J, T) fall from the top
- **Number Merging**: Adjacent same-number tiles merge automatically with chain reactions
- **Chain Multipliers**: x1 → x3 → x7 → x15 for consecutive merges
- **Classic Mode**: Reach 2048 to win, or keep going for high scores
- **Time Attack Mode**: Score as high as you can in 3 minutes
- **Items**: Number Purge, Max Keep, Shuffle (consumable power-ups)
- **Online Leaderboard**: Compete globally with daily/weekly/monthly/yearly/all-time filters
- **Tutorial**: Interactive guides for both game modes

## Tech Stack

- **Framework**: Flutter / Dart
- **State Management**: Riverpod (code-gen)
- **Backend**: Supabase (PostgreSQL + RLS)
- **Ads**: Google AdMob (banner, interstitial, rewarded)
- **IAP**: in_app_purchase (remove ads)
- **Audio**: just_audio (BGM + SFX)
- **Localization**: ARB-based i18n (English, Korean)

## Getting Started

### Prerequisites

- Flutter SDK (stable channel)
- Xcode (for iOS)
- Android Studio (for Android)

### Setup

```bash
cd izak_app
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter gen-l10n
```

### Run

```bash
flutter run
```

### Build

```bash
# iOS
flutter build ios --release

# Android (Play Store)
flutter build appbundle --release

# Android (APK)
flutter build apk --release
```

### Test

```bash
flutter analyze
flutter test
```

## Project Structure

```
izak_app/lib/
├── core/           # Constants, theme, providers (ads, IAP, audio), utils
├── features/
│   ├── game/       # Game logic, state, board, blocks, items, UI
│   ├── settings/   # User preferences, item inventory
│   ├── leaderboard/# Online rankings (Supabase)
│   ├── home/       # Home screen
│   ├── tutorial/   # Interactive tutorial
│   └── splash/     # Splash screen
├── shared/         # Reusable widgets
└── l10n/           # Localization files (en, ko)
```

## Platform Support

| Platform | Status |
|----------|--------|
| iOS      | Production |
| Android  | Production |
