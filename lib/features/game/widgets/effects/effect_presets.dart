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

    // 1) Ring (shockwave)
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

    // 2) Orbs — gradient spheres
    final int orbCount = (12 + tier * 4 + chainLevel * 3).clamp(12, 38).toInt();
    for (int i = 0; i < orbCount; i++) {
      final double angle = _rng.nextDouble() * 2 * pi;
      final double speed = 80 + _rng.nextDouble() * 150 * intensity;
      final double zVel = (_rng.nextDouble() - 0.5) * 280;
      system.spawn(
        x: cx,
        y: cy,
        z: (_rng.nextDouble() - 0.5) * 56,
        vx: cos(angle) * speed,
        vy: sin(angle) * speed,
        vz: zVel,
        baseSize: 3 + _rng.nextDouble() * 3 * intensity,
        life: 0.45 + _rng.nextDouble() * 0.45,
        color: _varyColor(color),
        shape: ParticleShape.orb,
        drag: 0.955,
        gravity: 135,
        maxTrailLength: 6,
      );
    }

    // 3) Sparks — fast bright streaks
    final int sparkCount = (10 + tier * 3 + chainLevel * 3)
        .clamp(10, 34)
        .toInt();
    for (int i = 0; i < sparkCount; i++) {
      final double angle = _rng.nextDouble() * 2 * pi;
      final double speed = 150 + _rng.nextDouble() * 220 * intensity;
      system.spawn(
        x: cx,
        y: cy,
        z: (_rng.nextDouble() - 0.5) * 42,
        vx: cos(angle) * speed,
        vy: sin(angle) * speed,
        vz: (_rng.nextDouble() - 0.5) * 160,
        baseSize: 1.3 + _rng.nextDouble() * 1.7,
        life: 0.34 + _rng.nextDouble() * 0.32,
        color: i % 3 == 0 ? const Color(0xFFFFFFFF) : _brighten(color),
        shape: ParticleShape.spark,
        drag: 0.935,
        gravity: 0,
        maxTrailLength: 10,
      );
    }

    // 4) Debris — rotating diamond shards
    final int debrisCount = (7 + tier * 2 + chainLevel * 2)
        .clamp(7, 24)
        .toInt();
    for (int i = 0; i < debrisCount; i++) {
      final double angle = _rng.nextDouble() * 2 * pi;
      final double speed = 65 + _rng.nextDouble() * 120 * intensity;
      system.spawn(
        x: cx,
        y: cy,
        z: (_rng.nextDouble() - 0.5) * 50,
        vx: cos(angle) * speed,
        vy: sin(angle) * speed - 35,
        vz: (_rng.nextDouble() - 0.5) * 170,
        baseSize: 2.3 + _rng.nextDouble() * 2.2 * intensity,
        rotation: _rng.nextDouble() * 2 * pi,
        rotationSpeed: (_rng.nextDouble() - 0.5) * 12,
        life: 0.55 + _rng.nextDouble() * 0.34,
        color: _lighten(color),
        shape: ParticleShape.debris,
        drag: 0.97,
        gravity: 280,
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

  /// Mid-phase accent burst: ring pulse + directional sparks.
  ///
  /// This replaces the old secondary flash to keep merge feedback strong
  /// without a jarring white blink.
  static void spawnMergeAccentBurst(
    ParticleSystem system, {
    required double cx,
    required double cy,
    required int tileValue,
    required int chainLevel,
    required Color color,
  }) {
    final int tier = tileValue < 64 ? 0 : (log(tileValue) / ln2 - 5).round();
    final double intensity = 1.0 + chainLevel * 0.25 + tier * 0.1;

    system.spawn(
      x: cx,
      y: cy,
      baseSize: 8 * intensity,
      vx: 0,
      vy: 0,
      life: 0.32,
      color: _brighten(color),
      shape: ParticleShape.ring,
    );

    final int sparkCount = (8 + chainLevel * 2 + tier).clamp(8, 20).toInt();
    for (int i = 0; i < sparkCount; i++) {
      final double angle = _rng.nextDouble() * 2 * pi;
      final double speed = 120 + _rng.nextDouble() * 170 * intensity;
      system.spawn(
        x: cx,
        y: cy,
        z: (_rng.nextDouble() - 0.5) * 36,
        vx: cos(angle) * speed,
        vy: sin(angle) * speed,
        vz: (_rng.nextDouble() - 0.5) * 90,
        baseSize: 1.1 + _rng.nextDouble() * 1.7,
        life: 0.26 + _rng.nextDouble() * 0.18,
        color: i.isEven ? _brighten(color) : const Color(0xFFFFFFFF),
        shape: ParticleShape.spark,
        drag: 0.95,
        gravity: 20,
        maxTrailLength: 8,
      );
    }
  }

  /// Late-phase depth burst: foreground chunks + background dust.
  static void spawnMergeDepthBurst(
    ParticleSystem system, {
    required double cx,
    required double cy,
    required int tileValue,
    required int chainLevel,
    required Color color,
  }) {
    final int tier = tileValue < 64 ? 0 : (log(tileValue) / ln2 - 5).round();
    final int foregroundCount = (6 + tier + chainLevel).clamp(6, 18).toInt();
    final int backgroundCount = (12 + tier * 2 + chainLevel * 2)
        .clamp(12, 28)
        .toInt();

    for (int i = 0; i < foregroundCount; i++) {
      final double angle = _rng.nextDouble() * 2 * pi;
      final double speed = 70 + _rng.nextDouble() * 110;
      system.spawn(
        x: cx + (_rng.nextDouble() - 0.5) * 10,
        y: cy + (_rng.nextDouble() - 0.5) * 10,
        z: 12 + _rng.nextDouble() * 58,
        vx: cos(angle) * speed,
        vy: sin(angle) * speed - 20,
        vz: 120 + _rng.nextDouble() * 180,
        baseSize: 1.8 + _rng.nextDouble() * 2.3,
        rotation: _rng.nextDouble() * 2 * pi,
        rotationSpeed: (_rng.nextDouble() - 0.5) * 14,
        life: 0.34 + _rng.nextDouble() * 0.24,
        color: _lighten(color),
        shape: ParticleShape.debris,
        drag: 0.95,
        gravity: 220,
      );
    }

    for (int i = 0; i < backgroundCount; i++) {
      final double angle = _rng.nextDouble() * 2 * pi;
      final double speed = 40 + _rng.nextDouble() * 90;
      system.spawn(
        x: cx + (_rng.nextDouble() - 0.5) * 8,
        y: cy + (_rng.nextDouble() - 0.5) * 8,
        z: -12 - _rng.nextDouble() * 58,
        vx: cos(angle) * speed,
        vy: sin(angle) * speed,
        vz: -80 - _rng.nextDouble() * 120,
        baseSize: 0.9 + _rng.nextDouble() * 1.5,
        life: 0.3 + _rng.nextDouble() * 0.22,
        color: _varyColor(color),
        shape: ParticleShape.orb,
        drag: 0.96,
        gravity: 40,
        maxTrailLength: 5,
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
