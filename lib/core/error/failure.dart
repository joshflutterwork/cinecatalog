/// Errors the domain layer knows about.
///
/// Repositories return these through `Either<Failure, T>`; presentation
/// providers rethrow them so `AsyncValue.error` carries a typed failure.
sealed class Failure implements Exception {
  const Failure(this.message);

  final String message;

  @override
  String toString() => 'Failure: $message';
}

/// No connection or the request timed out.
final class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'No internet connection']);
}

/// HTTP 401: the TMDB token is missing or invalid.
final class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure([super.message = 'Unauthorized']);
}

/// HTTP 404.
final class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message = 'Not found']);
}

/// HTTP 429 even after the automatic retries: TMDB is throttling us.
final class RateLimitFailure extends Failure {
  const RateLimitFailure([super.message = 'Too many requests']);
}

/// HTTP 5xx or any other unexpected response.
final class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Server error']);
}

/// Reading or writing on-device storage failed (e.g. the watchlist).
final class StorageFailure extends Failure {
  const StorageFailure([super.message = 'Storage error']);
}

/// The response could not be parsed into a model.
final class ParsingFailure extends Failure {
  const ParsingFailure([super.message = 'Invalid response']);
}
