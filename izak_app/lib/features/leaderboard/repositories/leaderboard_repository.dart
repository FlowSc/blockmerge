import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/leaderboard_entry.dart';

class LeaderboardRepository {
  LeaderboardRepository(this._client);

  final SupabaseClient _client;

  Future<List<LeaderboardEntry>> getTopScores({
    int limit = 100,
    String gameMode = 'classic',
  }) async {
    final List<Map<String, dynamic>> data = await _client
        .from('leaderboard')
        .select()
        .eq('game_mode', gameMode)
        .order('score', ascending: false)
        .limit(limit);

    return data.map(LeaderboardEntry.fromJson).toList();
  }

  Future<void> submitScore({
    required String nickname,
    required int score,
    required String deviceId,
    required int totalMerges,
    required int maxChainLevel,
    String gameMode = 'classic',
  }) async {
    await _client.from('leaderboard').insert({
      'nickname': nickname,
      'score': score,
      'device_id': deviceId,
      'total_merges': totalMerges,
      'max_chain_level': maxChainLevel,
      'game_mode': gameMode,
    });
  }
}
