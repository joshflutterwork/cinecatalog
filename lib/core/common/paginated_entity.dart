import 'dart:math' as math;

/// TMDB never serves more than 500 pages for a list endpoint.
const tmdbMaxPage = 500;

/// One page of a TMDB list endpoint, in domain terms.
final class PaginatedEntity<T> {
  const PaginatedEntity({
    required this.items,
    required this.page,
    required this.totalPages,
    required this.totalResults,
  });

  final List<T> items;
  final int page;
  final int totalPages;
  final int totalResults;

  int get lastPage => math.min(totalPages, tmdbMaxPage);

  bool get hasMore => page < lastPage;
}
