import '../../../core/constants/game_constants.dart';
import 'falling_block.dart';
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

  /// Find all mergeable pairs of adjacent tiles with the same value.
  /// Scans bottom-to-top so base tiles are paired first.
  /// Merge direction: toward the adjacent bigger number.
  /// Each tile participates in at most one pair per step.
  static List<MergedPair> findMergeablePairs(List<List<int?>> grid) {
    final List<MergedPair> pairs = [];
    final Set<Position> used = {};

    // Scan bottom-to-top so base (lower) tiles are paired first.
    // This ensures stacked identical tiles merge from the bottom up.

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

    // Vertical pairs — bottom-to-top
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
}
