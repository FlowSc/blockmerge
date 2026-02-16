import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/utils/device_id.dart';
import 'models/leaderboard_entry.dart';
import 'repositories/leaderboard_repository.dart';

/// Time period filter for leaderboard queries.
enum LeaderboardPeriod { daily, weekly, monthly, yearly, all }

class LeaderboardScreen extends ConsumerStatefulWidget {
  const LeaderboardScreen({this.initialTab = 0, super.key});

  /// 0 = classic, 1 = time attack.
  final int initialTab;

  @override
  ConsumerState<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends ConsumerState<LeaderboardScreen>
    with SingleTickerProviderStateMixin {
  String? _myDeviceId;
  late final TabController _tabController;
  late final LeaderboardRepository _repository;

  // Per-mode state
  final Map<String, _ModeState> _modeState = {
    'classic': _ModeState(),
    'time_attack': _ModeState(),
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTab,
    );
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
    await Future.wait([
      _loadData('classic'),
      _loadData('time_attack'),
    ]);
  }

  DateTime? _periodAfter(LeaderboardPeriod period) {
    final DateTime now = DateTime.now().toUtc();
    return switch (period) {
      LeaderboardPeriod.daily => DateTime.utc(now.year, now.month, now.day),
      LeaderboardPeriod.weekly => DateTime.utc(now.year, now.month, now.day)
          .subtract(Duration(days: now.weekday - 1)),
      LeaderboardPeriod.monthly => DateTime.utc(now.year, now.month),
      LeaderboardPeriod.yearly => DateTime.utc(now.year),
      LeaderboardPeriod.all => null,
    };
  }

  Future<void> _loadData(String gameMode) async {
    final _ModeState ms = _modeState[gameMode]!;
    setState(() {
      ms.loading = true;
      ms.error = null;
    });
    try {
      final DateTime? after = _periodAfter(ms.period);
      final List<LeaderboardEntry> entries = await _repository.getTopScores(
        gameMode: gameMode,
        after: after,
      );

      LeaderboardEntry? myBest;
      int? myRank;
      if (_myDeviceId != null) {
        myBest = await _repository.getMyBestScore(
          deviceId: _myDeviceId!,
          gameMode: gameMode,
          after: after,
        );
        if (myBest != null) {
          myRank = await _repository.getRank(
            score: myBest.score,
            gameMode: gameMode,
            after: after,
          );
        }
      }

      if (mounted) {
        setState(() {
          ms.entries = entries;
          ms.myBest = myBest;
          ms.myRank = myRank;
          ms.loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          ms.error = e.toString();
          ms.loading = false;
        });
      }
    }
  }

