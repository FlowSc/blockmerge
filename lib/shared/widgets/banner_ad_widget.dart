import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../core/providers/ad_provider.dart';
import '../../features/settings/providers/settings_notifier.dart';

class BannerAdWidget extends ConsumerStatefulWidget {
  const BannerAdWidget({super.key});

  @override
  ConsumerState<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends ConsumerState<BannerAdWidget> {
  bool _adRequested = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_adRequested) {
      _adRequested = true;
      _loadAdaptiveBanner();
    }
  }

  Future<void> _loadAdaptiveBanner() async {
    final int width = MediaQuery.of(context).size.width.truncate();
    final AnchoredAdaptiveBannerAdSize? adSize =
        await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(width);
    if (adSize == null || !mounted) return;

    ref.read(adNotifierProvider.notifier).loadBannerAd(adSize: adSize);
  }

  @override
  Widget build(BuildContext context) {
    final bool isAdFree =
        ref.watch(settingsNotifierProvider.select((s) => s.isAdFree));

    if (isAdFree) {
      return const SizedBox.shrink();
    }

    final AdState adState = ref.watch(adNotifierProvider);
    final double bottomPadding = MediaQuery.of(context).padding.bottom;

    if (!adState.isBannerLoaded || adState.bannerAd == null) {
      return Container(
        width: double.infinity,
        height: 60 + bottomPadding,
        color: Colors.black,
      );
    }

    final double adHeight = adState.bannerAd!.size.height.toDouble();

    return Container(
      width: double.infinity,
      color: Colors.black,
      padding: EdgeInsets.only(bottom: bottomPadding),
      child: SizedBox(
        width: adState.bannerAd!.size.width.toDouble(),
        height: adHeight,
        child: AdWidget(ad: adState.bannerAd!),
      ),
    );
  }
}
