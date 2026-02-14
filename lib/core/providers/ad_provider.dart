import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/settings/providers/settings_notifier.dart';
import '../constants/ad_constants.dart';

part 'ad_provider.g.dart';

@immutable
final class AdState {
  const AdState({
    this.bannerAd,
    this.isBannerLoaded = false,
    this.interstitialAd,
    this.lastInterstitialShown,
  });

  final BannerAd? bannerAd;
  final bool isBannerLoaded;
  final InterstitialAd? interstitialAd;
  final DateTime? lastInterstitialShown;

  AdState copyWith({
    BannerAd? Function()? bannerAd,
    bool? isBannerLoaded,
    InterstitialAd? Function()? interstitialAd,
    DateTime? Function()? lastInterstitialShown,
  }) {
    return AdState(
      bannerAd: bannerAd != null ? bannerAd() : this.bannerAd,
      isBannerLoaded: isBannerLoaded ?? this.isBannerLoaded,
      interstitialAd:
          interstitialAd != null ? interstitialAd() : this.interstitialAd,
      lastInterstitialShown: lastInterstitialShown != null
          ? lastInterstitialShown()
          : this.lastInterstitialShown,
    );
  }
}

@Riverpod(keepAlive: true)
class AdNotifier extends _$AdNotifier {
  @override
  AdState build() {
    final bool isAdFree =
        ref.watch(settingsNotifierProvider.select((s) => s.isAdFree));

    if (isAdFree) {
      return const AdState();
    }

    ref.onDispose(_disposeAds);

    // Banner ad is loaded from BannerAdWidget with adaptive size.
    loadInterstitialAd();

    return const AdState();
  }

  void _disposeAds() {
    state.bannerAd?.dispose();
    state.interstitialAd?.dispose();
  }

  void loadBannerAd({AdSize? adSize}) {
    final bool isAdFree =
        ref.read(settingsNotifierProvider.select((s) => s.isAdFree));
    if (isAdFree) return;

    final AdSize size = adSize ?? AdSize.banner;

    final BannerAd banner = BannerAd(
      adUnitId: AdConstants.bannerAdUnitId,
      size: size,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) {
          state = state.copyWith(
            bannerAd: () => ad as BannerAd,
            isBannerLoaded: true,
          );
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          ad.dispose();
          state = state.copyWith(
            bannerAd: () => null,
            isBannerLoaded: false,
          );
        },
      ),
    );

    banner.load();
  }

  void loadInterstitialAd() {
    final bool isAdFree =
        ref.read(settingsNotifierProvider.select((s) => s.isAdFree));
    if (isAdFree) return;

    InterstitialAd.load(
      adUnitId: AdConstants.interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          state = state.copyWith(interstitialAd: () => ad);
        },
        onAdFailedToLoad: (LoadAdError error) {
          state = state.copyWith(interstitialAd: () => null);
        },
      ),
    );
  }

  /// Minimum interval between interstitial ads (seconds).
  static const int _interstitialCooldownSeconds = 60;

  /// Show an interstitial ad if cooldown has passed.
  /// [onComplete] is called after the ad is dismissed, fails, or is skipped.
  void showInterstitial({VoidCallback? onComplete}) {
    final bool isAdFree =
        ref.read(settingsNotifierProvider.select((s) => s.isAdFree));
    if (isAdFree) {
      onComplete?.call();
      return;
    }

    // Enforce cooldown — skip if shown recently.
    final DateTime? lastShown = state.lastInterstitialShown;
    if (lastShown != null &&
        DateTime.now().difference(lastShown).inSeconds <
            _interstitialCooldownSeconds) {
      onComplete?.call();
      return;
    }

    final InterstitialAd? ad = state.interstitialAd;
    if (ad == null) {
      // Ad not loaded yet — load and show when ready.
      _loadAndShowInterstitial(onComplete: onComplete);
      return;
    }

    _showLoadedInterstitial(ad, onComplete: onComplete);
  }

  void _showLoadedInterstitial(InterstitialAd ad,
      {VoidCallback? onComplete}) {
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (InterstitialAd ad) {
        // Set cooldown only after ad is actually displayed.
        state = state.copyWith(
          lastInterstitialShown: () => DateTime.now(),
        );
      },
      onAdDismissedFullScreenContent: (InterstitialAd ad) {
        ad.dispose();
        state = state.copyWith(interstitialAd: () => null);
        loadInterstitialAd();
        onComplete?.call();
      },
      onAdFailedToShowFullScreenContent:
          (InterstitialAd ad, AdError error) {
        ad.dispose();
        state = state.copyWith(interstitialAd: () => null);
        loadInterstitialAd();
        onComplete?.call();
      },
    );

    ad.show();
  }

  void _loadAndShowInterstitial({VoidCallback? onComplete}) {
    InterstitialAd.load(
      adUnitId: AdConstants.interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          state = state.copyWith(interstitialAd: () => ad);
          _showLoadedInterstitial(ad, onComplete: onComplete);
        },
        onAdFailedToLoad: (LoadAdError error) {
          // Ad failed to load — silently skip.
          state = state.copyWith(interstitialAd: () => null);
          onComplete?.call();
        },
      ),
    );
  }

  // Rewarded ads are currently disabled.
  // void loadRewardedAd() { ... }
  // void showRewardedAd({required void Function() onRewarded}) { ... }
}
