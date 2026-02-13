import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'particle.dart';
import 'particle_system.dart';

/// Renders all particles from a [ParticleSystem] onto a [Canvas].
///
/// Uses additive blending (BlendMode.plus) for flash/orb/spark/ember
/// so overlapping particles become brighter instead of muddier.
class ParticlePainter extends CustomPainter {
  ParticlePainter({required this.system});

  final ParticleSystem system;

  // Reused Paint objects to avoid per-frame allocation.
  static final Paint _paint = Paint();
  static final Paint _trailPaint = Paint();
  static final Paint _borderPaint = Paint()..style = PaintingStyle.stroke;
  static final Path _debrisPath = Path();

  @override
  void paint(Canvas canvas, Size size) {
    if (system.isEmpty) return;
    // Depth sorting is done in ParticleSystem.update(), not here.

    for (final Particle p in system.particles) {
      if (p.isDead) continue;
      final double opacity = p.projectedOpacity;
      if (opacity <= 0.01) continue;

      switch (p.shape) {
        case ParticleShape.flash:
          _drawFlash(canvas, p, opacity);
        case ParticleShape.ring:
          _drawRing(canvas, p, opacity);
        case ParticleShape.orb:
          _drawOrb(canvas, p, opacity);
        case ParticleShape.spark:
          _drawSpark(canvas, p, opacity);
        case ParticleShape.debris:
          _drawDebris(canvas, p, opacity);
        case ParticleShape.ember:
          _drawEmber(canvas, p, opacity);
      }
    }
  }

  void _drawFlash(Canvas canvas, Particle p, double opacity) {
    final double radius = p.projectedSize * p.lifeRatio * 2;
    if (radius < 0.5) return;
    // Additive blend — overlapping flashes get brighter.
    _paint
      ..blendMode = BlendMode.plus
      ..shader = ui.Gradient.radial(
        Offset(p.x, p.y),
        radius,
        [
          Colors.white.withValues(alpha: opacity),
          Colors.white.withValues(alpha: opacity * 0.7),
          p.color.withValues(alpha: opacity * 0.4),
          p.color.withValues(alpha: 0),
        ],
        [0.0, 0.2, 0.6, 1.0],
      )
      ..maskFilter = null;
    canvas.drawCircle(Offset(p.x, p.y), radius, _paint);
    _paint
      ..shader = null
      ..blendMode = BlendMode.srcOver;
  }

  void _drawRing(Canvas canvas, Particle p, double opacity) {
    final double progress = 1.0 - p.lifeRatio;
    final double radius = p.baseSize + p.baseSize * 3 * progress;
    final double strokeW = (3.0 * p.lifeRatio).clamp(0.5, 3.0);
    canvas.save();
    canvas.translate(p.x, p.y);
    // Perspective squash on Y axis.
    canvas.scale(1.0, 0.85);

    // Bright white-tinted ring for visibility.
    _paint
      ..shader = null
      ..blendMode = BlendMode.plus
      ..color = Color.lerp(p.color, Colors.white, 0.5)!
          .withValues(alpha: opacity * 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeW
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, strokeW * 1.2);
    canvas.drawCircle(Offset.zero, radius, _paint);
    _paint
      ..style = PaintingStyle.fill
      ..maskFilter = null
      ..blendMode = BlendMode.srcOver;
    canvas.restore();
  }

  void _drawOrb(Canvas canvas, Particle p, double opacity) {
    final double sz = p.projectedSize;
    if (sz < 0.3) return;

    // Draw trail first (behind the orb).
    _drawTrail(canvas, p, opacity * 0.5, sz * 0.6);

    // Gradient sphere — no MaskFilter.blur for performance.
    // Instead, use a larger gradient radius for soft glow.
    final Offset center = Offset(p.x, p.y);
    final Offset highlight = Offset(p.x - sz * 0.25, p.y - sz * 0.25);
    _paint
      ..blendMode = BlendMode.plus
      ..shader = ui.Gradient.radial(
        highlight,
        sz * 2.0,
        [
          Colors.white.withValues(alpha: opacity * 0.9),
          Color.lerp(p.color, Colors.white, 0.3)!
              .withValues(alpha: opacity * 0.8),
          p.color.withValues(alpha: opacity * 0.4),
          p.color.withValues(alpha: 0),
        ],
        [0.0, 0.3, 0.6, 1.0],
      )
      ..maskFilter = null;
    canvas.drawCircle(center, sz * 1.4, _paint);

    // White core dot for 3D highlight.
    _paint
      ..shader = null
      ..color = Colors.white.withValues(alpha: opacity * 0.7);
    canvas.drawCircle(
      Offset(p.x - sz * 0.15, p.y - sz * 0.15),
      sz * 0.3,
      _paint,
    );
    _paint.blendMode = BlendMode.srcOver;
  }

