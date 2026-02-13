import 'dart:math';
import 'dart:ui';

import 'particle.dart';
import 'particle_system.dart';

/// Factory that spawns themed particle groups into a [ParticleSystem].
class EffectPresets {
  EffectPresets._();

  static final Random _rng = Random();

  /// Spawn a full merge-explosion burst.
  ///
  /// [cx], [cy] — centre of the merged tile in local paint coordinates.
  /// [tileValue] — the resulting tile value after merge (e.g. 4, 64, 2048).
  /// [chainLevel] — current chain combo index (0-based).
  /// [color] — dominant colour derived from the tile.
  static void spawnMergeExplosion(
    ParticleSystem system, {
    required double cx,
    required double cy,
    required int tileValue,
    required int chainLevel,
    required Color color,
  }) {
    final int tier = tileValue < 64 ? 0 : (log(tileValue) / ln2 - 5).round();
    final double intensity = 1.0 + chainLevel * 0.3 + tier * 0.15;

    // 1) Flash
    system.spawn(
      x: cx,
      y: cy,
      baseSize: 30 * intensity,
      vx: 0,
      vy: 0,
      life: 0.25,
      color: color,
      shape: ParticleShape.flash,
    );

    // 2) Ring (shockwave)
    system.spawn(
      x: cx,
      y: cy,
      baseSize: 10 * intensity,
      vx: 0,
      vy: 0,
      life: 0.5,
      color: color,
      shape: ParticleShape.ring,
    );

    // 3) Orbs — gradient spheres
    final int orbCount = (8 + tier * 3 + chainLevel * 2)
        .clamp(8, 24)
        .toInt();
    for (int i = 0; i < orbCount; i++) {
      final double angle = _rng.nextDouble() * 2 * pi;
      final double speed = 60 + _rng.nextDouble() * 120 * intensity;
      final double zVel = (_rng.nextDouble() - 0.5) * 200;
      system.spawn(
        x: cx,
        y: cy,
        z: (_rng.nextDouble() - 0.5) * 40,
        vx: cos(angle) * speed,
        vy: sin(angle) * speed,
        vz: zVel,
        baseSize: 3 + _rng.nextDouble() * 3 * intensity,
        life: 0.4 + _rng.nextDouble() * 0.4,
        color: _varyColor(color),
        shape: ParticleShape.orb,
        drag: 0.96,
        gravity: 150,
        maxTrailLength: 4,
      );
    }

    // 4) Sparks — fast bright streaks
    final int sparkCount = (6 + tier * 2 + chainLevel * 2)
        .clamp(6, 20)
        .toInt();
    for (int i = 0; i < sparkCount; i++) {
      final double angle = _rng.nextDouble() * 2 * pi;
      final double speed = 120 + _rng.nextDouble() * 180 * intensity;
      system.spawn(
        x: cx,
        y: cy,
        z: (_rng.nextDouble() - 0.5) * 30,
        vx: cos(angle) * speed,
        vy: sin(angle) * speed,
        vz: (_rng.nextDouble() - 0.5) * 100,
        baseSize: 1.5 + _rng.nextDouble() * 1.5,
        life: 0.3 + _rng.nextDouble() * 0.3,
        color: i % 3 == 0 ? const Color(0xFFFFFFFF) : _brighten(color),
        shape: ParticleShape.spark,
        drag: 0.94,
        gravity: 0,
        maxTrailLength: 8,
      );
    }

    // 5) Debris — rotating diamond shards
    final int debrisCount = (4 + tier * 1.5 + chainLevel)
        .clamp(4, 12)
        .toInt();
    for (int i = 0; i < debrisCount; i++) {
      final double angle = _rng.nextDouble() * 2 * pi;
      final double speed = 40 + _rng.nextDouble() * 80 * intensity;
      system.spawn(
        x: cx,
        y: cy,
        z: (_rng.nextDouble() - 0.5) * 20,
        vx: cos(angle) * speed,
        vy: sin(angle) * speed - 30,
        vz: (_rng.nextDouble() - 0.5) * 60,
        baseSize: 2.5 + _rng.nextDouble() * 2 * intensity,
        rotation: _rng.nextDouble() * 2 * pi,
        rotationSpeed: (_rng.nextDouble() - 0.5) * 12,
        life: 0.5 + _rng.nextDouble() * 0.3,
        color: _lighten(color),
        shape: ParticleShape.debris,
        drag: 0.97,
        gravity: 300,
      );
    }
  }

  /// Additional embers spawned when [chainLevel] >= 2.
  static void spawnChainEnhancement(
    ParticleSystem system, {
    required double cx,
    required double cy,
    required int chainLevel,
    required Color color,
  }) {
    final int count = 4 + chainLevel * 2;
    for (int i = 0; i < count; i++) {
      final double angle = _rng.nextDouble() * 2 * pi;
      final double speed = 15 + _rng.nextDouble() * 30;
      system.spawn(
        x: cx + (_rng.nextDouble() - 0.5) * 20,
        y: cy + (_rng.nextDouble() - 0.5) * 20,
        z: _rng.nextDouble() * 30,
        vx: cos(angle) * speed,
        vy: -20 - _rng.nextDouble() * 40, // float upward
        vz: (_rng.nextDouble() - 0.5) * 40,
        baseSize: 2 + _rng.nextDouble() * 2,
        life: 0.6 + _rng.nextDouble() * 0.5,
        color: _varyColor(color),
        shape: ParticleShape.ember,
        drag: 0.98,
        gravity: -30, // slight upward drift
      );
    }
  }

  // --- colour helpers ---

  static int _to8bit(double component) => (component * 255.0).round() & 0xff;

  static Color _varyColor(Color base) {
    final int r = _to8bit(base.r);
    final int g = _to8bit(base.g);
    final int b = _to8bit(base.b);
    // Wider variation range (±40) + bias toward brighter for dark-bg visibility.
    final int dr = ((_rng.nextDouble() - 0.3) * 80).round();
    final int dg = ((_rng.nextDouble() - 0.3) * 80).round();
    final int db = ((_rng.nextDouble() - 0.3) * 80).round();
    return Color.fromARGB(
      255,
      (r + dr).clamp(60, 255),
      (g + dg).clamp(60, 255),
      (b + db).clamp(60, 255),
    );
  }

  static Color _brighten(Color base) {
    return Color.fromARGB(
      255,
      (_to8bit(base.r) + 80).clamp(0, 255),
      (_to8bit(base.g) + 80).clamp(0, 255),
      (_to8bit(base.b) + 80).clamp(0, 255),
    );
  }

  /// Slightly lighter variant (not darker) for debris visibility on dark bg.
  static Color _lighten(Color base) {
    return Color.fromARGB(
      255,
      (_to8bit(base.r) + 40).clamp(80, 255),
      (_to8bit(base.g) + 40).clamp(80, 255),
      (_to8bit(base.b) + 40).clamp(80, 255),
    );
  }
}
