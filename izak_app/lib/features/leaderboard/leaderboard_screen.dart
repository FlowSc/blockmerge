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

  LeaderboardEntry? _myClassicBest;
  LeaderboardEntry? _myTimeAttackBest;
  int? _myClassicRank;
  int? _myTimeAttackRank;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _repository = LeaderboardRepository(Supabase.instance.client);
    _init();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _init() async {
    final String id = await getDeviceId();
    if (mounted) {
      setState(() => _myDeviceId = id);
    }
    await Future.wait([_loadClassic(), _loadTimeAttack()]);
  }

  Future<void> _loadClassic() async {
    setState(() {
      _classicLoading = true;
      _classicError = null;
    });
    try {
      final List<LeaderboardEntry> entries =
          await _repository.getTopScores(gameMode: 'classic');

      LeaderboardEntry? myBest;
      int? myRank;
      if (_myDeviceId != null) {
        myBest = await _repository.getMyBestScore(
          deviceId: _myDeviceId!,
          gameMode: 'classic',
        );
        if (myBest != null) {
          myRank = await _repository.getRank(
            score: myBest.score,
            gameMode: 'classic',
          );
        }
      }

      if (mounted) {
        setState(() {
          _classicEntries = entries;
          _myClassicBest = myBest;
          _myClassicRank = myRank;
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

      LeaderboardEntry? myBest;
      int? myRank;
      if (_myDeviceId != null) {
        myBest = await _repository.getMyBestScore(
          deviceId: _myDeviceId!,
          gameMode: 'time_attack',
        );
        if (myBest != null) {
          myRank = await _repository.getRank(
            score: myBest.score,
            gameMode: 'time_attack',
          );
        }
      }

      if (mounted) {
        setState(() {
          _timeAttackEntries = entries;
          _myTimeAttackBest = myBest;
          _myTimeAttackRank = myRank;
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
          labelStyle: const TextStyle(
            fontFamily: 'PressStart2P',
            fontSize: 8,
            fontWeight: FontWeight.bold,
          ),
          unselectedLabelStyle: const TextStyle(
            fontFamily: 'PressStart2P',
            fontSize: 8,
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTab(
            entries: _classicEntries,
            loading: _classicLoading,
            error: _classicError,
            onRefresh: _loadClassic,
            myBest: _myClassicBest,
            myRank: _myClassicRank,
          ),
          _buildTab(
            entries: _timeAttackEntries,
            loading: _timeAttackLoading,
            error: _timeAttackError,
            onRefresh: _loadTimeAttack,
            myBest: _myTimeAttackBest,
            myRank: _myTimeAttackRank,
          ),
        ],
      ),
    );
  }

  Widget _buildTab({
    required List<LeaderboardEntry> entries,
    required bool loading,
    required String? error,
    required Future<void> Function() onRefresh,
    required LeaderboardEntry? myBest,
    required int? myRank,
  }) {
    return Column(
      children: [
        Expanded(
          child: _buildList(
            entries: entries,
            loading: loading,
            error: error,
            onRefresh: onRefresh,
          ),
        ),
        _MyBestBar(entry: myBest, rank: myRank),
      ],
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
                fontFamily: 'PressStart2P',
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 9,
              ),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: onRefresh,
              child: Text(
                l10n.tryAgain,
                style: const TextStyle(
                  fontFamily: 'PressStart2P',
                  fontSize: 8,
                ),
              ),
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
            fontFamily: 'PressStart2P',
            color: Colors.white.withValues(alpha: 0.5),
            fontSize: 8,
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

class _MyBestBar extends StatelessWidget {
  const _MyBestBar({required this.entry, required this.rank});

  final LeaderboardEntry? entry;
  final int? rank;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C3A),
        border: Border(
          top: BorderSide(
            color: const Color(0xFF00E5FF).withValues(alpha: 0.4),
            width: 1,
          ),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: SafeArea(
        top: false,
        child: entry != null
            ? Row(
                children: [
                  SizedBox(
                    width: 36,
                    child: Text(
                      rank != null ? '#$rank' : '-',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'PressStart2P',
                        color: Color(0xFF00E5FF),
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00E5FF).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: Text(
                      l10n.myBest,
                      style: const TextStyle(
                        fontFamily: 'PressStart2P',
                        color: Color(0xFF00E5FF),
                        fontSize: 6,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      entry!.nickname,
                      style: const TextStyle(
                        fontFamily: 'PressStart2P',
                        color: Color(0xFF00E5FF),
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    '${entry!.score}',
                    style: const TextStyle(
                      fontFamily: 'PressStart2P',
                      color: Color(0xFF00E5FF),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              )
            : Center(
                child: Text(
                  l10n.noRecord,
                  style: TextStyle(
                    fontFamily: 'PressStart2P',
                    color: Colors.white.withValues(alpha: 0.3),
                    fontSize: 7,
                  ),
                ),
              ),
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
                    fontFamily: 'PressStart2P',
                    color: Colors.white.withValues(alpha: 0.4),
                    fontSize: 6,
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
