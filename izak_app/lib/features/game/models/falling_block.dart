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

  /// Rotate 90 degrees clockwise around the block's pivot.
  /// Formula: new_row = pivot.row + dc, new_col = pivot.col - dr
  /// where dr = row - pivot.row, dc = col - pivot.col.
  FallingBlock rotated() {
    if (type == BlockType.single) return this;

    final Position pivot = _pivot;
    final List<Tile> rotatedTiles = tiles.map((Tile t) {
      final int dr = t.position.row - pivot.row;
      final int dc = t.position.col - pivot.col;
      return t.copyWith(
        position: Position(row: pivot.row + dc, col: pivot.col - dr),
      );
    }).toList();

    return FallingBlock(tiles: rotatedTiles, type: type);
  }

  /// Pivot point for rotation, chosen per block type.
  Position get _pivot {
    switch (type) {
      case BlockType.single:
        return tiles[0].position;
      case BlockType.pair:
        return tiles[0].position;
      case BlockType.lShape:
        return tiles[0].position;
      case BlockType.jShape:
        return tiles[1].position;
      case BlockType.tShape:
        return tiles[2].position;
    }
  }

  /// Generate a random tile value using weighted probabilities.
  static int _randomValue(Random rng) {
    final int roll = rng.nextInt(100);
    if (roll < GameConstants.weight2) return 2;
    if (roll < GameConstants.weight4) return 4;
    if (roll < GameConstants.weight8) return 8;
    return 16;
  }

  static const int _r = GameConstants.spawnRow;
  static const int _c = GameConstants.spawnColumn;

  /// Spawn a random block at the top center of the board.
  static FallingBlock spawn(Random rng) {
    final int roll = rng.nextInt(100);
    if (roll < GameConstants.weightSingle) return _spawnSingle(rng);
    if (roll < GameConstants.weightPair) return _spawnPair(rng);
    if (roll < GameConstants.weightLShape) return _spawnLShape(rng);
    if (roll < GameConstants.weightJShape) return _spawnJShape(rng);
    return _spawnTShape(rng);
  }

  static FallingBlock _spawnSingle(Random rng) {
    return FallingBlock(
      tiles: [
        Tile(value: _randomValue(rng), position: const Position(row: _r, col: _c)),
      ],
      type: BlockType.single,
    );
  }

  static FallingBlock _spawnPair(Random rng) {
    return FallingBlock(
      tiles: [
        Tile(value: _randomValue(rng), position: const Position(row: _r, col: _c)),
        Tile(value: _randomValue(rng), position: const Position(row: _r + 1, col: _c)),
      ],
      type: BlockType.pair,
    );
  }

  /// ㄱ shape:
  /// ```
  /// X X
  /// X .
  /// ```
  static FallingBlock _spawnLShape(Random rng) {
    return FallingBlock(
      tiles: [
        Tile(value: _randomValue(rng), position: const Position(row: _r, col: _c)),
        Tile(value: _randomValue(rng), position: const Position(row: _r, col: _c + 1)),
        Tile(value: _randomValue(rng), position: const Position(row: _r + 1, col: _c)),
      ],
      type: BlockType.lShape,
    );
  }

  /// Reverse ㄱ shape:
  /// ```
  /// X X
  /// . X
  /// ```
  static FallingBlock _spawnJShape(Random rng) {
    return FallingBlock(
      tiles: [
        Tile(value: _randomValue(rng), position: const Position(row: _r, col: _c)),
        Tile(value: _randomValue(rng), position: const Position(row: _r, col: _c + 1)),
        Tile(value: _randomValue(rng), position: const Position(row: _r + 1, col: _c + 1)),
      ],
      type: BlockType.jShape,
    );
  }

  /// ㅗ shape:
  /// ```
  /// . X .
  /// X X X
  /// ```
  static FallingBlock _spawnTShape(Random rng) {
    return FallingBlock(
      tiles: [
        Tile(value: _randomValue(rng), position: const Position(row: _r, col: _c + 1)),
        Tile(value: _randomValue(rng), position: const Position(row: _r + 1, col: _c)),
        Tile(value: _randomValue(rng), position: const Position(row: _r + 1, col: _c + 1)),
        Tile(value: _randomValue(rng), position: const Position(row: _r + 1, col: _c + 2)),
      ],
      type: BlockType.tShape,
    );
  }
}
