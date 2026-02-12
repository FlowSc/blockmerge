import 'package:flutter/foundation.dart';

import 'falling_block.dart';
import 'game_mode.dart';
import 'merge_result.dart';
import 'position.dart';

/// Data for the sliding merge animation.
/// Contains the merge pair info needed by the widget layer.
@immutable
final class SlidingMerge {
  const SlidingMerge({
    required this.from,
    required this.to,
    required this.stayPosition,
    required this.tileValue,
  });

  /// Position the sliding tile is moving FROM.
  final Position from;

  /// Position the sliding tile is moving TO (same as stayPosition).
  final Position to;

  /// Position of the tile that stays in place.
  final Position stayPosition;

  /// Value of the source tiles (before merge).
  final int tileValue;
}

enum GameStatus { idle, playing, paused, gameOver, victory }

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
    this.totalMerges = 0,
    this.maxChainLevel = 0,
    this.currentChainLevel = 0,
    this.hasReachedVictory = false,
    this.gameMode = GameMode.classic,
    this.remainingSeconds = 0,
    this.slidingMerge,
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

  /// Total number of merges in the current game.
  final int totalMerges;

  /// Maximum chain level reached in the current game.
  final int maxChainLevel;

  /// Chain level of the merge that just happened (for screen effects).
  final int currentChainLevel;

  /// True after the player chose to continue past the 2048 victory.
  final bool hasReachedVictory;

  /// The current game mode (classic or time attack).
  final GameMode gameMode;

  /// Seconds remaining in time attack mode. 0 for classic.
  final int remainingSeconds;

  /// Sliding merge animation data. Non-null while a tile is sliding.
  final SlidingMerge? slidingMerge;

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
    int? totalMerges,
    int? maxChainLevel,
    int? currentChainLevel,
    bool? hasReachedVictory,
    GameMode? gameMode,
    int? remainingSeconds,
    SlidingMerge? Function()? slidingMerge,
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
      totalMerges: totalMerges ?? this.totalMerges,
      maxChainLevel: maxChainLevel ?? this.maxChainLevel,
      currentChainLevel: currentChainLevel ?? this.currentChainLevel,
      hasReachedVictory: hasReachedVictory ?? this.hasReachedVictory,
      gameMode: gameMode ?? this.gameMode,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      slidingMerge:
          slidingMerge != null ? slidingMerge() : this.slidingMerge,
    );
  }
}
