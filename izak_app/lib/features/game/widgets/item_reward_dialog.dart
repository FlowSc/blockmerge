import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../models/item_type.dart';

/// Shows a dialog to pick one of the three items as a reward.
/// Returns the chosen ItemType, or null if dismissed.
Future<ItemType?> showItemRewardDialog(BuildContext context) {
  return showDialog<ItemType>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext ctx) {
      final l10n = AppLocalizations.of(ctx)!;
      return AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: Text(
          l10n.itemReward,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: 'PressStart2P',
            color: Color(0xFFFFD700),
            fontSize: 10,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _RewardCard(
              itemType: ItemType.numberPurge,
              icon: Icons.gps_fixed,
              name: l10n.itemNumberPurge,
              description: l10n.itemNumberPurgeDesc,
              color: const Color(0xFFFF5555),
            ),
            const SizedBox(height: 8),
            _RewardCard(
              itemType: ItemType.maxKeep,
              icon: Icons.star,
              name: l10n.itemMaxKeep,
              description: l10n.itemMaxKeepDesc,
              color: const Color(0xFFFFD700),
            ),
            const SizedBox(height: 8),
            _RewardCard(
              itemType: ItemType.shuffle,
              icon: Icons.shuffle,
              name: l10n.itemShuffle,
              description: l10n.itemShuffleDesc,
              color: const Color(0xFF55FFFF),
            ),
          ],
        ),
      );
    },
  );
}

class _RewardCard extends StatelessWidget {
  const _RewardCard({
    required this.itemType,
    required this.icon,
    required this.name,
    required this.description,
    required this.color,
  });

  final ItemType itemType;
  final IconData icon;
  final String name;
  final String description;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(6),
        onTap: () => Navigator.of(context).pop(itemType),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: color.withValues(alpha: 0.4),
            ),
          ),
          child: Row(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontFamily: 'PressStart2P',
                        color: color,
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontFamily: 'PressStart2P',
                        color: Colors.white.withValues(alpha: 0.6),
                        fontSize: 6,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
