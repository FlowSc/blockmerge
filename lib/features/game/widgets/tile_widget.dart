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
    final Color lightEdge = _shade(bgColor, 0.22);
    final Color lighterEdge = _shade(bgColor, 0.35);
    final Color darkEdge = _shade(bgColor, -0.28);
    final Color darkerEdge = _shade(bgColor, -0.4);
    final Color borderColor = darkEdge;
    final double pixel = (size / 8).clamp(2.0, 6.0);
    final double bevelThickness = (size * 0.14).clamp(2.0, 6.0);

    Widget tile = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: darkerEdge,
        borderRadius: BorderRadius.circular(2),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: darkerEdge.withValues(alpha: 0.9),
            offset: Offset(0, pixel * 0.55),
            blurRadius: 0,
          ),
        ],
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(2),
          border: Border.all(color: borderColor, width: 2),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(1),
          child: Stack(
            children: <Widget>[
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: <Color>[
                        lighterEdge.withValues(alpha: 0.45),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: bevelThickness,
                top: 0,
                height: bevelThickness,
                child: ColoredBox(color: lightEdge),
              ),
              Positioned(
                left: 0,
                top: 0,
                bottom: bevelThickness,
                width: bevelThickness,
                child: ColoredBox(color: lightEdge),
              ),
              Positioned(
                left: bevelThickness,
                right: 0,
                bottom: 0,
                height: bevelThickness,
                child: ColoredBox(color: darkEdge),
              ),
              Positioned(
                top: bevelThickness,
                right: 0,
                bottom: 0,
                width: bevelThickness,
                child: ColoredBox(color: darkEdge),
              ),
              Positioned(
                left: pixel,
                top: pixel,
                width: pixel,
                height: pixel,
                child: ColoredBox(color: lighterEdge),
              ),
              Positioned(
                right: pixel,
                bottom: pixel,
                width: pixel,
                height: pixel,
                child: ColoredBox(color: darkerEdge),
              ),
              Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Text(
                      '$value',
                      style: TextStyle(
                        fontFamily: 'DungGeunMo',
                        color: textColor,
                        fontSize: size * 0.28,
                        fontWeight: FontWeight.bold,
                        shadows: <Shadow>[
                          Shadow(
                            color: darkEdge,
                            offset: const Offset(1, 1),
                            blurRadius: 0,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (isNewMerge) {
      tile = _MergeAnimation(child: tile);
    }

    return tile;
  }

  Color _shade(Color color, double amount) {
    final HSLColor hsl = HSLColor.fromColor(color);
    final double lightness = (hsl.lightness + amount)
        .clamp(0.0, 1.0)
        .toDouble();
    return hsl.withLightness(lightness).toColor();
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

    // Scale: quick pop and settle without harsh squeeze (avoid visual flicker).
    _scaleAnimation = TweenSequence<double>(
      [
        TweenSequenceItem(tween: Tween(begin: 1.12, end: 0.98), weight: 42),
        TweenSequenceItem(tween: Tween(begin: 0.98, end: 1.03), weight: 28),
        TweenSequenceItem(tween: Tween(begin: 1.03, end: 1.0), weight: 30),
      ],
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

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
        return Transform.scale(scale: _scaleAnimation.value, child: child);
      },
      child: widget.child,
    );
  }
}
