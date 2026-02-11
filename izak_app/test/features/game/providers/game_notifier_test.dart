import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:izak_app/features/game/models/game_state.dart';
import 'package:izak_app/features/game/providers/game_notifier.dart';

void main() {
  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer();
  });

  tearDown(() {
    container.dispose();
  });

  group('GameNotifier', () {
    test('initial state is idle', () {
      final GameState state = container.read(gameNotifierProvider);
      expect(state.status, GameStatus.idle);
      expect(state.score, 0);
      expect(state.currentBlock, isNull);
      expect(state.nextBlock, isNull);
    });

    test('startGame sets status to playing and spawns blocks', () {
      container.read(gameNotifierProvider.notifier).startGame();
      final GameState state = container.read(gameNotifierProvider);

      expect(state.status, GameStatus.playing);
      expect(state.currentBlock, isNotNull);
      expect(state.nextBlock, isNotNull);
      expect(state.score, 0);
    });

    test('moveLeft moves the block left', () {
      container.read(gameNotifierProvider.notifier).startGame();
      final GameState before = container.read(gameNotifierProvider);
      final int originalCol = before.currentBlock!.tiles.first.position.col;

      container.read(gameNotifierProvider.notifier).moveLeft();
      final GameState after = container.read(gameNotifierProvider);
      final int newCol = after.currentBlock!.tiles.first.position.col;

      expect(newCol, originalCol - 1);
    });

    test('moveRight moves the block right', () {
      container.read(gameNotifierProvider.notifier).startGame();
      final GameState before = container.read(gameNotifierProvider);
      final int originalCol = before.currentBlock!.tiles.first.position.col;

      container.read(gameNotifierProvider.notifier).moveRight();
      final GameState after = container.read(gameNotifierProvider);
      final int newCol = after.currentBlock!.tiles.first.position.col;

      expect(newCol, originalCol + 1);
    });

    test('moveLeft does not move past left wall', () {
      container.read(gameNotifierProvider.notifier).startGame();
      // Move left many times to hit the wall
      final GameNotifier notifier =
          container.read(gameNotifierProvider.notifier);
      for (int i = 0; i < 10; i++) {
        notifier.moveLeft();
      }
      final GameState state = container.read(gameNotifierProvider);
      expect(state.currentBlock!.leftCol, greaterThanOrEqualTo(0));
    });

    test('moveRight does not move past right wall', () {
      container.read(gameNotifierProvider.notifier).startGame();
      final GameNotifier notifier =
          container.read(gameNotifierProvider.notifier);
      for (int i = 0; i < 10; i++) {
        notifier.moveRight();
      }
      final GameState state = container.read(gameNotifierProvider);
      expect(state.currentBlock!.rightCol, lessThan(6));
    });

    test('hardDrop places block at bottom', () {
      container.read(gameNotifierProvider.notifier).startGame();
      container.read(gameNotifierProvider.notifier).hardDrop();
      final GameState state = container.read(gameNotifierProvider);

      // After hard drop, the block should be placed and a new block spawned
      // (unless game over). The grid should have at least one non-null cell.
      bool hasPlacedTile = false;
      for (final List<int?> row in state.grid) {
        for (final int? cell in row) {
          if (cell != null) {
            hasPlacedTile = true;
            break;
          }
        }
        if (hasPlacedTile) break;
      }
      expect(hasPlacedTile, isTrue);
    });

    test('pause and resume toggle state correctly', () {
      container.read(gameNotifierProvider.notifier).startGame();
      expect(
        container.read(gameNotifierProvider).status,
        GameStatus.playing,
      );

      container.read(gameNotifierProvider.notifier).pause();
      expect(
        container.read(gameNotifierProvider).status,
        GameStatus.paused,
      );

      container.read(gameNotifierProvider.notifier).resume();
      expect(
        container.read(gameNotifierProvider).status,
        GameStatus.playing,
      );
    });

    test('softDrop moves block down one row', () {
      container.read(gameNotifierProvider.notifier).startGame();
      final GameState before = container.read(gameNotifierProvider);
      final int originalRow = before.currentBlock!.tiles.first.position.row;

      container.read(gameNotifierProvider.notifier).softDrop();
      final GameState after = container.read(gameNotifierProvider);

      // After soft drop, block should either be one row lower or placed
      if (after.currentBlock != null) {
        final int newRow = after.currentBlock!.tiles.first.position.row;
        expect(newRow, originalRow + 1);
      }
    });
  });
}
