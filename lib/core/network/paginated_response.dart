import 'package:cinecatalog/core/common/paginated_entity.dart';
import 'package:cinecatalog/core/network/json.dart';

/// Body of every TMDB list endpoint:
/// `{page, results, total_pages, total_results}`.
final class PaginatedResponse<M extends Object> {
  const PaginatedResponse({
    required this.results,
    required this.page,
    required this.totalPages,
    required this.totalResults,
  });

  /// [fromItem] may return null to skip a row, e.g. a `/search/multi` result
  /// with a `media_type` the app does not show.
  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    M? Function(Map<String, dynamic> item) fromItem,
  ) => PaginatedResponse(
    results: json.objects('results').map(fromItem).nonNulls.toList(),
    page: json.intOr('page', 1),
    totalPages: json.intOr('total_pages', 1),
    totalResults: json.intOr('total_results'),
  );

  final List<M> results;
  final int page;
  final int totalPages;
  final int totalResults;

  PaginatedEntity<E> toEntity<E>(E Function(M model) toItem) => PaginatedEntity(
    items: results.map(toItem).toList(),
    page: page,
    totalPages: totalPages,
    totalResults: totalResults,
  );
}
