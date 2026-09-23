import 'package:cinecatalog/core/network/api_endpoints.dart';
import 'package:dio/dio.dart';

/// Retries a request TMDB answered with `429 Too Many Requests`.
///
/// TMDB allows "somewhere in the 40 requests per second range" and asks
/// clients to respect the 429. Waits for `Retry-After` when TMDB sends it,
/// otherwise [backoff] × attempt, and gives up after [maxRetries]; the
/// final 429 then becomes a `RateLimitFailure`.
final class RetryInterceptor extends Interceptor {
  RetryInterceptor(
    this._dio, {
    this.maxRetries = 2,
    this.backoff = const Duration(seconds: 1),
  });

  final Dio _dio;
  final int maxRetries;
  final Duration backoff;

  static const _attemptKey = 'tmdb_retry_attempt';

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final options = err.requestOptions;
    final attempt = (options.extra[_attemptKey] as int?) ?? 0;
    if (err.response?.statusCode != 429 || attempt >= maxRetries) {
      handler.next(err);
      return;
    }

    await Future<void>.delayed(_delayFor(err.response, attempt + 1));
    options.extra[_attemptKey] = attempt + 1;
    try {
      handler.resolve(await _dio.fetch<Object?>(options));
    } on DioException catch (e) {
      handler.next(e);
    }
  }

  Duration _delayFor(Response<dynamic>? response, int attempt) {
    final seconds = int.tryParse(response?.headers.value('retry-after') ?? '');
    return seconds != null ? Duration(seconds: seconds) : backoff * attempt;
  }
}

/// Adds the TMDB query params that depend on the endpoint:
///
/// * `region` on the four movie lists, so "now playing" and "upcoming"
///   follow that country's release dates;
/// * `include_video_language` when a detail call appends `videos`, because
///   `language` also filters videos and would otherwise drop English
///   trailers for a non-English UI.
final class TmdbParamsInterceptor extends Interceptor {
  TmdbParamsInterceptor({required this.language, this.region = ''});

  final String language;
  final String region;

  static final Set<String> _regionPaths = ApiEndpoints.movie.lists;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final query = options.queryParameters;
    if (region.isNotEmpty && _regionPaths.contains(options.path)) {
      query[ApiParams.region] = region;
    }
    final appended = query[ApiParams.appendToResponse];
    if (appended is String && appended.split(',').contains(ApiAppend.videos)) {
      final code = language.split('-').first;
      // `null` keeps videos with no language set.
      query[ApiParams.includeVideoLanguage] = {code, 'en', 'null'}.join(',');
    }
    handler.next(options);
  }
}
