import 'package:flutter/foundation.dart';

@immutable
final class LeaderboardEntry {
  const LeaderboardEntry({
    required this.id,
    required this.nickname,
    required this.score,
    required this.deviceId,
    required this.totalMerges,
    required this.maxChainLevel,
    required this.createdAt,
    this.gameMode = 'classic',
  });

  final String id;
  final String nickname;
  final int score;
  final String deviceId;
  final int totalMerges;
  final int maxChainLevel;
  final DateTime createdAt;
  final String gameMode;

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntry(
      id: json['id'] as String,
      nickname: json['nickname'] as String,
      score: json['score'] as int,
      deviceId: json['device_id'] as String,
      totalMerges: (json['total_merges'] as int?) ?? 0,
      maxChainLevel: (json['max_chain_level'] as int?) ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
      gameMode: (json['game_mode'] as String?) ?? 'classic',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nickname': nickname,
      'score': score,
      'device_id': deviceId,
      'total_merges': totalMerges,
      'max_chain_level': maxChainLevel,
      'game_mode': gameMode,
    };
  }
}
