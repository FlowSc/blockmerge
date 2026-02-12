import 'dart:io';

import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:audio_session/audio_session.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
import 'core/config/supabase_config.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Configure audio session to respect iOS silent switch.
  final AudioSession session = await AudioSession.instance;
  await session.configure(const AudioSessionConfiguration(
    avAudioSessionCategory: AVAudioSessionCategory.ambient,
    avAudioSessionMode: AVAudioSessionMode.defaultMode,
  ));

  await Supabase.initialize(
    url: SupabaseConfig.url,
    anonKey: SupabaseConfig.anonKey,
  );

  // Request ATT permission before initializing ads (iOS only).
  if (Platform.isIOS) {
    final TrackingStatus status =
        await AppTrackingTransparency.trackingAuthorizationStatus;
    if (status == TrackingStatus.notDetermined) {
      await AppTrackingTransparency.requestTrackingAuthorization();
    }

    // Print IDFA for AdMob test device registration.
    final String idfa =
        await AppTrackingTransparency.getAdvertisingIdentifier();
    debugPrint('=== IDFA: $idfa ===');
  }

  await MobileAds.instance.initialize();

  runApp(
    const ProviderScope(
      child: IzakApp(),
    ),
  );
}
