import 'dart:math';

import 'package:flutter/material.dart';

/// Radial burst particle effect shown at a merge position for 5+ combos.
class MegaMergeEffect extends StatefulWidget {
  const MegaMergeEffect({
    super.key,
    required this.size,
    required this.color,
    required this.chainLevel,
  });

  final double size;
  final Color color;
  final int chainLevel;

  @override
  State<MegaMergeEffect> createState() => _MegaMergeEffectState();
}

class _MegaMergeEffectState extends State<MegaMergeEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    )..forward();
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
        return CustomPaint(
          size: Size(widget.size, widget.size),
          painter: _BurstPainter(
            progress: _controller.value,
            color: widget.color,
            chainLevel: widget.chainLevel,
          ),
        );
      },
    );
  }
}

class _BurstPainter extends CustomPainter {
  _BurstPainter({
    required this.progress,
    required this.color,
    required this.chainLevel,
  });

  final double progress;
  final Color color;
  final int chainLevel;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = Offset(size.width / 2, size.height / 2);
    final double maxRadius = size.width * 1.2;
    final int rayCount = 8 + (chainLevel - 4) * 2; // More rays for higher combos
    final double opacity = (1.0 - progress).clamp(0.0, 1.0);

    // Radial glow ring
    final Paint glowPaint = Paint()
      ..color = color.withValues(alpha: opacity * 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0 * (1.0 - progress);
    final double ringRadius = maxRadius * progress;
    canvas.drawCircle(center, ringRadius, glowPaint);

    // Inner flash
    if (progress < 0.3) {
      final double flashOpacity = (1.0 - progress / 0.3) * 0.6;
      final Paint flashPaint = Paint()
        ..color = Colors.white.withValues(alpha: flashOpacity);
      canvas.drawCircle(center, size.width * 0.4 * (1.0 - progress), flashPaint);
    }

    // Ray particles
    final Paint rayPaint = Paint()..strokeCap = StrokeCap.round;
    for (int i = 0; i < rayCount; i++) {
      final double angle = (2 * pi / rayCount) * i;
      final double rayLength = maxRadius * 0.3 * (1.0 - progress * 0.5);
      final double startDist = maxRadius * progress * 0.4;
      final double endDist = startDist + rayLength;

      final Offset start = Offset(
        center.dx + cos(angle) * startDist,
        center.dy + sin(angle) * startDist,
      );
      final Offset end = Offset(
        center.dx + cos(angle) * endDist,
        center.dy + sin(angle) * endDist,
      );

      rayPaint
        ..color = color.withValues(alpha: opacity * 0.8)
        ..strokeWidth = 2.0 * (1.0 - progress);
      canvas.drawLine(start, end, rayPaint);
    }

    // Dot particles (scattered outward)
    final int dotCount = 6 + chainLevel;
    final Random rng = Random(42); // Fixed seed for deterministic pattern
    final Paint dotPaint = Paint();
    for (int i = 0; i < dotCount; i++) {
      final double angle = rng.nextDouble() * 2 * pi;
      final double dist = maxRadius * progress * (0.3 + rng.nextDouble() * 0.7);
      final double dotSize = (2.0 + rng.nextDouble() * 2.0) * (1.0 - progress);

      dotPaint.color = (i % 2 == 0 ? color : Colors.white)
          .withValues(alpha: opacity * 0.9);
      canvas.drawCircle(
        Offset(center.dx + cos(angle) * dist, center.dy + sin(angle) * dist),
        dotSize,
        dotPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_BurstPainter oldDelegate) =>
      progress != oldDelegate.progress;
}
