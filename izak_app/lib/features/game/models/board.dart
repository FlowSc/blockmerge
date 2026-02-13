import 'dart:math';

import '../../../core/constants/game_constants.dart';
import 'falling_block.dart';
import 'game_state.dart';
import 'merge_result.dart';
import 'position.dart';
import 'tile.dart';

/// Pure functions for board manipulation.
/// The grid is represented as `List<List<int?>>` where `grid[row][col]` = tile value or null.
abstract final class Board {
  /// Create an empty grid.
  static List<List<int?>> empty() {
    return List.generate(
      GameConstants.rows,
      (_) => List.filled(GameConstants.columns, null),
    );
  }

  /// Deep copy a grid.
  static List<List<int?>> copyGrid(List<List<int?>> grid) {
    return [
      for (final List<int?> row in grid) [...row],
    ];
  }

  /// Check if a position is within bounds.
  static bool inBounds(Position pos) {
    return pos.row >= 0 &&
        pos.row < GameConstants.rows &&
        pos.col >= 0 &&
        pos.col < GameConstants.columns;
  }

  /// Check if a position is empty on the grid.
  static bool isEmpty(List<List<int?>> grid, Position pos) {
    return inBounds(pos) && grid[pos.row][pos.col] == null;
  }

  /// Check if the falling block can occupy its current positions.
  static bool canPlace(List<List<int?>> grid, FallingBlock block) {
    for (final Tile tile in block.tiles) {
      if (!inBounds(tile.position)) return false;
      if (grid[tile.position.row][tile.position.col] != null) return false;
    }
    return true;
  }

  /// Place a block's tiles onto the grid. Returns a new grid.
  static List<List<int?>> placeBlock(
    List<List<int?>> grid,
    FallingBlock block,
  ) {
    final List<List<int?>> newGrid = copyGrid(grid);
    for (final Tile tile in block.tiles) {
      newGrid[tile.position.row][tile.position.col] = tile.value;
    }
    return newGrid;
  }

  /// Find non-overlapping mergeable pairs (for batch processing).
  /// Each tile participates in at most one pair per step.
  static List<MergedPair> findMergeablePairs(List<List<int?>> grid) {
    final List<MergedPair> pairs = [];
    final Set<Position> used = {};

    // Vertical pairs first — bottom merges get highest priority
    for (int row = GameConstants.rows - 1; row > 0; row--) {
      for (int col = 0; col < GameConstants.columns; col++) {
        final Position pos1 = Position(row: row - 1, col: col);
        final Position pos2 = Position(row: row, col: col);
        if (used.contains(pos1) || used.contains(pos2)) continue;
        final int? val1 = grid[row - 1][col];
        final int? val2 = grid[row][col];
        if (val1 != null && val1 == val2) {
          pairs.add(MergedPair(
            from1: pos1,
            from2: pos2,
            to: _chooseMergeTo(grid, pos1, pos2, val1),
            newValue: val1 * 2,
          ));
          used.add(pos1);
          used.add(pos2);
        }
      }
    }

    // Horizontal pairs — right-to-left so rightmost pair is preferred
    for (int row = GameConstants.rows - 1; row >= 0; row--) {
      for (int col = GameConstants.columns - 2; col >= 0; col--) {
        final Position pos1 = Position(row: row, col: col);
        final Position pos2 = Position(row: row, col: col + 1);
        if (used.contains(pos1) || used.contains(pos2)) continue;
        final int? val1 = grid[row][col];
        final int? val2 = grid[row][col + 1];
        if (val1 != null && val1 == val2) {
          pairs.add(MergedPair(
            from1: pos1,
            from2: pos2,
            to: _chooseMergeTo(grid, pos1, pos2, val1),
            newValue: val1 * 2,
          ));
          used.add(pos1);
          used.add(pos2);
        }
      }
    }

    return pairs;
  }

  /// Find ALL adjacent same-value pairs (may share tiles).
  /// Used by animated merge to let the selector pick the best pair.
  static List<MergedPair> findAllAdjacentPairs(List<List<int?>> grid) {
    final List<MergedPair> pairs = [];

    // Vertical pairs
    for (int row = GameConstants.rows - 1; row > 0; row--) {
      for (int col = 0; col < GameConstants.columns; col++) {
        final int? val1 = grid[row - 1][col];
        final int? val2 = grid[row][col];
        if (val1 != null && val1 == val2) {
          final Position pos1 = Position(row: row - 1, col: col);
          final Position pos2 = Position(row: row, col: col);
          pairs.add(MergedPair(
            from1: pos1,
            from2: pos2,
            to: _chooseMergeTo(grid, pos1, pos2, val1),
            newValue: val1 * 2,
          ));
        }
      }
    }

    // Horizontal pairs
    for (int row = GameConstants.rows - 1; row >= 0; row--) {
      for (int col = 0; col < GameConstants.columns - 1; col++) {
        final int? val1 = grid[row][col];
        final int? val2 = grid[row][col + 1];
        if (val1 != null && val1 == val2) {
          final Position pos1 = Position(row: row, col: col);
          final Position pos2 = Position(row: row, col: col + 1);
          pairs.add(MergedPair(
            from1: pos1,
            from2: pos2,
            to: _chooseMergeTo(grid, pos1, pos2, val1),
            newValue: val1 * 2,
          ));
        }
      }
    }

    return pairs;
  }

