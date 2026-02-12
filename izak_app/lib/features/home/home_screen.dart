import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers/bgm_notifier.dart';
import '../game/providers/game_notifier.dart';
import '../settings/providers/settings_notifier.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Activate BGM from home screen onward.
    ref.watch(bgmNotifierProvider);

    final bool tutorialSeen =
        ref.watch(settingsNotifierProvider.select((s) => s.tutorialSeen));
    final AsyncValue<bool> hasSaved = ref.watch(hasSavedGameProvider);
    final bool showContinue = hasSaved.valueOrNull ?? false;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 3),
              Text(
                l10n.appTitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'PressStart2P',
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF00E5FF),
                  letterSpacing: 3,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'PressStart2P',
                  fontSize: 8,
                  color: Colors.white70,
                ),
              ),
              const Spacer(flex: 2),
              if (showContinue) ...[
                SizedBox(
                  width: 220,
                  height: 56,
                  child: FilledButton(
                    onPressed: () {
                      context.go('/game?continue=true');
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFFFFD700),
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      textStyle: const TextStyle(
                        fontFamily: 'PressStart2P',
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    child: Text(l10n.continueGame),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              SizedBox(
                width: 220,
                height: 56,
                child: FilledButton(
                  onPressed: () {
                    if (tutorialSeen) {
                      context.go('/game');
                    } else {
                      context.push('/tutorial');
                    }
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF00E5FF),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    textStyle: const TextStyle(
                      fontFamily: 'PressStart2P',
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  child: Text(l10n.start),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: 220,
                height: 56,
                child: FilledButton(
                  onPressed: () {
                    context.go('/game?mode=timeAttack');
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFFF6EC7),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    textStyle: const TextStyle(
                      fontFamily: 'PressStart2P',
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  child: Text(l10n.timeAttack),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: 220,
                height: 56,
                child: OutlinedButton(
                  onPressed: () => context.push('/leaderboard'),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: const Color(0xFFFFD700).withValues(alpha: 0.5),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    textStyle: const TextStyle(
                      fontFamily: 'PressStart2P',
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  child: Text(l10n.leaderboard),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: 220,
                height: 56,
                child: OutlinedButton(
                  onPressed: () => context.push('/settings'),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: const Color(0xFF00E5FF).withValues(alpha: 0.5),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    textStyle: const TextStyle(
                      fontFamily: 'PressStart2P',
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  child: Text(l10n.settings),
                ),
              ),
              const Spacer(flex: 2),
            ],
          ),
        ),
      ),
    );
  }
}
