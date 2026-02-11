import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/device_id.dart';
import 'models/leaderboard_entry.dart';
import 'providers/leaderboard_notifier.dart';

class LeaderboardScreen extends ConsumerStatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  ConsumerState<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends ConsumerState<LeaderboardScreen> {
  String? _myDeviceId;

  @override
  void initState() {
    super.initState();
    _loadDeviceId();
  }

  Future<void> _loadDeviceId() async {
    final String id = await getDeviceId();
    if (mounted) {
      setState(() => _myDeviceId = id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<List<LeaderboardEntry>> entriesAsync =
        ref.watch(leaderboardNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('리더보드'),
      ),
      body: entriesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object error, StackTrace stack) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.white38),
              const SizedBox(height: 12),
              Text(
                '불러오기 실패',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () =>
                    ref.read(leaderboardNotifierProvider.notifier).loadTopScores(),
                child: const Text('다시 시도'),
              ),
            ],
          ),
        ),
        data: (List<LeaderboardEntry> entries) {
          if (entries.isEmpty) {
            return Center(
              child: Text(
                '아직 기록이 없습니다',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 16,
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () =>
                ref.read(leaderboardNotifierProvider.notifier).loadTopScores(),
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: entries.length,
              itemBuilder: (BuildContext context, int index) {
                final LeaderboardEntry entry = entries[index];
                final bool isMe =
                    _myDeviceId != null && entry.deviceId == _myDeviceId;
                return _LeaderboardTile(
                  rank: index + 1,
                  entry: entry,
                  isMe: isMe,
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _LeaderboardTile extends StatelessWidget {
  const _LeaderboardTile({
    required this.rank,
    required this.entry,
    required this.isMe,
  });

  final int rank;
  final LeaderboardEntry entry;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    final Color rankColor = switch (rank) {
      1 => const Color(0xFFFFD700),
      2 => const Color(0xFFC0C0C0),
      3 => const Color(0xFFCD7F32),
      _ => Colors.white38,
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isMe
            ? const Color(0xFFFFD700).withValues(alpha: 0.1)
            : Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(10),
        border: isMe
            ? Border.all(
                color: const Color(0xFFFFD700).withValues(alpha: 0.3),
              )
            : null,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 36,
            child: Text(
              '$rank',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: rankColor,
                fontSize: rank <= 3 ? 20 : 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.nickname,
                  style: TextStyle(
                    color: isMe ? const Color(0xFFFFD700) : Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Merges: ${entry.totalMerges} | Chain: x${entry.maxChainLevel + 1}',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.4),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${entry.score}',
            style: TextStyle(
              color: isMe ? const Color(0xFFFFD700) : Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
