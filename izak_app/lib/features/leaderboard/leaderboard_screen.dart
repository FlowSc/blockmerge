import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/utils/device_id.dart';
import 'models/leaderboard_entry.dart';
import 'repositories/leaderboard_repository.dart';

class LeaderboardScreen extends ConsumerStatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  ConsumerState<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends ConsumerState<LeaderboardScreen>
    with SingleTickerProviderStateMixin {
  String? _myDeviceId;
  late final TabController _tabController;
  late final LeaderboardRepository _repository;

  List<LeaderboardEntry> _classicEntries = [];
  List<LeaderboardEntry> _timeAttackEntries = [];
  bool _classicLoading = true;
  bool _timeAttackLoading = true;
  String? _classicError;
  String? _timeAttackError;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _repository = LeaderboardRepository(Supabase.instance.client);
    _loadDeviceId();
    _loadClassic();
    _loadTimeAttack();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadDeviceId() async {
    final String id = await getDeviceId();
    if (mounted) {
      setState(() => _myDeviceId = id);
    }
  }

  Future<void> _loadClassic() async {
    setState(() {
      _classicLoading = true;
      _classicError = null;
    });
    try {
      final List<LeaderboardEntry> entries =
          await _repository.getTopScores(gameMode: 'classic');
      if (mounted) {
        setState(() {
          _classicEntries = entries;
          _classicLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _classicError = e.toString();
          _classicLoading = false;
        });
      }
    }
  }

  Future<void> _loadTimeAttack() async {
    setState(() {
      _timeAttackLoading = true;
      _timeAttackError = null;
    });
    try {
      final List<LeaderboardEntry> entries =
          await _repository.getTopScores(gameMode: 'time_attack');
      if (mounted) {
        setState(() {
          _timeAttackEntries = entries;
          _timeAttackLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _timeAttackError = e.toString();
          _timeAttackLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.leaderboard),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: l10n.classic),
            Tab(text: l10n.timeAttack),
          ],
          indicatorColor: const Color(0xFFFFD700),
          labelColor: const Color(0xFFFFD700),
          unselectedLabelColor: Colors.white54,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildList(
            entries: _classicEntries,
            loading: _classicLoading,
            error: _classicError,
            onRefresh: _loadClassic,
          ),
          _buildList(
            entries: _timeAttackEntries,
            loading: _timeAttackLoading,
            error: _timeAttackError,
            onRefresh: _loadTimeAttack,
          ),
        ],
      ),
    );
  }

  Widget _buildList({
    required List<LeaderboardEntry> entries,
    required bool loading,
    required String? error,
    required Future<void> Function() onRefresh,
  }) {
    final l10n = AppLocalizations.of(context)!;

    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.white38),
            const SizedBox(height: 12),
            Text(
              l10n.loadFailed,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: onRefresh,
              child: Text(l10n.tryAgain),
            ),
          ],
        ),
      );
    }

    if (entries.isEmpty) {
      return Center(
        child: Text(
          l10n.noRecords,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.5),
            fontSize: 16,
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
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
    final l10n = AppLocalizations.of(context)!;
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
        borderRadius: BorderRadius.circular(2),
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
                fontFamily: 'PressStart2P',
                color: rankColor,
                fontSize: rank <= 3 ? 12 : 10,
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
                    fontFamily: 'PressStart2P',
                    color: isMe ? const Color(0xFFFFD700) : Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  l10n.leaderboardEntry(
                    entry.totalMerges,
                    entry.maxChainLevel + 1,
                  ),
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
              fontFamily: 'PressStart2P',
              color: isMe ? const Color(0xFFFFD700) : Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
