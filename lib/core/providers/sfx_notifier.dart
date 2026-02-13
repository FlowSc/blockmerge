import 'dart:async';
import 'dart:math';

import 'package:just_audio/just_audio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/settings/providers/settings_notifier.dart';

part 'sfx_notifier.g.dart';

/// Pre-loaded sound effect player that only needs seek+play on each use.
class _SfxPlayer {
  _SfxPlayer(this._player);

  final AudioPlayer _player;
  bool _ready = false;

  Future<void> load(String asset) async {
    await _player.setAsset(asset);
    await _player.setVolume(0.6);
    _ready = true;
  }

  void play() {
    if (!_ready) return;
    // seek to start and play — no asset reload needed.
    _player.seek(Duration.zero).then((_) => _player.play());
  }

  void dispose() {
    _player.dispose();
  }
}

@Riverpod(keepAlive: true)
class SfxNotifier extends _$SfxNotifier {
  /// Two players per merge sound for overlapping playback.
  static const int _playersPerSound = 2;

  /// merge_1~9 × 2 players + drop × 2 players = 20 players total.
  final Map<String, List<_SfxPlayer>> _players = {};
  final Map<String, int> _roundRobin = {};
  final Random _rng = Random();
  bool _loaded = false;

  @override
  void build() {
    ref.onDispose(_dispose);
    // Pre-load all assets in background on first build.
    _preload();
  }

  void _preload() {
    runZonedGuarded(() async {
      final List<String> assets = [
        for (int i = 1; i <= 9; i++) 'assets/sfx/merge_$i.ogg',
        'assets/sfx/drop.ogg',
      ];

      for (final String asset in assets) {
        final List<_SfxPlayer> pool = [];
        for (int i = 0; i < _playersPerSound; i++) {
          final _SfxPlayer sfx = _SfxPlayer(AudioPlayer());
          await sfx.load(asset);
          pool.add(sfx);
        }
        _players[asset] = pool;
        _roundRobin[asset] = 0;
      }

      _loaded = true;
    }, (Object _, StackTrace __) {
      // Silently ignore preload errors (e.g. in tests).
    });
  }

  /// Play a merge sound effect. Higher [chainLevel] picks a more dramatic sound.
  /// chainLevel 0 → merge_1~3, 1 → merge_4~6, 2+ → merge_7~9.
  void playMerge(int chainLevel) {
    if (!_loaded) return;
    final bool sfxEnabled = ref.read(settingsNotifierProvider).sfxEnabled;
    if (!sfxEnabled) return;

    final int group = chainLevel.clamp(0, 2);
    final int index = group * 3 + _rng.nextInt(3) + 1;
    _play('assets/sfx/merge_$index.ogg');
  }

  /// Play a drop sound effect when a block lands on the board.
  void playDrop() {
    if (!_loaded) return;
    final bool sfxEnabled = ref.read(settingsNotifierProvider).sfxEnabled;
    if (!sfxEnabled) return;

    _play('assets/sfx/drop.ogg');
  }

  void _play(String asset) {
    final List<_SfxPlayer>? pool = _players[asset];
    if (pool == null || pool.isEmpty) return;

    final int idx = _roundRobin[asset] ?? 0;
    pool[idx].play();
    _roundRobin[asset] = (idx + 1) % pool.length;
  }

  void _dispose() {
    for (final List<_SfxPlayer> pool in _players.values) {
      for (final _SfxPlayer sfx in pool) {
        sfx.dispose();
      }
    }
    _players.clear();
    _roundRobin.clear();
    _loaded = false;
  }
}