  /// Choose merge target: prefer the side adjacent to a strictly bigger number.
  /// Only neighbors with value > [tileValue] count (same-value neighbors ignored).
  /// Tiebreaker: lower row (closer to base), then rightward.
  static Position _chooseMergeTo(
    List<List<int?>> grid,
    Position pos1,
    Position pos2,
    int tileValue,
  ) {
    final int mergedValue = tileValue * 2;

    // Primary: immediate chain — merged value matches an adjacent tile.
    bool hasMatchingNeighbor(Position pos, Position exclude) {
      for (final Position n in pos.neighbors) {
        if (n == exclude) continue;
        if (!inBounds(n)) continue;
        if (grid[n.row][n.col] == mergedValue) return true;
      }
      return false;
    }

    final bool match1 = hasMatchingNeighbor(pos1, pos2);
    final bool match2 = hasMatchingNeighbor(pos2, pos1);
    if (match1 && !match2) return pos1;
    if (match2 && !match1) return pos2;

    // Secondary: toward strictly-bigger neighbor.
    int maxStrictNeighbor(Position pos, Position exclude) {
      int maxVal = 0;
      for (final Position n in pos.neighbors) {
        if (n == exclude) continue;
        if (!inBounds(n)) continue;
        final int? val = grid[n.row][n.col];
        if (val != null && val > tileValue && val > maxVal) maxVal = val;
      }
      return maxVal;
    }

    final int score1 = maxStrictNeighbor(pos1, pos2);
    final int score2 = maxStrictNeighbor(pos2, pos1);

    if (score1 > score2) return pos1;
    if (score2 > score1) return pos2;

    // Tied: prefer lower row (closer to base), then rightward
    if (pos1.row > pos2.row) return pos1;
    if (pos2.row > pos1.row) return pos2;
    return pos2;
  }

  /// Apply merges to the grid. Returns a new grid.
  static List<List<int?>> applyMerges(
    List<List<int?>> grid,
    List<MergedPair> pairs,
  ) {
    final List<List<int?>> newGrid = copyGrid(grid);
    for (final MergedPair pair in pairs) {
      // Clear both positions
      newGrid[pair.from1.row][pair.from1.col] = null;
      newGrid[pair.from2.row][pair.from2.col] = null;
      // Place merged value at the target position
      newGrid[pair.to.row][pair.to.col] = pair.newValue;
    }
    return newGrid;
  }

  /// Compute which tiles will drop and how far due to gravity.
  /// Returns only tiles that actually move (fromRow != toRow).
  static List<TileDrop> computeGravityDrops(List<List<int?>> grid) {
    final List<TileDrop> drops = [];
    for (int col = 0; col < GameConstants.columns; col++) {
      int writeRow = GameConstants.rows - 1;
      for (int row = GameConstants.rows - 1; row >= 0; row--) {
        if (grid[row][col] != null) {
          if (writeRow != row) {
            drops.add(TileDrop(
              col: col,
              fromRow: row,
              toRow: writeRow,
              value: grid[row][col]!,
            ));
          }
          writeRow--;
        }
      }
    }
    return drops;
  }

  /// Apply gravity: tiles fall down to fill empty spaces.
  /// Returns a new grid.
  static List<List<int?>> applyGravity(List<List<int?>> grid) {
    final List<List<int?>> newGrid = Board.empty();
    for (int col = 0; col < GameConstants.columns; col++) {
      int writeRow = GameConstants.rows - 1;
      for (int row = GameConstants.rows - 1; row >= 0; row--) {
        if (grid[row][col] != null) {
          newGrid[writeRow][col] = grid[row][col];
          writeRow--;
        }
      }
    }
    return newGrid;
  }

