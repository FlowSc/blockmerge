import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../game/providers/game_notifier.dart';
import '../settings/providers/settings_notifier.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                style: TextStyle(
                  fontSize: 64,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                  letterSpacing: 12,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.subtitle,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const Spacer(flex: 2),
              if (showContinue) ...[
                SizedBox(
                  width: 220,
                  height: 56,
                  child: FilledButton(
                    onPressed: () async {
                      final bool restored = await ref
                          .read(gameNotifierProvider.notifier)
                          .restoreGame();
                      if (restored && context.mounted) {
                        context.go('/game?continue=true');
                      }
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFFFFD700),
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 20,
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
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  child: Text(l10n.start),
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
                      borderRadius: BorderRadius.circular(16),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 20,
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
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withValues(alpha: 0.5),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 20,
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
