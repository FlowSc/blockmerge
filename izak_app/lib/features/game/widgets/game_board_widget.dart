import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/game_constants.dart';
import '../models/falling_block.dart';
import '../models/position.dart';
import '../models/tile.dart' as game;
import '../providers/game_notifier.dart';
import 'tile_widget.dart';

class GameBoardWidget extends ConsumerWidget {
  const GameBoardWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameNotifierProvider);
    final List<List<int?>> grid = gameState.grid;
    final FallingBlock? currentBlock = gameState.currentBlock;
    final Set<Position>? highlighted = gameState.highlightedPositions;
    final Set<Position>? newMerged = gameState.newMergedPositions;

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
    Set<Position>? ghostPositions;
    Map<Position, int>? ghostValues;
    if (currentBlock != null) {
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

        return Center(
          child: SizedBox(
            width: boardWidth + 2,
            height: boardHeight + 2,
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF0D1117),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: const Color(0xFF6C5CE7).withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Stack(
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
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  double _calculateCellSize(BoxConstraints constraints) {
    final double maxCellWidth = constraints.maxWidth / GameConstants.columns;
    final double maxCellHeight = constraints.maxHeight / GameConstants.rows;
    return maxCellWidth < maxCellHeight ? maxCellWidth : maxCellHeight;
  }

  List<Widget> _buildTiles(
    List<List<int?>> grid,
    double cellSize, {
    Set<Position>? highlighted,
    Set<Position>? newMerged,
  }) {
    final List<Widget> widgets = [];
    for (int row = 0; row < GameConstants.rows; row++) {
      for (int col = 0; col < GameConstants.columns; col++) {
        final int? value = grid[row][col];
        if (value != null) {
          final Position pos = Position(row: row, col: col);
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
              borderRadius: BorderRadius.circular(6),
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
}

class _GridPainter extends CustomPainter {
  _GridPainter({required this.cellSize});

  final double cellSize;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.05)
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
