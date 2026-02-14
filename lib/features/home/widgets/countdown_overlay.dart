import 'dart:async';

import 'package:flutter/material.dart';

class CountdownOverlay extends StatefulWidget {
  const CountdownOverlay({super.key, required this.onComplete});

  final VoidCallback onComplete;

  @override
  State<CountdownOverlay> createState() => _CountdownOverlayState();
}

class _CountdownOverlayState extends State<CountdownOverlay>
    with SingleTickerProviderStateMixin {
  int _count = 3;
  Timer? _timer;
  late final AnimationController _scaleController;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 2.0, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );
    _scaleController.forward();
    _startCountdown();
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_count <= 1) {
        timer.cancel();
        widget.onComplete();
        return;
      }
      setState(() {
        _count--;
      });
      _scaleController.reset();
      _scaleController.forward();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withValues(alpha: 0.85),
      child: Center(
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Text(
            '$_count',
            style: const TextStyle(
              fontFamily: 'DungGeunMo',
              fontSize: 72,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
