import 'package:flutter_test/flutter_test.dart';
import 'package:izak_app/core/constants/game_constants.dart';
import 'package:izak_app/features/game/models/board.dart';
import 'package:izak_app/features/game/models/falling_block.dart';
import 'package:izak_app/features/game/models/merge_result.dart';
import 'package:izak_app/features/game/models/position.dart';
import 'package:izak_app/features/game/models/tile.dart';

void main() {
  group('Board.empty', () {
    test('creates a grid with correct dimensions', () {
      final List<List<int?>> grid = Board.empty();
      expect(grid.length, GameConstants.rows);
      for (final List<int?> row in grid) {
        expect(row.length, GameConstants.columns);
        for (final int? cell in row) {
          expect(cell, isNull);
        }
      }
    });
  });

  group('Board.inBounds', () {
    test('returns true for valid positions', () {
      expect(Board.inBounds(const Position(row: 0, col: 0)), isTrue);
      expect(Board.inBounds(const Position(row: 11, col: 5)), isTrue);
      expect(Board.inBounds(const Position(row: 5, col: 3)), isTrue);
    });

    test('returns false for out of bounds positions', () {
      expect(Board.inBounds(const Position(row: -1, col: 0)), isFalse);
      expect(Board.inBounds(const Position(row: 0, col: -1)), isFalse);
      expect(Board.inBounds(const Position(row: 12, col: 0)), isFalse);
      expect(Board.inBounds(const Position(row: 0, col: 6)), isFalse);
    });
  });

  group('Board.canPlace', () {
    test('returns true for empty grid', () {
      final List<List<int?>> grid = Board.empty();
      const FallingBlock block = FallingBlock(
        tiles: [
          Tile(value: 2, position: Position(row: 0, col: 2)),
        ],
        type: BlockType.single,
      );
      expect(Board.canPlace(grid, block), isTrue);
    });

    test('returns false when position is occupied', () {
      final List<List<int?>> grid = Board.empty();
      grid[5][3] = 4;
      const FallingBlock block = FallingBlock(
        tiles: [
          Tile(value: 2, position: Position(row: 5, col: 3)),
        ],
        type: BlockType.single,
      );
      expect(Board.canPlace(grid, block), isFalse);
    });

    test('returns false when out of bounds', () {
      final List<List<int?>> grid = Board.empty();
      const FallingBlock block = FallingBlock(
        tiles: [
          Tile(value: 2, position: Position(row: 12, col: 0)),
        ],
        type: BlockType.single,
      );
      expect(Board.canPlace(grid, block), isFalse);
    });
  });

  group('Board.placeBlock', () {
    test('places single block tiles on grid', () {
      final List<List<int?>> grid = Board.empty();
      const FallingBlock block = FallingBlock(
        tiles: [
          Tile(value: 2, position: Position(row: 11, col: 3)),
        ],
        type: BlockType.single,
      );
      final List<List<int?>> result = Board.placeBlock(grid, block);
      expect(result[11][3], 2);
      // Original grid should be unchanged (immutability)
      expect(grid[11][3], isNull);
    });

    test('places pair block tiles on grid', () {
      final List<List<int?>> grid = Board.empty();
      const FallingBlock block = FallingBlock(
        tiles: [
          Tile(value: 2, position: Position(row: 10, col: 3)),
          Tile(value: 4, position: Position(row: 11, col: 3)),
        ],
        type: BlockType.pair,
      );
      final List<List<int?>> result = Board.placeBlock(grid, block);
      expect(result[10][3], 2);
      expect(result[11][3], 4);
    });
  });

  group('Board.findMergeablePairs', () {
    test('finds horizontal pair', () {
      final List<List<int?>> grid = Board.empty();
      grid[11][0] = 2;
      grid[11][1] = 2;

      final List<MergedPair> pairs = Board.findMergeablePairs(grid);
      expect(pairs.length, 1);
      expect(pairs[0].newValue, 4);
      expect(pairs[0].from1, const Position(row: 11, col: 0));
      expect(pairs[0].from2, const Position(row: 11, col: 1));
    });

    test('finds vertical pair', () {
      final List<List<int?>> grid = Board.empty();
      grid[10][0] = 4;
      grid[11][0] = 4;

      final List<MergedPair> pairs = Board.findMergeablePairs(grid);
      expect(pairs.length, 1);
      expect(pairs[0].newValue, 8);
    });

    test('does not merge different values', () {
      final List<List<int?>> grid = Board.empty();
      grid[11][0] = 2;
      grid[11][1] = 4;

      final List<MergedPair> pairs = Board.findMergeablePairs(grid);
      expect(pairs, isEmpty);
    });

    test('each tile used only once per step (2-2-2 case)', () {
      final List<List<int?>> grid = Board.empty();
      grid[11][0] = 2;
      grid[11][1] = 2;
      grid[11][2] = 2;

      final List<MergedPair> pairs = Board.findMergeablePairs(grid);
      // Only one pair should be found (first two), third remains
      expect(pairs.length, 1);
      expect(pairs[0].from1, const Position(row: 11, col: 0));
      expect(pairs[0].from2, const Position(row: 11, col: 1));
    });

    test('finds multiple independent pairs', () {
      final List<List<int?>> grid = Board.empty();
      grid[11][0] = 2;
      grid[11][1] = 2;
      grid[11][4] = 4;
      grid[11][5] = 4;

      final List<MergedPair> pairs = Board.findMergeablePairs(grid);
      expect(pairs.length, 2);
    });
  });

  group('Board.applyMerges', () {
    test('merges horizontal pair correctly', () {
      final List<List<int?>> grid = Board.empty();
      grid[11][0] = 2;
      grid[11][1] = 2;

      final List<MergedPair> pairs = Board.findMergeablePairs(grid);
      final List<List<int?>> result = Board.applyMerges(grid, pairs);

      expect(result[11][0], isNull); // left position cleared
      expect(result[11][1], 4); // merged value at right position
    });
  });

  group('Board.applyGravity', () {
    test('tiles fall to fill gaps', () {
      final List<List<int?>> grid = Board.empty();
      grid[5][0] = 2;
      // gap at rows 6-10
      grid[11][0] = 4;

      final List<List<int?>> result = Board.applyGravity(grid);
      expect(result[11][0], 4);
      expect(result[10][0], 2);
      expect(result[5][0], isNull);
    });

    test('already settled tiles stay in place', () {
      final List<List<int?>> grid = Board.empty();
      grid[10][0] = 2;
      grid[11][0] = 4;

      final List<List<int?>> result = Board.applyGravity(grid);
      expect(result[10][0], 2);
      expect(result[11][0], 4);
    });

    test('multiple tiles in column settle correctly', () {
      final List<List<int?>> grid = Board.empty();
      grid[0][0] = 8;
      grid[3][0] = 4;
      grid[7][0] = 2;

      final List<List<int?>> result = Board.applyGravity(grid);
      expect(result[11][0], 2);
      expect(result[10][0], 4);
      expect(result[9][0], 8);
    });
  });

  group('Board.runMergeChain', () {
    test('no merges returns empty result', () {
      final List<List<int?>> grid = Board.empty();
      grid[11][0] = 2;
      grid[11][1] = 4;

      final MergeChainResult result = Board.runMergeChain(grid);
      expect(result.steps, isEmpty);
      expect(result.totalScore, 0);
    });

    test('single merge returns one step', () {
      final List<List<int?>> grid = Board.empty();
      grid[11][0] = 2;
      grid[11][1] = 2;

      final MergeChainResult result = Board.runMergeChain(grid);
      expect(result.steps.length, 1);
      expect(result.steps[0].chainLevel, 0);
      // Score: 4 * 1 (chain level 0 multiplier)
      expect(result.totalScore, 4);
    });

    test('chain merge: 2-2-2-2 vertical produces multi-step chain', () {
      final List<List<int?>> grid = Board.empty();
      // Stack four 2s in a column
      grid[8][0] = 2;
      grid[9][0] = 2;
      grid[10][0] = 2;
      grid[11][0] = 2;

      final (List<List<int?>> finalGrid, MergeChainResult result) =
          Board.runMergeChainWithGrid(grid);

      // Step 1: two pairs of 2s merge into two 4s
      // Step 2: two 4s merge into one 8
      expect(result.steps.length, 2);
      expect(result.steps[0].chainLevel, 0);
      expect(result.steps[1].chainLevel, 1);

      // Final grid should have a single 8 at the bottom
      expect(finalGrid[11][0], 8);
      expect(finalGrid[10][0], isNull);
    });

    test('chain scoring uses correct multipliers', () {
      final List<List<int?>> grid = Board.empty();
      grid[8][0] = 2;
      grid[9][0] = 2;
      grid[10][0] = 2;
      grid[11][0] = 2;

      final MergeChainResult result = Board.runMergeChain(grid);
      // Chain 0: two 2+2=4 merges → 4*1 + 4*1 = 8
      // Chain 1: one 4+4=8 merge → 8*3 = 24
      expect(result.steps[0].scoreGained, 8); // 2 pairs * 4 * x1
      expect(result.steps[1].scoreGained, 24); // 1 pair * 8 * x3
      expect(result.totalScore, 32);
    });
  });

  group('Board.isSpawnBlocked', () {
    test('returns false for empty grid', () {
      final List<List<int?>> grid = Board.empty();
      expect(Board.isSpawnBlocked(grid), isFalse);
    });

    test('returns true when spawn position is occupied', () {
      final List<List<int?>> grid = Board.empty();
      grid[GameConstants.spawnRow][GameConstants.spawnColumn] = 2;
      expect(Board.isSpawnBlocked(grid), isTrue);
    });
  });
}
