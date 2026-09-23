import 'package:cinecatalog/core/error/failure.dart';
import 'package:cinecatalog/core/state/paging.dart';
import 'package:cinecatalog/features/search/domain/entities/search_result.dart';

/// `/search/multi` results for one (debounced) query.
sealed class SearchResultsState {
  const SearchResultsState();
}

/// Page 1 is loading: show the skeleton.
final class SearchResultsLoading extends SearchResultsState {
  const SearchResultsLoading();
}

/// TMDB found nothing for the query.
final class SearchResultsEmpty extends SearchResultsState {
  const SearchResultsEmpty();
}

/// Page 1 failed: show the error card.
final class SearchResultsError extends SearchResultsState {
  const SearchResultsError(this.failure);

  final Failure failure;
}

/// Results on screen; [data] also says whether the next page is loading or
/// failed.
final class SearchResultsLoaded extends SearchResultsState {
  const SearchResultsLoaded(this.data);

  final PageData<SearchResult> data;

  List<SearchResult> get results => data.items;
}
