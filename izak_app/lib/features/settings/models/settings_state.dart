import 'package:flutter/foundation.dart';

@immutable
final class SettingsState {
  const SettingsState({
    this.soundEnabled = true,
    this.vibrationEnabled = true,
    this.showGhost = true,
    this.tutorialSeen = false,
    this.nickname,
    this.isAdFree = false,
  });

  final bool soundEnabled;
  final bool vibrationEnabled;
  final bool showGhost;
  final bool tutorialSeen;
  final String? nickname;
  final bool isAdFree;

  SettingsState copyWith({
    bool? soundEnabled,
    bool? vibrationEnabled,
    bool? showGhost,
    bool? tutorialSeen,
    String? Function()? nickname,
    bool? isAdFree,
  }) {
    return SettingsState(
      soundEnabled: soundEnabled ?? this.soundEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      showGhost: showGhost ?? this.showGhost,
      tutorialSeen: tutorialSeen ?? this.tutorialSeen,
      nickname: nickname != null ? nickname() : this.nickname,
      isAdFree: isAdFree ?? this.isAdFree,
    );
  }
}
