import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/game_mode.dart';
import '../models/game_state.dart';
import '../providers/game_notifier.dart';

/// Shows time warnings in time attack mode:
/// - Brief banner at 60s and 30s remaining
/// - Persistent countdown from 10s
class TimeAttackWarning extends ConsumerStatefulWidget {
  const TimeAttackWarning({super.key});

  @override
  ConsumerState<TimeAttackWarning> createState() => _TimeAttackWarningState();
}

class _TimeAttackWarningState extends ConsumerState<TimeAttackWarning>
    with TickerProviderStateMixin {
  // Banner animation (60s / 30s warnings)
  AnimationController? _bannerController;
  Animation<double>? _bannerOpacity;
  Animation<double>? _bannerScale;
  String _bannerText = '';
  Color _bannerColor = const Color(0xFFFFD700);

  // Countdown animation (10s and below)
  AnimationController? _countdownController;
  Animation<double>? _countdownScale;
  int _lastCountdown = -1;

  // Track which warnings have been shown
  bool _shown60 = false;
  bool _shown30 = false;

  @override
  void dispose() {
    _bannerController?.dispose();
    _countdownController?.dispose();
    super.dispose();
  }

  void _showBanner(String text, Color color) {
    _bannerController?.dispose();
    _bannerController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _bannerOpacity = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 15),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.0), weight: 55),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 30),
    ]).animate(_bannerController!);
    _bannerScale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.5, end: 1.1), weight: 15),
      TweenSequenceItem(tween: Tween(begin: 1.1, end: 1.0), weight: 15),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.0), weight: 70),
    ]).animate(CurvedAnimation(
      parent: _bannerController!,
      curve: Curves.easeOut,
    ));

    setState(() {
      _bannerText = text;
      _bannerColor = color;
    });
    _bannerController!.forward(from: 0);
  }

  void _pulseCountdown() {
    _countdownController?.dispose();
    _countdownController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _countdownScale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.4, end: 0.9), weight: 60),
      TweenSequenceItem(tween: Tween(begin: 0.9, end: 1.0), weight: 40),
    ]).animate(CurvedAnimation(
      parent: _countdownController!,
      curve: Curves.easeOut,
    ));
    _countdownController!.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final GameMode gameMode =
        ref.watch(gameNotifierProvider.select((GameState s) => s.gameMode));
    final int remaining =
        ref.watch(gameNotifierProvider.select((GameState s) => s.remainingSeconds));
    final GameStatus status =
        ref.watch(gameNotifierProvider.select((GameState s) => s.status));

    if (gameMode != GameMode.timeAttack || status != GameStatus.playing) {
      return const SizedBox.shrink();
    }

    // Reset flags when a new game starts (remaining > 60 means fresh game)
    if (remaining > 60) {
      _shown60 = false;
      _shown30 = false;
    }

    // 60s warning
    if (remaining == 60 && !_shown60) {
      _shown60 = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showBanner('1:00', const Color(0xFFFFD700));
      });
    }

    // 30s warning
    if (remaining == 30 && !_shown30) {
      _shown30 = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showBanner('0:30', const Color(0xFFFF4444));
      });
    }

    // Countdown from 10s
    if (remaining <= 10 && remaining > 0 && remaining != _lastCountdown) {
      _lastCountdown = remaining;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _pulseCountdown();
      });
    }

    return IgnorePointer(
      child: Stack(
        children: [
          // Banner (60s / 30s)
          if (_bannerController != null && _bannerOpacity != null)
            Positioned(
              top: 8,
              left: 0,
              right: 0,
              child: AnimatedBuilder(
                animation: _bannerController!,
                builder: (BuildContext context, Widget? child) {
                  return Opacity(
                    opacity: _bannerOpacity!.value,
                    child: Transform.scale(
                      scale: _bannerScale?.value ?? 1.0,
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: _bannerColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(2),
                            border: Border.all(
                              color: _bannerColor.withValues(alpha: 0.6),
                              width: 2,
                            ),
                          ),
                          child: Text(
                            _bannerText,
                            style: TextStyle(
                              fontFamily: 'PressStart2P',
                              color: _bannerColor,
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              shadows: [
                                Shadow(
                                  color: _bannerColor.withValues(alpha: 0.8),
                                  blurRadius: 12,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

          // Countdown (10s and below)
          if (remaining <= 10 && remaining > 0)
            Positioned(
              top: 8,
              left: 0,
              right: 0,
              child: Center(
                child: _countdownController != null && _countdownScale != null
                    ? AnimatedBuilder(
                        animation: _countdownController!,
                        builder: (BuildContext context, Widget? child) {
                          return Transform.scale(
                            scale: _countdownScale!.value,
                            child: _buildCountdownText(remaining),
                          );
                        },
                      )
                    : _buildCountdownText(remaining),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCountdownText(int seconds) {
    final Color color = seconds <= 3
        ? const Color(0xFFFF0000)
        : seconds <= 5
            ? const Color(0xFFFF4444)
            : const Color(0xFFFF8844);

    return Text(
      '$seconds',
      style: TextStyle(
        fontFamily: 'PressStart2P',
        color: color,
        fontSize: 32,
        fontWeight: FontWeight.w900,
        shadows: [
          Shadow(
            color: color.withValues(alpha: 0.8),
            blurRadius: 16,
          ),
          Shadow(
            color: color.withValues(alpha: 0.4),
            blurRadius: 32,
          ),
        ],
      ),
    );
  }
}
