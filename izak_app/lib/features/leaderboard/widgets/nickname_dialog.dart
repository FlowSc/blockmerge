import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../settings/providers/settings_notifier.dart';

/// Shows a dialog to input/update nickname.
/// Returns the nickname if saved, or null if cancelled.
Future<String?> showNicknameDialog(BuildContext context, WidgetRef ref) async {
  final String? current = ref.read(settingsNotifierProvider).nickname;
  final TextEditingController controller =
      TextEditingController(text: current);
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  return showDialog<String>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext ctx) {
      final l10n = AppLocalizations.of(ctx)!;

      return AlertDialog(
        title: Text(l10n.enterNickname),
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
              hintText: l10n.nicknameDialogHint,
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
            onPressed: () => Navigator.of(ctx).pop(null),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () {
              if (formKey.currentState?.validate() ?? false) {
                final String nickname = controller.text.trim();
                ref
                    .read(settingsNotifierProvider.notifier)
                    .setNickname(nickname);
                Navigator.of(ctx).pop(nickname);
              }
            },
            child: Text(l10n.confirm),
          ),
        ],
      );
    },
  );
}
