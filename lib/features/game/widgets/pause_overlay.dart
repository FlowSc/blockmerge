import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/ad_provider.dart';
import '../../../core/utils/country_code.dart';
import '../../../core/utils/device_id.dart';
import '../../leaderboard/providers/leaderboard_notifier.dart';
import '../../leaderboard/widgets/nickname_dialog.dart';
import '../../settings/providers/settings_notifier.dart';
import '../models/game_mode.dart';
import '../providers/game_notifier.dart';

class PauseOverlay extends ConsumerWidget {
  const PauseOverlay({required this.onResume, super.key});

  final VoidCallback onResume;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final String playTime = ref.watch(
      gameNotifierProvider.select((s) => s.formattedPlayTime),
    );

    return Container(
      color: Colors.black.withValues(alpha: 0.8),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.pause_circle_outline,
              color: Colors.white54,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.paused,
              style: const TextStyle(
                fontFamily: 'DungGeunMo',
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w900,
                letterSpacing: 4,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              playTime,
              style: TextStyle(
                fontFamily: 'DungGeunMo',
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: 12,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 32),
            _MenuButton(
              label: l10n.resume,
              icon: Icons.play_arrow,
              color: const Color(0xFF00E5FF),
              onPressed: onResume,
            ),
            const SizedBox(height: 16),
            _MenuButton(
              label: l10n.quit,
              icon: Icons.exit_to_app,
              color: const Color(0xFF636e72),
              onPressed: () async {
                final bool? confirmed = await showDialog<bool>(
                  context: context,
                  builder: (BuildContext ctx) => AlertDialog(
                    title: Text(
                      l10n.quitConfirmTitle,
                      style: const TextStyle(
                        fontFamily: 'DungGeunMo',
                        fontSize: 16,
                      ),
                    ),
                    content: Text(
                      l10n.quitConfirmMessage,
                      style: const TextStyle(
                        fontFamily: 'DungGeunMo',
                        fontSize: 12,
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: Text(
                          l10n.cancel,
                          style: const TextStyle(
                            fontFamily: 'DungGeunMo',
                            fontSize: 12,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        child: Text(
                          l10n.confirm,
                          style: const TextStyle(
                            fontFamily: 'DungGeunMo',
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
                if (confirmed == true && context.mounted) {
                  // Submit score to leaderboard before quitting
                  final gameState = ref.read(gameNotifierProvider);
                  if (gameState.score > 0) {
                    String? nickname =
                        ref.read(settingsNotifierProvider).nickname;
                    if ((nickname == null || nickname.isEmpty) &&
                        context.mounted) {
                      nickname = await showNicknameDialog(context, ref);
                    }
                    if (nickname != null && nickname.isNotEmpty) {
                      try {
                        final String deviceId = await getDeviceId();
                        final String gameMode =
                            gameState.gameMode == GameMode.timeAttack
                                ? 'time_attack'
                                : 'classic';
                        await ref
                            .read(leaderboardNotifierProvider.notifier)
                            .submitScore(
                              nickname: nickname,
                              score: gameState.score,
                              deviceId: deviceId,
                              totalMerges: gameState.totalMerges,
                              maxChainLevel: gameState.maxChainLevel,
                              gameMode: gameMode,
                              isCleared: gameState.hasReachedVictory,
                              country: getCountryCode(),
                              playTimeSeconds: gameState.playTimeSeconds,
                            );
                      } catch (_) {
                        // Silent fail — don't block quit
                      }
                    }
                  }
                  if (!context.mounted) return;
                  await ref.read(gameNotifierProvider.notifier).clearSavedGame();
                  if (!context.mounted) return;
                  ref.invalidate(hasSavedGameProvider);
                  ref
                      .read(adNotifierProvider.notifier)
                      .showInterstitial(onComplete: () {
                    if (context.mounted) context.go('/home');
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  const _MenuButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(
          label,
          style: const TextStyle(
            fontFamily: 'DungGeunMo',
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }
}
