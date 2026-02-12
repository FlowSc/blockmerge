import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/game_constants.dart';
import '../../settings/providers/settings_notifier.dart';
import '../models/falling_block.dart';
import '../models/game_state.dart';
import '../models/position.dart';
import '../models/tile.dart' as game;
import '../providers/game_notifier.dart';
import 'high_value_merge_effect.dart';
import 'mega_merge_effect.dart';
import 'tile_widget.dart';

/// Minimum tile value that triggers the high-value merge glow effect.
const int _highValueThreshold = 64;

/// Minimum chain level that triggers the mega merge screen effect.
const int _megaComboThreshold = 4; // chainLevel 4 = 5th combo

class GameBoardWidget extends ConsumerStatefulWidget {
  const GameBoardWidget({super.key});

  @override
  ConsumerState<GameBoardWidget> createState() => _GameBoardWidgetState();
}

class _GameBoardWidgetState extends ConsumerState<GameBoardWidget>
    with TickerProviderStateMixin {
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  late AnimationController _borderColorController;
  Color _borderColorFrom = const Color(0xFF00E5FF);
  Color _borderColorTo = const Color(0xFF00E5FF);

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _shakeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: 4), weight: 15),
      TweenSequenceItem(tween: Tween(begin: 4, end: -3), weight: 15),
      TweenSequenceItem(tween: Tween(begin: -3, end: 2.5), weight: 15),
      TweenSequenceItem(tween: Tween(begin: 2.5, end: -1.5), weight: 15),
      TweenSequenceItem(tween: Tween(begin: -1.5, end: 1), weight: 15),
      TweenSequenceItem(tween: Tween(begin: 1, end: 0), weight: 25),
    ]).animate(CurvedAnimation(
      parent: _shakeController,
      curve: Curves.easeOut,
    ));

    _borderColorController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _shakeController.dispose();
    _borderColorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final GameState gameState = ref.watch(gameNotifierProvider);
    final List<List<int?>> grid = gameState.grid;
    final FallingBlock? currentBlock = gameState.currentBlock;
    final Set<Position>? highlighted = gameState.highlightedPositions;
    final Set<Position>? newMerged = gameState.newMergedPositions;
    final int chainLevel = gameState.currentChainLevel;
    final SlidingMerge? slidingMerge = gameState.slidingMerge;

    // Trigger shake when chainLevel reaches threshold and there are new merges.
    ref.listen<int>(
      gameNotifierProvider.select((GameState s) => s.currentChainLevel),
      (int? prev, int next) {
        if (next >= _megaComboThreshold &&
            ref.read(gameNotifierProvider).newMergedPositions != null) {
          _shakeController.forward(from: 0);
        }
      },
    );

    // Update border color when new merges occur.
    ref.listen<Set<Position>?>(
      gameNotifierProvider.select((GameState s) => s.newMergedPositions),
      (Set<Position>? prev, Set<Position>? next) {
        if (next != null && next.isNotEmpty) {
          final GameState gs = ref.read(gameNotifierProvider);
          // Find the highest merged tile value for border color.
          int? maxValue;
          for (final Position pos in next) {
            final int? val = gs.grid[pos.row][pos.col];
            if (val != null && (maxValue == null || val > maxValue)) {
              maxValue = val;
            }
          }
          if (maxValue != null) {
            final Color newColor =
                GameConstants.tileColors[maxValue] ?? const Color(0xFF00E5FF);
            _borderColorFrom = Color.lerp(
              _borderColorFrom,
              _borderColorTo,
              _borderColorController.value,
            )!;
            _borderColorTo = newColor;
            _borderColorController.forward(from: 0);
          }
        }
      },
    );

    // Build a display grid that includes the falling block overlay
    final List<List<int?>> displayGrid = [
      for (final List<int?> row in grid) [...row],
    ];

    // Track which cells are from the falling block (not board tiles)
    final Set<Position> fallingBlockPositions = {};

    if (currentBlock != null) {
      for (final game.Tile tile in currentBlock.tiles) {
        final int r = tile.position.row;
        final int c = tile.position.col;
        if (r >= 0 &&
            r < GameConstants.rows &&
            c >= 0 &&
            c < GameConstants.columns) {
          displayGrid[r][c] = tile.value;
          fallingBlockPositions.add(Position(row: r, col: c));
        }
      }
    }

    // Compute ghost (hard drop preview) positions
    final bool showGhost = ref.watch(
      settingsNotifierProvider.select((s) => s.showGhost),
    );
    Set<Position>? ghostPositions;
    Map<Position, int>? ghostValues;
    if (showGhost && currentBlock != null) {
      FallingBlock ghost = currentBlock;
      while (true) {
        final FallingBlock next = ghost.move(1, 0);
        bool canPlace = true;
        for (final game.Tile tile in next.tiles) {
          final int r = tile.position.row;
          final int c = tile.position.col;
          if (r < 0 ||
              r >= GameConstants.rows ||
              c < 0 ||
              c >= GameConstants.columns ||
              grid[r][c] != null) {
            canPlace = false;
            break;
          }
        }
        if (canPlace) {
          ghost = next;
        } else {
          break;
        }
      }
      if (ghost.bottomRow != currentBlock.bottomRow) {
        ghostPositions = {};
        ghostValues = {};
        for (final game.Tile tile in ghost.tiles) {
          final Position pos =
              Position(row: tile.position.row, col: tile.position.col);
          ghostPositions.add(pos);
          ghostValues[pos] = tile.value;
        }
      }
    }

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double cellSize = _calculateCellSize(constraints);
        final double boardWidth = cellSize * GameConstants.columns;
        final double boardHeight = cellSize * GameConstants.rows;

        Widget board = SizedBox(
          width: boardWidth + 2,
          height: boardHeight + 2,
          child: AnimatedBuilder(
            animation: _borderColorController,
            builder: (BuildContext context, Widget? child) {
              final Color borderColor = Color.lerp(
                _borderColorFrom,
                _borderColorTo,
                Curves.easeOut.transform(_borderColorController.value),
              )!;
              return Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF0B0B1A),
                  borderRadius: BorderRadius.circular(2),
                  border: Border.all(
                    color: borderColor,
                    width: 2,
                  ),
                ),
                child: child,
              );
            },
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Grid lines
                CustomPaint(
                  size: Size(boardWidth, boardHeight),
                  painter: _GridPainter(cellSize: cellSize),
                ),
                // Ghost tiles
                if (ghostPositions != null && ghostValues != null)
                  ..._buildGhostTiles(
                      ghostPositions, ghostValues, cellSize),
                // Board tiles + falling block
                ..._buildTiles(
                  displayGrid,
                  cellSize,
                  highlighted: highlighted,
                  newMerged: newMerged,
                  slidingMerge: slidingMerge,
                ),
                // Sliding merge tile
                if (slidingMerge != null)
                  _SlidingTile(
                    key: ValueKey(
                      'slide_${slidingMerge.from.row}_${slidingMerge.from.col}',
                    ),
                    fromRow: slidingMerge.from.row,
                    fromCol: slidingMerge.from.col,
                    toRow: slidingMerge.to.row,
                    toCol: slidingMerge.to.col,
                    value: slidingMerge.tileValue,
                    cellSize: cellSize,
                  ),
                // High-value merge glow effects (64+)
                if (newMerged != null)
                  ..._buildHighValueEffects(
                    newMerged,
                    displayGrid,
                    cellSize,
                  ),
                // Mega merge particle effects
                if (newMerged != null && chainLevel >= _megaComboThreshold)
                  ..._buildMegaEffects(
                    newMerged,
                    displayGrid,
                    cellSize,
                    chainLevel,
                  ),
              ],
            ),
          ),
        );

        // Wrap with shake animation for 5+ combos
        board = AnimatedBuilder(
          animation: _shakeController,
          builder: (BuildContext context, Widget? child) {
            return Transform.translate(
              offset: Offset(_shakeAnimation.value, 0),
              child: child,
            );
          },
          child: board,
        );

        return Center(child: board);
      },
    );
  }

  double _calculateCellSize(BoxConstraints constraints) {
    final double maxCellWidth = constraints.maxWidth / GameConstants.columns;
    final double maxCellHeight = constraints.maxHeight / GameConstants.rows;
    return min(maxCellWidth, maxCellHeight);
  }

  List<Widget> _buildTiles(
    List<List<int?>> grid,
    double cellSize, {
    Set<Position>? highlighted,
    Set<Position>? newMerged,
    SlidingMerge? slidingMerge,
  }) {
    // The sliding tile's source position should be hidden from the grid
    // (it's rendered as an animated overlay instead).
    final Position? hiddenPos = slidingMerge?.from;

    final List<Widget> widgets = [];
    for (int row = 0; row < GameConstants.rows; row++) {
      for (int col = 0; col < GameConstants.columns; col++) {
        final int? value = grid[row][col];
        if (value != null) {
          final Position pos = Position(row: row, col: col);

          // Skip the tile that is being animated as a sliding overlay
          if (hiddenPos != null &&
              pos.row == hiddenPos.row &&
              pos.col == hiddenPos.col) {
            continue;
          }

          final bool isHighlighted = highlighted?.contains(pos) ?? false;
          final bool isNewMerge = newMerged?.contains(pos) ?? false;

          widgets.add(
            Positioned(
              key: ValueKey('tile_${row}_${col}_${value}_$isNewMerge'),
              left: col * cellSize + 1,
              top: row * cellSize + 1,
              child: TileWidget(
                value: value,
                size: cellSize - 2,
                isHighlighted: isHighlighted,
                isNewMerge: isNewMerge,
              ),
            ),
          );
        }
      }
    }
    return widgets;
  }

  List<Widget> _buildGhostTiles(
    Set<Position> positions,
    Map<Position, int> values,
    double cellSize,
  ) {
    final List<Widget> widgets = [];
    for (final Position pos in positions) {
      widgets.add(
        Positioned(
          left: pos.col * cellSize + 1,
          top: pos.row * cellSize + 1,
          child: Container(
            width: cellSize - 2,
            height: cellSize - 2,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
          ),
        ),
      );
    }
    return widgets;
  }

  List<Widget> _buildHighValueEffects(
    Set<Position> mergedPositions,
    List<List<int?>> grid,
    double cellSize,
  ) {
    final List<Widget> widgets = [];
    for (final Position pos in mergedPositions) {
      final int? value = grid[pos.row][pos.col];
      if (value == null || value < _highValueThreshold) continue;

      // Scale effect size with tile value: 64→1.8x, 128→2.2x, … 2048→4.2x
      final double tier = (log(value) / ln2) - 5; // 64→1, 128→2, …
      final double sizeMultiplier = 1.4 + tier * 0.4;
      final double effectSize = cellSize * sizeMultiplier;
      final double offset = (effectSize - cellSize) / 2;

      final Color color =
          GameConstants.tileColors[value] ?? const Color(0xFFEDC22E);

      widgets.add(
        Positioned(
          key: ValueKey('hv_effect_${pos.row}_${pos.col}'),
          left: pos.col * cellSize + 1 - offset,
          top: pos.row * cellSize + 1 - offset,
          child: IgnorePointer(
            child: HighValueMergeEffect(
              size: effectSize,
              color: color,
              tileValue: value,
            ),
          ),
        ),
      );
    }
    return widgets;
  }

  List<Widget> _buildMegaEffects(
    Set<Position> mergedPositions,
    List<List<int?>> grid,
    double cellSize,
    int chainLevel,
  ) {
    final List<Widget> widgets = [];
    final double effectSize = cellSize * 2.5;
    final double offset = (effectSize - cellSize) / 2;

    for (final Position pos in mergedPositions) {
      final int? value = grid[pos.row][pos.col];
      final Color color = GameConstants.tileColors[value] ??
          const Color(0xFFFF4444);

      widgets.add(
        Positioned(
          key: ValueKey('effect_${pos.row}_${pos.col}'),
          left: pos.col * cellSize + 1 - offset,
          top: pos.row * cellSize + 1 - offset,
          child: IgnorePointer(
            child: MegaMergeEffect(
              size: effectSize,
              color: color,
              chainLevel: chainLevel,
            ),
          ),
        ),
      );
    }
    return widgets;
  }
}

