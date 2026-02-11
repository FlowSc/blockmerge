import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/game_constants.dart';
import '../providers/game_notifier.dart';

class ScoreDisplay extends ConsumerWidget {
  const ScoreDisplay({super.key, this.center});

  final Widget? center;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final int score =
        ref.watch(gameNotifierProvider.select((s) => s.score));
    final int highScore =
        ref.watch(gameNotifierProvider.select((s) => s.highScore));
    final int level = score ~/ GameConstants.pointsPerLevel;

    return Row(
      children: [
        Expanded(child: _ScoreBox(label: 'SCORE', value: score, sublabel: 'LV.$level')),
        if (center != null) ...[
          const SizedBox(width: 8),
          center!,
          const SizedBox(width: 8),
        ],
        Expanded(child: _ScoreBox(label: 'BEST', value: highScore)),
      ],
    );
  }
}

class _ScoreBox extends StatelessWidget {
  const _ScoreBox({required this.label, required this.value, this.sublabel});

  final String label;
  final int value;
  final String? sublabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1117),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$value',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (sublabel != null) ...[
            const SizedBox(height: 2),
            Text(
              sublabel!,
              style: TextStyle(
                color: const Color(0xFF00D2FF).withValues(alpha: 0.8),
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
