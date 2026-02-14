import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/game_mode.dart';
import '../providers/game_notifier.dart';

class ScoreDisplay extends ConsumerWidget {
  const ScoreDisplay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final int score =
        ref.watch(gameNotifierProvider.select((s) => s.score));
    final GameMode gameMode =
        ref.watch(gameNotifierProvider.select((s) => s.gameMode));
    final int remainingSeconds =
        ref.watch(gameNotifierProvider.select((s) => s.remainingSeconds));
    final int level = ref.watch(gameNotifierProvider.select((s) => s.level));
    final l10n = AppLocalizations.of(context)!;

    final bool isTimeAttack = gameMode == GameMode.timeAttack;
    final String bottomLabel = isTimeAttack
        ? _formatTime(remainingSeconds)
        : l10n.levelLabel(level);
    final Color bottomColor = isTimeAttack
        ? (remainingSeconds <= 30
            ? const Color(0xFFFF4444)
            : const Color(0xFFFF6EC7).withValues(alpha: 0.9))
        : const Color(0xFF00E5FF).withValues(alpha: 0.8);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF0B0B1A),
        borderRadius: BorderRadius.circular(2),
        border: Border.all(
          color: const Color(0xFF00E5FF).withValues(alpha: 0.4),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l10n.scoreLabel,
            style: TextStyle(
              fontFamily: 'DungGeunMo',
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 7,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '$score',
            style: const TextStyle(
              fontFamily: 'DungGeunMo',
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            bottomLabel,
            style: TextStyle(
              fontFamily: 'DungGeunMo',
              color: bottomColor,
              fontSize: 7,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(int seconds) {
    final int m = seconds ~/ 60;
    final int s = seconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }
}
