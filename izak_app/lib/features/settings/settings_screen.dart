import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers/purchase_provider.dart';
import 'providers/settings_notifier.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsNotifierProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 8),
          _SettingsTile(
            icon: settings.soundEnabled ? Icons.volume_up : Icons.volume_off,
            title: l10n.sound,
            subtitle: l10n.soundDesc,
            value: settings.soundEnabled,
            onChanged: (_) {
              ref.read(settingsNotifierProvider.notifier).toggleSound();
            },
          ),
          _SettingsTile(
            icon: Icons.vibration,
            title: l10n.vibration,
            subtitle: l10n.vibrationDesc,
            value: settings.vibrationEnabled,
            onChanged: (_) {
              ref.read(settingsNotifierProvider.notifier).toggleVibration();
            },
          ),
          _SettingsTile(
            icon:
                settings.showGhost ? Icons.visibility : Icons.visibility_off,
            title: l10n.ghostBlock,
            subtitle: l10n.ghostBlockDesc,
            value: settings.showGhost,
            onChanged: (_) {
              ref.read(settingsNotifierProvider.notifier).toggleGhost();
            },
          ),
          const Divider(height: 32),
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: Text(l10n.nickname),
            subtitle: Text(
              settings.nickname ?? l10n.nicknameNotSet,
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
            title: Text(l10n.reviewTutorial),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/tutorial'),
          ),
          const Divider(height: 32),
          _AdRemovalTile(isAdFree: settings.isAdFree),
          ListTile(
            leading: const Icon(Icons.restore),
            title: Text(l10n.restorePurchases),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              ref.read(purchaseNotifierProvider.notifier).restorePurchases();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.restoringPurchases)),
              );
            },
          ),
          const SizedBox(height: 48),
          Center(
            child: Text(
              'Drop Merge v1.0.0',
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
      final l10n = AppLocalizations.of(ctx)!;

      return AlertDialog(
        title: Text(l10n.setNickname),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: controller,
            autofocus: true,
            maxLength: 10,
            decoration: InputDecoration(
              hintText: l10n.nicknameHint,
            ),
            validator: (String? value) {
              if (value == null || value.trim().length < 2) {
                return l10n.nicknameMinError;
              }
              if (value.trim().length > 10) {
                return l10n.nicknameMaxError;
              }
              return null;
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.cancel),
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
            child: Text(l10n.save),
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
    final l10n = AppLocalizations.of(context)!;

    if (isAdFree) {
      return ListTile(
        leading: Icon(
          Icons.check_circle,
          color: Colors.green.withValues(alpha: 0.7),
        ),
        title: Text(l10n.removeAds),
        subtitle: Text(
          l10n.purchased,
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
      title: Text(l10n.removeAds),
      subtitle: Text(
        purchaseState.removeAdsPrice ?? l10n.removeAdsDesc,
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
        final l10n = AppLocalizations.of(ctx)!;

        return AlertDialog(
          title: Text(l10n.removeAds),
          content: Text(
            price != null
                ? l10n.removeAdsConfirm(price)
                : l10n.removeAdsConfirmDefault,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                ref.read(purchaseNotifierProvider.notifier).buyRemoveAds();
              },
              child: Text(l10n.purchase),
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