class _SlidingTile extends StatefulWidget {
  const _SlidingTile({
    super.key,
    required this.fromRow,
    required this.fromCol,
    required this.toRow,
    required this.toCol,
    required this.value,
    required this.cellSize,
  });

  final int fromRow;
  final int fromCol;
  final int toRow;
  final int toCol;
  final int value;
  final double cellSize;

  @override
  State<_SlidingTile> createState() => _SlidingTileState();
}

class _SlidingTileState extends State<_SlidingTile>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _positionAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );

    final Offset from = Offset(
      widget.fromCol * widget.cellSize + 1,
      widget.fromRow * widget.cellSize + 1,
    );
    final Offset to = Offset(
      widget.toCol * widget.cellSize + 1,
      widget.toRow * widget.cellSize + 1,
    );

    _positionAnimation = Tween<Offset>(begin: from, end: to).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInQuart),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (BuildContext context, Widget? child) {
        return Transform.translate(
          offset: _positionAnimation.value,
          child: child,
        );
      },
      child: SizedBox(
        width: widget.cellSize - 2,
        height: widget.cellSize - 2,
        child: TileWidget(
          value: widget.value,
          size: widget.cellSize - 2,
        ),
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  _GridPainter({required this.cellSize});

  final double cellSize;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = const Color(0xFF2A2A4A)
      ..strokeWidth = 0.5;

    for (int col = 1; col < GameConstants.columns; col++) {
      final double x = col * cellSize;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    for (int row = 1; row < GameConstants.rows; row++) {
      final double y = row * cellSize;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_GridPainter oldDelegate) =>
      cellSize != oldDelegate.cellSize;
}
