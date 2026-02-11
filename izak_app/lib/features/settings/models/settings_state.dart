import 'package:flutter/foundation.dart';

@immutable
final class SettingsState {
  const SettingsState({
    this.soundEnabled = true,
    this.vibrationEnabled = true,
    this.showGhost = true,
    this.tutorialSeen = false,
  });

  final bool soundEnabled;
  final bool vibrationEnabled;
  final bool showGhost;
  final bool tutorialSeen;

  SettingsState copyWith({
    bool? soundEnabled,
    bool? vibrationEnabled,
    bool? showGhost,
    bool? tutorialSeen,
  }) {
    return SettingsState(
      soundEnabled: soundEnabled ?? this.soundEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      showGhost: showGhost ?? this.showGhost,
      tutorialSeen: tutorialSeen ?? this.tutorialSeen,
    );
  }
}
