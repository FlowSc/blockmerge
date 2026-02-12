import 'dart:async';

import 'package:just_audio/just_audio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/settings/providers/settings_notifier.dart';

part 'bgm_notifier.g.dart';

const List<String> _bgmAssets = [
  'assets/music/bgm_1.mp3',
  'assets/music/bgm_2.mp3',
  'assets/music/bgm_3.mp3',
];

@Riverpod(keepAlive: true)
class BgmNotifier extends _$BgmNotifier {
  AudioPlayer? _player;

  @override
  void build() {
    ref.onDispose(_dispose);

    ref.listen<bool>(
      settingsNotifierProvider.select((s) => s.bgmEnabled),
      (bool? prev, bool next) {
        _onBgmSettingChanged(next);
      },
    );

    // Start playing immediately if bgm is enabled.
    final bool bgmEnabled = ref.read(settingsNotifierProvider).bgmEnabled;
    if (bgmEnabled) {
      _play();
    }
  }

  void _onBgmSettingChanged(bool enabled) {
    if (enabled) {
      _play();
    } else {
      _pause();
    }
  }

  void _play() {
    runZonedGuarded(() async {
      final AudioPlayer player = await _ensurePlayer();
      if (!player.playing) {
        await player.play();
      }
    }, (Object _, StackTrace __) {
      // Silently ignore playback errors.
    });
  }

  Future<AudioPlayer> _ensurePlayer() async {
    if (_player != null) return _player!;

    final AudioPlayer player = AudioPlayer();
    await player.setAudioSource(
      ConcatenatingAudioSource(
        children: [
          for (final String path in _bgmAssets) AudioSource.asset(path),
        ],
      ),
    );
    await player.setLoopMode(LoopMode.all);
    await player.setVolume(0.3);
    _player = player;
    return player;
  }

  void _pause() {
    _player?.pause();
  }

  void _dispose() {
    _player?.dispose();
    _player = null;
  }
}
