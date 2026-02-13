import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/game_constants.dart';
import '../../../core/providers/sfx_notifier.dart';
import '../../settings/providers/settings_notifier.dart';
import '../models/board.dart';
import '../models/falling_block.dart';
import '../models/game_mode.dart';
import '../models/game_state.dart';
import '../models/merge_result.dart';
import '../models/position.dart';

part 'game_notifier.g.dart';

const String _highScoreKey = 'high_score';
const String _savedGameKey = 'saved_game';

@riverpod
// ignore: deprecated_member_use_from_same_package
Future<bool> hasSavedGame(HasSavedGameRef ref) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.containsKey(_savedGameKey);
}

@riverpod
class GameNotifier extends _$GameNotifier {
  late Random _rng;
  Timer? _tickTimer;
  Timer? _animTimer;
  Timer? _lockTimer;
  Timer? _countdownTimer;
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

  /// Save current game state to SharedPreferences for crash/termination recovery.
  /// Time attack mode is never saved (3-minute limit makes it meaningless).
  Future<void> saveGame() async {
    if (state.gameMode == GameMode.timeAttack) return;
    if (state.status != GameStatus.paused &&
        state.status != GameStatus.playing) {
      return;
    }
    final Map<String, dynamic> json = {
      'grid': state.grid,
      'score': state.score,
      'highScore': state.highScore,
      'totalMerges': state.totalMerges,
      'maxChainLevel': state.maxChainLevel,
      'hasReachedVictory': state.hasReachedVictory,
      'gameMode': state.gameMode.name,
    };
    if (state.currentBlock != null) {
      json['currentBlock'] = state.currentBlock!.toJson();
    }
    if (state.nextBlock != null) {
      json['nextBlock'] = state.nextBlock!.toJson();
    }
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_savedGameKey, jsonEncode(json));
  }

  /// Restore a previously saved game. Returns true if successful.
  Future<bool> restoreGame() async {
    _disposeTimers();
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? raw = prefs.getString(_savedGameKey);
    if (raw == null) return false;

    try {
      final Map<String, dynamic> json =
          jsonDecode(raw) as Map<String, dynamic>;

      final List<List<int?>> grid = (json['grid'] as List<dynamic>)
          .map((dynamic row) => (row as List<dynamic>)
              .map((dynamic v) => v as int?)
              .toList())
          .toList();

      FallingBlock? currentBlock;
      if (json['currentBlock'] != null) {
        currentBlock = FallingBlock.fromJson(
            json['currentBlock'] as Map<String, dynamic>);
      }
      FallingBlock? nextBlock;
      if (json['nextBlock'] != null) {
        nextBlock =
            FallingBlock.fromJson(json['nextBlock'] as Map<String, dynamic>);
      }

      final String modeStr = json['gameMode'] as String? ?? 'classic';
      final GameMode restoredMode = GameMode.values.firstWhere(
        (GameMode m) => m.name == modeStr,
        orElse: () => GameMode.classic,
      );

      state = GameState(
        grid: grid,
        currentBlock: currentBlock,
        nextBlock: nextBlock,
        score: json['score'] as int,
        highScore: json['highScore'] as int,
        status: GameStatus.playing,
        lastMergeChain: null,
        totalMerges: json['totalMerges'] as int,
        maxChainLevel: json['maxChainLevel'] as int,
        hasReachedVictory: json['hasReachedVictory'] as bool? ?? false,
        gameMode: restoredMode,
      );

      _rng = Random();
      if (currentBlock != null) {
        _startTicker();
      } else {
        _spawnNext();
      }

      await clearSavedGame();
      return true;
    } catch (_) {
      await clearSavedGame();
      return false;
    }
  }

  Future<void> clearSavedGame() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_savedGameKey);
  }

  void _disposeTimers() {
    _tickTimer?.cancel();
    _tickTimer = null;
    _animTimer?.cancel();
    _animTimer = null;
    _lockTimer?.cancel();
    _lockTimer = null;
    _countdownTimer?.cancel();
    _countdownTimer = null;
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

  void startGame({GameMode mode = GameMode.classic}) {
    _disposeTimers();
    _rng = Random();
    final FallingBlock first = FallingBlock.spawn(_rng, level: 0);
    final FallingBlock next = FallingBlock.spawn(_rng, level: 0);

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
      gameMode: mode,
      remainingSeconds: mode == GameMode.timeAttack
          ? GameConstants.timeAttackSeconds
          : 0,
    );

    clearSavedGame();
    _startTicker();
    if (mode == GameMode.timeAttack) {
      _startCountdownTimer();
    }
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
    _countdownTimer?.cancel();
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
        slidingMerge: () => null,
        gravityDrops: () => null,
        lastMergeChain: () => null,
      );
    } else {
      state = state.copyWith(status: GameStatus.paused);
    }
  }

  /// Continue after watching a rewarded ad (clear top rows, resume play).
  /// Only allowed once per game.
  void continueAfterAd() {
    if (state.status != GameStatus.gameOver) return;
    if (state.hasUsedContinue) return;

    final List<List<int?>> grid = Board.copyGrid(state.grid);
    // Clear top 3 rows to make room for new blocks.
    for (int row = 0; row < 3; row++) {
      for (int col = 0; col < GameConstants.columns; col++) {
        grid[row][col] = null;
      }
    }

    state = state.copyWith(
      grid: grid,
      status: GameStatus.playing,
      hasUsedContinue: true,
      isAnimating: false,
      highlightedPositions: () => null,
      newMergedPositions: () => null,
      slidingMerge: () => null,
        gravityDrops: () => null,
    );

    if (state.gameMode == GameMode.timeAttack) {
      // Give 30 extra seconds in time attack mode
      state = state.copyWith(
        remainingSeconds: state.remainingSeconds + 30,
      );
      _startCountdownTimer();
    }

    _spawnNext();
  }

  /// Continue playing after reaching 2048 (endless mode).
  void continueAfterVictory() {
    if (state.status != GameStatus.victory) return;
    state = state.copyWith(
      status: GameStatus.playing,
      hasReachedVictory: true,
    );
    _spawnNext();
  }

  void resume() {
    if (state.status != GameStatus.paused) return;
    state = state.copyWith(status: GameStatus.playing);

    if (state.gameMode == GameMode.timeAttack) {
      _startCountdownTimer();
    }

    if (state.currentBlock == null) {
      // Was paused during animation — chain is now complete, spawn next
      _spawnNext();
    } else {
      _startTicker();
    }
  }

  // --- Internal ---

  void _startCountdownTimer() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state.status != GameStatus.playing) return;
      final int next = state.remainingSeconds - 1;
      if (next <= 0) {
        _countdownTimer?.cancel();
        _countdownTimer = null;
        _tickTimer?.cancel();
        _animTimer?.cancel();
        _lockTimer?.cancel();
        _isLocking = false;
        clearSavedGame();
        state = state.copyWith(
          remainingSeconds: 0,
          status: GameStatus.gameOver,
          isAnimating: false,
          highlightedPositions: () => null,
          newMergedPositions: () => null,
          slidingMerge: () => null,
        gravityDrops: () => null,
        );
      } else {
        state = state.copyWith(remainingSeconds: next);
      }
    });
  }

  void _startTicker() {
    _tickTimer?.cancel();
    final int level = state.level;
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

    // Game over: block overlaps with existing tiles at lock time.
    // This happens when a block spawns in an occupied zone and the
    // player couldn't move it to a valid position during lock delay.
    if (!Board.canPlace(state.grid, block)) {
      clearSavedGame();
      state = state.copyWith(
        status: GameStatus.gameOver,
        currentBlock: () => null,
      );
      return;
    }

    // Track positions of newly placed tiles (before gravity).
    final Set<Position> newPositions = {
      for (final tile in block.tiles) tile.position,
    };

    // Play drop sound effect
    ref.read(sfxNotifierProvider.notifier).playDrop();

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
      final List<TileDrop> initialDrops = Board.computeGravityDrops(grid);

      if (initialDrops.isEmpty) {
        // No gravity needed
        _animTimer = Timer(const Duration(milliseconds: 100), () {
          _animateMergeChain(grid, 0, newTilePositions: newPositions);
        });
        return;
      }

      // Animate initial gravity drop
      state = state.copyWith(gravityDrops: () => initialDrops);

      _animTimer = Timer(const Duration(milliseconds: 200), () {
        final List<List<int?>> settledGrid = Board.applyGravity(grid);
        final Set<Position> adjustedNew =
            _adjustPositionsAfterGravity(grid, newPositions);

        state = state.copyWith(
          grid: settledGrid,
          gravityDrops: () => null,
        );

        _animTimer = Timer(const Duration(milliseconds: 80), () {
          _animateMergeChain(settledGrid, 0, newTilePositions: adjustedNew);
        });
      });
    });
  }

  /// Re-map [positions] from [gridBeforeGravity] to their post-gravity rows.
  /// Gravity compacts each column downward, preserving relative order.
  Set<Position> _adjustPositionsAfterGravity(
    List<List<int?>> gridBeforeGravity,
    Set<Position> positions,
  ) {
    final Set<Position> adjusted = {};
    for (int col = 0; col < GameConstants.columns; col++) {
      final List<bool> isNew = [];
      for (int row = 0; row < GameConstants.rows; row++) {
        if (gridBeforeGravity[row][col] != null) {
          isNew.add(positions.contains(Position(row: row, col: col)));
        }
      }
      final int tileCount = isNew.length;
      for (int i = 0; i < tileCount; i++) {
        if (isNew[i]) {
          adjusted.add(Position(
            row: GameConstants.rows - tileCount + i,
            col: col,
          ));
        }
      }
    }
    return adjusted;
  }

  /// Pick the best pair to merge.
  /// Priority: pre-existing tiles first, then bottom-most, then best
  /// direction (via chain simulation including gravity).
  MergedPair _selectBestPair(
    List<List<int?>> grid,
    List<MergedPair> pairs, {
    Set<Position>? newTilePositions,
  }) {
    if (pairs.length == 1) return _chooseBestDirection(grid, pairs.first);

    // Prefer pairs involving only pre-existing (non-new) tiles.
    if (newTilePositions != null && newTilePositions.isNotEmpty) {
      int newCount(MergedPair p) {
        int c = 0;
        if (newTilePositions.contains(p.from1)) c++;
        if (newTilePositions.contains(p.from2)) c++;
        return c;
      }

      final int fewest = pairs.map(newCount).reduce(min);
      final List<MergedPair> preferred =
          pairs.where((MergedPair p) => newCount(p) == fewest).toList();
      if (preferred.length == 1) {
        return _chooseBestDirection(grid, preferred.first);
      }
      pairs = preferred;
    }

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

    // Secondary: toward the closest bigger neighbor (better chain setup).
    // e.g. 4+4=8: neighbor 32 (2 steps) is better than 128 (4 steps).
    final int c1 =
        _closestChainNeighbor(grid, pair.from1, pair.from2, mergedValue);
    final int c2 =
        _closestChainNeighbor(grid, pair.from2, pair.from1, mergedValue);
    if (c1 != 0 && (c2 == 0 || c1 < c2)) return toPos1;
    if (c2 != 0 && (c1 == 0 || c2 < c1)) return toPos2;

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

  /// Closest neighbor value strictly greater than [mergedValue], excluding
  /// [exclude]. Returns 0 if no such neighbor exists.
  /// A smaller return value means better chain potential (fewer doublings away).
  int _closestChainNeighbor(
    List<List<int?>> grid,
    Position pos,
    Position exclude,
    int mergedValue,
  ) {
    int closest = 0;
    for (final Position n in pos.neighbors) {
      if (n == exclude) continue;
      if (!Board.inBounds(n)) continue;
      final int? val = grid[n.row][n.col];
      if (val != null && val > mergedValue) {
        if (closest == 0 || val < closest) closest = val;
      }
    }
    return closest;
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
      final int neighborVal = _closestChainNeighbor(
        grid,
        candidate.to,
        other,
        candidate.newValue,
      );
      final (int totalMerges, int totalScore) =
          _simulateChain(grid, candidate);

      // Primary: immediate chain adjacency
      // Secondary: closest bigger neighbor (smaller value = closer chain)
      // Tertiary: more chain merges / higher score
      final bool isBetterNeighbor = (neighborVal != 0 && bestNeighbor == 0) ||
          (neighborVal != 0 &&
              bestNeighbor != 0 &&
              neighborVal < bestNeighbor);
      final bool sameNeighbor = neighborVal == bestNeighbor;
      final bool isBetter = (hasChain && !bestHasChain) ||
          (hasChain == bestHasChain && isBetterNeighbor) ||
          (hasChain == bestHasChain &&
              sameNeighbor &&
              totalMerges > bestMerges) ||
          (hasChain == bestHasChain &&
              sameNeighbor &&
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

  /// Compute animation delay scaled by chain level.
  /// Higher chains play faster: 0.92^chainLevel, clamped to 60% minimum.
  int _chainDelayMs(int baseMs, int chainLevel) {
    if (chainLevel <= 0) return baseMs;
    final double multiplier =
        pow(0.92, chainLevel).toDouble().clamp(0.6, 1.0);
    return (baseMs * multiplier).round();
  }

  void _animateMergeChain(
    List<List<int?>> grid,
    int chainLevel, {
    Set<Position>? newTilePositions,
  }) {
    final List<MergedPair> allPairs = Board.findAllAdjacentPairs(grid);
    if (allPairs.isEmpty) {
      _finishMergeChain();
      return;
    }

    // Process one pair at a time, choosing the best for chain potential.
    MergedPair target = _selectBestPair(
      grid,
      allPairs,
      newTilePositions: newTilePositions,
    );

    // For vertical pairs, always merge to the lower position (higher row)
    // so the slide animation goes top→bottom (consistent with gravity).
    if (target.from1.col == target.from2.col) {
      final Position lowerPos = target.from1.row > target.from2.row
          ? target.from1
          : target.from2;
      if (target.to != lowerPos) {
        target = MergedPair(
          from1: target.from1,
          from2: target.from2,
          to: lowerPos,
          newValue: target.newValue,
        );
      }
    }

    final List<MergedPair> singlePair = [target];

    // Phase 1: Highlight the pair about to merge (glow effect)
    final Set<Position> highlights = {target.from1, target.from2};

    state = state.copyWith(
      highlightedPositions: () => highlights,
    );

    // Determine which tile slides and which stays
    final Position stayPos = target.to;
    final Position slidePos =
        target.to == target.from1 ? target.from2 : target.from1;
    final int tileValue = target.newValue ~/ 2;

    // Phase 2: After glow, start sliding animation
    _animTimer = Timer(Duration(milliseconds: _chainDelayMs(200, chainLevel)), () {
      state = state.copyWith(
        highlightedPositions: () => null,
        slidingMerge: () => SlidingMerge(
          from: slidePos,
          to: stayPos,
          stayPosition: stayPos,
          tileValue: tileValue,
        ),
      );

      // Phase 3: After slide completes, apply merge
      _animTimer = Timer(Duration(milliseconds: _chainDelayMs(250, chainLevel)), () {
        final int multiplier = GameConstants.chainMultiplier(chainLevel);
        final int stepScore = target.newValue * multiplier;

        _haptic(chainLevel);
        ref.read(sfxNotifierProvider.notifier).playMerge(chainLevel);
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
          slidingMerge: () => null,
        gravityDrops: () => null,
          newMergedPositions: () => {target.to},
          score: state.score + stepScore,
          lastMergeChain: () => chainResult,
          totalMerges: state.totalMerges + 1,
          maxChainLevel: max(state.maxChainLevel, chainLevel),
          currentChainLevel: chainLevel,
        );

        // Phase 4: After showing merged tile, animate gravity drop
        _animTimer = Timer(Duration(milliseconds: _chainDelayMs(200, chainLevel)), () {
          final List<TileDrop> drops =
              Board.computeGravityDrops(mergedGrid);

          if (drops.isEmpty) {
            // No gravity needed — go straight to next merge check
            state = state.copyWith(
              newMergedPositions: () => null,
            );
            _animTimer = Timer(Duration(milliseconds: _chainDelayMs(100, chainLevel)), () {
              _animateMergeChain(mergedGrid, chainLevel + 1);
            });
            return;
          }

          // Set gravity drops for widget animation (grid stays pre-gravity)
          state = state.copyWith(
            newMergedPositions: () => null,
            gravityDrops: () => drops,
          );

          // Phase 5: After gravity animation, apply actual gravity
          _animTimer = Timer(Duration(milliseconds: _chainDelayMs(200, chainLevel)), () {
            final List<List<int?>> gravityGrid =
                Board.applyGravity(mergedGrid);

            state = state.copyWith(
              grid: gravityGrid,
              gravityDrops: () => null,
            );

            // Phase 6: After gravity settles, check for next merge
            _animTimer = Timer(Duration(milliseconds: _chainDelayMs(80, chainLevel)), () {
              _animateMergeChain(gravityGrid, chainLevel + 1);
            });
          });
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

    // Check for win condition (2048 tile) — skip in time attack or endless mode.
    if (!state.hasReachedVictory &&
        state.gameMode != GameMode.timeAttack) {
      final bool hasWinTile = state.grid.any(
        (List<int?> row) =>
            row.any((int? v) => v != null && v >= GameConstants.winTileValue),
      );

      if (hasWinTile) {
        _tickTimer?.cancel();
        clearSavedGame();
        state = state.copyWith(
          highScore: newHighScore,
          isAnimating: false,
          highlightedPositions: () => null,
          newMergedPositions: () => null,
          slidingMerge: () => null,
        gravityDrops: () => null,
          currentChainLevel: 0,
          status: GameStatus.victory,
        );
        return;
      }
    }

    state = state.copyWith(
      highScore: newHighScore,
      isAnimating: false,
      highlightedPositions: () => null,
      newMergedPositions: () => null,
      slidingMerge: () => null,
        gravityDrops: () => null,
      currentChainLevel: 0,
    );

    _spawnNext();
  }

  void _spawnNext() {
    final FallingBlock next =
        state.nextBlock ?? FallingBlock.spawn(_rng, level: state.level);
    final FallingBlock upcoming =
        FallingBlock.spawn(_rng, level: state.level);

    // Always spawn the block — game over is checked at lock time
    // (_placeAndMerge), giving the player a chance to move/rotate.
    state = state.copyWith(
      currentBlock: () => next,
      nextBlock: () => upcoming,
    );

    _startTicker();
  }
}
