import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../home/widgets/countdown_overlay.dart';
import 'models/game_mode.dart';
import 'models/game_state.dart';
import 'providers/game_notifier.dart';
import 'widgets/combo_display.dart';
import 'widgets/game_board_widget.dart';
import 'widgets/game_over_overlay.dart';
import 'widgets/new_best_notification.dart';
import 'widgets/next_block_preview.dart';
import 'widgets/pause_overlay.dart';
import 'widgets/score_display.dart';
import 'widgets/time_attack_warning.dart';
import 'widgets/victory_overlay.dart';
import '../../shared/widgets/banner_ad_widget.dart';

class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({
    this.isContinue = false,
    this.gameMode = GameMode.classic,
    super.key,
  });

  final bool isContinue;
  final GameMode gameMode;

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen>
    with WidgetsBindingObserver {
  bool _showCountdown = true;
  bool _pendingResume = false;

  // Gesture tracking
  Offset? _dragStart;
  static const double _horizontalSwipeThreshold = 14;
  static const double _hardDropVelocity = 800;

  // DAS (Delayed Auto Shift) — auto-repeat when holding a direction
  static const int _dasDelayMs = 170;
  static const int _arrIntervalMs = 50;
  Timer? _dasTimer;
  Timer? _arrTimer;
  int _dasDirection = 0; // -1 left, 1 right, 0 none

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    _cancelDas();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _startDas(int direction) {
    if (_dasDirection == direction) return;
    _cancelDas();
    _dasDirection = direction;
    _dasTimer = Timer(const Duration(milliseconds: _dasDelayMs), () {
      _arrTimer =
          Timer.periodic(const Duration(milliseconds: _arrIntervalMs), (_) {
        final GameNotifier notifier = ref.read(gameNotifierProvider.notifier);
        if (_dasDirection == -1) {
          notifier.moveLeft();
        } else if (_dasDirection == 1) {
          notifier.moveRight();
        }
      });
    });
  }

  void _cancelDas() {
    _dasTimer?.cancel();
    _arrTimer?.cancel();
    _dasTimer = null;
    _arrTimer = null;
    _dasDirection = 0;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      // Time attack: never pause — timer keeps running.
      if (widget.gameMode == GameMode.timeAttack) return;
      final GameNotifier notifier = ref.read(gameNotifierProvider.notifier);
      notifier.pause();
      notifier.saveGame();
    }
  }

  void _onCountdownComplete() async {
    setState(() {
      _showCountdown = false;
    });
    if (_pendingResume) {
      _pendingResume = false;
      ref.read(gameNotifierProvider.notifier).resume();
    } else if (widget.isContinue) {
      final bool restored =
          await ref.read(gameNotifierProvider.notifier).restoreGame();
      if (!restored && mounted) {
        ref.read(gameNotifierProvider.notifier).startGame(mode: widget.gameMode);
      }
    } else {
      ref.read(gameNotifierProvider.notifier).startGame(mode: widget.gameMode);
    }
  }

  void _onResume() {
    setState(() {
      _pendingResume = true;
      _showCountdown = true;
    });
  }

  void _showPauseNotAllowed() {
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          l10n.pauseNotAllowed,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: 'PressStart2P',
            fontSize: 7,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFFFF4444).withValues(alpha: 0.9),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _onPanStart(DragStartDetails details) {
    _dragStart = details.localPosition;
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (_dragStart == null) return;
    final Offset delta = details.localPosition - _dragStart!;
    final GameNotifier notifier = ref.read(gameNotifierProvider.notifier);

    if (delta.dx.abs() > _horizontalSwipeThreshold &&
        delta.dx.abs() > delta.dy.abs()) {
      final int direction = delta.dx > 0 ? 1 : -1;
      if (direction > 0) {
        notifier.moveRight();
      } else {
        notifier.moveLeft();
      }
      _startDas(direction);
      _dragStart = details.localPosition;
    }
  }

  void _onPanEnd(DragEndDetails details) {
    _cancelDas();
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
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Column(
              children: [
                // Header: [Pause] --- [NEXT block] --- [SCORE]
                Padding(
                  padding: const EdgeInsets.fromLTRB(4, 8, 16, 4),
                  child: Row(
                    children: [
                      if (status == GameStatus.playing ||
                          status == GameStatus.paused)
                        IconButton(
                          icon: const Icon(Icons.pause, color: Colors.white),
                          onPressed: () {
                            if (widget.gameMode == GameMode.timeAttack) {
                              _showPauseNotAllowed();
                            } else {
                              ref.read(gameNotifierProvider.notifier).pause();
                            }
                          },
                        )
                      else
                        const SizedBox(width: 48),
                      const Spacer(),
                      const NextBlockPreview(),
                      const Spacer(),
                      const ScoreDisplay(),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                // Game board + time attack warning overlay
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Stack(
                      children: [
                        GestureDetector(
                          onPanStart: _onPanStart,
                          onPanUpdate: _onPanUpdate,
                          onPanEnd: _onPanEnd,
                          onTap: _onTap,
                          behavior: HitTestBehavior.opaque,
                          child: const GameBoardWidget(),
                        ),
                        const Positioned(
                          top: 4,
                          left: 0,
                          right: 0,
                          child: TimeAttackWarning(),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
            // Combo overlay: centered on screen, no layout impact
            const Positioned.fill(
              child: ComboDisplay(),
            ),
            const NewBestNotification(),
            if (status == GameStatus.paused && !_showCountdown)
              PauseOverlay(onResume: _onResume),
            if (status == GameStatus.victory) const VictoryOverlay(),
            if (status == GameStatus.gameOver) const GameOverOverlay(),
            if (_showCountdown)
              CountdownOverlay(
                onComplete: _onCountdownComplete,
              ),
          ],
        ),
      ),
      bottomNavigationBar: const BannerAdWidget(),
    );
  }
}
