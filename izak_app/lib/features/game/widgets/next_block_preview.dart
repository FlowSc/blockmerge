import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/falling_block.dart';
import '../models/tile.dart' as game;
import '../providers/game_notifier.dart';
import 'tile_widget.dart';

class NextBlockPreview extends ConsumerWidget {
  const NextBlockPreview({super.key});

  static const double _tileSize = 24;
  // Fixed size to fit the largest block (T-shape: 3 cols x 2 rows).
  static const double _previewWidth = _tileSize * 3;
  static const double _previewHeight = _tileSize * 2;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final FallingBlock? nextBlock =
        ref.watch(gameNotifierProvider.select((s) => s.nextBlock));
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1117),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l10n.next,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 4),
          nextBlock == null
              ? const SizedBox(width: _previewWidth, height: _previewHeight)
              : _buildPreview(nextBlock),
        ],
      ),
    );
  }

  Widget _buildPreview(FallingBlock block) {
    // Compute bounding box
    int minRow = block.tiles.first.position.row;
    int maxRow = minRow;
    int minCol = block.tiles.first.position.col;
    int maxCol = minCol;
    for (final game.Tile tile in block.tiles) {
      final int r = tile.position.row;
      final int c = tile.position.col;
      if (r < minRow) minRow = r;
      if (r > maxRow) maxRow = r;
      if (c < minCol) minCol = c;
      if (c > maxCol) maxCol = c;
    }

    final int rowCount = maxRow - minRow + 1;
    final int colCount = maxCol - minCol + 1;
    final double blockWidth = colCount * _tileSize;
    final double blockHeight = rowCount * _tileSize;
    final double offsetX = (_previewWidth - blockWidth) / 2;
    final double offsetY = (_previewHeight - blockHeight) / 2;

    return SizedBox(
      width: _previewWidth,
      height: _previewHeight,
      child: Stack(
        children: [
          for (final game.Tile tile in block.tiles)
            Positioned(
              left: offsetX + (tile.position.col - minCol) * _tileSize,
              top: offsetY + (tile.position.row - minRow) * _tileSize,
              child: TileWidget(
                value: tile.value,
                size: _tileSize - 2,
              ),
            ),
        ],
      ),
    );
  }
}