  /// Run the full merge chain: merge → gravity → repeat until no merges.
  /// Returns the chain result with all steps and total score.
  static MergeChainResult runMergeChain(List<List<int?>> grid) {
    final List<MergeStep> steps = [];
    int totalScore = 0;
    int chainLevel = 0;
    List<List<int?>> currentGrid = copyGrid(grid);

    while (true) {
      final List<MergedPair> pairs = findMergeablePairs(currentGrid);
      if (pairs.isEmpty) break;

      final int multiplier = GameConstants.chainMultiplier(chainLevel);
      int stepScore = 0;
      for (final MergedPair pair in pairs) {
        stepScore += pair.newValue * multiplier;
      }

      currentGrid = applyMerges(currentGrid, pairs);
      currentGrid = applyGravity(currentGrid);

      steps.add(MergeStep(
        mergedPairs: pairs,
        chainLevel: chainLevel,
        scoreGained: stepScore,
      ));

      totalScore += stepScore;
      chainLevel++;
    }

    // Copy the final grid state back. We return the result;
    // the caller is responsible for updating the grid from the chain.
    return MergeChainResult(steps: steps, totalScore: totalScore);
  }

  /// Run merge chain and return both the result and the final grid.
  static (List<List<int?>>, MergeChainResult) runMergeChainWithGrid(
    List<List<int?>> grid,
  ) {
    final List<MergeStep> steps = [];
    int totalScore = 0;
    int chainLevel = 0;
    List<List<int?>> currentGrid = copyGrid(grid);

    while (true) {
      final List<MergedPair> pairs = findMergeablePairs(currentGrid);
      if (pairs.isEmpty) break;

      final int multiplier = GameConstants.chainMultiplier(chainLevel);
      int stepScore = 0;
      for (final MergedPair pair in pairs) {
        stepScore += pair.newValue * multiplier;
      }

      currentGrid = applyMerges(currentGrid, pairs);
      currentGrid = applyGravity(currentGrid);

      steps.add(MergeStep(
        mergedPairs: pairs,
        chainLevel: chainLevel,
        scoreGained: stepScore,
      ));

      totalScore += stepScore;
      chainLevel++;
    }

    final MergeChainResult result =
        MergeChainResult(steps: steps, totalScore: totalScore);
    return (currentGrid, result);
  }

  /// Check if the spawn area is blocked (game over condition).
  static bool isSpawnBlocked(List<List<int?>> grid) {
    // Check if the spawn column at rows 0-1 is occupied
    return grid[GameConstants.spawnRow][GameConstants.spawnColumn] != null;
  }

  // --- Item utility functions ---

  /// Remove all tiles with the given [value] and apply gravity.
  static List<List<int?>> removeValue(List<List<int?>> grid, int value) {
    final List<List<int?>> newGrid = copyGrid(grid);
    for (int row = 0; row < GameConstants.rows; row++) {
      for (int col = 0; col < GameConstants.columns; col++) {
        if (newGrid[row][col] == value) {
          newGrid[row][col] = null;
        }
      }
    }
    return applyGravity(newGrid);
  }

  /// Keep only tiles with the maximum value, remove everything else,
  /// then apply gravity.
  static List<List<int?>> keepMaxOnly(List<List<int?>> grid) {
    int maxValue = 0;
    for (int row = 0; row < GameConstants.rows; row++) {
      for (int col = 0; col < GameConstants.columns; col++) {
        final int? v = grid[row][col];
        if (v != null && v > maxValue) maxValue = v;
      }
    }
    if (maxValue == 0) return copyGrid(grid);

    final List<List<int?>> newGrid = copyGrid(grid);
    for (int row = 0; row < GameConstants.rows; row++) {
      for (int col = 0; col < GameConstants.columns; col++) {
        if (newGrid[row][col] != maxValue) {
          newGrid[row][col] = null;
        }
      }
    }
    return applyGravity(newGrid);
  }

  /// Shuffle all tile positions randomly and fill from the bottom up.
  static List<List<int?>> shuffleTiles(List<List<int?>> grid, Random rng) {
    final List<int> values = [];
    for (int row = 0; row < GameConstants.rows; row++) {
      for (int col = 0; col < GameConstants.columns; col++) {
        final int? v = grid[row][col];
        if (v != null) values.add(v);
      }
    }
    if (values.isEmpty) return copyGrid(grid);

    values.shuffle(rng);

    // Fill from the bottom row upward, left to right.
    final List<List<int?>> newGrid = empty();
    int idx = 0;
    for (int row = GameConstants.rows - 1; row >= 0 && idx < values.length; row--) {
      for (int col = 0; col < GameConstants.columns && idx < values.length; col++) {
        newGrid[row][col] = values[idx++];
      }
    }

    return newGrid;
  }
}
