import 'package:cinecatalog/core/error/failure.dart';
import 'package:cinecatalog/features/tv/domain/entities/tv_detail.dart';

/// `/tv/{id}` with credits, videos and similar shows.
sealed class TvDetailState {
  const TvDetailState();
}

final class TvDetailLoading extends TvDetailState {
  const TvDetailLoading();
}

final class TvDetailLoaded extends TvDetailState {
  const TvDetailLoaded(this.detail);

  final TvDetail detail;
}

final class TvDetailError extends TvDetailState {
  const TvDetailError(this.failure);

  final Failure failure;
}
