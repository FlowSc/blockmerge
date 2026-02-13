import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../../settings/providers/settings_notifier.dart';
import '../models/item_type.dart';
import '../providers/game_notifier.dart';
import 'number_select_dialog.dart';

class ItemButtons extends ConsumerWidget {
  const ItemButtons({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Map<String, int> itemCounts =
        ref.watch(settingsNotifierProvider.select((s) => s.itemCounts));
    final bool canUse =
        ref.watch(gameNotifierProvider.select((s) => !s.isAnimating));
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _ItemButton(
            icon: Icons.gps_fixed,
            label: l10n.itemNumberPurge,
            count: itemCounts[ItemType.numberPurge.name] ?? 0,
            enabled: canUse,
            color: const Color(0xFFFF5555),
            onPressed: () => _onNumberPurge(context, ref),
          ),
          const SizedBox(width: 8),
          _ItemButton(
            icon: Icons.star,
            label: l10n.itemMaxKeep,
            count: itemCounts[ItemType.maxKeep.name] ?? 0,
            enabled: canUse,
            color: const Color(0xFFFFD700),
            onPressed: () => _onMaxKeep(ref),
          ),
          const SizedBox(width: 8),
          _ItemButton(
            icon: Icons.shuffle,
            label: l10n.itemShuffle,
            count: itemCounts[ItemType.shuffle.name] ?? 0,
            enabled: canUse,
            color: const Color(0xFF55FFFF),
            onPressed: () => _onShuffle(ref),
          ),
        ],
      ),
    );
  }

  void _onNumberPurge(BuildContext context, WidgetRef ref) async {
    final gameState = ref.read(gameNotifierProvider);
    if (!ref.read(gameNotifierProvider.notifier).canUseItem) return;

    final int? value =
        await showNumberSelectDialog(context, gameState.grid);
    if (value == null) return;

    ref.read(gameNotifierProvider.notifier).useNumberPurge(value);
  }

  void _onMaxKeep(WidgetRef ref) {
    ref.read(gameNotifierProvider.notifier).useMaxKeep();
  }

  void _onShuffle(WidgetRef ref) {
    ref.read(gameNotifierProvider.notifier).useShuffle();
  }
}

class _ItemButton extends StatelessWidget {
  const _ItemButton({
    required this.icon,
    required this.label,
    required this.count,
    required this.enabled,
    required this.color,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final int count;
  final bool enabled;
  final Color color;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final bool active = enabled && count > 0;

    return GestureDetector(
      onTap: active ? onPressed : null,
      child: AnimatedOpacity(
        opacity: active ? 1.0 : 0.35,
        duration: const Duration(milliseconds: 150),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: active ? 0.15 : 0.05),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: color.withValues(alpha: active ? 0.6 : 0.15),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: color.withValues(alpha: active ? 0.9 : 0.3),
                size: 14,
              ),
              const SizedBox(width: 4),
              Text(
                'x$count',
                style: TextStyle(
                  fontFamily: 'PressStart2P',
                  color: Colors.white.withValues(alpha: active ? 0.9 : 0.3),
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
