import 'dart:math';

import 'package:flutter/foundation.dart';

import '../../../core/constants/game_constants.dart';
import 'position.dart';
import 'tile.dart';

enum BlockType { single, pair, lShape, jShape, tShape }

@immutable
final class FallingBlock {
  const FallingBlock({
    required this.tiles,
    required this.type,
  });

  /// The tiles that make up this block, with positions relative to the board.
  final List<Tile> tiles;
  final BlockType type;

  Map<String, dynamic> toJson() => {
        'tiles': tiles.map((Tile t) => t.toJson()).toList(),
        'type': type.name,
      };

  static FallingBlock fromJson(Map<String, dynamic> json) => FallingBlock(
        tiles: (json['tiles'] as List<dynamic>)
            .map((dynamic t) => Tile.fromJson(t as Map<String, dynamic>))
            .toList(),
        type: BlockType.values.byName(json['type'] as String),
      );

  int get leftCol =>
      tiles.map((Tile t) => t.position.col).reduce((int a, int b) => a < b ? a : b);

  int get rightCol =>
      tiles.map((Tile t) => t.position.col).reduce((int a, int b) => a > b ? a : b);

  int get bottomRow =>
      tiles.map((Tile t) => t.position.row).reduce((int a, int b) => a > b ? a : b);

  int get topRow =>
      tiles.map((Tile t) => t.position.row).reduce((int a, int b) => a < b ? a : b);

  /// Move the entire block by (dRow, dCol).
  FallingBlock move(int dRow, int dCol) {
    return FallingBlock(
      tiles: tiles
          .map((Tile t) => t.copyWith(position: t.position.offset(dRow, dCol)))
          .toList(),
      type: type,
    );
  }

  /// Rotate 90 degrees clockwise, preserving the bounding-box top-left
  /// so the block stays in the same area instead of orbiting.
  FallingBlock rotated() {
    if (type == BlockType.single) return this;

    final Position pivot = tiles[0].position;

    // Remember original bounding-box top-left
    final int origTop = topRow;
    final int origLeft = leftCol;

    // Apply standard 90° CW rotation formula
    final List<Tile> rotatedTiles = tiles.map((Tile t) {
      final int dr = t.position.row - pivot.row;
      final int dc = t.position.col - pivot.col;
      return t.copyWith(
        position: Position(row: pivot.row + dc, col: pivot.col - dr),
      );
    }).toList();

    // Compute new bounding-box top-left and correct drift
    final int newTop = rotatedTiles
        .map((Tile t) => t.position.row)
        .reduce((int a, int b) => a < b ? a : b);
    final int newLeft = rotatedTiles
        .map((Tile t) => t.position.col)
        .reduce((int a, int b) => a < b ? a : b);

    final int dRow = origTop - newTop;
    final int dCol = origLeft - newLeft;

    if (dRow == 0 && dCol == 0) {
      return FallingBlock(tiles: rotatedTiles, type: type);
    }

    return FallingBlock(
      tiles: rotatedTiles
          .map((Tile t) => t.copyWith(
                position: t.position.offset(dRow, dCol),
              ))
          .toList(),
      type: type,
    );
  }

  /// Generate a random tile value using level-based weighted probabilities.
  static int _randomValue(Random rng, int level) {
    final weights = GameConstants.tileWeights(level);
    final int roll = rng.nextInt(100);
    if (roll < weights.w2) return 2;
    if (roll < weights.w4) return 4;
    if (roll < weights.w8) return 8;
    return 16;
  }

  static const int _r = GameConstants.spawnRow;
  static const int _c = GameConstants.spawnColumn;

  /// Spawn a random block at the top center of the board.
  static FallingBlock spawn(Random rng, {int level = 0}) {
    final weights = GameConstants.blockWeights(level);
    final int roll = rng.nextInt(100);
    if (roll < weights.single) return _spawnSingle(rng, level);
    if (roll < weights.pair) return _spawnPair(rng, level);
    if (roll < weights.lShape) return _spawnLShape(rng, level);
    if (roll < weights.jShape) return _spawnJShape(rng, level);
    return _spawnTShape(rng, level);
  }

  static FallingBlock _spawnSingle(Random rng, int level) {
    return FallingBlock(
      tiles: [
        Tile(value: _randomValue(rng, level), position: const Position(row: _r, col: _c)),
      ],
      type: BlockType.single,
    );
  }

  /// Generate tile values for a multi-tile block.
  /// With [sameValueChance] probability, most tiles share the same value
  /// but one tile is guaranteed to be different.
  static List<int> _multiTileValues(Random rng, int level, int count) {
    final int baseValue = _randomValue(rng, level);
    if (rng.nextInt(100) < GameConstants.sameValueChance(level)) {
      final List<int> values = List<int>.filled(count, baseValue);
      final int diffIndex = rng.nextInt(count);
      values[diffIndex] = _differentValue(rng, level, baseValue);
      return values;
    }
    return [baseValue, for (int i = 1; i < count; i++) _randomValue(rng, level)];
  }

  /// Return a random tile value that is different from [exclude].
  static int _differentValue(Random rng, int level, int exclude) {
    for (int i = 0; i < 10; i++) {
      final int v = _randomValue(rng, level);
      if (v != exclude) return v;
    }
    return exclude == 2 ? 4 : 2;
  }

  static FallingBlock _spawnPair(Random rng, int level) {
    final List<int> values = _multiTileValues(rng, level, 2);
    return FallingBlock(
      tiles: [
        Tile(value: values[0], position: const Position(row: _r, col: _c)),
        Tile(value: values[1], position: const Position(row: _r + 1, col: _c)),
      ],
      type: BlockType.pair,
    );
  }

  /// ㄱ shape:
  /// ```
  /// X X
  /// X .
  /// ```
  static FallingBlock _spawnLShape(Random rng, int level) {
    final List<int> values = _multiTileValues(rng, level, 3);
    return FallingBlock(
      tiles: [
        Tile(value: values[0], position: const Position(row: _r, col: _c)),
        Tile(value: values[1], position: const Position(row: _r, col: _c + 1)),
        Tile(value: values[2], position: const Position(row: _r + 1, col: _c)),
      ],
      type: BlockType.lShape,
    );
  }

  /// Reverse ㄱ shape:
  /// ```
  /// X X
  /// . X
  /// ```
  static FallingBlock _spawnJShape(Random rng, int level) {
    final List<int> values = _multiTileValues(rng, level, 3);
    return FallingBlock(
      tiles: [
        Tile(value: values[0], position: const Position(row: _r, col: _c)),
        Tile(value: values[1], position: const Position(row: _r, col: _c + 1)),
        Tile(value: values[2], position: const Position(row: _r + 1, col: _c + 1)),
      ],
      type: BlockType.jShape,
    );
  }

  /// ㅗ shape:
  /// ```
  /// . X .
  /// X X X
  /// ```
  static FallingBlock _spawnTShape(Random rng, int level) {
    final List<int> values = _multiTileValues(rng, level, 4);
    return FallingBlock(
      tiles: [
        Tile(value: values[0], position: const Position(row: _r, col: _c + 1)),
        Tile(value: values[1], position: const Position(row: _r + 1, col: _c)),
        Tile(value: values[2], position: const Position(row: _r + 1, col: _c + 1)),
        Tile(value: values[3], position: const Position(row: _r + 1, col: _c + 2)),
      ],
      type: BlockType.tShape,
    );
  }
}