  void _drawSpark(Canvas canvas, Particle p, double opacity) {
    final double sz = p.projectedSize;
    if (sz < 0.2) return;

    // Trail lines with fading thickness.
    _drawTrail(canvas, p, opacity * 0.7, sz * 0.8);

    // Bright head — additive for glow.
    _paint
      ..shader = null
      ..blendMode = BlendMode.plus
      ..color = Color.lerp(p.color, Colors.white, 0.4)!
          .withValues(alpha: opacity)
      ..maskFilter = null;
    canvas.drawCircle(Offset(p.x, p.y), sz, _paint);
    _paint.blendMode = BlendMode.srcOver;
  }

  void _drawDebris(Canvas canvas, Particle p, double opacity) {
    final double sz = p.projectedSize;
    if (sz < 0.3) return;
    canvas.save();
    canvas.translate(p.x, p.y);
    canvas.rotate(p.rotation);

    // Diamond shape.
    _debrisPath
      ..reset()
      ..moveTo(0, -sz)
      ..lineTo(sz * 0.6, 0)
      ..lineTo(0, sz)
      ..lineTo(-sz * 0.6, 0)
      ..close();

    // Lighter fill — lerp toward white for visibility on dark background.
    _paint
      ..shader = null
      ..color = Color.lerp(p.color, Colors.white, 0.3)!
          .withValues(alpha: opacity * 0.85)
      ..style = PaintingStyle.fill
      ..maskFilter = null
      ..blendMode = BlendMode.srcOver;
    canvas.drawPath(_debrisPath, _paint);

    // Bright white edge.
    _borderPaint
      ..color = Colors.white.withValues(alpha: opacity * 0.6)
      ..strokeWidth = 0.7;
    canvas.drawPath(_debrisPath, _borderPaint);

    canvas.restore();
  }

  void _drawEmber(Canvas canvas, Particle p, double opacity) {
    final double sz = p.projectedSize;
    // Pulsing size using sin wave.
    final double pulse = 1.0 + sin(p.life * 14) * 0.3;
    final double radius = sz * pulse;
    if (radius < 0.3) return;

    _paint
      ..blendMode = BlendMode.plus
      ..shader = ui.Gradient.radial(
        Offset(p.x, p.y),
        radius * 1.5,
        [
          Colors.white.withValues(alpha: opacity * 0.6),
          Color.lerp(p.color, Colors.white, 0.3)!
              .withValues(alpha: opacity * 0.7),
          p.color.withValues(alpha: opacity * 0.2),
          p.color.withValues(alpha: 0),
        ],
        [0.0, 0.25, 0.6, 1.0],
      )
      ..maskFilter = null;
    canvas.drawCircle(Offset(p.x, p.y), radius * 1.5, _paint);
    _paint
      ..shader = null
      ..blendMode = BlendMode.srcOver;
  }

  /// Draw a motion trail from recorded positions.
  void _drawTrail(
    Canvas canvas,
    Particle p,
    double opacity,
    double maxWidth,
  ) {
    final int len = p.trailX.length;
    if (len < 2) return;

    _trailPaint.blendMode = BlendMode.plus;

    for (int i = 0; i < len - 1; i++) {
      final double t = i / len; // 0..1, older = smaller t
      final double alpha = opacity * t * 0.7;
      if (alpha < 0.01) continue;
      final double w = maxWidth * t;
      _trailPaint
        ..color = Color.lerp(p.color, Colors.white, 0.2)!
            .withValues(alpha: alpha)
        ..strokeWidth = w
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(
        Offset(p.trailX[i], p.trailY[i]),
        Offset(p.trailX[i + 1], p.trailY[i + 1]),
        _trailPaint,
      );
    }

    // Connect last trail point to current position.
    if (len >= 1) {
      final double alpha = opacity * 0.7;
      _trailPaint
        ..color = Color.lerp(p.color, Colors.white, 0.2)!
            .withValues(alpha: alpha)
        ..strokeWidth = maxWidth
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(
        Offset(p.trailX.last, p.trailY.last),
        Offset(p.x, p.y),
        _trailPaint,
      );
    }

    _trailPaint.blendMode = BlendMode.srcOver;
  }

  @override
  bool shouldRepaint(covariant ParticlePainter oldDelegate) => true;
}
