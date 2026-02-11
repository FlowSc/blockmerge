import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/settings/providers/settings_notifier.dart';
// import '../constants/ad_constants.dart';

part 'ad_provider.g.dart';

// TODO: AdMob 설정 후 _kAdsEnabled를 true로 변경
const bool _kAdsEnabled = false;

@immutable
final class AdState {
  const AdState({
    this.bannerAd,
    this.isBannerLoaded = false,
    this.interstitialAd,
  });

  final BannerAd? bannerAd;
  final bool isBannerLoaded;
  final InterstitialAd? interstitialAd;

  AdState copyWith({
    BannerAd? Function()? bannerAd,
    bool? isBannerLoaded,
    InterstitialAd? Function()? interstitialAd,
  }) {
    return AdState(
      bannerAd: bannerAd != null ? bannerAd() : this.bannerAd,
      isBannerLoaded: isBannerLoaded ?? this.isBannerLoaded,
      interstitialAd:
          interstitialAd != null ? interstitialAd() : this.interstitialAd,
    );
  }
}

@Riverpod(keepAlive: true)
class AdNotifier extends _$AdNotifier {
  @override
  AdState build() {
    if (!_kAdsEnabled) return const AdState();

    final bool isAdFree =
        ref.watch(settingsNotifierProvider.select((s) => s.isAdFree));

    if (isAdFree) {
      return const AdState();
    }

    ref.onDispose(_disposeAds);

    loadBannerAd();
    loadInterstitialAd();

    return const AdState();
  }

  void _disposeAds() {
    state.bannerAd?.dispose();
    state.interstitialAd?.dispose();
  }

  void loadBannerAd() {
    if (!_kAdsEnabled) return;
    // final bool isAdFree =
    //     ref.read(settingsNotifierProvider.select((s) => s.isAdFree));
    // if (isAdFree) return;
    //
    // final BannerAd banner = BannerAd(
    //   adUnitId: AdConstants.bannerAdUnitId,
    //   size: AdSize.banner,
    //   request: const AdRequest(),
    //   listener: BannerAdListener(
    //     onAdLoaded: (Ad ad) {
    //       state = state.copyWith(
    //         bannerAd: () => ad as BannerAd,
    //         isBannerLoaded: true,
    //       );
    //     },
    //     onAdFailedToLoad: (Ad ad, LoadAdError error) {
    //       ad.dispose();
    //       state = state.copyWith(
    //         bannerAd: () => null,
    //         isBannerLoaded: false,
    //       );
    //     },
    //   ),
    // );
    //
    // banner.load();
  }

  void loadInterstitialAd() {
    if (!_kAdsEnabled) return;
    // final bool isAdFree =
    //     ref.read(settingsNotifierProvider.select((s) => s.isAdFree));
    // if (isAdFree) return;
    //
    // InterstitialAd.load(
    //   adUnitId: AdConstants.interstitialAdUnitId,
    //   request: const AdRequest(),
    //   adLoadCallback: InterstitialAdLoadCallback(
    //     onAdLoaded: (InterstitialAd ad) {
    //       state = state.copyWith(interstitialAd: () => ad);
    //     },
    //     onAdFailedToLoad: (LoadAdError error) {
    //       state = state.copyWith(interstitialAd: () => null);
    //     },
    //   ),
    // );
  }

  void showInterstitial() {
    if (!_kAdsEnabled) return;
    // final bool isAdFree =
    //     ref.read(settingsNotifierProvider.select((s) => s.isAdFree));
    // if (isAdFree) return;
    //
    // final InterstitialAd? ad = state.interstitialAd;
    // if (ad == null) return;
    //
    // ad.fullScreenContentCallback = FullScreenContentCallback(
    //   onAdDismissedFullScreenContent: (InterstitialAd ad) {
    //     ad.dispose();
    //     state = state.copyWith(interstitialAd: () => null);
    //     loadInterstitialAd();
    //   },
    //   onAdFailedToShowFullScreenContent:
    //       (InterstitialAd ad, AdError error) {
    //     ad.dispose();
    //     state = state.copyWith(interstitialAd: () => null);
    //     loadInterstitialAd();
    //   },
    // );
    //
    // ad.show();
  }
}
