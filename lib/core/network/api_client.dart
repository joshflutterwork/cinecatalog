import 'package:chucker_flutter/chucker_flutter.dart';
import 'package:cinecatalog/core/error/network_exception.dart';
import 'package:cinecatalog/core/network/api_config.dart';
import 'package:cinecatalog/core/network/api_endpoints.dart';
import 'package:cinecatalog/core/network/failure_mapper.dart';
import 'package:cinecatalog/core/network/guard_request.dart';
import 'package:cinecatalog/core/network/interceptors.dart';
import 'package:cinecatalog/core/network/token_storage.dart';
import 'package:cinecatalog/core/widgets/state_views.dart';
import 'package:cinecatalog/core/widgets/toast.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// Why [ApiClient] considers the session over.
enum SessionEndReason {
  /// No token configured; nothing was sent.
  missingToken,

  /// TMDB answered 401: the token is invalid or revoked.
  rejected,
}

/// The app's single HTTP client for TMDB.
///
/// Datasources call [get] with a parser and never touch Dio. The client
/// owns everything cross-cutting:
///
/// * bearer token from [TokenStorage]; [onUnauthorized] when it is missing
///   or TMDB rejects it;
/// * TMDB params (`region`, `include_video_language`) per endpoint;
/// * retry on 429;
/// * [onMaintenance] on the first 503 and [onServiceAvailable] on the next
///   success;
/// * every failed call mapped to a [NetworkException] and shown as a toast
///   on [navigatorKey]'s overlay, the same error type at most once per
///   [errorToastWindow];
/// * the Chucker HTTP inspector in debug builds when
///   [ApiConfig.enableHttpInspector].
final class ApiClient {
  ApiClient(
    ApiConfig config,
    this._tokenStorage, {
    required this.navigatorKey,
    this.onUnauthorized,
    this.onMaintenance,
    this.onServiceAvailable,
    this.errorToastWindow = const Duration(seconds: 3),
    Duration retryBackoff = const Duration(seconds: 1),
    @visibleForTesting HttpClientAdapter? httpClientAdapter,
  }) : _dio = _buildDio(config) {
    if (httpClientAdapter != null) _dio.httpClientAdapter = httpClientAdapter;
    _dio.interceptors.addAll([
      _buildAuthInterceptor(),
      TmdbParamsInterceptor(language: config.language, region: config.region),
      if (kDebugMode)
        LogInterceptor(
          requestHeader: false,
          responseHeader: false,
          logPrint: (line) => debugPrint('$line'),
        ),
      // Restrict the inspector to dev debug builds. UAT / staging / prod
      // skip it even when debug-built so testers don't see internal
      // traffic, and release/profile builds never add it, even with
      // APP_ENV=dev.
      if (kDebugMode && config.enableHttpInspector) ChuckerDioInterceptor(),
      RetryInterceptor(_dio, backoff: retryBackoff),
      // Last, so it sees the final outcome of every request.
      _buildStatusInterceptor(),
    ]);
  }

  final GlobalKey<NavigatorState> navigatorKey;
  final Duration errorToastWindow;
  final TokenStorage _tokenStorage;
  final void Function(SessionEndReason reason)? onUnauthorized;
  final void Function()? onMaintenance;
  final void Function()? onServiceAvailable;
  final Dio _dio;

  /// Set by a 503, cleared by the next successful response.
  bool _inMaintenance = false;
  final _lastErrorToast = <NetworkErrorType, DateTime>{};

  static Dio _buildDio(ApiConfig config) => Dio(
    BaseOptions(
      baseUrl: config.baseUrl,
      connectTimeout: config.connectTimeout,
      receiveTimeout: config.receiveTimeout,
      queryParameters: {ApiParams.language: config.language},
    ),
  );

  /// `GET path?query`, parsed with [parser].
  ///
  /// Throws [DioException] (carrying a [NetworkException]) or
  /// [FormatException]; repositories turn both into failures with
  /// `guardRequest`.
  Future<T> get<T>(
    String path, {
    required T Function(Map<String, dynamic> json) parser,
    Map<String, dynamic>? query,
  }) async {
    final response = await _dio.get<Object?>(path, queryParameters: query);
    return parseJson<T>(response.data, parser);
  }

  void close() => _dio.close(force: true);

  Interceptor _buildAuthInterceptor() => InterceptorsWrapper(
    onRequest: (options, handler) async {
      final token = await _tokenStorage.readAccessToken();
      if (token == null) {
        onUnauthorized?.call(SessionEndReason.missingToken);
        handler.reject(
          DioException(
            requestOptions: options,
            error: const NetworkException(
              NetworkErrorType.unauthorized,
              message: 'TMDB_TOKEN is not set',
            ),
          ),
          // Still run the error interceptors, so the toast shows it too.
          true,
        );
        return;
      }
      options.headers['Authorization'] = 'Bearer $token';
      handler.next(options);
    },
  );

  Interceptor _buildStatusInterceptor() => InterceptorsWrapper(
    onResponse: (response, handler) {
      if (_inMaintenance) {
        _inMaintenance = false;
        onServiceAvailable?.call();
      }
      handler.next(response);
    },
    onError: (err, handler) {
      final error = NetworkException.fromDio(err);
      if (error.type != NetworkErrorType.cancelled) {
        _showErrorToast(error);
        if (error.statusCode == 401) {
          onUnauthorized?.call(SessionEndReason.rejected);
        }
        if (error.statusCode == 503 && !_inMaintenance) {
          _inMaintenance = true;
          onMaintenance?.call();
        }
      }
      handler.next(err.copyWith(error: error));
    },
  );

  /// Opening home offline fails four lists at once; one toast is enough.
  void _showErrorToast(NetworkException error) {
    final now = DateTime.now();
    final last = _lastErrorToast[error.type];
    if (last != null && now.difference(last) < errorToastWindow) return;
    _lastErrorToast[error.type] = now;

    final overlay = navigatorKey.currentState?.overlay;
    if (overlay != null) showToastOn(overlay, failureFromNetwork(error).title);
  }
}
