import 'package:cinecatalog/core/common/paginated_entity.dart';
import 'package:cinecatalog/core/error/failure.dart';
import 'package:cinecatalog/core/network/api_client_provider.dart';
import 'package:cinecatalog/core/state/paging.dart';
import 'package:cinecatalog/core/usecase/usecase.dart';
import 'package:cinecatalog/features/tv/data/datasources/tv_remote_datasource.dart';
import 'package:cinecatalog/features/tv/data/repositories/tv_repository_impl.dart';
import 'package:cinecatalog/features/tv/domain/entities/tv_show.dart';
import 'package:cinecatalog/features/tv/domain/repositories/tv_repository.dart';
import 'package:cinecatalog/features/tv/domain/usecases/get_tv_detail.dart';
import 'package:cinecatalog/features/tv/domain/usecases/get_tv_shows.dart';
import 'package:cinecatalog/features/tv/presentation/state/tv_detail_state.dart';
import 'package:cinecatalog/features/tv/presentation/state/tv_list_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:fpdart/fpdart.dart';

final tvRemoteDataSourceProvider = Provider<TvRemoteDataSource>(
  (ref) => TvRemoteDataSourceImpl(ref.watch(apiClientProvider)),
);

/// Tests override this to avoid the network.
final tvRepositoryProvider = Provider<TvRepository>(
  (ref) => TvRepositoryImpl(ref.watch(tvRemoteDataSourceProvider)),
);

final Provider<GetTvShows> getTvShowsProvider = Provider(
  (ref) => GetTvShows(ref.watch(tvRepositoryProvider)),
);

final Provider<GetTvDetail> getTvDetailProvider = Provider(
  (ref) => GetTvDetail(ref.watch(tvRepositoryProvider)),
);

/// One paginated list per category, kept alive like the movie lists.
final NotifierProviderFamily<TvListNotifier, TvListState, TvCategory>
tvListProvider =
    NotifierProvider.family<TvListNotifier, TvListState, TvCategory>(
      TvListNotifier.new,
    );

final class TvListNotifier extends Notifier<TvListState>
    with PagingMixin<TvShow, TvListState> {
  TvListNotifier(this.category);

  final TvCategory category;

  @override
  TvListState build() {
    loadFirstPage();
    return const TvListLoading();
  }

  @override
  Future<Either<Failure, PaginatedEntity<TvShow>>> fetchPage(int page) =>
      ref.read(getTvShowsProvider)(PageParams(category, page));

  @override
  TvListState get loadingState => const TvListLoading();

  @override
  TvListState get emptyState => const TvListEmpty();

  @override
  TvListState errorState(Failure failure) => TvListError(failure);

  @override
  TvListState loadedState(PageData<TvShow> data) => TvListLoaded(data);

  @override
  PageData<TvShow>? pageDataOf(TvListState state) => switch (state) {
    TvListLoaded(:final data) => data,
    _ => null,
  };
}

final NotifierProviderFamily<TvDetailNotifier, TvDetailState, int>
tvDetailProvider = NotifierProvider.autoDispose
    .family<TvDetailNotifier, TvDetailState, int>(TvDetailNotifier.new);

/// Loading → Loaded | Error for one show; [retry] starts over.
final class TvDetailNotifier extends Notifier<TvDetailState> {
  TvDetailNotifier(this.id);

  final int id;

  /// Bumped by [retry], so an answer to an older request is ignored.
  int _generation = 0;

  @override
  TvDetailState build() {
    _load(_generation);
    return const TvDetailLoading();
  }

  void retry() {
    _generation++;
    state = const TvDetailLoading();
    _load(_generation);
  }

  /// Pull to refresh: reloads while the current detail stays on screen. A
  /// failure keeps it (the ApiClient toast says why).
  Future<void> refresh() async {
    final generation = ++_generation;
    final result = await ref.read(getTvDetailProvider)(id);
    if (!ref.mounted || generation != _generation) return;
    state = result.fold(
      (failure) => state is TvDetailLoaded ? state : TvDetailError(failure),
      TvDetailLoaded.new,
    );
  }

  Future<void> _load(int generation) async {
    final result = await ref.read(getTvDetailProvider)(id);
    if (!ref.mounted || generation != _generation) return;
    state = result.fold(TvDetailError.new, TvDetailLoaded.new);
  }
}
