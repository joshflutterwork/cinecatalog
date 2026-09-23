import 'package:chucker_flutter/chucker_flutter.dart';
import 'package:cinecatalog/core/network/api_client.dart';
import 'package:cinecatalog/core/network/api_config.dart';
import 'package:cinecatalog/core/network/token_storage.dart';
import 'package:cinecatalog/core/widgets/toast.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The root navigator, shared by GoRouter, Chucker (its notifications and
/// inspector) and [ApiClient] (its toasts).
final rootNavigatorKeyProvider = Provider<GlobalKey<NavigatorState>>(
  (ref) => ChuckerFlutter.navigatorKey,
);

final apiConfigProvider = Provider<ApiConfig>(
  (ref) => ApiConfig.fromEnvironment(),
);

final tokenStorageProvider = Provider<TokenStorage>(
  (ref) => const EnvTokenStorage(),
);

/// The single [ApiClient]; every remote datasource gets it from here.
final apiClientProvider = Provider<ApiClient>((ref) {
  final navigatorKey = ref.watch(rootNavigatorKeyProvider);
  void toast(String message) {
    final overlay = navigatorKey.currentState?.overlay;
    if (overlay != null) showToastOn(overlay, message);
  }

  final client = ApiClient(
    ref.watch(apiConfigProvider),
    ref.watch(tokenStorageProvider),
    navigatorKey: navigatorKey,
    // TMDB has no login: a missing or rejected token is a build/config
    // problem, already shown by the error toast and the error cards.
    onUnauthorized: (reason) => debugPrint('TMDB session ended: $reason'),
    onMaintenance: () =>
        toast('TMDB is under maintenance. Some data may not load.'),
    onServiceAvailable: () => toast('TMDB is back online'),
  );
  ref.onDispose(client.close);
  return client;
});
