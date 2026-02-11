import 'package:flutter/foundation.dart';

import 'falling_block.dart';
import 'merge_result.dart';
import 'position.dart';

enum GameStatus { idle, playing, paused, gameOver }

@immutable
final class GameState {
  const GameState({
    required this.grid,
    required this.currentBlock,
    required this.nextBlock,
    required this.score,
    required this.highScore,
    required this.status,
    required this.lastMergeChain,
    this.isAnimating = false,
    this.highlightedPositions,
    this.newMergedPositions,
  });

  /// 12 rows x 6 columns. null = empty cell, int = tile value.
  final List<List<int?>> grid;

  final FallingBlock? currentBlock;
  final FallingBlock? nextBlock;
  final int score;
  final int highScore;
  final GameStatus status;

  /// The most recent merge chain result (for combo display).
  final MergeChainResult? lastMergeChain;

  /// True while merge chain animation is playing. Input is blocked.
  final bool isAnimating;

  /// Positions of tiles about to merge (glow highlight).
  final Set<Position>? highlightedPositions;

  /// Positions of tiles that just appeared from a merge (pop effect).
  final Set<Position>? newMergedPositions;

  GameState copyWith({
    List<List<int?>>? grid,
    FallingBlock? Function()? currentBlock,
    FallingBlock? Function()? nextBlock,
    int? score,
    int? highScore,
    GameStatus? status,
    MergeChainResult? Function()? lastMergeChain,
    bool? isAnimating,
    Set<Position>? Function()? highlightedPositions,
    Set<Position>? Function()? newMergedPositions,
  }) {
    return GameState(
      grid: grid ?? this.grid,
      currentBlock:
          currentBlock != null ? currentBlock() : this.currentBlock,
      nextBlock: nextBlock != null ? nextBlock() : this.nextBlock,
      score: score ?? this.score,
      highScore: highScore ?? this.highScore,
      status: status ?? this.status,
      lastMergeChain:
          lastMergeChain != null ? lastMergeChain() : this.lastMergeChain,
      isAnimating: isAnimating ?? this.isAnimating,
      highlightedPositions: highlightedPositions != null
          ? highlightedPositions()
          : this.highlightedPositions,
      newMergedPositions: newMergedPositions != null
          ? newMergedPositions()
          : this.newMergedPositions,
    );
  }
}
