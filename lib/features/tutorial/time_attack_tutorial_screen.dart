import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../settings/providers/settings_notifier.dart';

class TimeAttackTutorialScreen extends ConsumerWidget {
  const TimeAttackTutorialScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            children: [
              const Spacer(flex: 2),
              // Title
              const Icon(
                Icons.timer,
                size: 64,
                color: Color(0xFFFF6EC7),
              ),
              const SizedBox(height: 24),
              Text(
                l10n.timeAttackTutorialTitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'DungGeunMo',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFF6EC7),
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 40),
              // Rules
              _RuleRow(
                icon: Icons.schedule,
                color: const Color(0xFFFFD700),
                text: l10n.timeAttackTutorialRule1,
              ),
              const SizedBox(height: 20),
              _RuleRow(
                icon: Icons.pause_circle_outline,
                color: const Color(0xFFFF4444),
                text: l10n.timeAttackTutorialRule2,
              ),
              const SizedBox(height: 20),
              _RuleRow(
                icon: Icons.phonelink_erase,
                color: const Color(0xFF00E5FF),
                text: l10n.timeAttackTutorialRule3,
              ),
              const Spacer(flex: 3),
              // GO button
              SizedBox(
                width: 200,
                height: 56,
                child: FilledButton(
                  onPressed: () {
                    ref
                        .read(settingsNotifierProvider.notifier)
                        .markTimeAttackTutorialSeen();
                    context.go('/game?mode=timeAttack');
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFFF6EC7),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  child: Text(
                    l10n.timeAttackTutorialGo,
                    style: const TextStyle(
                      fontFamily: 'DungGeunMo',
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}

class _RuleRow extends StatelessWidget {
  const _RuleRow({
    required this.icon,
    required this.color,
    required this.text,
  });

  final IconData icon;
  final Color color;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontFamily: 'DungGeunMo',
              color: Colors.white,
              fontSize: 8,
              height: 1.8,
            ),
          ),
        ),
      ],
    );
  }
}
