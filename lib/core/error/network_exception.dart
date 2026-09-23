import 'package:dio/dio.dart';

/// What went wrong on the wire, as the data layer sees it.
enum NetworkErrorType {
  /// No connection or DNS failure.
  noConnection,

  /// Connect, send or receive timed out.
  timeout,

  /// HTTP 401, or no token configured.
  unauthorized,

  /// HTTP 404.
  notFound,

  /// HTTP 429 after the automatic retries.
  rateLimited,

  /// HTTP 5xx, any other status, or an unexpected Dio error.
  server,

  /// The request was cancelled on purpose; never shown to the user.
  cancelled,
}

/// The data layer's error for a failed TMDB call.
///
/// `ErrorInterceptor` builds it from a [DioException] and stores it in
/// [DioException.error]; repositories turn it into a domain `Failure`, so
/// nothing above the data layer depends on Dio.
final class NetworkException implements Exception {
  const NetworkException(this.type, {this.statusCode, this.message});

  factory NetworkException.fromDio(DioException e) {
    if (e.error case final NetworkException known) return known;
    final status = e.response?.statusCode;
    final type = switch (e.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout => NetworkErrorType.timeout,
      DioExceptionType.connectionError => NetworkErrorType.noConnection,
      DioExceptionType.cancel => NetworkErrorType.cancelled,
      DioExceptionType.badResponse => switch (status) {
        401 => NetworkErrorType.unauthorized,
        404 => NetworkErrorType.notFound,
        429 => NetworkErrorType.rateLimited,
        _ => NetworkErrorType.server,
      },
      DioExceptionType.transformTimeout ||
      DioExceptionType.badCertificate ||
      DioExceptionType.unknown => NetworkErrorType.server,
    };
    return NetworkException(
      type,
      statusCode: status,
      message: _tmdbMessage(e.response) ?? e.message,
    );
  }

  final NetworkErrorType type;
  final int? statusCode;

  /// TMDB's `status_message` when it sent one.
  final String? message;

  @override
  String toString() =>
      'NetworkException(${type.name}'
      '${statusCode == null ? '' : ', $statusCode'}'
      '${message == null ? '' : ', $message'})';
}

/// TMDB errors carry `{"status_message": "..."}`.
String? _tmdbMessage(Response<dynamic>? response) {
  final data = response?.data;
  return data is Map && data['status_message'] is String
      ? data['status_message'] as String
      : null;
}
