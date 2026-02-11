import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/settings_state.dart';

part 'settings_notifier.g.dart';

const String _soundKey = 'sound_enabled';
const String _vibrationKey = 'vibration_enabled';
const String _ghostKey = 'show_ghost';
const String _tutorialKey = 'tutorial_seen';
const String _nicknameKey = 'nickname';
const String _adFreeKey = 'ad_free';

@Riverpod(keepAlive: true)
class SettingsNotifier extends _$SettingsNotifier {
  @override
  SettingsState build() {
    _load();
    return const SettingsState();
  }

  Future<void> _load() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    state = SettingsState(
      soundEnabled: prefs.getBool(_soundKey) ?? true,
      vibrationEnabled: prefs.getBool(_vibrationKey) ?? true,
      showGhost: prefs.getBool(_ghostKey) ?? true,
      tutorialSeen: prefs.getBool(_tutorialKey) ?? false,
      nickname: prefs.getString(_nicknameKey),
      isAdFree: prefs.getBool(_adFreeKey) ?? false,
    );
  }

  Future<void> toggleSound() async {
    final bool newValue = !state.soundEnabled;
    state = state.copyWith(soundEnabled: newValue);
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_soundKey, newValue);
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