  void _onPeriodChanged(String gameMode, LeaderboardPeriod period) {
    final _ModeState ms = _modeState[gameMode]!;
    if (ms.period == period) return;
    ms.period = period;
    _loadData(gameMode);
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
            fontFamily: 'DungGeunMo',
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
          unselectedLabelStyle: const TextStyle(
            fontFamily: 'DungGeunMo',
            fontSize: 10,
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTab('classic'),
          _buildTab('time_attack'),
        ],
      ),
    );
  }

  Widget _buildTab(String gameMode) {
    final _ModeState ms = _modeState[gameMode]!;
    return Column(
      children: [
        _PeriodSelector(
          selected: ms.period,
          onChanged: (LeaderboardPeriod p) => _onPeriodChanged(gameMode, p),
        ),
        Expanded(
          child: _buildList(
            entries: ms.entries,
            loading: ms.loading,
            error: ms.error,
            onRefresh: () => _loadData(gameMode),
          ),
        ),
        _MyBestBar(entry: ms.myBest, rank: ms.myRank),
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
                fontFamily: 'DungGeunMo',
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 11,
              ),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: onRefresh,
              child: Text(
                l10n.tryAgain,
                style: const TextStyle(
                  fontFamily: 'DungGeunMo',
                  fontSize: 10,
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
            fontFamily: 'DungGeunMo',
            color: Colors.white.withValues(alpha: 0.5),
            fontSize: 10,
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

/// Mutable state holder for each game mode tab.
class _ModeState {
  List<LeaderboardEntry> entries = [];
  bool loading = true;
  String? error;
  LeaderboardEntry? myBest;
  int? myRank;
  LeaderboardPeriod period = LeaderboardPeriod.all;
}

/// Horizontal period selector chips.
class _PeriodSelector extends StatelessWidget {
  const _PeriodSelector({
    required this.selected,
    required this.onChanged,
  });

  final LeaderboardPeriod selected;
  final ValueChanged<LeaderboardPeriod> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final List<(LeaderboardPeriod, String)> periods = [
      (LeaderboardPeriod.daily, l10n.periodDaily),
      (LeaderboardPeriod.weekly, l10n.periodWeekly),
      (LeaderboardPeriod.monthly, l10n.periodMonthly),
      (LeaderboardPeriod.yearly, l10n.periodYearly),
      (LeaderboardPeriod.all, l10n.periodAll),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (int i = 0; i < periods.length; i++) ...[
            if (i > 0) const SizedBox(width: 4),
            _PeriodChip(
              label: periods[i].$2,
              isSelected: selected == periods[i].$1,
              onTap: () => onChanged(periods[i].$1),
            ),
          ],
        ],
      ),
    );
  }
}

class _PeriodChip extends StatelessWidget {
  const _PeriodChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF00E5FF).withValues(alpha: 0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(2),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF00E5FF).withValues(alpha: 0.6)
                : Colors.white.withValues(alpha: 0.15),
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'DungGeunMo',
            fontSize: 8,
            color: isSelected
                ? const Color(0xFF00E5FF)
                : Colors.white.withValues(alpha: 0.5),
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
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
                        fontFamily: 'DungGeunMo',
                        color: Color(0xFF00E5FF),
                        fontSize: 10,
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
                        fontFamily: 'DungGeunMo',
                        color: Color(0xFF00E5FF),
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      entry!.nickname,
                      style: const TextStyle(
                        fontFamily: 'DungGeunMo',
                        color: Color(0xFF00E5FF),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    '${entry!.score}',
                    style: const TextStyle(
                      fontFamily: 'DungGeunMo',
                      color: Color(0xFF00E5FF),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              )
            : Center(
                child: Text(
                  l10n.noRecord,
                  style: TextStyle(
                    fontFamily: 'DungGeunMo',
                    color: Colors.white.withValues(alpha: 0.3),
                    fontSize: 9,
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

    final String? flag = _countryCodeToFlag(entry.country);

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
                fontFamily: 'DungGeunMo',
                color: rankColor,
                fontSize: rank <= 3 ? 14 : 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (flag != null)
                      Padding(
                        padding: const EdgeInsets.only(right: 4),
                        child: Text(flag, style: const TextStyle(fontSize: 14)),
                      ),
                    Flexible(
                      child: Text(
                        entry.nickname,
                        style: TextStyle(
                          fontFamily: 'DungGeunMo',
                          color:
                              isMe ? const Color(0xFFFFD700) : Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (entry.isCleared)
                      Container(
                        margin: const EdgeInsets.only(left: 4),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color:
                              const Color(0xFFFFD700).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(2),
                          border: Border.all(
                            color: const Color(0xFFFFD700)
                                .withValues(alpha: 0.5),
                            width: 0.5,
                          ),
                        ),
                        child: const Text(
                          '2048',
                          style: TextStyle(
                            fontFamily: 'DungGeunMo',
                            color: Color(0xFFFFD700),
                            fontSize: 7,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  l10n.leaderboardEntry(
                    entry.totalMerges,
                    entry.maxChainLevel + 1,
                  ),
                  style: TextStyle(
                    fontFamily: 'DungGeunMo',
                    color: Colors.white.withValues(alpha: 0.4),
                    fontSize: 8,
                  ),
                ),
                if (entry.playTimeSeconds > 0)
                  Text(
                    _formatPlayTime(entry.playTimeSeconds),
                    style: TextStyle(
                      fontFamily: 'DungGeunMo',
                      color: Colors.white.withValues(alpha: 0.3),
                      fontSize: 7,
                    ),
                  ),
              ],
            ),
          ),
          Text(
            '${entry.score}',
            style: TextStyle(
              fontFamily: 'DungGeunMo',
              color: isMe ? const Color(0xFFFFD700) : Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

String _formatPlayTime(int seconds) {
  final int m = seconds ~/ 60;
  final int s = seconds % 60;
  return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
}

/// Converts a 2-letter ISO country code (e.g. "KR") to a flag emoji.
String? _countryCodeToFlag(String? countryCode) {
  if (countryCode == null || countryCode.length != 2) return null;
  final String code = countryCode.toUpperCase();
  const int base = 0x1F1E6 - 0x41; // regional indicator 'A'
  return String.fromCharCodes([
    base + code.codeUnitAt(0),
    base + code.codeUnitAt(1),
  ]);
}
