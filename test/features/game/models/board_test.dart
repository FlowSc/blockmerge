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
      // Right-to-left scan: rightmost pair (col 1+2) is found, col 0 remains
      expect(pairs.length, 1);
      expect(pairs[0].from1, const Position(row: 11, col: 1));
      expect(pairs[0].from2, const Position(row: 11, col: 2));
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

    test('prefers chain-enabling pair over non-chain pair', () {
      // col:  0   1   2   3
      // row10:     4   4
      // row11: 8   4
      // Vertical (10,1)+(11,1)=8 merges to (11,1) which is adjacent to
      // (11,0)=8, enabling an immediate chain to 16.
      // Horizontal (10,1)+(10,2)=8 merges to (10,2) with no chain neighbor.
      // The vertical pair should be preferred (chain-enabling).
      final List<List<int?>> grid = Board.empty();
      grid[10][1] = 4;
      grid[10][2] = 4;
      grid[11][0] = 8;
      grid[11][1] = 4;

      final List<MergedPair> pairs = Board.findMergeablePairs(grid);
      // Both pairs produce value 8, but only vertical enables a chain.
      expect(pairs.length, 1);
      final MergedPair selected = pairs[0];
      expect(selected.newValue, 8);
      // The chain-enabling vertical pair should be selected.
      expect(selected.from1, const Position(row: 10, col: 1));
      expect(selected.from2, const Position(row: 11, col: 1));
    });

    test('higher-value pair selected even when lower-value vertical exists', () {
      // col:  0   1   2
      // row9:      2
      // row10:     2
      // row11: 8   8
      // Vertical (9,1)+(10,1)=4 vs Horizontal (11,0)+(11,1)=16.
      // The 16-value merge must be selected; the 4-value merge too
      // (they don't conflict).
      final List<List<int?>> grid = Board.empty();
      grid[9][1] = 2;
      grid[10][1] = 2;
      grid[11][0] = 8;
      grid[11][1] = 8;

      final List<MergedPair> pairs = Board.findMergeablePairs(grid);
      expect(pairs.length, 2);
      // First pair should be the higher-value merge.
      expect(pairs[0].newValue, 16);
      expect(pairs[1].newValue, 4);
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

    test('2-2 / 4-4 / 4-2 cascades into multiple merges', () {
      // Regression: small merge (2+2) must not be blocked by larger pair
      // selection, because it creates a cascade through the 4s.
      //
      //  col:  0  1
      //  row9: 2  2
      // row10: 4  4
      // row11: 4  2
      final List<List<int?>> grid = Board.empty();
      grid[9][0] = 2;
      grid[9][1] = 2;
      grid[10][0] = 4;
      grid[10][1] = 4;
      grid[11][0] = 4;
      grid[11][1] = 2;

      final (List<List<int?>> finalGrid, MergeChainResult result) =
          Board.runMergeChainWithGrid(grid);

      // Must have at least 2 chain steps (not just 1 merge that kills
      // the cascade). Batch path merges 2+2 AND one 4+4 in step 1,
      // then remaining 4+4 in step 2.
      expect(result.steps.length, greaterThanOrEqualTo(2));

      // All original 2s and 4s should be consumed. Only 8s (or higher)
      // and the isolated bottom-right 2 should remain.
      final List<int> remaining = [];
      for (final List<int?> row in finalGrid) {
        for (final int? v in row) {
          if (v != null) remaining.add(v);
        }
      }
      // The bottom-right 2 is untouched; everything else merged upward.
      expect(remaining, contains(2)); // isolated bottom-right 2
      expect(remaining.where((int v) => v >= 8).length, greaterThanOrEqualTo(1));
      // No stray 4s should survive — all 4-value tiles should have merged.
      expect(remaining.where((int v) => v == 4).length, 0);
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
