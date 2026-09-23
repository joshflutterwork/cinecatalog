import 'package:cinecatalog/core/config/app_config.dart';
import 'package:cinecatalog/core/network/api_client.dart' show ApiClient;

enum AppEnvironment { dev, staging, prod }

/// Everything [ApiClient] needs to talk to TMDB, resolved once from the
/// build flags so tests can pass their own.
final class ApiConfig {
  const ApiConfig({
    required this.environment,
    required this.language,
    this.baseUrl = 'https://api.themoviedb.org/3',
    this.region = '',
    this.connectTimeout = const Duration(seconds: 15),
    this.receiveTimeout = const Duration(seconds: 15),
  });

  factory ApiConfig.fromEnvironment() => ApiConfig(
    environment: AppEnvironment.values.firstWhere(
      (e) => e.name == AppConfig.environment,
      orElse: () => AppEnvironment.dev,
    ),
    language: AppConfig.tmdbLanguage,
  );

  final AppEnvironment environment;
  final String baseUrl;

  /// `language` sent with every request, e.g. `en-US`.
  final String language;

  /// ISO 3166-1 country for the movie lists; empty to leave it out.
  final String region;
  final Duration connectTimeout;
  final Duration receiveTimeout;

  /// Chucker only in dev (and only in debug builds, see `ApiClient`).
  /// Staging and prod skip it even when debug-built, so testers do not see
  /// internal traffic.
  bool get enableHttpInspector => environment == AppEnvironment.dev;
}
