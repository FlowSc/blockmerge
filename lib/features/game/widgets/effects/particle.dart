import 'dart:math';
import 'dart:ui';

/// Visual shape categories for the particle system.
enum ParticleShape { orb, spark, debris, ring, flash, ember }

/// A single particle with pseudo-3D position, velocity, and visual properties.
///
/// The z-axis simulates depth: positive z = closer to camera (larger),
/// negative z = farther (smaller).
class Particle {
  double x;
  double y;
  double z;
  double vx;
  double vy;
  double vz;
  double baseSize;
  double rotation;
  double rotationSpeed;
  double life;
  double maxLife;
  Color color;
  ParticleShape shape;
  double drag;
  double gravity;

  /// Trail history as (x, y) pairs for motion blur.
  final List<double> trailX = [];
  final List<double> trailY = [];
  int maxTrailLength;

  bool get isDead => life <= 0;
  double get lifeRatio => (life / maxLife).clamp(0.0, 1.0);

  /// Projected size based on z-depth.
  double get projectedSize =>
      baseSize * (1.0 + z * 0.005).clamp(0.3, 3.0);

  /// Projected opacity based on z-depth and remaining life.
  double get projectedOpacity =>
      ((1.0 + z * 0.003).clamp(0.2, 1.0) * lifeRatio).clamp(0.0, 1.0);

  Particle()
      : x = 0,
        y = 0,
        z = 0,
        vx = 0,
        vy = 0,
        vz = 0,
        baseSize = 4,
        rotation = 0,
        rotationSpeed = 0,
        life = 0,
        maxLife = 1,
        color = const Color(0xFFFFFFFF),
        shape = ParticleShape.orb,
        drag = 0.96,
        gravity = 0,
        maxTrailLength = 0;

  /// Reset for object-pool reuse.
  void init({
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
    this.x = x;
    this.y = y;
    this.z = z;
    this.vx = vx;
    this.vy = vy;
    this.vz = vz;
    this.baseSize = baseSize;
    this.rotation = rotation;
    this.rotationSpeed = rotationSpeed;
    this.life = life;
    maxLife = life;
    this.color = color;
    this.shape = shape;
    this.drag = drag;
    this.gravity = gravity;
    this.maxTrailLength = maxTrailLength;
    trailX.clear();
    trailY.clear();
  }

  /// Advance physics by [dt] seconds.
  void update(double dt) {
    // Record trail before moving.
    if (maxTrailLength > 0) {
      trailX.add(x);
      trailY.add(y);
      if (trailX.length > maxTrailLength) {
        trailX.removeAt(0);
        trailY.removeAt(0);
      }
    }

    // Apply velocity.
    x += vx * dt;
    y += vy * dt;
    z += vz * dt;

    // Drag.
    final double dragFactor = pow(drag, dt * 60).toDouble();
    vx *= dragFactor;
    vy *= dragFactor;
    vz *= dragFactor;

    // Gravity (screen-space downward).
    vy += gravity * dt;

    // Rotation.
    rotation += rotationSpeed * dt;

    // Deplete life.
    life -= dt;
  }
}
