import 'package:cinecatalog/core/config/env.dart';

/// App settings. TMDB values come from `.env` through [Env]; per-run QA
/// switches stay `--dart-define`s.
abstract final class AppConfig {
  /// TMDB "API Read Access Token" (v4 bearer), from `.env`.
  static String get tmdbToken => Env.tmdbToken;

  /// `language` query param sent with every TMDB request.
  static const String tmdbLanguage = Env.tmdbLanguage;

  /// ISO 3166-1 country (e.g. `ID`) for the movie lists' release dates.
  /// Empty: TMDB uses each movie's primary release date.
  static const String tmdbRegion = Env.tmdbRegion;

  /// `dev`, `staging` or `prod`; only `dev` gets the HTTP inspector. Taken
  /// from `.env`, unless a launch overrides it with
  /// `--dart-define=APP_ENV=staging`.
  static const String environment = _environmentOverride == ''
      ? Env.appEnv
      : _environmentOverride;
  static const _environmentOverride = String.fromEnvironment('APP_ENV');

  /// Opens the app on this route instead of the splash, for QA and
  /// screenshots, e.g. `--dart-define=INITIAL_ROUTE=/movie/27205`.
  static const initialRoute = String.fromEnvironment('INITIAL_ROUTE');
}
