import 'package:flutter/foundation.dart';

import 'position.dart';

/// Represents the result of a single merge step within a chain.
@immutable
final class MergeStep {
  const MergeStep({
    required this.mergedPairs,
    required this.chainLevel,
    required this.scoreGained,
  });

  /// Each pair: the two positions that merged and the resulting value.
  final List<MergedPair> mergedPairs;

  /// 0-indexed chain level (0 = first merge, 1 = second after gravity, etc.)
  final int chainLevel;

  /// Total score gained from this step (sum of merged values * chain multiplier).
  final int scoreGained;
}

/// A single pair of tiles that merged.
@immutable
final class MergedPair {
  const MergedPair({
    required this.from1,
    required this.from2,
    required this.to,
    required this.newValue,
  });

  final Position from1;
  final Position from2;

  /// The position where the merged tile ends up.
  final Position to;

  /// The value after merging (e.g., 2+2 = 4).
  final int newValue;
}

/// Complete result of a merge chain (all steps until no more merges).
@immutable
final class MergeChainResult {
  const MergeChainResult({
    required this.steps,
    required this.totalScore,
  });

  static const MergeChainResult empty =
      MergeChainResult(steps: [], totalScore: 0);

  final List<MergeStep> steps;
  final int totalScore;

  int get maxChainLevel => steps.isEmpty ? -1 : steps.last.chainLevel;
}
