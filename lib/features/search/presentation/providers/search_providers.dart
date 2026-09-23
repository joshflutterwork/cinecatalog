import 'dart:async';

import 'package:cinecatalog/core/common/paginated_entity.dart';
import 'package:cinecatalog/core/error/failure.dart';
import 'package:cinecatalog/core/network/api_client_provider.dart';
import 'package:cinecatalog/core/state/paging.dart';
import 'package:cinecatalog/core/theme/app_tokens.dart';
import 'package:cinecatalog/features/search/data/datasources/search_remote_datasource.dart';
import 'package:cinecatalog/features/search/data/repositories/search_repository_impl.dart';
import 'package:cinecatalog/features/search/domain/entities/search_result.dart';
import 'package:cinecatalog/features/search/domain/repositories/search_repository.dart';
import 'package:cinecatalog/features/search/domain/usecases/get_trending.dart';
import 'package:cinecatalog/features/search/domain/usecases/search_multi.dart';
import 'package:cinecatalog/features/search/presentation/state/search_results_state.dart';
import 'package:cinecatalog/features/search/presentation/state/trending_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:fpdart/fpdart.dart';

final searchRemoteDataSourceProvider = Provider<SearchRemoteDataSource>(
  (ref) => SearchRemoteDataSourceImpl(ref.watch(apiClientProvider)),
);

/// Tests override this to avoid the network.
final searchRepositoryProvider = Provider<SearchRepository>(
  (ref) => SearchRepositoryImpl(ref.watch(searchRemoteDataSourceProvider)),
);

final searchMultiProvider = Provider<SearchMulti>(
  (ref) => SearchMulti(ref.watch(searchRepositoryProvider)),
);

/// Paginated `/search/multi` results for one query. Auto-disposed, so a
/// query the user moved away from stops holding memory, and a late answer
/// for it can never overwrite the current results.
final NotifierProviderFamily<SearchResultsNotifier, SearchResultsState, String>
searchResultsProvider = NotifierProvider.autoDispose
    .family<SearchResultsNotifier, SearchResultsState, String>(
      SearchResultsNotifier.new,
    );

final class SearchResultsNotifier extends Notifier<SearchResultsState>
    with PagingMixin<SearchResult, SearchResultsState> {
  SearchResultsNotifier(this.query);

  final String query;

  @override
  SearchResultsState build() {
    loadFirstPage();
    return const SearchResultsLoading();
  }

  @override
  Future<Either<Failure, PaginatedEntity<SearchResult>>> fetchPage(int page) =>
      ref.read(searchMultiProvider)(SearchParams(query, page));

  @override
  SearchResultsState get loadingState => const SearchResultsLoading();

  @override
  SearchResultsState get emptyState => const SearchResultsEmpty();

  @override
  SearchResultsState errorState(Failure failure) => SearchResultsError(failure);

  @override
  SearchResultsState loadedState(PageData<SearchResult> data) =>
      SearchResultsLoaded(data);

  @override
  PageData<SearchResult>? pageDataOf(SearchResultsState state) =>
      switch (state) {
        SearchResultsLoaded(:final data) => data,
        _ => null,
      };
}

enum SearchFilter { all, movie, tv, person }

extension SearchFilterApply on SearchFilter {
  /// Narrows loaded results down to this filter, here rather than in the
  /// widget.
  List<SearchResult> apply(List<SearchResult> items) => switch (this) {
    SearchFilter.all => items,
    SearchFilter.movie => items.whereType<MovieResult>().toList(),
    SearchFilter.tv => items.whereType<TvResult>().toList(),
    SearchFilter.person => items.whereType<PersonResult>().toList(),
  };
}

/// What the user typed, the query actually sent (after the debounce) and
/// the active filter. Results live in [searchResultsProvider].
final class SearchState {
  const SearchState({
    this.query = '',
    this.committedQuery = '',
    this.filter = SearchFilter.all,
  });

  final String query;

  /// Trimmed [query] once it has been stable for the debounce delay.
  final String committedQuery;
  final SearchFilter filter;

  bool get hasQuery => query.trim().isNotEmpty;

  /// Typing, waiting for the debounce: show the skeleton straight away.
  bool get isDebouncing => hasQuery && query.trim() != committedQuery;

  SearchState copyWith({
    String? query,
    String? committedQuery,
    SearchFilter? filter,
  }) => SearchState(
    query: query ?? this.query,
    committedQuery: committedQuery ?? this.committedQuery,
    filter: filter ?? this.filter,
  );
}

final NotifierProvider<SearchNotifier, SearchState> searchProvider =
    NotifierProvider.autoDispose<SearchNotifier, SearchState>(
      SearchNotifier.new,
    );

final class SearchNotifier extends Notifier<SearchState> {
  Timer? _debounce;

  @override
  SearchState build() {
    ref.onDispose(() => _debounce?.cancel());
    return const SearchState();
  }

  void setQuery(String query) {
    _debounce?.cancel();
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      state = state.copyWith(query: query, committedQuery: '');
      return;
    }
    state = state.copyWith(query: query);
    _debounce = Timer(AppMotion.searchDebounce, () {
      if (ref.mounted) state = state.copyWith(committedQuery: trimmed);
    });
  }

  void setFilter(SearchFilter filter) {
    state = state.copyWith(filter: filter);
  }
}

final getTrendingProvider = Provider<GetTrending>(
  (ref) => GetTrending(ref.watch(searchRepositoryProvider)),
);

/// Suggestions under "Popular searches": today's trending titles.
final NotifierProvider<TrendingNotifier, TrendingState> trendingProvider =
    NotifierProvider.autoDispose<TrendingNotifier, TrendingState>(
      TrendingNotifier.new,
    );

/// Loading → Loaded | Empty | Error; [retry] starts over.
final class TrendingNotifier extends Notifier<TrendingState> {
  /// Bumped by [retry], so an answer to an older request is ignored.
  int _generation = 0;

  @override
  TrendingState build() {
    _load(_generation);
    return const TrendingLoading();
  }

  void retry() {
    _generation++;
    state = const TrendingLoading();
    _load(_generation);
  }

  Future<void> _load(int generation) async {
    final result = await ref.read(getTrendingProvider)(null);
    if (!ref.mounted || generation != _generation) return;
    state = result.fold(
      TrendingError.new,
      (results) =>
          results.isEmpty ? const TrendingEmpty() : TrendingLoaded(results),
    );
  }
}
