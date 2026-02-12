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
        borderRadius: BorderRadius.circular(2),
        border: isHighlighted
            ? Border.all(
                color: const Color(0xFF00E5FF),
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
              fontFamily: 'PressStart2P',
              color: textColor,
              fontSize: size * 0.28,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );

    if (isNewMerge) {
      tile = _MergeAnimation(child: tile);
    }

    return tile;
  }
}

class _MergeAnimation extends StatefulWidget {
  const _MergeAnimation({required this.child});

  final Widget child;

  @override
  State<_MergeAnimation> createState() => _MergeAnimationState();
}

class _MergeAnimationState extends State<_MergeAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 280),
      vsync: this,
    );

    // Scale: pop up, squeeze, settle — punchy merge impact
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.3, end: 0.88), weight: 45),
      TweenSequenceItem(tween: Tween(begin: 0.88, end: 1.05), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 1.05, end: 1.0), weight: 25),
    ]).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (BuildContext context, Widget? child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        );
      },
      child: widget.child,
    );
  }
}
