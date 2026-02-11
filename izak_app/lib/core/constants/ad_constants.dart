import 'dart:io';

abstract final class AdConstants {
  // Test banner ad IDs
  static String get bannerAdUnitId => Platform.isIOS
      ? 'ca-app-pub-3940256099942544/2435281174'
      : 'ca-app-pub-3940256099942544/6300978111';

  // Test interstitial ad IDs
  static String get interstitialAdUnitId => Platform.isIOS
      ? 'ca-app-pub-3940256099942544/4411468910'
      : 'ca-app-pub-3940256099942544/1033173712';

  // In-app purchase product ID
  static const String removeAdsProductId = 'remove_ads';
}
