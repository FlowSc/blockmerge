import 'dart:convert';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../game/models/item_type.dart';
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
const String _itemCountsKey = 'item_counts';

// Legacy key for migration from single sound toggle.
const String _legacySoundKey = 'sound_enabled';

/// Default item counts for first-time users.
const Map<String, int> _defaultItemCounts = {
  'numberPurge': 3,
  'maxKeep': 3,
  'shuffle': 3,
};

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

    // Load item counts (first launch → default 3 each).
    Map<String, int> itemCounts;
    final String? itemCountsRaw = prefs.getString(_itemCountsKey);
    if (itemCountsRaw != null) {
      final Map<String, dynamic> decoded =
          jsonDecode(itemCountsRaw) as Map<String, dynamic>;
      itemCounts = decoded.map((String k, dynamic v) => MapEntry(k, v as int));
    } else {
      itemCounts = Map<String, int>.from(_defaultItemCounts);
      await prefs.setString(_itemCountsKey, jsonEncode(itemCounts));
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
      itemCounts: itemCounts,
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

  /// Add [count] items of [type] to the inventory.
  Future<void> addItem(ItemType type, int count) async {
    final Map<String, int> updated = Map<String, int>.from(state.itemCounts);
    updated[type.name] = (updated[type.name] ?? 0) + count;
    state = state.copyWith(itemCounts: updated);
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_itemCountsKey, jsonEncode(updated));
  }

  /// Consume one item of [type]. Returns false if none available.
  Future<bool> useItem(ItemType type) async {
    final int current = state.itemCounts[type.name] ?? 0;
    if (current <= 0) return false;

    final Map<String, int> updated = Map<String, int>.from(state.itemCounts);
    updated[type.name] = current - 1;
    state = state.copyWith(itemCounts: updated);
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_itemCountsKey, jsonEncode(updated));
    return true;
  }

  /// Get the current count for [type].
  int getItemCount(ItemType type) {
    return state.itemCounts[type.name] ?? 0;
  }
}
