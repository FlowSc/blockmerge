# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**izak** is a hybrid puzzle game mobile application combining Tetris-style block dropping with 2048-style number merging. Built with Flutter (frontend) and NestJS with Supabase (backend). Primary deployment target is **iOS**.

## Language Convention

- Communicate with the user in **Korean (한국어)**
- All code, variable names, comments, commit messages, and technical identifiers must be in **English**

## Tech Stack

- **Frontend**: Flutter, Dart
- **Backend**: NestJS, TypeScript, Supabase (PostgreSQL, Auth, Realtime, Storage, RLS)
- **State Management**: Riverpod (flutter_riverpod + riverpod_generator)
- **Routing**: go_router
- **Testing**: flutter_test (단위 테스트), integration_test (E2E)
- **Deployment**: App Store (iOS) / TestFlight, Railway (백엔드)

## Backend Architecture (NestJS + Supabase)

Each feature module follows this structure:
```
module/
├── dto/              # Request/Response DTOs with class-validator
├── entities/         # Domain entities / Supabase table types
├── guards/           # Module-specific guards
├── interceptors/
├── interfaces/
├── module.controller.ts
├── module.service.ts
├── module.repository.ts  # Supabase query layer
└── module.module.ts
```

Key rules:
- Services must never call `supabase.from()` directly — use the Repository layer
- Generate Supabase types via `supabase gen types typescript`
- Always enable RLS on all tables
- Always handle Supabase `{ data, error }` pattern — never ignore `error`
- Separate DTOs for Create, Update, and Response (never reuse request DTOs as response)
- Use `whitelist: true` and `forbidNonWhitelisted: true` in the global validation pipe

## Flutter Architecture

The Flutter project lives in `izak_app/` and follows a **feature-first** structure:
```
izak_app/lib/
├── main.dart                 # Entry point (ProviderScope)
├── app.dart                  # MaterialApp.router + GoRouter setup
├── core/
│   ├── constants/            # Game constants (board size, speed, etc.)
│   ├── theme/                # App theme (colors, typography)
│   └── utils/                # Common utilities
├── features/
│   └── game/
│       ├── models/           # Game data models (Board, Block, Tile)
│       ├── providers/        # Riverpod providers (game state, score)
│       ├── widgets/          # Game widgets (GameBoard, BlockTile, ScoreDisplay)
│       └── game_screen.dart  # Game main screen
└── shared/
    └── widgets/              # Common reusable widgets
```

Key rules:
- Use `ConsumerWidget` / `ConsumerStatefulWidget` for widgets that read providers
- Prefer code generation with `@riverpod` annotation over manual provider definitions
- One widget per file, co-locate related files (widget, test, model)
- Feature directories must be self-contained — avoid cross-feature imports
- Composition over inheritance for widget construction
- Use `const` constructors wherever possible for performance
- 모든 새 기능에는 flutter_test 단위 테스트를 포함할 것

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
