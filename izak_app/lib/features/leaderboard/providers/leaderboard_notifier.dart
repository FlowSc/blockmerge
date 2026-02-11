import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/leaderboard_entry.dart';
import '../repositories/leaderboard_repository.dart';

part 'leaderboard_notifier.g.dart';

@riverpod
class LeaderboardNotifier extends _$LeaderboardNotifier {
  late final LeaderboardRepository _repository;

  @override
  FutureOr<List<LeaderboardEntry>> build() {
    _repository = LeaderboardRepository(Supabase.instance.client);
    return _repository.getTopScores();
  }

  Future<void> loadTopScores() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repository.getTopScores());
  }

  Future<void> submitScore({
    required String nickname,
    required int score,
    required String deviceId,
    required int totalMerges,
    required int maxChainLevel,
  }) async {
    await _repository.submitScore(
      nickname: nickname,
      score: score,
      deviceId: deviceId,
      totalMerges: totalMerges,
      maxChainLevel: maxChainLevel,
    );
    await loadTopScores();
  }
}
