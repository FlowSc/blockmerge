import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
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
    final l10n = AppLocalizations.of(context)!;

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
    final String label = _comboLabel(chainLevel, l10n);
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
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: color.withValues(alpha: 0.4),
                        width: 1.5,
                      ),
                    ),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        label,
                        maxLines: 1,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'DungGeunMo',
                          color: color,
                          fontSize: 18 + chainLevel * 2.0,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 3,
                          shadows: [
                            Shadow(
                              color: color.withValues(alpha: 0.8),
                              blurRadius: 8,
                            ),
                            Shadow(
                              color: color.withValues(alpha: 0.4),
                              blurRadius: 16,
                            ),
                          ],
                        ),
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

  String _comboLabel(int chainLevel, AppLocalizations l10n) {
    final int count = chainLevel + 1;
    return switch (chainLevel) {
      0 => l10n.merge,
      1 => l10n.chainX2,
      2 => l10n.chainX3,
      3 || 4 => l10n.megaChain(count),
      5 || 6 => l10n.superChain(count),
      7 || 8 => l10n.amazingChain(count),
      9 || 10 => l10n.spectacularChain(count),
      _ => l10n.legendaryChain(count),
    };
  }

  Color _comboColor(int chainLevel) {
    return switch (chainLevel) {
      0 => const Color(0xFF00D2FF),
      1 => const Color(0xFF00FF88),
      2 => const Color(0xFFFFD700),
      3 || 4 => const Color(0xFFFF4444),
      5 || 6 => const Color(0xFFFF6B6B),
      7 || 8 => const Color(0xFFE040FB),
      9 || 10 => const Color(0xFFFF9100),
      _ => const Color(0xFFFFD700),
    };
  }
}
