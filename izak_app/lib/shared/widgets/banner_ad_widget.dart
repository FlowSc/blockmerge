import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../core/providers/ad_provider.dart';
import '../../features/settings/providers/settings_notifier.dart';

class BannerAdWidget extends ConsumerWidget {
  const BannerAdWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool isAdFree =
        ref.watch(settingsNotifierProvider.select((s) => s.isAdFree));

    if (isAdFree) {
      return const SizedBox.shrink();
    }

    final AdState adState = ref.watch(adNotifierProvider);

    if (!adState.isBannerLoaded || adState.bannerAd == null) {
      // Placeholder: reserve space so layout doesn't jump when ad loads
      return Container(
        width: double.infinity,
        height: 50,
        color: Colors.black,
      );
    }

    return Container(
      width: double.infinity,
      height: adState.bannerAd!.size.height.toDouble(),
      color: Colors.black,
      alignment: Alignment.center,
      child: SizedBox(
        width: adState.bannerAd!.size.width.toDouble(),
        height: adState.bannerAd!.size.height.toDouble(),
        child: AdWidget(ad: adState.bannerAd!),
      ),
    );
  }
}
