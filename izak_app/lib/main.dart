import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:google_mobile_ads/google_mobile_ads.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // TODO: Supabase 설정 후 주석 해제
  // await Supabase.initialize(
  //   url: 'https://YOUR_PROJECT_REF.supabase.co',
  //   anonKey: 'YOUR_ANON_KEY',
  // );

  // TODO: AdMob 설정 후 주석 해제
  // await MobileAds.instance.initialize();

  runApp(
    const ProviderScope(
      child: IzakApp(),
    ),
  );
}
