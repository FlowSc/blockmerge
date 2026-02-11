import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _deviceIdKey = 'cached_device_id';

Future<String> getDeviceId() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final String? cached = prefs.getString(_deviceIdKey);
  if (cached != null && cached.isNotEmpty) {
    return cached;
  }

  final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  String id;

  try {
    if (Platform.isIOS) {
      final IosDeviceInfo ios = await deviceInfo.iosInfo;
      id = ios.identifierForVendor ?? _fallbackId();
    } else if (Platform.isAndroid) {
      final AndroidDeviceInfo android = await deviceInfo.androidInfo;
      id = android.id;
    } else {
      id = _fallbackId();
    }
  } catch (_) {
    id = _fallbackId();
  }

  await prefs.setString(_deviceIdKey, id);
  return id;
}

String _fallbackId() {
  return 'device_${DateTime.now().microsecondsSinceEpoch}';
}
