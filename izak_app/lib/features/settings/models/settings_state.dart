import 'package:flutter/foundation.dart';

@immutable
final class SettingsState {
  const SettingsState({
    this.bgmEnabled = true,
    this.sfxEnabled = true,
    this.vibrationEnabled = true,
    this.showGhost = true,
    this.tutorialSeen = false,
    this.nickname,
    this.isAdFree = false,
  });

  final bool bgmEnabled;
  final bool sfxEnabled;
  final bool vibrationEnabled;
  final bool showGhost;
  final bool tutorialSeen;
  final String? nickname;
  final bool isAdFree;

  SettingsState copyWith({
    bool? bgmEnabled,
    bool? sfxEnabled,
    bool? vibrationEnabled,
    bool? showGhost,
    bool? tutorialSeen,
    String? Function()? nickname,
    bool? isAdFree,
  }) {
    return SettingsState(
      bgmEnabled: bgmEnabled ?? this.bgmEnabled,
      sfxEnabled: sfxEnabled ?? this.sfxEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      showGhost: showGhost ?? this.showGhost,
      tutorialSeen: tutorialSeen ?? this.tutorialSeen,
      nickname: nickname != null ? nickname() : this.nickname,
      isAdFree: isAdFree ?? this.isAdFree,
    );
  }
}
