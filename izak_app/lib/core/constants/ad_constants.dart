import 'dart:io';

abstract final class AdConstants {
  static String get bannerAdUnitId => Platform.isIOS
      ? 'ca-app-pub-9212649214874133/2317703114'
      : 'ca-app-pub-3940256099942544/6300978111'; // Android: test ID

  static String get interstitialAdUnitId => Platform.isIOS
      ? 'ca-app-pub-9212649214874133/2397603901'
      : 'ca-app-pub-3940256099942544/1033173712'; // Android: test ID

  // TODO: Replace iOS rewarded ad unit ID after creating it in AdMob console
  static String get rewardedAdUnitId => Platform.isIOS
      ? 'ca-app-pub-9212649214874133/8039498104'
      : 'ca-app-pub-3940256099942544/5224354917'; // Android: test ID

  static const String removeAdsProductId = 'remove_ads';
}
