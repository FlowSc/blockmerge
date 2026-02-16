import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/leaderboard_entry.dart';

class LeaderboardRepository {
  LeaderboardRepository(this._client);

  final SupabaseClient _client;

  Future<List<LeaderboardEntry>> getTopScores({
    int limit = 100,
    String gameMode = 'classic',
    DateTime? after,
  }) async {
    var query = _client
        .from('leaderboard')
        .select()
        .eq('game_mode', gameMode);

    if (after != null) {
      query = query.gte('created_at', after.toUtc().toIso8601String());
    }

    final List<Map<String, dynamic>> data = await query
        .order('score', ascending: false)
        .limit(limit);

    return data.map(LeaderboardEntry.fromJson).toList();
  }

  /// Returns the user's best score entry for the given game mode, or null.
  Future<LeaderboardEntry?> getMyBestScore({
    required String deviceId,
    String gameMode = 'classic',
    DateTime? after,
  }) async {
    var query = _client
        .from('leaderboard')
        .select()
        .eq('device_id', deviceId)
        .eq('game_mode', gameMode);

    if (after != null) {
      query = query.gte('created_at', after.toUtc().toIso8601String());
    }

    final List<Map<String, dynamic>> data = await query
        .order('score', ascending: false)
        .limit(1);

    if (data.isEmpty) return null;
    return LeaderboardEntry.fromJson(data.first);
  }

  /// Returns the rank (1-based) of a given score in the leaderboard.
  Future<int> getRank({
    required int score,
    String gameMode = 'classic',
    DateTime? after,
  }) async {
    var query = _client
        .from('leaderboard')
        .select('id')
        .eq('game_mode', gameMode)
        .gt('score', score);

    if (after != null) {
      query = query.gte('created_at', after.toUtc().toIso8601String());
    }

    final List<Map<String, dynamic>> data = await query;

    return data.length + 1;
  }

  Future<void> submitScore({
    required String nickname,
    required int score,
    required String deviceId,
    required int totalMerges,
    required int maxChainLevel,
    String gameMode = 'classic',
    bool isCleared = false,
    String? country,
    int playTimeSeconds = 0,
  }) async {
    await _client.from('leaderboard').insert({
      'nickname': nickname,
      'score': score,
      'device_id': deviceId,
      'total_merges': totalMerges,
      'max_chain_level': maxChainLevel,
      'game_mode': gameMode,
      'is_cleared': isCleared,
      'country': country,
      'play_time_seconds': playTimeSeconds,
    });
  }
}
