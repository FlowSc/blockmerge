import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/merge_result.dart';
import '../providers/game_notifier.dart';

class ComboDisplay extends ConsumerStatefulWidget {
  const ComboDisplay({super.key});

  @override
  ConsumerState<ComboDisplay> createState() => _ComboDisplayState();
}

class _ComboDisplayState extends ConsumerState<ComboDisplay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<Offset> _slideAnimation;
  MergeChainResult? _currentChain;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    );
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.3, end: 1.2), weight: 25),
      TweenSequenceItem(tween: Tween(begin: 1.2, end: 1.0), weight: 15),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.0), weight: 60),
    ]).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));
    _opacityAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 15),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.0), weight: 55),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 30),
    ]).animate(_controller);
    _slideAnimation = TweenSequence<Offset>([
      TweenSequenceItem(
        tween: Tween(begin: const Offset(0, 0.1), end: Offset.zero),
        weight: 25,
      ),
      TweenSequenceItem(
        tween: Tween(begin: Offset.zero, end: const Offset(0, -0.05)),
        weight: 75,
      ),
    ]).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<MergeChainResult?>(
      gameNotifierProvider.select((s) => s.lastMergeChain),
      (MergeChainResult? prev, MergeChainResult? next) {
        if (next != null && next.steps.isNotEmpty) {
          setState(() => _currentChain = next);
          _controller.forward(from: 0);
        }
      },
    );

    if (_currentChain == null) return const SizedBox.shrink();

    final int chainLevel = _currentChain!.maxChainLevel;
    final String label = _comboLabel(chainLevel);
    final Color color = _comboColor(chainLevel);

    return IgnorePointer(
      child: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (BuildContext context, Widget? child) {
            return SlideTransition(
              position: _slideAnimation,
              child: Opacity(
                opacity: _opacityAnimation.value,
                child: Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: color.withValues(alpha: 0.4),
                        width: 1.5,
                      ),
                    ),
                    child: Text(
                      label,
                      style: TextStyle(
                        color: color,
                        fontSize: 32 + chainLevel * 6.0,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 3,
                        shadows: [
                          Shadow(
                            color: color.withValues(alpha: 0.8),
                            blurRadius: 20,
                          ),
                          Shadow(
                            color: color.withValues(alpha: 0.4),
                            blurRadius: 40,
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
    );
  }

  String _comboLabel(int chainLevel) {
    return switch (chainLevel) {
      0 => 'MERGE!',
      1 => 'CHAIN x2!',
      2 => 'CHAIN x3!',
      _ => 'MEGA x${chainLevel + 1}!',
    };
  }

  Color _comboColor(int chainLevel) {
    return switch (chainLevel) {
      0 => const Color(0xFF00D2FF),
      1 => const Color(0xFF00FF88),
      2 => const Color(0xFFFFD700),
      _ => const Color(0xFFFF4444),
    };
  }
}
