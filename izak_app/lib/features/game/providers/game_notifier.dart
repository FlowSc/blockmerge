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
  Timer? _lockTimer;
  bool _isLocking = false;
  DateTime? _lockStartedAt;

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
    _lockTimer?.cancel();
    _lockTimer = null;
    _isLocking = false;
    _lockStartedAt = null;
  }

  bool get _canAcceptInput =>
      state.status == GameStatus.playing && !state.isAnimating;

  /// After a successful move during lock delay, reset the lock timer.
  void _resetLockIfNeeded() {
    if (!_isLocking) return;

    // Hard cap: if total lock time exceeded, don't reset
    if (_lockStartedAt != null) {
      final int elapsed =
          DateTime.now().difference(_lockStartedAt!).inMilliseconds;
      if (elapsed >= GameConstants.maxLockMs) return;
    }

    _lockTimer?.cancel();
    // Check if block is still grounded after the move
    final FallingBlock? block = state.currentBlock;
    if (block != null && !Board.canPlace(state.grid, block.move(1, 0))) {
      _restartLockTimer();
    } else {
      // Block is no longer grounded — cancel lock, resume normal tick
      _isLocking = false;
      _lockStartedAt = null;
      _startTicker();
    }
  }

  void _startLockDelay() {
    _lockTimer?.cancel();
    _isLocking = true;
    _lockStartedAt = DateTime.now();
    _restartLockTimer();
  }

  void _restartLockTimer() {
    _lockTimer?.cancel();

    // Clamp remaining time to not exceed the hard cap
    int delayMs = GameConstants.lockDelayMs;
    if (_lockStartedAt != null) {
      final int elapsed =
          DateTime.now().difference(_lockStartedAt!).inMilliseconds;
      final int remaining = GameConstants.maxLockMs - elapsed;
      delayMs = delayMs.clamp(0, remaining);
    }

    _lockTimer = Timer(
      Duration(milliseconds: delayMs),
      () {
        _isLocking = false;
        _lockStartedAt = null;
        _placeAndMerge();
      },
    );
  }

  void _haptic([int chainLevel = 0]) {
    final bool enabled =
        ref.read(settingsNotifierProvider).vibrationEnabled;
    if (!enabled) return;

    switch (chainLevel) {
      case 0:
        HapticFeedback.lightImpact();
      case 1:
        HapticFeedback.mediumImpact();
      case 2:
        HapticFeedback.heavyImpact();
      default:
        // 3+ chains: heavy + vibrate for extra punch
        HapticFeedback.heavyImpact();
        Future<void>.delayed(const Duration(milliseconds: 50), () {
          HapticFeedback.heavyImpact();
        });
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
      totalMerges: 0,
      maxChainLevel: 0,
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
      _resetLockIfNeeded();
    }
  }

  void moveRight() {
    if (!_canAcceptInput) return;
    final FallingBlock? block = state.currentBlock;
    if (block == null) return;

    final FallingBlock moved = block.move(0, 1);
    if (Board.canPlace(state.grid, moved)) {
      state = state.copyWith(currentBlock: () => moved);
      _resetLockIfNeeded();
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
        _resetLockIfNeeded();
        return;
      }
    }
    // All kicks failed — rotation not possible.
  }

  void hardDrop() {
    if (!_canAcceptInput) return;
    final FallingBlock? block = state.currentBlock;
    if (block == null) return;

    // Cancel lock delay if active
    _lockTimer?.cancel();
    _isLocking = false;

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
    _lockTimer?.cancel();
    _isLocking = false;

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
    if (_isLocking) return; // Lock delay in progress — skip tick
    final FallingBlock? block = state.currentBlock;
    if (block == null) return;

    final FallingBlock moved = block.move(1, 0);
    if (Board.canPlace(state.grid, moved)) {
      state = state.copyWith(currentBlock: () => moved);
    } else {
      // Block touched ground — start lock delay instead of instant place
      _tickTimer?.cancel();
      _startLockDelay();
    }
  }

  void _placeAndMerge() {
    _tickTimer?.cancel();
    _lockTimer?.cancel();
    _isLocking = false;

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

  /// Pick the best pair to merge.
  /// Priority: bottom-most pair first, then best direction (via chain
  /// simulation including gravity), chain simulation as tiebreaker
  /// when multiple bottom pairs exist.
  MergedPair _selectBestPair(
    List<List<int?>> grid,
    List<MergedPair> pairs,
  ) {
    if (pairs.length == 1) return _chooseBestDirection(grid, pairs.first);

    // Group by bottom-ness (highest max row = closest to base)
    int pairBottomRow(MergedPair p) => max(p.from1.row, p.from2.row);

    final int bottomRow = pairs.map(pairBottomRow).reduce(max);
    final List<MergedPair> bottomPairs = pairs
        .where((MergedPair p) => pairBottomRow(p) == bottomRow)
        .toList();

    if (bottomPairs.length == 1) {
      return _chooseBestDirection(grid, bottomPairs.first);
    }

    // Multiple bottom pairs: pick best direction for each, then compare
    final List<MergedPair> candidates = [
      for (final MergedPair pair in bottomPairs)
        _chooseBestDirection(grid, pair),
    ];
    return _pickBestCandidate(grid, candidates);
  }

  /// Choose the best merge direction for a single pair by simulating
  /// both directions (merge → gravity → full chain).
  MergedPair _chooseBestDirection(
    List<List<int?>> grid,
    MergedPair pair,
  ) {
    final MergedPair toPos1 = MergedPair(
      from1: pair.from1,
      from2: pair.from2,
      to: pair.from1,
      newValue: pair.newValue,
    );
    final MergedPair toPos2 = MergedPair(
      from1: pair.from1,
      from2: pair.from2,
      to: pair.from2,
      newValue: pair.newValue,
    );

    // Primary: immediate chain — merged value matches an adjacent tile.
    final int mergedValue = pair.newValue;
    final bool chain1 =
        _hasMatchingNeighbor(grid, pair.from1, pair.from2, mergedValue);
    final bool chain2 =
        _hasMatchingNeighbor(grid, pair.from2, pair.from1, mergedValue);
    if (chain1 && !chain2) return toPos1;
    if (chain2 && !chain1) return toPos2;

    // Secondary: toward strictly-bigger neighbor.
    final int tileValue = pair.newValue ~/ 2;
    final int n1 = _maxStrictNeighbor(grid, pair.from1, pair.from2, tileValue);
    final int n2 = _maxStrictNeighbor(grid, pair.from2, pair.from1, tileValue);
    if (n1 > n2) return toPos1;
    if (n2 > n1) return toPos2;

    // Tertiary: simulate chain.
    final (int merges1, int score1) = _simulateChain(grid, toPos1);
    final (int merges2, int score2) = _simulateChain(grid, toPos2);

    if (merges1 > merges2) return toPos1;
    if (merges2 > merges1) return toPos2;

    if (score1 > score2) return toPos1;
    if (score2 > score1) return toPos2;

    // Final: lower row (base), then rightward
    if (pair.from1.row > pair.from2.row) return toPos1;
    if (pair.from2.row > pair.from1.row) return toPos2;
    return toPos2;
  }

  /// Simulate merge → gravity → full chain and return (totalMerges, totalScore).
  (int, int) _simulateChain(List<List<int?>> grid, MergedPair candidate) {
    final List<List<int?>> afterMerge =
        Board.applyMerges(grid, [candidate]);
    final List<List<int?>> afterGravity = Board.applyGravity(afterMerge);
    final MergeChainResult result = Board.runMergeChain(afterGravity);

    final int totalMerges = 1 + result.steps.fold<int>(
      0,
      (int sum, MergeStep step) => sum + step.mergedPairs.length,
    );
    final int totalScore = candidate.newValue + result.totalScore;
    return (totalMerges, totalScore);
  }

  /// Whether [pos] has a neighbor with value equal to [value], excluding [exclude].
  bool _hasMatchingNeighbor(
    List<List<int?>> grid,
    Position pos,
    Position exclude,
    int value,
  ) {
    for (final Position n in pos.neighbors) {
      if (n == exclude) continue;
      if (!Board.inBounds(n)) continue;
      if (grid[n.row][n.col] == value) return true;
    }
    return false;
  }

  /// Max neighbor value strictly greater than [tileValue], excluding [exclude].
  int _maxStrictNeighbor(
    List<List<int?>> grid,
    Position pos,
    Position exclude,
    int tileValue,
  ) {
    int maxVal = 0;
    for (final Position n in pos.neighbors) {
      if (n == exclude) continue;
      if (!Board.inBounds(n)) continue;
      final int? val = grid[n.row][n.col];
      if (val != null && val > tileValue && val > maxVal) maxVal = val;
    }
    return maxVal;
  }

  MergedPair _pickBestCandidate(
    List<List<int?>> grid,
    List<MergedPair> candidates,
  ) {
    MergedPair best = candidates.first;
    bool bestHasChain = false;
    int bestNeighbor = -1;
    int bestMerges = -1;
    int bestScore = -1;

    for (final MergedPair candidate in candidates) {
      final Position other =
          candidate.to == candidate.from1 ? candidate.from2 : candidate.from1;
      final bool hasChain = _hasMatchingNeighbor(
        grid,
        candidate.to,
        other,
        candidate.newValue,
      );
      final int tileValue = candidate.newValue ~/ 2;
      final int neighborVal = _maxStrictNeighbor(
        grid,
        candidate.to,
        other,
        tileValue,
      );
      final (int totalMerges, int totalScore) =
          _simulateChain(grid, candidate);

      // Primary: immediate chain adjacency
      // Secondary: bigger neighbor
      // Tertiary: more chain merges / higher score
      final bool isBetter = (hasChain && !bestHasChain) ||
          (hasChain == bestHasChain && neighborVal > bestNeighbor) ||
          (hasChain == bestHasChain &&
              neighborVal == bestNeighbor &&
              totalMerges > bestMerges) ||
          (hasChain == bestHasChain &&
              neighborVal == bestNeighbor &&
              totalMerges == bestMerges &&
              totalScore > bestScore);

      if (isBetter) {
        best = candidate;
        bestHasChain = hasChain;
        bestNeighbor = neighborVal;
        bestMerges = totalMerges;
        bestScore = totalScore;
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

      _haptic(chainLevel);
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
        totalMerges: state.totalMerges + 1,
        maxChainLevel: max(state.maxChainLevel, chainLevel),
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
