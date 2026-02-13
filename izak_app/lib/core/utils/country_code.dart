import 'dart:io';

/// Returns the device's country code (e.g. "KR", "US") from the platform locale.
/// Falls back to null if it cannot be determined.
String? getCountryCode() {
  try {
    final String localeName = Platform.localeName; // e.g. "ko_KR", "en_US"
    final List<String> parts = localeName.replaceAll('-', '_').split('_');
    if (parts.length >= 2) {
      return parts.last.toUpperCase();
    }
    return null;
  } catch (_) {
    return null;
  }
}
