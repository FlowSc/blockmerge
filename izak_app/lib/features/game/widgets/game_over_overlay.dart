import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/ad_provider.dart';
import '../../../core/utils/device_id.dart';
import '../../leaderboard/providers/leaderboard_notifier.dart';
import '../../leaderboard/widgets/nickname_dialog.dart';
import '../../settings/providers/settings_notifier.dart';
import '../providers/game_notifier.dart';

class GameOverOverlay extends ConsumerStatefulWidget {
  const GameOverOverlay({super.key});

  @override
  ConsumerState<GameOverOverlay> createState() => _GameOverOverlayState();
}

class _GameOverOverlayState extends ConsumerState<GameOverOverlay> {
  bool _submitted = false;
  bool _submitting = false;

  Future<void> _submitScore() async {
    if (_submitted || _submitting) return;

    String? nickname = ref.read(settingsNotifierProvider).nickname;

    if (nickname == null || nickname.isEmpty) {
      if (!mounted) return;
      nickname = await showNicknameDialog(context, ref);
      if (nickname == null) return;
    }

    setState(() => _submitting = true);

    try {
      final String deviceId = await getDeviceId();
      final gameState = ref.read(gameNotifierProvider);

      await ref.read(leaderboardNotifierProvider.notifier).submitScore(
            nickname: nickname,
            score: gameState.score,
            deviceId: deviceId,
            totalMerges: gameState.totalMerges,
            maxChainLevel: gameState.maxChainLevel,
          );

      if (mounted) {
        setState(() {
          _submitted = true;
          _submitting = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _submitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('점수 제출에 실패했습니다')),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Show interstitial ad on game over
      ref.read(adNotifierProvider.notifier).showInterstitial();
      // Auto-submit if nickname exists
      _submitScore();
    });
  }

  @override
  Widget build(BuildContext context) {
    final int score =
        ref.watch(gameNotifierProvider.select((s) => s.score));
    final int totalMerges =
        ref.watch(gameNotifierProvider.select((s) => s.totalMerges));
    final int maxChainLevel =
        ref.watch(gameNotifierProvider.select((s) => s.maxChainLevel));

    return Container(
      color: Colors.black.withValues(alpha: 0.75),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'GAME OVER',
              style: TextStyle(
                color: Colors.white,
                fontSize: 36,
                fontWeight: FontWeight.w900,
                letterSpacing: 4,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Score: $score',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 24,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _StatChip(label: 'Merges', value: '$totalMerges'),
                const SizedBox(width: 16),
                _StatChip(
                  label: 'Max Chain',
                  value: 'x${maxChainLevel + 1}',
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (_submitting)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white.withValues(alpha: 0.5),
                  ),
                ),
              )
            else if (_submitted)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'Score submitted!',
                  style: TextStyle(
                    color: const Color(0xFF00D2FF).withValues(alpha: 0.8),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              )
            else
              TextButton(
                onPressed: _submitScore,
                child: Text(
                  'Submit Score',
                  style: TextStyle(
                    color: const Color(0xFFFFD700).withValues(alpha: 0.8),
                    fontSize: 13,
                  ),
                ),
              ),
            const SizedBox(height: 20),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                OutlinedButton(
                  onPressed: () => context.go('/'),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.white38),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'HOME',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                      color: Colors.white70,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                OutlinedButton(
                  onPressed: () => context.push('/leaderboard'),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: const Color(0xFFFFD700).withValues(alpha: 0.5),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'RANK',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                      color: Color(0xFFFFD700),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    ref.read(gameNotifierProvider.notifier).startGame();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6C5CE7),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'RETRY',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
