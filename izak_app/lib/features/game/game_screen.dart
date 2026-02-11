import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../home/widgets/countdown_overlay.dart';
import 'models/game_state.dart';
import 'providers/game_notifier.dart';
import 'widgets/combo_display.dart';
import 'widgets/game_board_widget.dart';
import 'widgets/game_over_overlay.dart';
import 'widgets/new_best_notification.dart';
import 'widgets/next_block_preview.dart';
import 'widgets/pause_overlay.dart';
import 'widgets/score_display.dart';
import '../../shared/widgets/banner_ad_widget.dart';

class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({super.key});

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen>
    with WidgetsBindingObserver {
  bool _showCountdown = true;

  // Gesture tracking
  Offset? _dragStart;
  static const double _swipeThreshold = 20;
  static const double _hardDropVelocity = 800;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      ref.read(gameNotifierProvider.notifier).pause();
    }
  }

  void _onCountdownComplete() {
    setState(() {
      _showCountdown = false;
    });
    ref.read(gameNotifierProvider.notifier).startGame();
  }

  void _onPanStart(DragStartDetails details) {
    _dragStart = details.localPosition;
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (_dragStart == null) return;
    final Offset delta = details.localPosition - _dragStart!;
    final GameNotifier notifier = ref.read(gameNotifierProvider.notifier);

    if (delta.dx.abs() > _swipeThreshold && delta.dx.abs() > delta.dy.abs()) {
      if (delta.dx > 0) {
        notifier.moveRight();
      } else {
        notifier.moveLeft();
      }
      _dragStart = details.localPosition;
    } else if (delta.dy > _swipeThreshold && delta.dy > delta.dx.abs()) {
      notifier.softDrop();
      _dragStart = details.localPosition;
    }
  }

  void _onPanEnd(DragEndDetails details) {
    final double vy = details.velocity.pixelsPerSecond.dy;
    if (vy > _hardDropVelocity) {
      ref.read(gameNotifierProvider.notifier).hardDrop();
    }
    _dragStart = null;
  }

  void _onTap() {
    ref.read(gameNotifierProvider.notifier).rotate();
  }

  @override
  Widget build(BuildContext context) {
    final GameStatus status =
        ref.watch(gameNotifierProvider.select((s) => s.status));

    return Scaffold(
      appBar: AppBar(
        leading: (status == GameStatus.playing || status == GameStatus.paused)
            ? IconButton(
                icon: const Icon(Icons.pause),
                onPressed: () {
                  ref.read(gameNotifierProvider.notifier).pause();
                },
              )
            : null,
        automaticallyImplyLeading: false,
        title: const Text('IZAK'),
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        const SizedBox(height: 8),
                        const ScoreDisplay(
                          center: NextBlockPreview(),
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          child: GestureDetector(
                            onPanStart: _onPanStart,
                            onPanUpdate: _onPanUpdate,
                            onPanEnd: _onPanEnd,
                            onTap: _onTap,
                            behavior: HitTestBehavior.opaque,
                            child: const GameBoardWidget(),
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ),
                // Combo overlay: centered on screen, no layout impact
                const Positioned.fill(
                  child: ComboDisplay(),
                ),
                const NewBestNotification(),
                if (status == GameStatus.paused) const PauseOverlay(),
                if (status == GameStatus.gameOver) const GameOverOverlay(),
                if (_showCountdown)
                  CountdownOverlay(
                    onComplete: _onCountdownComplete,
                  ),
              ],
            ),
          ),
          const BannerAdWidget(),
        ],
      ),
    );
  }
}
