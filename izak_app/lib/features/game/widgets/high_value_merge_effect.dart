import 'dart:math';

import 'package:flutter/material.dart';

/// Glowing pulse ring effect shown when a merge produces a tile of value 64+.
/// The effect size and intensity scale with the tile value.
class HighValueMergeEffect extends StatefulWidget {
  const HighValueMergeEffect({
    super.key,
    required this.size,
    required this.color,
    required this.tileValue,
  });

  final double size;
  final Color color;
  final int tileValue;

  @override
  State<HighValueMergeEffect> createState() => _HighValueMergeEffectState();
}

class _HighValueMergeEffectState extends State<HighValueMergeEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 650),
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
          painter: _GlowPulsePainter(
            progress: _controller.value,
            color: widget.color,
            tileValue: widget.tileValue,
          ),
        );
      },
    );
  }
}

class _GlowPulsePainter extends CustomPainter {
  _GlowPulsePainter({
    required this.progress,
    required this.color,
    required this.tileValue,
  });

  final double progress;
  final Color color;
  final int tileValue;

  /// Intensity tier: 64→1, 128→2, 256→3, 512→4, 1024→5, 2048→6
  int get _tier => (log(tileValue) / ln2).round() - 5;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = Offset(size.width / 2, size.height / 2);
    final double maxRadius = size.width / 2;
    final double fade = (1.0 - progress).clamp(0.0, 1.0);
    final int tier = _tier;

    // 1) Expanding glow ring (outer)
    final double ringRadius = maxRadius * (0.3 + 0.7 * progress);
    final double ringWidth = (3.0 + tier * 0.8) * fade;
    final Paint ringPaint = Paint()
      ..color = color.withValues(alpha: fade * 0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = ringWidth
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 4.0 + tier * 1.5);
    canvas.drawCircle(center, ringRadius, ringPaint);

    // 2) Second ring (inner, slightly delayed)
    if (tier >= 2) {
      final double innerProgress = (progress * 1.3 - 0.3).clamp(0.0, 1.0);
      final double innerFade = (1.0 - innerProgress).clamp(0.0, 1.0);
      final double innerRadius = maxRadius * 0.6 * (0.2 + 0.8 * innerProgress);
      final Paint innerRingPaint = Paint()
        ..color = Colors.white.withValues(alpha: innerFade * 0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0 * innerFade
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
      canvas.drawCircle(center, innerRadius, innerRingPaint);
    }

    // 3) Center flash (brief white flare)
    if (progress < 0.35) {
      final double flashT = progress / 0.35;
      final double flashOpacity = (1.0 - flashT) * (0.4 + tier * 0.08);
      final double flashRadius = maxRadius * 0.35 * (0.5 + 0.5 * flashT);
      final Paint flashPaint = Paint()
        ..shader = RadialGradient(
          colors: [
            Colors.white.withValues(alpha: flashOpacity),
            color.withValues(alpha: flashOpacity * 0.5),
            color.withValues(alpha: 0),
          ],
          stops: const [0.0, 0.5, 1.0],
        ).createShader(
          Rect.fromCircle(center: center, radius: flashRadius),
        );
      canvas.drawCircle(center, flashRadius, flashPaint);
    }

    // 4) Sparkle dots for 256+ tiles
    if (tier >= 3) {
      final int sparkleCount = 4 + tier;
      final Random rng = Random(tileValue); // deterministic
      final Paint sparklePaint = Paint();
      for (int i = 0; i < sparkleCount; i++) {
        final double angle = rng.nextDouble() * 2 * pi;
        final double dist = maxRadius * progress * (0.4 + rng.nextDouble() * 0.5);
        final double dotSize = (1.5 + rng.nextDouble() * 1.5) * fade;

        sparklePaint.color = (i % 3 == 0 ? Colors.white : color)
            .withValues(alpha: fade * 0.8);
        canvas.drawCircle(
          Offset(center.dx + cos(angle) * dist, center.dy + sin(angle) * dist),
          dotSize,
          sparklePaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_GlowPulsePainter oldDelegate) =>
      progress != oldDelegate.progress;
}
