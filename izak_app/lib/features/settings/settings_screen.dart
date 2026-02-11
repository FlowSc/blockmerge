import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'providers/settings_notifier.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('설정'),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 8),
          _SettingsTile(
            icon: settings.soundEnabled ? Icons.volume_up : Icons.volume_off,
            title: '사운드',
            subtitle: '효과음 및 배경음악',
            value: settings.soundEnabled,
            onChanged: (_) {
              ref.read(settingsNotifierProvider.notifier).toggleSound();
            },
          ),
          _SettingsTile(
            icon: Icons.vibration,
            title: '진동',
            subtitle: '병합 및 드롭 시 햅틱 피드백',
            value: settings.vibrationEnabled,
            onChanged: (_) {
              ref.read(settingsNotifierProvider.notifier).toggleVibration();
            },
          ),
          _SettingsTile(
            icon:
                settings.showGhost ? Icons.visibility : Icons.visibility_off,
            title: '고스트 블록',
            subtitle: '블록 착지 위치 미리보기',
            value: settings.showGhost,
            onChanged: (_) {
              ref.read(settingsNotifierProvider.notifier).toggleGhost();
            },
          ),
          const Divider(height: 32),
          ListTile(
            leading: const Icon(Icons.school_outlined),
            title: const Text('튜토리얼 다시보기'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/tutorial'),
          ),
          const SizedBox(height: 48),
          Center(
            child: Text(
              'IZAK v1.0.0',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.3),
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      secondary: Icon(icon),
      title: Text(title),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.5),
          fontSize: 12,
        ),
      ),
      value: value,
      onChanged: onChanged,
    );
  }
}
