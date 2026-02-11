import 'dart:async';
import 'dart:math';

import 'package:flutter/services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/game_constants.dart';
import '../../settings/providers/settings_notifier.dart';
import '../models/board.dart';
import '../models/falling_block.dart';
import '../models/game_state.dart';
import '../models/merge_result.dart';
import '../models/position.dart';

part 'game_notifier.g.dart';

const String _highScoreKey = 'high_score';

@riverpod
class GameNotifier extends _$GameNotifier {
  late Random _rng;
  Timer? _tickTimer;
  Timer? _animTimer;

  @override
  GameState build() {
    ref.onDispose(_disposeTimers);
    _rng = Random();
    _loadHighScore();
    return GameState(
      grid: Board.empty(),
      currentBlock: null,
      nextBlock: null,
      score: 0,
      highScore: 0,
      status: GameStatus.idle,
      lastMergeChain: null,
    );
  }

  Future<void> _loadHighScore() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final int saved = prefs.getInt(_highScoreKey) ?? 0;
    if (saved > state.highScore) {
      state = state.copyWith(highScore: saved);
    }
  }

  Future<void> _saveHighScore(int score) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_highScoreKey, score);
  }

  void _disposeTimers() {
    _tickTimer?.cancel();
    _tickTimer = null;
    _animTimer?.cancel();
    _animTimer = null;
  }

  bool get _canAcceptInput =>
      state.status == GameStatus.playing && !state.isAnimating;

  void _haptic() {
    final bool enabled =
        ref.read(settingsNotifierProvider).vibrationEnabled;
    if (enabled) {
      HapticFeedback.mediumImpact();
    }
  }

  // --- Public API ---

  void startGame() {
    _disposeTimers();
    _rng = Random();
    final FallingBlock first = FallingBlock.spawn(_rng);
    final FallingBlock next = FallingBlock.spawn(_rng);

    state = GameState(
      grid: Board.empty(),
      currentBlock: first,
      nextBlock: next,
      score: 0,
      highScore: state.highScore,
      status: GameStatus.playing,
      lastMergeChain: null,
    );

    _startTicker();
  }

  void moveLeft() {
    if (!_canAcceptInput) return;
    final FallingBlock? block = state.currentBlock;
    if (block == null) return;

    final FallingBlock moved = block.move(0, -1);
    if (Board.canPlace(state.grid, moved)) {
      state = state.copyWith(currentBlock: () => moved);
    }
  }

  void moveRight() {
    if (!_canAcceptInput) return;
    final FallingBlock? block = state.currentBlock;
    if (block == null) return;

    final FallingBlock moved = block.move(0, 1);
    if (Board.canPlace(state.grid, moved)) {
      state = state.copyWith(currentBlock: () => moved);
    }
  }

  void softDrop() {
    if (!_canAcceptInput) return;
    _tick();
  }

  void rotate() {
    if (!_canAcceptInput) return;
    final FallingBlock? block = state.currentBlock;
    if (block == null) return;
    if (block.type == BlockType.single) return;

    final FallingBlock rotated = block.rotated();

    // Try original position first, then wall kick offsets.
    const List<List<int>> kicks = [
      [0, 0],
      [0, -1],
      [0, 1],
      [0, -2],
      [0, 2],
      [-1, 0],
    ];

    for (final List<int> kick in kicks) {
      final FallingBlock shifted = rotated.move(kick[0], kick[1]);
      if (Board.canPlace(state.grid, shifted)) {
        state = state.copyWith(currentBlock: () => shifted);
        return;
      }
    }
    // All kicks failed — rotation not possible.
  }

  void hardDrop() {
    if (!_canAcceptInput) return;
    final FallingBlock? block = state.currentBlock;
    if (block == null) return;

    FallingBlock current = block;
    while (true) {
      final FallingBlock next = current.move(1, 0);
      if (Board.canPlace(state.grid, next)) {
        current = next;
      } else {
        break;
      }
    }

    state = state.copyWith(currentBlock: () => current);
    _haptic();
    _placeAndMerge();
  }

  /// Pause the game. Works during animation too — remaining merges
  /// are resolved instantly so the grid is in a clean state.
  void pause() {
    if (state.status != GameStatus.playing) return;
    _tickTimer?.cancel();
    _animTimer?.cancel();

    if (state.isAnimating) {
      // Complete remaining merges instantly
      final List<List<int?>> settled = Board.applyGravity(state.grid);
      final (List<List<int?>> finalGrid, MergeChainResult result) =
          Board.runMergeChainWithGrid(settled);
      final int newScore = state.score + result.totalScore;
      final int newHighScore =
          newScore > state.highScore ? newScore : state.highScore;

      if (newHighScore > state.highScore) {
        _saveHighScore(newHighScore);
      }

      state = state.copyWith(
        grid: finalGrid,
        score: newScore,
        highScore: newHighScore,
        status: GameStatus.paused,
        isAnimating: false,
        highlightedPositions: () => null,
        newMergedPositions: () => null,
        lastMergeChain: () => null,
      );
    } else {
      state = state.copyWith(status: GameStatus.paused);
    }
  }

  void resume() {
    if (state.status != GameStatus.paused) return;
    state = state.copyWith(status: GameStatus.playing);

    if (state.currentBlock == null) {
      // Was paused during animation — chain is now complete, spawn next
      _spawnNext();
    } else {
      _startTicker();
    }
  }

  // --- Internal ---

  void _startTicker() {
    _tickTimer?.cancel();
    final int level = state.score ~/ GameConstants.pointsPerLevel;
    final int tickMs = (GameConstants.initialTickMs -
            level * GameConstants.speedIncreasePerLevel)
        .clamp(GameConstants.minTickMs, GameConstants.initialTickMs);
    _tickTimer = Timer.periodic(Duration(milliseconds: tickMs), (_) {
      _tick();
    });
  }

  void _tick() {
    if (state.status != GameStatus.playing || state.isAnimating) return;
    final FallingBlock? block = state.currentBlock;
    if (block == null) return;

    final FallingBlock moved = block.move(1, 0);
    if (Board.canPlace(state.grid, moved)) {
      state = state.copyWith(currentBlock: () => moved);
    } else {
      _placeAndMerge();
    }
  }

  void _placeAndMerge() {
    _tickTimer?.cancel();

    final FallingBlock? block = state.currentBlock;
    if (block == null) return;

    // Place block on grid synchronously
    final List<List<int?>> grid = Board.placeBlock(state.grid, block);

    state = state.copyWith(
      grid: grid,
      currentBlock: () => null,
      isAnimating: true,
      lastMergeChain: () => null,
    );

    // Apply initial gravity so unsupported tiles fall first
    _animTimer = Timer(const Duration(milliseconds: 120), () {
      final List<List<int?>> settledGrid = Board.applyGravity(grid);
      state = state.copyWith(grid: settledGrid);

      // Then start merge chain after gravity settles
      _animTimer = Timer(const Duration(milliseconds: 150), () {
        _animateMergeChain(settledGrid, 0);
      });
    });
  }

  /// Pick the pair that maximises follow-up chain potential.
  /// Tiebreaker: prefer merges closer to bottom-right.
  MergedPair _selectBestPair(
    List<List<int?>> grid,
    List<MergedPair> pairs,
  ) {
    if (pairs.length == 1) return pairs.first;

    MergedPair best = pairs.first;
    int bestChain = -1;
    int bestPos = -1;

    for (final MergedPair pair in pairs) {
      // Simulate this single merge + gravity
      final List<List<int?>> afterMerge = Board.applyMerges(grid, [pair]);
      final List<List<int?>> afterGravity = Board.applyGravity(afterMerge);
      final int nextCount = Board.findMergeablePairs(afterGravity).length;

      // Position score: higher row (bottom) and higher col (right) = better
      final int posScore =
          pair.to.row * GameConstants.columns + pair.to.col;

      if (nextCount > bestChain ||
          (nextCount == bestChain && posScore > bestPos)) {
        best = pair;
        bestChain = nextCount;
        bestPos = posScore;
      }
    }

    return best;
  }

  void _animateMergeChain(List<List<int?>> grid, int chainLevel) {
    final List<MergedPair> allPairs = Board.findMergeablePairs(grid);
    if (allPairs.isEmpty) {
      _finishMergeChain();
      return;
    }

    // Process one pair at a time, choosing the best for chain potential.
    final MergedPair target = _selectBestPair(grid, allPairs);
    final List<MergedPair> singlePair = [target];

    // Phase 1: Highlight the pair about to merge (glow effect)
    final Set<Position> highlights = {target.from1, target.from2};

    state = state.copyWith(
      highlightedPositions: () => highlights,
    );

    // Phase 2: After glow, apply merge
    _animTimer = Timer(const Duration(milliseconds: 300), () {
      final int multiplier = GameConstants.chainMultiplier(chainLevel);
      final int stepScore = target.newValue * multiplier;

      _haptic();
      final List<List<int?>> mergedGrid =
          Board.applyMerges(grid, singlePair);

      // Build progressive chain result for combo display
      final List<MergeStep> prevSteps =
          state.lastMergeChain?.steps ?? const [];
      final int prevTotal = state.lastMergeChain?.totalScore ?? 0;
      final MergeChainResult chainResult = MergeChainResult(
        steps: [
          ...prevSteps,
          MergeStep(
            mergedPairs: singlePair,
            chainLevel: chainLevel,
            scoreGained: stepScore,
          ),
        ],
        totalScore: prevTotal + stepScore,
      );

      state = state.copyWith(
        grid: mergedGrid,
        highlightedPositions: () => null,
        newMergedPositions: () => {target.to},
        score: state.score + stepScore,
        lastMergeChain: () => chainResult,
      );

      // Phase 3: After showing merged tile, apply gravity
      _animTimer = Timer(const Duration(milliseconds: 200), () {
        final List<List<int?>> gravityGrid = Board.applyGravity(mergedGrid);

        state = state.copyWith(
          grid: gravityGrid,
          newMergedPositions: () => null,
        );

        // Phase 4: After gravity settles, check for next merge
        _animTimer = Timer(const Duration(milliseconds: 150), () {
          _animateMergeChain(gravityGrid, chainLevel + 1);
        });
      });
    });
  }

  void _finishMergeChain() {
    final int newHighScore =
        state.score > state.highScore ? state.score : state.highScore;

    if (newHighScore > state.highScore) {
      _saveHighScore(newHighScore);
    }

    state = state.copyWith(
      highScore: newHighScore,
      isAnimating: false,
      highlightedPositions: () => null,
      newMergedPositions: () => null,
    );

    _spawnNext();
  }

  void _spawnNext() {
    if (Board.isSpawnBlocked(state.grid)) {
      state = state.copyWith(
        status: GameStatus.gameOver,
        currentBlock: () => null,
      );
      return;
    }

    final FallingBlock next = state.nextBlock ?? FallingBlock.spawn(_rng);
    final FallingBlock upcoming = FallingBlock.spawn(_rng);

    if (!Board.canPlace(state.grid, next)) {
      state = state.copyWith(
        status: GameStatus.gameOver,
        currentBlock: () => null,
      );
      return;
    }

    state = state.copyWith(
      currentBlock: () => next,
      nextBlock: () => upcoming,
    );

    _startTicker();
  }
}
