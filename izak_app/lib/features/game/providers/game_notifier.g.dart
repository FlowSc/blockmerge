// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$hasSavedGameHash() => r'c5c043d6a6edac282e0a256792cfcc3a242dc208';

/// See also [hasSavedGame].
@ProviderFor(hasSavedGame)
final hasSavedGameProvider = AutoDisposeFutureProvider<bool>.internal(
  hasSavedGame,
  name: r'hasSavedGameProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$hasSavedGameHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef HasSavedGameRef = AutoDisposeFutureProviderRef<bool>;
String _$gameNotifierHash() => r'c329c3a0d6107b9c24bba61fb847f99f0d822bc1';

/// See also [GameNotifier].
@ProviderFor(GameNotifier)
final gameNotifierProvider =
    AutoDisposeNotifierProvider<GameNotifier, GameState>.internal(
      GameNotifier.new,
      name: r'gameNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$gameNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$GameNotifier = AutoDisposeNotifier<GameState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
