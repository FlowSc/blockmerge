import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/settings/providers/settings_notifier.dart';
import '../constants/ad_constants.dart';

part 'purchase_provider.g.dart';

enum PurchaseLoadingState { idle, loading, purchased, error }

@immutable
final class PurchaseState {
  const PurchaseState({
    this.loadingState = PurchaseLoadingState.idle,
    this.removeAdsPrice,
    this.errorMessage,
  });

  final PurchaseLoadingState loadingState;
  final String? removeAdsPrice;
  final String? errorMessage;

  PurchaseState copyWith({
    PurchaseLoadingState? loadingState,
    String? Function()? removeAdsPrice,
    String? Function()? errorMessage,
  }) {
    return PurchaseState(
      loadingState: loadingState ?? this.loadingState,
      removeAdsPrice:
          removeAdsPrice != null ? removeAdsPrice() : this.removeAdsPrice,
      errorMessage:
          errorMessage != null ? errorMessage() : this.errorMessage,
    );
  }
}

@Riverpod(keepAlive: true)
class PurchaseNotifier extends _$PurchaseNotifier {
  StreamSubscription<List<PurchaseDetails>>? _subscription;

  @override
  PurchaseState build() {
    ref.onDispose(() {
      _subscription?.cancel();
    });

    _initialize();
    return const PurchaseState();
  }

  Future<void> _initialize() async {
    final bool available = await InAppPurchase.instance.isAvailable();
    if (!available) return;

    _subscription = InAppPurchase.instance.purchaseStream.listen(
      _onPurchaseUpdate,
      onDone: () => _subscription?.cancel(),
      onError: (_) {},
    );

    final ProductDetailsResponse response =
        await InAppPurchase.instance.queryProductDetails(
      {AdConstants.removeAdsProductId},
    );

    if (response.productDetails.isNotEmpty) {
      state = state.copyWith(
        removeAdsPrice: () => response.productDetails.first.price,
      );
    }
  }

  void _onPurchaseUpdate(List<PurchaseDetails> purchaseDetailsList) {
    for (final PurchaseDetails purchase in purchaseDetailsList) {
      if (purchase.productID != AdConstants.removeAdsProductId) continue;

      switch (purchase.status) {
        case PurchaseStatus.pending:
          state = state.copyWith(loadingState: PurchaseLoadingState.loading);
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          _completePurchase(purchase);
        case PurchaseStatus.error:
          state = state.copyWith(
            loadingState: PurchaseLoadingState.error,
            errorMessage: () => purchase.error?.message ?? 'Purchase failed',
          );
          if (purchase.pendingCompletePurchase) {
            InAppPurchase.instance.completePurchase(purchase);
          }
        case PurchaseStatus.canceled:
          state = state.copyWith(loadingState: PurchaseLoadingState.idle);
      }
    }
  }

  Future<void> _completePurchase(PurchaseDetails purchase) async {
    if (purchase.pendingCompletePurchase) {
      await InAppPurchase.instance.completePurchase(purchase);
    }
    ref.read(settingsNotifierProvider.notifier).setAdFree(true);
    state = state.copyWith(loadingState: PurchaseLoadingState.purchased);
  }

  Future<void> buyRemoveAds() async {
    state = state.copyWith(
      loadingState: PurchaseLoadingState.loading,
      errorMessage: () => null,
    );

    final ProductDetailsResponse response =
        await InAppPurchase.instance.queryProductDetails(
      {AdConstants.removeAdsProductId},
    );

    if (response.productDetails.isEmpty) {
      state = state.copyWith(
        loadingState: PurchaseLoadingState.error,
        errorMessage: () => 'Product not found',
      );
      return;
    }

    final PurchaseParam purchaseParam = PurchaseParam(
      productDetails: response.productDetails.first,
    );

    await InAppPurchase.instance.buyNonConsumable(
      purchaseParam: purchaseParam,
    );
  }

  Future<void> restorePurchases() async {
    state = state.copyWith(
      loadingState: PurchaseLoadingState.loading,
      errorMessage: () => null,
    );

    await InAppPurchase.instance.restorePurchases();

    // If state is still loading after restore, nothing was found
    await Future<void>.delayed(const Duration(seconds: 3));
    if (state.loadingState == PurchaseLoadingState.loading) {
      state = state.copyWith(loadingState: PurchaseLoadingState.idle);
    }
  }
}
