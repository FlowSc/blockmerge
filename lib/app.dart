import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

import 'core/theme/app_theme.dart';
import 'features/settings/providers/settings_notifier.dart';
import 'features/game/game_screen.dart';
import 'features/game/models/game_mode.dart';
import 'features/home/home_screen.dart';
import 'features/leaderboard/leaderboard_screen.dart';
import 'features/settings/settings_screen.dart';
import 'features/splash/splash_screen.dart';
import 'features/tutorial/time_attack_tutorial_screen.dart';
import 'features/tutorial/tutorial_screen.dart';

GoRouter _createRouter() => GoRouter(
  initialLocation: '/',
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) {
        return const SplashScreen();
      },
    ),
    GoRoute(
      path: '/home',
      builder: (BuildContext context, GoRouterState state) {
        return const HomeScreen();
      },
    ),
    GoRoute(
      path: '/game',
      builder: (BuildContext context, GoRouterState state) {
        final bool isContinue =
            state.uri.queryParameters['continue'] == 'true';
        final bool isTimeAttack =
            state.uri.queryParameters['mode'] == 'timeAttack';
        return GameScreen(
          isContinue: isContinue,
          gameMode:
              isTimeAttack ? GameMode.timeAttack : GameMode.classic,
        );
      },
    ),
    GoRoute(
      path: '/settings',
      builder: (BuildContext context, GoRouterState state) {
        return const SettingsScreen();
      },
    ),
    GoRoute(
      path: '/tutorial',
      builder: (BuildContext context, GoRouterState state) {
        return const TutorialScreen();
      },
    ),
    GoRoute(
      path: '/time-attack-tutorial',
      builder: (BuildContext context, GoRouterState state) {
        return const TimeAttackTutorialScreen();
      },
    ),
    GoRoute(
      path: '/leaderboard',
      builder: (BuildContext context, GoRouterState state) {
        final int initialTab =
            state.uri.queryParameters['tab'] == 'timeAttack' ? 1 : 0;
        return LeaderboardScreen(initialTab: initialTab);
      },
    ),
  ],
);

class IzakApp extends ConsumerStatefulWidget {
  const IzakApp({super.key});

  @override
  ConsumerState<IzakApp> createState() => _IzakAppState();
}

class _IzakAppState extends ConsumerState<IzakApp> {
  late final GoRouter _router = _createRouter();

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String? localeCode = ref.watch(
      settingsNotifierProvider.select((s) => s.localeCode),
    );

    return MaterialApp.router(
      title: 'Merge Chain Blast',
      theme: AppTheme.darkTheme,
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: localeCode != null ? Locale(localeCode) : null,
    );
  }
}
