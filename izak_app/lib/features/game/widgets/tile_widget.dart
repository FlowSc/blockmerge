import 'package:flutter/material.dart';

import '../../../core/constants/game_constants.dart';

class TileWidget extends StatelessWidget {
  const TileWidget({
    super.key,
    required this.value,
    this.size = 48,
    this.isHighlighted = false,
    this.isNewMerge = false,
  });

  final int value;
  final double size;
  final bool isHighlighted;
  final bool isNewMerge;

  @override
  Widget build(BuildContext context) {
    final Color bgColor =
        GameConstants.tileColors[value] ?? const Color(0xFF3C3A32);
    final Color textColor = GameConstants.tileTextColor(value);

    Widget tile = AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          if (isHighlighted) ...[
            BoxShadow(
              color: Colors.white.withValues(alpha: 0.9),
              blurRadius: 16,
              spreadRadius: 3,
            ),
            BoxShadow(
              color: bgColor.withValues(alpha: 0.8),
              blurRadius: 8,
              spreadRadius: 1,
            ),
          ] else
            BoxShadow(
              color: bgColor.withValues(alpha: 0.4),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
        ],
        border: isHighlighted
            ? Border.all(
                color: Colors.white.withValues(alpha: 0.9),
                width: 2,
              )
            : null,
      ),
      alignment: Alignment.center,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Text(
            '$value',
            style: TextStyle(
              color: textColor,
              fontSize: size * 0.4,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );

    if (isNewMerge) {
      tile = TweenAnimationBuilder<double>(
        tween: Tween(begin: 1.3, end: 1.0),
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        builder: (BuildContext context, double scale, Widget? child) {
          return Transform.scale(scale: scale, child: child);
        },
        child: tile,
      );
    }

    return tile;
  }
}
