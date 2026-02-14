import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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
            icon: settings.bgmEnabled ? Icons.music_note : Icons.music_off,
            title: l10n.bgm,
            subtitle: l10n.bgmDesc,
            value: settings.bgmEnabled,
            onChanged: (_) {
              ref.read(settingsNotifierProvider.notifier).toggleBgm();
            },
          ),
          _SettingsTile(
            icon: settings.sfxEnabled ? Icons.volume_up : Icons.volume_off,
            title: l10n.sfx,
            subtitle: l10n.sfxDesc,
            value: settings.sfxEnabled,
            onChanged: (_) {
              ref.read(settingsNotifierProvider.notifier).toggleSfx();
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
                fontFamily: 'DungGeunMo',
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: 8,
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
          ListTile(
            leading: const Icon(Icons.language),
            title: Text(l10n.language),
            subtitle: Text(
              _localeDisplayName(settings.localeCode),
              style: TextStyle(
                fontFamily: 'DungGeunMo',
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: 8,
              ),
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () =>
                _showLanguageDialog(context, ref, settings.localeCode),
          ),
          const Divider(height: 32),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: Text(l10n.privacyPolicy),
            trailing: const Icon(Icons.open_in_new, size: 18),
            onTap: () => launchUrl(
              Uri.parse('https://liftinnovations.cc/mergeblast/terms/privacy-policy'),
              mode: LaunchMode.externalApplication,
            ),
          ),
          const SizedBox(height: 48),
          Center(
            child: Text(
              'Merge Chain Blast v1.0.0',
              style: TextStyle(
                fontFamily: 'DungGeunMo',
                color: Colors.white.withValues(alpha: 0.3),
                fontSize: 8,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String _localeDisplayName(String? localeCode) {
  return switch (localeCode) {
    'en' => 'English',
    'ko' => '한국어',
    'ja' => '日本語',
    'es' => 'Español',
    _ => 'System',
  };
}

void _showLanguageDialog(
  BuildContext context,
  WidgetRef ref,
  String? currentLocale,
) {
  const List<(String?, String)> options = [
    (null, 'System'),
    ('en', 'English'),
    ('ko', '한국어'),
    ('ja', '日本語'),
    ('es', 'Español'),
  ];

  showDialog<void>(
    context: context,
    builder: (BuildContext ctx) {
      final l10n = AppLocalizations.of(ctx)!;

      return AlertDialog(
        title: Text(l10n.language),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final (String? code, String label) in options)
              RadioListTile<String?>(
                title: Text(
                  label,
                  style: const TextStyle(
                    fontFamily: 'DungGeunMo',
                    fontSize: 12,
                  ),
                ),
                value: code,
                groupValue: currentLocale,
                onChanged: (String? value) {
                  ref
                      .read(settingsNotifierProvider.notifier)
                      .setLocale(value);
                  Navigator.of(ctx).pop();
                },
              ),
          ],
        ),
      );
    },
  );
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
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9_]')),
            ],
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
          fontFamily: 'DungGeunMo',
          color: Colors.white.withValues(alpha: 0.5),
          fontSize: 8,
        ),
      ),
      value: value,
      onChanged: onChanged,
    );
  }
}
