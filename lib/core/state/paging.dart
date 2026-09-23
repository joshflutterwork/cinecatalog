import 'dart:math' as math;

import 'package:cinecatalog/core/common/paginated_entity.dart';
import 'package:cinecatalog/core/error/failure.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';

/// Items loaded so far for one list, held by a feature's `...Loaded` state.
final class PageData<T> {
  const PageData({
    required this.items,
    required this.page,
    required this.totalPages,
    this.loadMore = const LoadMoreIdle(),
  });

  final List<T> items;

  /// Last page loaded, 1-based.
  final int page;
  final int totalPages;
  final LoadMoreStatus loadMore;

  /// TMDB serves at most [tmdbMaxPage] pages whatever `total_pages` says.
  bool get hasMore => page < math.min(totalPages, tmdbMaxPage);

  bool get isLoadingMore => loadMore is LoadMoreLoading;

  Failure? get loadMoreFailure => switch (loadMore) {
    LoadMoreFailed(:final failure) => failure,
    _ => null,
  };

  PageData<T> copyWith({
    List<T>? items,
    int? page,
    int? totalPages,
    LoadMoreStatus? loadMore,
  }) => PageData(
    items: items ?? this.items,
    page: page ?? this.page,
    totalPages: totalPages ?? this.totalPages,
    loadMore: loadMore ?? this.loadMore,
  );
}

/// State of the page after [PageData.page].
sealed class LoadMoreStatus {
  const LoadMoreStatus();
}

final class LoadMoreIdle extends LoadMoreStatus {
  const LoadMoreIdle();
}

final class LoadMoreLoading extends LoadMoreStatus {
  const LoadMoreLoading();
}

/// The items already shown stay; the footer offers a retry.
final class LoadMoreFailed extends LoadMoreStatus {
  const LoadMoreFailed(this.failure);

  final Failure failure;
}

/// What a screen can ask any paginated list to do.
abstract interface class PagingActions {
  Future<void> loadNextPage();

  void retry();

  /// Pull to refresh: reloads page 1 while the current items stay visible.
  Future<void> refresh();
}

/// Paging rules shared by every list notifier. The notifier keeps its own
/// sealed state (`MovieListLoading`, `MovieListLoaded`, ...) and tells the
/// mixin how to build each one:
///
/// * page 1 failing gives the error state; an empty page 1 the empty state;
/// * a later page failing keeps the items and sets [LoadMoreFailed];
/// * [loadNextPage] is ignored while a request is in flight or after the
///   last page (`min(total_pages, 500)`);
/// * a response that arrives after [retry] or [refresh] started over is
///   dropped;
/// * [refresh] keeps the items on screen while page 1 reloads; if it
///   fails they stay (the ApiClient toast says why), unless there were no
///   items yet, in which case the error state shows.
///
/// Call [loadFirstPage] from `build` and return the loading state.
mixin PagingMixin<T, S> on Notifier<S> implements PagingActions {
  int _generation = 0;

  Future<Either<Failure, PaginatedEntity<T>>> fetchPage(int page);

  S get loadingState;
  S get emptyState;
  S errorState(Failure failure);
  S loadedState(PageData<T> data);

  /// The loaded data inside [state], or null when it is not loaded.
  PageData<T>? pageDataOf(S state);

  Future<void> loadFirstPage() async {
    final generation = _generation;
    final result = await fetchPage(1);
    if (!ref.mounted || generation != _generation) return;
    state = result.fold(
      errorState,
      (page) => page.items.isEmpty
          ? emptyState
          : loadedState(
              PageData(
                items: page.items,
                page: page.page,
                totalPages: page.totalPages,
              ),
            ),
    );
  }

  @override
  Future<void> loadNextPage() async {
    final current = pageDataOf(state);
    if (current == null || current.isLoadingMore || !current.hasMore) return;
    final generation = _generation;

    state = loadedState(current.copyWith(loadMore: const LoadMoreLoading()));
    final result = await fetchPage(current.page + 1);
    if (!ref.mounted || generation != _generation) return;

    state = loadedState(
      result.fold(
        (failure) => current.copyWith(loadMore: LoadMoreFailed(failure)),
        (next) => current.copyWith(
          items: [...current.items, ...next.items],
          page: next.page,
          totalPages: next.totalPages,
          loadMore: const LoadMoreIdle(),
        ),
      ),
    );
  }

  @override
  Future<void> refresh() async {
    final generation = ++_generation;
    final result = await fetchPage(1);
    if (!ref.mounted || generation != _generation) return;
    final current = pageDataOf(state);
    state = result.fold(
      // Keep what is on screen; a next page that was loading was dropped
      // with the generation bump, so its footer goes back to idle.
      (failure) => current == null
          ? errorState(failure)
          : loadedState(current.copyWith(loadMore: const LoadMoreIdle())),
      (page) => page.items.isEmpty
          ? emptyState
          : loadedState(
              PageData(
                items: page.items,
                page: page.page,
                totalPages: page.totalPages,
              ),
            ),
    );
  }

  /// Starts over from page 1, used by the error card's retry button.
  @override
  void retry() {
    _generation++;
    state = loadingState;
    loadFirstPage();
  }
}
