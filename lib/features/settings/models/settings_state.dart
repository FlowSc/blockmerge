import 'package:flutter/foundation.dart';

@immutable
final class SettingsState {
  const SettingsState({
    this.bgmEnabled = true,
    this.sfxEnabled = true,
    this.vibrationEnabled = true,
    this.showGhost = true,
    this.tutorialSeen = false,
    this.timeAttackTutorialSeen = false,
    this.nickname,
    this.isAdFree = false,
    this.localeCode,
  });

  final bool bgmEnabled;
  final bool sfxEnabled;
  final bool vibrationEnabled;
  final bool showGhost;
  final bool tutorialSeen;
  final bool timeAttackTutorialSeen;
  final String? nickname;
  final bool isAdFree;
  final String? localeCode;

  SettingsState copyWith({
    bool? bgmEnabled,
    bool? sfxEnabled,
    bool? vibrationEnabled,
    bool? showGhost,
    bool? tutorialSeen,
    bool? timeAttackTutorialSeen,
    String? Function()? nickname,
    bool? isAdFree,
    String? Function()? localeCode,
  }) {
    return SettingsState(
      bgmEnabled: bgmEnabled ?? this.bgmEnabled,
      sfxEnabled: sfxEnabled ?? this.sfxEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      showGhost: showGhost ?? this.showGhost,
      tutorialSeen: tutorialSeen ?? this.tutorialSeen,
      timeAttackTutorialSeen:
          timeAttackTutorialSeen ?? this.timeAttackTutorialSeen,
      nickname: nickname != null ? nickname() : this.nickname,
      isAdFree: isAdFree ?? this.isAdFree,
      localeCode: localeCode != null ? localeCode() : this.localeCode,
    );
  }
}
