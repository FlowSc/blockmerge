import 'dart:ui';

import 'particle.dart';

/// Manages a pool of [Particle] instances with a hard cap.
///
/// Provides object pooling to eliminate GC pressure during gameplay,
/// and z-depth sorting for correct draw order.
class ParticleSystem {
  static const int _maxParticles = 200;

  final List<Particle> _active = [];
  final List<Particle> _pool = [];

  /// All currently alive particles (read-only view).
  List<Particle> get particles => _active;

  bool get isEmpty => _active.isEmpty;

  /// Acquire a particle from the pool (or create one) and initialise it.
  Particle? spawn({
    required double x,
    required double y,
    double z = 0,
    required double vx,
    required double vy,
    double vz = 0,
    required double baseSize,
    double rotation = 0,
    double rotationSpeed = 0,
    required double life,
    required Color color,
    required ParticleShape shape,
    double drag = 0.96,
    double gravity = 0,
    int maxTrailLength = 0,
  }) {
    if (_active.length >= _maxParticles) return null;

    final Particle p =
        _pool.isNotEmpty ? _pool.removeLast() : Particle();

    p.init(
      x: x,
      y: y,
      z: z,
      vx: vx,
      vy: vy,
      vz: vz,
      baseSize: baseSize,
      rotation: rotation,
      rotationSpeed: rotationSpeed,
      life: life,
      color: color,
      shape: shape,
      drag: drag,
      gravity: gravity,
      maxTrailLength: maxTrailLength,
    );

    _active.add(p);
    return p;
  }

  /// Advance all particles, reclaim dead ones, then sort by depth.
  void update(double dt) {
    // Swap-remove pattern: O(1) per removal instead of O(n).
    int writeIdx = 0;
    for (int i = 0; i < _active.length; i++) {
      final Particle p = _active[i];
      p.update(dt);
      if (p.isDead) {
        _pool.add(p);
      } else {
        if (writeIdx != i) {
          _active[writeIdx] = p;
        }
        writeIdx++;
      }
    }
    _active.length = writeIdx;

    // Sort once per update (not per paint) — far particles first.
    if (_active.length > 1) {
      _active.sort((Particle a, Particle b) => a.z.compareTo(b.z));
    }
  }

  /// Return all particles to the pool.
  void clear() {
    _pool.addAll(_active);
    _active.clear();
  }
}
