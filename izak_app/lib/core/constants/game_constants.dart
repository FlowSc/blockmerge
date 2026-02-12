import 'package:flutter/material.dart';

abstract final class GameConstants {
  // Board dimensions
  static const int columns = 6;
  static const int rows = 12;

  // Spawn position (top center)
  static const int spawnColumn = 2;
  static const int spawnRow = 0;

  // Drop speed (milliseconds per tick)
  static const int initialTickMs = 800;
  static const int minTickMs = 250;
  static const int speedIncreasePerLevel = 30;
  static const int pointsPerLevel = 1000;

  // Win condition
  static const int winTileValue = 2048;

  // Time attack duration (seconds)
  static const int timeAttackSeconds = 180;

  // Lock delay (milliseconds): time to move after touching ground
  static const int lockDelayMs = 500;

  // Maximum total lock time (milliseconds): hard cap for lock resets
  static const int maxLockMs = 2000;

  // Block type weights (cumulative probability out of 100)
  static const int weightSingle = 30; // 30%
  static const int weightPair = 55; // +25%
  static const int weightLShape = 70; // +15%
  static const int weightJShape = 85; // +15%
  // remaining 15% = tShape

  // Tile number weights (cumulative probability out of 100)
  static const int weight2 = 50;
  static const int weight4 = 80; // 50 + 30
  static const int weight8 = 95; // 80 + 15
  // remaining 5% = 16

  // Level-based same-value chance (0~100) for multi-tile blocks
  static int sameValueChance(int level) {
    if (level <= 4) return 50;
    if (level <= 9) return 35;
    if (level <= 14) return 25;
    return 15;
  }

  // Level-based tile value weights (cumulative probability out of 100)
  static ({int w2, int w4, int w8}) tileWeights(int level) {
    if (level <= 2) return (w2: 70, w4: 100, w8: 100);
    if (level <= 5) return (w2: 55, w4: 85, w8: 100);
    if (level <= 9) return (w2: 45, w4: 75, w8: 95);
    return (w2: 40, w4: 70, w8: 90);
  }

  // Level-based block type weights (cumulative probability out of 100)
  static ({int single, int pair, int lShape, int jShape}) blockWeights(
      int level) {
    if (level <= 2) return (single: 45, pair: 75, lShape: 85, jShape: 95);
    if (level <= 5) return (single: 35, pair: 60, lShape: 75, jShape: 90);
    if (level <= 9) return (single: 25, pair: 50, lShape: 65, jShape: 80);
    return (single: 20, pair: 40, lShape: 60, jShape: 80);
  }

  // Chain score multipliers
  static const List<int> chainMultipliers = [1, 3, 7, 15];

  static int chainMultiplier(int chainLevel) {
    if (chainLevel < 0) return 1;
    if (chainLevel >= chainMultipliers.length) {
      return chainMultipliers.last;
    }
    return chainMultipliers[chainLevel];
  }

  // Tile colors by value (8-bit vivid palette)
  static const Map<int, Color> tileColors = {
    2: Color(0xFF55FF55),
    4: Color(0xFF55FFFF),
    8: Color(0xFFFF8844),
    16: Color(0xFFCCCC00),
    32: Color(0xFFFF5555),
    64: Color(0xFFFF55FF),
    128: Color(0xFF5577FF),
    256: Color(0xFFFFAA00),
    512: Color(0xFFFF0088),
    1024: Color(0xFF00FFAA),
    2048: Color(0xFFFFD700),
  };

  // Text color: white for all vivid backgrounds
  static Color tileTextColor(int value) {
    return Colors.white;
  }
}
