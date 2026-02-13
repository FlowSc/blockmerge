import 'package:flutter/material.dart';

import '../../../core/constants/game_constants.dart';
import '../../../l10n/app_localizations.dart';

/// Shows a dialog with the unique tile values currently on the board.
/// Returns the selected value, or null if cancelled.
Future<int?> showNumberSelectDialog(
  BuildContext context,
  List<List<int?>> grid,
) async {
  final Set<int> values = {};
  for (final List<int?> row in grid) {
    for (final int? v in row) {
      if (v != null) values.add(v);
    }
  }
  if (values.isEmpty) return null;

  final List<int> sorted = values.toList()..sort();

  return showDialog<int>(
    context: context,
    builder: (BuildContext ctx) {
      final l10n = AppLocalizations.of(ctx)!;
      return AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: Text(
          l10n.selectNumberToRemove,
          style: const TextStyle(
            fontFamily: 'PressStart2P',
            color: Colors.white,
            fontSize: 9,
          ),
        ),
        content: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final int value in sorted)
              _NumberChip(value: value),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(null),
            child: Text(
              l10n.cancel,
              style: const TextStyle(
                fontFamily: 'PressStart2P',
                fontSize: 8,
                color: Colors.white70,
              ),
            ),
          ),
        ],
      );
    },
  );
}

class _NumberChip extends StatelessWidget {
  const _NumberChip({required this.value});

  final int value;

  @override
  Widget build(BuildContext context) {
    final Color tileColor =
        GameConstants.tileColors[value] ?? const Color(0xFFFFFFFF);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(4),
        onTap: () => Navigator.of(context).pop(value),
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: tileColor.withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.3),
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            '$value',
            style: const TextStyle(
              fontFamily: 'PressStart2P',
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
