import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/settings_state.dart';

part 'settings_notifier.g.dart';

const String _bgmKey = 'bgm_enabled';
const String _sfxKey = 'sfx_enabled';
const String _vibrationKey = 'vibration_enabled';
const String _ghostKey = 'show_ghost';
const String _tutorialKey = 'tutorial_seen';
const String _timeAttackTutorialKey = 'time_attack_tutorial_seen';
const String _nicknameKey = 'nickname';
const String _adFreeKey = 'ad_free';

// Legacy key for migration from single sound toggle.
const String _legacySoundKey = 'sound_enabled';

@Riverpod(keepAlive: true)
class SettingsNotifier extends _$SettingsNotifier {
  @override
  SettingsState build() {
    _load();
    return const SettingsState();
  }

  Future<void> _load() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    // Migrate legacy "sound_enabled" → bgm + sfx if new keys don't exist yet.
    bool bgm = prefs.getBool(_bgmKey) ?? true;
    bool sfx = prefs.getBool(_sfxKey) ?? true;
    if (!prefs.containsKey(_bgmKey) && prefs.containsKey(_legacySoundKey)) {
      final bool legacy = prefs.getBool(_legacySoundKey) ?? true;
      bgm = legacy;
      sfx = legacy;
      await prefs.setBool(_bgmKey, bgm);
      await prefs.setBool(_sfxKey, sfx);
      await prefs.remove(_legacySoundKey);
    }

    state = SettingsState(
      bgmEnabled: bgm,
      sfxEnabled: sfx,
      vibrationEnabled: prefs.getBool(_vibrationKey) ?? true,
      showGhost: prefs.getBool(_ghostKey) ?? true,
      tutorialSeen: prefs.getBool(_tutorialKey) ?? false,
      timeAttackTutorialSeen:
          prefs.getBool(_timeAttackTutorialKey) ?? false,
      nickname: prefs.getString(_nicknameKey),
      isAdFree: prefs.getBool(_adFreeKey) ?? false,
    );
  }

  Future<void> toggleBgm() async {
    final bool newValue = !state.bgmEnabled;
    state = state.copyWith(bgmEnabled: newValue);
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_bgmKey, newValue);
  }

  Future<void> toggleSfx() async {
    final bool newValue = !state.sfxEnabled;
    state = state.copyWith(sfxEnabled: newValue);
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_sfxKey, newValue);
  }

  Future<void> toggleVibration() async {
    final bool newValue = !state.vibrationEnabled;
    state = state.copyWith(vibrationEnabled: newValue);
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_vibrationKey, newValue);
  }

  Future<void> toggleGhost() async {
    final bool newValue = !state.showGhost;
    state = state.copyWith(showGhost: newValue);
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_ghostKey, newValue);
  }

  Future<void> markTutorialSeen() async {
    state = state.copyWith(tutorialSeen: true);
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_tutorialKey, true);
  }

  Future<void> markTimeAttackTutorialSeen() async {
    state = state.copyWith(timeAttackTutorialSeen: true);
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_timeAttackTutorialKey, true);
  }

  Future<void> setNickname(String nickname) async {
    state = state.copyWith(nickname: () => nickname);
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_nicknameKey, nickname);
  }

  Future<void> setAdFree(bool value) async {
    state = state.copyWith(isAdFree: value);
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_adFreeKey, value);
  }
}
