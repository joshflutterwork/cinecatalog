import 'package:cinecatalog/core/config/app_config.dart';
import 'package:cinecatalog/core/network/api_client.dart' show ApiClient;

/// Where [ApiClient] reads the bearer token from.
///
/// TMDB's "API Read Access Token" never expires and has no refresh
/// endpoint, so [EnvTokenStorage] is all the app needs today. A user
/// session (e.g. TMDB account favourites) would add a storage backed by
/// secure storage plus a refresher in `ApiClient`'s auth interceptor.
abstract interface class TokenStorage {
  /// The bearer token, or null when there is none.
  Future<String?> readAccessToken();
}

/// The token compiled in from `.env` (see `Env`), or [token] in tests.
final class EnvTokenStorage implements TokenStorage {
  const EnvTokenStorage([this.token]);

  final String? token;

  @override
  Future<String?> readAccessToken() async {
    final value = token ?? AppConfig.tmdbToken;
    return value.isEmpty ? null : value;
  }
}
