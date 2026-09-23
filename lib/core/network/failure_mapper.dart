import 'package:cinecatalog/core/error/failure.dart';
import 'package:cinecatalog/core/error/network_exception.dart';
import 'package:dio/dio.dart';

/// Maps the data layer's [NetworkException] to the domain [Failure].
///
/// | NetworkErrorType          | Failure               |
/// | ------------------------- | --------------------- |
/// | noConnection / timeout    | [NetworkFailure]      |
/// | unauthorized              | [UnauthorizedFailure] |
/// | notFound                  | [NotFoundFailure]     |
/// | rateLimited               | [RateLimitFailure]    |
/// | server / cancelled        | [ServerFailure]       |
Failure failureFromNetwork(NetworkException e) => switch (e.type) {
  NetworkErrorType.noConnection ||
  NetworkErrorType.timeout => const NetworkFailure(),
  NetworkErrorType.unauthorized => const UnauthorizedFailure(),
  NetworkErrorType.notFound => const NotFoundFailure(),
  NetworkErrorType.rateLimited => const RateLimitFailure(),
  NetworkErrorType.server ||
  NetworkErrorType.cancelled => ServerFailure(e.message ?? 'Server error'),
};

/// For a [DioException], whether or not `ErrorInterceptor` already put a
/// [NetworkException] in it.
Failure failureFromDio(DioException e) =>
    failureFromNetwork(NetworkException.fromDio(e));
