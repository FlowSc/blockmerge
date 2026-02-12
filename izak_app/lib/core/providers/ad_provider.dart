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
    this.rewardedAd,
    this.isRewardedAdReady = false,
  });

  final BannerAd? bannerAd;
  final bool isBannerLoaded;
  final InterstitialAd? interstitialAd;
  final RewardedAd? rewardedAd;
  final bool isRewardedAdReady;

  AdState copyWith({
    BannerAd? Function()? bannerAd,
    bool? isBannerLoaded,
    InterstitialAd? Function()? interstitialAd,
    RewardedAd? Function()? rewardedAd,
    bool? isRewardedAdReady,
  }) {
    return AdState(
      bannerAd: bannerAd != null ? bannerAd() : this.bannerAd,
      isBannerLoaded: isBannerLoaded ?? this.isBannerLoaded,
      interstitialAd:
          interstitialAd != null ? interstitialAd() : this.interstitialAd,
      rewardedAd: rewardedAd != null ? rewardedAd() : this.rewardedAd,
      isRewardedAdReady: isRewardedAdReady ?? this.isRewardedAdReady,
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
    loadRewardedAd();

    return const AdState();
  }

  void _disposeAds() {
    state.bannerAd?.dispose();
    state.interstitialAd?.dispose();
    state.rewardedAd?.dispose();
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

  void showInterstitial() {
    final bool isAdFree =
        ref.read(settingsNotifierProvider.select((s) => s.isAdFree));
    if (isAdFree) return;

    final InterstitialAd? ad = state.interstitialAd;
    if (ad == null) {
      // Ad not loaded yet — load and show when ready.
      _loadAndShowInterstitial();
      return;
    }

    _showLoadedInterstitial(ad);
  }

  void _showLoadedInterstitial(InterstitialAd ad) {
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (InterstitialAd ad) {
        ad.dispose();
        state = state.copyWith(interstitialAd: () => null);
        loadInterstitialAd();
      },
      onAdFailedToShowFullScreenContent:
          (InterstitialAd ad, AdError error) {
        ad.dispose();
        state = state.copyWith(interstitialAd: () => null);
        loadInterstitialAd();
      },
    );

    ad.show();
  }

  void _loadAndShowInterstitial() {
    InterstitialAd.load(
      adUnitId: AdConstants.interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          state = state.copyWith(interstitialAd: () => ad);
          _showLoadedInterstitial(ad);
        },
        onAdFailedToLoad: (LoadAdError error) {
          // Ad failed to load — silently skip.
          state = state.copyWith(interstitialAd: () => null);
        },
      ),
    );
  }

  void loadRewardedAd() {
    final bool isAdFree =
        ref.read(settingsNotifierProvider.select((s) => s.isAdFree));
    if (isAdFree) return;

    RewardedAd.load(
      adUnitId: AdConstants.rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (RewardedAd ad) {
          state = state.copyWith(
            rewardedAd: () => ad,
            isRewardedAdReady: true,
          );
        },
        onAdFailedToLoad: (LoadAdError error) {
          state = state.copyWith(
            rewardedAd: () => null,
            isRewardedAdReady: false,
          );
        },
      ),
    );
  }

  /// Show rewarded ad. Calls [onRewarded] when the user earns the reward.
  void showRewardedAd({required void Function() onRewarded}) {
    final bool isAdFree =
        ref.read(settingsNotifierProvider.select((s) => s.isAdFree));
    if (isAdFree) {
      onRewarded();
      return;
    }

    final RewardedAd? ad = state.rewardedAd;
    if (ad == null) return;

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (RewardedAd ad) {
        ad.dispose();
        state = state.copyWith(
          rewardedAd: () => null,
          isRewardedAdReady: false,
        );
        loadRewardedAd();
      },
      onAdFailedToShowFullScreenContent: (RewardedAd ad, AdError error) {
        ad.dispose();
        state = state.copyWith(
          rewardedAd: () => null,
          isRewardedAdReady: false,
        );
        loadRewardedAd();
      },
    );

    ad.show(onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
      onRewarded();
    });
  }
}
