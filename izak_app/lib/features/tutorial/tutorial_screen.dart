import 'package:flutter/material.dart';
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
                  '건너뛰기',
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
                children: const [
                  _IntroPage(),
                  _ControlsPage(),
                  _ChainPage(),
                  _StartPage(),
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
                          child: const Text(
                            '시작하기',
                            style: TextStyle(
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
  const _IntroPage();

  @override
  Widget build(BuildContext context) {
    return const _TutorialPageLayout(
      icon: Icons.grid_4x4,
      iconColor: Color(0xFF6C5CE7),
      title: '블록을 떨어뜨려\n같은 숫자를 합쳐라!',
      description: '위에서 내려오는 블록을 배치하고\n같은 숫자 타일이 만나면 자동으로 병합됩니다.',
    );
  }
}

class _ControlsPage extends StatelessWidget {
  const _ControlsPage();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.touch_app,
            size: 64,
            color: Color(0xFF00D2FF),
          ),
          SizedBox(height: 32),
          Text(
            '조작법',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 32),
          _ControlRow(
            icon: Icons.swipe,
            label: '좌/우 스와이프',
            description: '블록 이동',
          ),
          SizedBox(height: 16),
          _ControlRow(
            icon: Icons.touch_app,
            label: '탭',
            description: '블록 회전',
          ),
          SizedBox(height: 16),
          _ControlRow(
            icon: Icons.keyboard_double_arrow_down,
            label: '빠른 아래 스와이프',
            description: '즉시 낙하',
          ),
          SizedBox(height: 16),
          _ControlRow(
            icon: Icons.arrow_downward,
            label: '아래 스와이프',
            description: '빠르게 내리기',
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
  const _ChainPage();

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
          const Text(
            '체인 병합',
            style: TextStyle(
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
            '연쇄 병합이 일어나면\n점수가 폭발적으로 증가합니다!',
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
            child: const Text(
              'CHAIN x3  x7  x15 !',
              style: TextStyle(
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
  const _StartPage();

  @override
  Widget build(BuildContext context) {
    return const _TutorialPageLayout(
      icon: Icons.emoji_events,
      iconColor: Color(0xFFFFD93D),
      title: '최고 점수에\n도전하세요!',
      description: '블록이 꼭대기까지 쌓이면 게임 오버.\n전략적으로 배치하고 체인을 노려보세요!',
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
