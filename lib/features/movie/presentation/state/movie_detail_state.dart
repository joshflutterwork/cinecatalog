import 'package:cinecatalog/core/error/failure.dart';
import 'package:cinecatalog/features/movie/domain/entities/movie_detail.dart';

/// `/movie/{id}` with credits, videos and similar titles.
sealed class MovieDetailState {
  const MovieDetailState();
}

final class MovieDetailLoading extends MovieDetailState {
  const MovieDetailLoading();
}

final class MovieDetailLoaded extends MovieDetailState {
  const MovieDetailLoaded(this.detail);

  final MovieDetail detail;
}

final class MovieDetailError extends MovieDetailState {
  const MovieDetailError(this.failure);

  final Failure failure;
}
