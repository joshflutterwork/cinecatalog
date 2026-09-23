import 'package:envied/envied.dart';

part 'env.g.dart';

/// Values from `.env`, compiled in by `envied`.
///
/// `env.g.dart` holds the token, so it is git-ignored like `.env`. After
/// editing `.env`, regenerate it:
/// `fvm dart run build_runner build --delete-conflicting-outputs`.
@Envied(path: '.env')
abstract final class Env {
  /// TMDB "API Read Access Token" (v4 bearer). Obfuscated: it is stored as
  /// XOR-ed int arrays in the binary instead of plain text, so a `strings`
  /// dump of the app does not reveal it. A determined reverse engineer can
  /// still recover it; this only raises the bar.
  @EnviedField(varName: 'TMDB_TOKEN', obfuscate: true, defaultValue: '')
  static final String tmdbToken = _Env.tmdbToken;

  @EnviedField(varName: 'TMDB_LANGUAGE', defaultValue: 'en-US')
  static const String tmdbLanguage = _Env.tmdbLanguage;

  /// ISO 3166-1 country for the movie lists; empty to leave it out.
  @EnviedField(varName: 'TMDB_REGION', defaultValue: '')
  static const String tmdbRegion = _Env.tmdbRegion;

  /// `dev`, `staging` or `prod`.
  @EnviedField(varName: 'APP_ENV', defaultValue: 'dev')
  static const String appEnv = _Env.appEnv;
}
