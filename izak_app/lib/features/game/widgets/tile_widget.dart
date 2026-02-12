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
  late final Animation<double> _opacityAnimation;
  late final Animation<double> _flashAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 350),
      vsync: this,
    );

    // Scale: start small, overshoot, settle
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.2), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.2, end: 0.95), weight: 25),
      TweenSequenceItem(tween: Tween(begin: 0.95, end: 1.0), weight: 25),
    ]).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    // Opacity: fade in quickly
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.3, curve: Curves.easeIn),
      ),
    );

    // Flash: bright white overlay that fades out
    _flashAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.6, end: 0.0), weight: 100),
    ]).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
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
        return Opacity(
          opacity: _opacityAnimation.value,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: Stack(
              children: [
                child!,
                // White flash overlay
                if (_flashAnimation.value > 0.01)
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(
                          alpha: _flashAnimation.value,
                        ),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
      child: widget.child,
    );
  }
}
