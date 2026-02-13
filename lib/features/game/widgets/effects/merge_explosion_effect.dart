import 'package:flutter/material.dart';

import 'effect_presets.dart';
import 'particle.dart';
import 'particle_painter.dart';
import 'particle_system.dart';

/// Unified pseudo-3D particle explosion shown at every merge position.
///
/// Intensity scales with [tileValue] and [chainLevel].
class MergeExplosionEffect extends StatefulWidget {
  const MergeExplosionEffect({
    super.key,
    required this.size,
    required this.cellSize,
    required this.color,
    required this.tileValue,
    required this.chainLevel,
  });

  final double size;
  final double cellSize;
  final Color color;
  final int tileValue;
  final int chainLevel;

  @override
  State<MergeExplosionEffect> createState() => _MergeExplosionEffectState();
}

class _MergeExplosionEffectState extends State<MergeExplosionEffect>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final ParticleSystem _system;
  double _prevValue = 0;
  bool _chainSpawned = false;
  bool _secondFlashSpawned = false;

  @override
  void initState() {
    super.initState();
    _system = ParticleSystem();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    )..addListener(_onTick);

    final double cx = widget.size / 2;
    final double cy = widget.size / 2;

    EffectPresets.spawnMergeExplosion(
      _system,
      cx: cx,
      cy: cy,
      tileValue: widget.tileValue,
      chainLevel: widget.chainLevel,
      color: widget.color,
    );

    _controller.forward();
  }

  void _onTick() {
    final double current = _controller.value;
    final double dt = (current - _prevValue) * 0.7; // duration in seconds
    _prevValue = current;

    if (dt > 0) {
      _system.update(dt);
    }

    // At ~10% progress, spawn chain enhancement embers.
    if (!_chainSpawned && current >= 0.10 && widget.chainLevel >= 2) {
      _chainSpawned = true;
      EffectPresets.spawnChainEnhancement(
        _system,
        cx: widget.size / 2,
        cy: widget.size / 2,
        chainLevel: widget.chainLevel,
        color: widget.color,
      );
    }

    // At ~15% progress, spawn a secondary flash.
    if (!_secondFlashSpawned && current >= 0.15) {
      _secondFlashSpawned = true;
      _system.spawn(
        x: widget.size / 2,
        y: widget.size / 2,
        baseSize: 18 * (1.0 + widget.chainLevel * 0.2),
        vx: 0,
        vy: 0,
        life: 0.2,
        color: widget.color,
        shape: ParticleShape.flash,
      );
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onTick);
    _controller.dispose();
    _system.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (BuildContext context, Widget? child) {
        return CustomPaint(
          size: Size(widget.size, widget.size),
          painter: ParticlePainter(system: _system),
        );
      },
    );
  }
}
