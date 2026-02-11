import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers/purchase_provider.dart';
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
            leading: const Icon(Icons.person_outline),
            title: const Text('닉네임'),
            subtitle: Text(
              settings.nickname ?? '미설정',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: 12,
              ),
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showNicknameDialog(context, ref, settings.nickname),
          ),
          ListTile(
            leading: const Icon(Icons.school_outlined),
            title: const Text('튜토리얼 다시보기'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/tutorial'),
          ),
          const Divider(height: 32),
          _AdRemovalTile(isAdFree: settings.isAdFree),
          ListTile(
            leading: const Icon(Icons.restore),
            title: const Text('구매 복원'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              ref.read(purchaseNotifierProvider.notifier).restorePurchases();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('구매 복원 중...')),
              );
            },
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

void _showNicknameDialog(
  BuildContext context,
  WidgetRef ref,
  String? currentNickname,
) {
  final TextEditingController controller =
      TextEditingController(text: currentNickname);
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  showDialog<void>(
    context: context,
    builder: (BuildContext ctx) {
      return AlertDialog(
        title: const Text('닉네임 설정'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: controller,
            autofocus: true,
            maxLength: 10,
            decoration: const InputDecoration(
              hintText: '2~10자 닉네임',
            ),
            validator: (String? value) {
              if (value == null || value.trim().length < 2) {
                return '최소 2자 이상 입력하세요';
              }
              if (value.trim().length > 10) {
                return '최대 10자까지 가능합니다';
              }
              return null;
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('취소'),
          ),
          FilledButton(
            onPressed: () {
              if (formKey.currentState?.validate() ?? false) {
                ref
                    .read(settingsNotifierProvider.notifier)
                    .setNickname(controller.text.trim());
                Navigator.of(ctx).pop();
              }
            },
            child: const Text('저장'),
          ),
        ],
      );
    },
  );
}

class _AdRemovalTile extends ConsumerWidget {
  const _AdRemovalTile({required this.isAdFree});

  final bool isAdFree;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final PurchaseState purchaseState = ref.watch(purchaseNotifierProvider);
    final bool isLoading =
        purchaseState.loadingState == PurchaseLoadingState.loading;

    if (isAdFree) {
      return ListTile(
        leading: Icon(
          Icons.check_circle,
          color: Colors.green.withValues(alpha: 0.7),
        ),
        title: const Text('광고 제거'),
        subtitle: Text(
          '구매 완료',
          style: TextStyle(
            color: Colors.green.withValues(alpha: 0.7),
            fontSize: 12,
          ),
        ),
        enabled: false,
      );
    }

    return ListTile(
      leading: const Icon(Icons.block),
      title: const Text('광고 제거'),
      subtitle: Text(
        purchaseState.removeAdsPrice ?? '영구적으로 모든 광고를 제거합니다',
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.5),
          fontSize: 12,
        ),
      ),
      trailing: isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.chevron_right),
      onTap: isLoading
          ? null
          : () => _showPurchaseDialog(context, ref, purchaseState.removeAdsPrice),
    );
  }

  void _showPurchaseDialog(
    BuildContext context,
    WidgetRef ref,
    String? price,
  ) {
    showDialog<void>(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: const Text('광고 제거'),
          content: Text(
            price != null
                ? '$price로 모든 광고를 영구적으로 제거하시겠습니까?'
                : '모든 광고를 영구적으로 제거하시겠습니까?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('취소'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                ref.read(purchaseNotifierProvider.notifier).buyRemoveAds();
              },
              child: const Text('구매'),
            ),
          ],
        );
      },
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
