import 'package:flutter/material.dart';
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
      return AlertDialog(
        title: const Text('닉네임 입력'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: controller,
            autofocus: true,
            maxLength: 10,
            decoration: const InputDecoration(
              hintText: '리더보드에 표시될 이름 (2~10자)',
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
            onPressed: () => Navigator.of(ctx).pop(null),
            child: const Text('취소'),
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
            child: const Text('확인'),
          ),
        ],
      );
    },
  );
}
