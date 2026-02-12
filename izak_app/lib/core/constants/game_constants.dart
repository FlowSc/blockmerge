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
  static const int minTickMs = 200;
  static const int speedIncreasePerLevel = 50;
  static const int pointsPerLevel = 500;

  // Win condition
  static const int winTileValue = 2048;

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

  // Chain score multipliers
  static const List<int> chainMultipliers = [1, 3, 7, 15];

  static int chainMultiplier(int chainLevel) {
    if (chainLevel < 0) return 1;
    if (chainLevel >= chainMultipliers.length) {
      return chainMultipliers.last;
    }
    return chainMultipliers[chainLevel];
  }

  // Tile colors by value
  static const Map<int, Color> tileColors = {
    2: Color(0xFFEEE4DA),
    4: Color(0xFFEDE0C8),
    8: Color(0xFFF2B179),
    16: Color(0xFFF59563),
    32: Color(0xFFF67C5F),
    64: Color(0xFFF65E3B),
    128: Color(0xFFEDCF72),
    256: Color(0xFFEDCC61),
    512: Color(0xFFEDC850),
    1024: Color(0xFFEDC53F),
    2048: Color(0xFFEDC22E),
  };

  // Text color: dark for low values, white for high values
  static Color tileTextColor(int value) {
    return value <= 4 ? const Color(0xFF776E65) : Colors.white;
  }
}
