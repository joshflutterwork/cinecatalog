import 'package:cinecatalog/core/error/failure.dart';
import 'package:cinecatalog/features/search/domain/entities/search_result.dart';

/// `/trending/all/day`, shown as suggestion chips before the user types.
sealed class TrendingState {
  const TrendingState();
}

final class TrendingLoading extends TrendingState {
  const TrendingLoading();
}

final class TrendingEmpty extends TrendingState {
  const TrendingEmpty();
}

final class TrendingError extends TrendingState {
  const TrendingError(this.failure);

  final Failure failure;
}

final class TrendingLoaded extends TrendingState {
  const TrendingLoaded(this.results);

  final List<SearchResult> results;
}
