import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../settings/providers/settings_notifier.dart';

class TutorialScreen extends ConsumerStatefulWidget {
  const TutorialScreen({super.key});

  @override
  ConsumerState<TutorialScreen> createState() => _TutorialScreenState();
}

class _TutorialScreenState extends ConsumerState<TutorialScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  static const int _pageCount = 4;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDone() {
    ref.read(settingsNotifierProvider.notifier).markTutorialSeen();
    context.go('/game');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _onDone,
                child: Text(
                  l10n.skip,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5),
                  ),
                ),
              ),
            ),
            // Pages
            Expanded(
              child: PageView(
                controller: _controller,
                onPageChanged: (int index) {
                  setState(() => _currentPage = index);
                },
                children: [
                  _IntroPage(l10n: l10n),
                  _ControlsPage(l10n: l10n),
                  _ChainPage(l10n: l10n),
                  _StartPage(l10n: l10n),
                ],
              ),
            ),
            // Dot indicator + next/start button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Dots
                  Row(
                    children: List.generate(_pageCount, (int i) {
                      return Container(
                        width: 8,
                        height: 8,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: i == _currentPage
                              ? const Color(0xFF6C5CE7)
                              : Colors.white.withValues(alpha: 0.2),
                        ),
                      );
                    }),
                  ),
                  // Button
                  _currentPage == _pageCount - 1
                      ? FilledButton(
                          onPressed: _onDone,
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFF6C5CE7),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 12,
                            ),
                          ),
                          child: Text(
                            l10n.start,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        )
                      : IconButton(
                          onPressed: () {
                            _controller.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          },
                          icon: const Icon(Icons.arrow_forward),
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- Tutorial Pages ---

class _IntroPage extends StatelessWidget {
  const _IntroPage({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return _TutorialPageLayout(
      icon: Icons.grid_4x4,
      iconColor: const Color(0xFF6C5CE7),
      title: l10n.tutorialIntroTitle,
      description: l10n.tutorialIntroDesc,
    );
  }
}

class _ControlsPage extends StatelessWidget {
  const _ControlsPage({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.touch_app,
            size: 64,
            color: Color(0xFF00D2FF),
          ),
          const SizedBox(height: 32),
          Text(
            l10n.tutorialControls,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 32),
          _ControlRow(
            icon: Icons.swipe,
            label: l10n.swipeLeftRight,
            description: l10n.moveBlock,
          ),
          const SizedBox(height: 16),
          _ControlRow(
            icon: Icons.touch_app,
            label: l10n.tap,
            description: l10n.rotateBlock,
          ),
          const SizedBox(height: 16),
          _ControlRow(
            icon: Icons.keyboard_double_arrow_down,
            label: l10n.swipeDownFast,
            description: l10n.hardDrop,
          ),
          const SizedBox(height: 16),
          _ControlRow(
            icon: Icons.arrow_downward,
            label: l10n.swipeDown,
            description: l10n.softDrop,
          ),
        ],
      ),
    );
  }
}

class _ControlRow extends StatelessWidget {
  const _ControlRow({
    required this.icon,
    required this.label,
    required this.description,
  });

  final IconData icon;
  final String label;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF00D2FF), size: 28),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                description,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ChainPage extends StatelessWidget {
  const _ChainPage({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.auto_awesome,
            size: 64,
            color: Color(0xFFFFD93D),
          ),
          const SizedBox(height: 32),
          Text(
            l10n.tutorialChainTitle,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 24),
          // Chain example visualization
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _NumberBox(value: '2', color: Color(0xFF6C5CE7)),
              Text(' + ', style: TextStyle(color: Colors.white54, fontSize: 20)),
              _NumberBox(value: '2', color: Color(0xFF6C5CE7)),
              Text(' = ', style: TextStyle(color: Colors.white54, fontSize: 20)),
              _NumberBox(value: '4', color: Color(0xFFA29BFE)),
            ],
          ),
          const SizedBox(height: 12),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _NumberBox(value: '4', color: Color(0xFFA29BFE)),
              Text(' + ', style: TextStyle(color: Colors.white54, fontSize: 20)),
              _NumberBox(value: '4', color: Color(0xFFA29BFE)),
              Text(' = ', style: TextStyle(color: Colors.white54, fontSize: 20)),
              _NumberBox(value: '8', color: Color(0xFFE17055)),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            l10n.tutorialChainDesc,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 15,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFFFD93D).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              l10n.tutorialChainExample,
              style: const TextStyle(
                color: Color(0xFFFFD93D),
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NumberBox extends StatelessWidget {
  const _NumberBox({required this.value, required this.color});

  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      alignment: Alignment.center,
      child: Text(
        value,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _StartPage extends StatelessWidget {
  const _StartPage({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return _TutorialPageLayout(
      icon: Icons.emoji_events,
      iconColor: const Color(0xFFFFD93D),
      title: l10n.tutorialGoTitle,
      description: l10n.tutorialGoDesc,
    );
  }
}

class _TutorialPageLayout extends StatelessWidget {
  const _TutorialPageLayout({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: iconColor),
          const SizedBox(height: 32),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            description,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 15,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
