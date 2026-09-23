import 'package:cinecatalog/core/common/paginated_entity.dart';
import 'package:cinecatalog/core/error/failure.dart';
import 'package:cinecatalog/core/network/api_client_provider.dart';
import 'package:cinecatalog/core/state/paging.dart';
import 'package:cinecatalog/core/usecase/usecase.dart';
import 'package:cinecatalog/features/movie/data/datasources/movie_remote_datasource.dart';
import 'package:cinecatalog/features/movie/data/repositories/movie_repository_impl.dart';
import 'package:cinecatalog/features/movie/domain/entities/movie.dart';
import 'package:cinecatalog/features/movie/domain/repositories/movie_repository.dart';
import 'package:cinecatalog/features/movie/domain/usecases/get_movie_detail.dart';
import 'package:cinecatalog/features/movie/domain/usecases/get_movies.dart';
import 'package:cinecatalog/features/movie/presentation/state/movie_detail_state.dart';
import 'package:cinecatalog/features/movie/presentation/state/movie_list_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:fpdart/fpdart.dart';

final movieRemoteDataSourceProvider = Provider<MovieRemoteDataSource>(
  (ref) => MovieRemoteDataSourceImpl(ref.watch(apiClientProvider)),
);

/// Tests override this to avoid the network.
final movieRepositoryProvider = Provider<MovieRepository>(
  (ref) => MovieRepositoryImpl(ref.watch(movieRemoteDataSourceProvider)),
);

final Provider<GetMovies> getMoviesProvider = Provider(
  (ref) => GetMovies(ref.watch(movieRepositoryProvider)),
);

final Provider<GetMovieDetail> getMovieDetailProvider = Provider(
  (ref) => GetMovieDetail(ref.watch(movieRepositoryProvider)),
);

/// One paginated list per category. Kept alive so the home rail and the
/// View all page share the pages already loaded.
final NotifierProviderFamily<MovieListNotifier, MovieListState, MovieCategory>
movieListProvider =
    NotifierProvider.family<MovieListNotifier, MovieListState, MovieCategory>(
      MovieListNotifier.new,
    );

final class MovieListNotifier extends Notifier<MovieListState>
    with PagingMixin<Movie, MovieListState> {
  MovieListNotifier(this.category);

  final MovieCategory category;

  @override
  MovieListState build() {
    loadFirstPage();
    return const MovieListLoading();
  }

  @override
  Future<Either<Failure, PaginatedEntity<Movie>>> fetchPage(int page) =>
      ref.read(getMoviesProvider)(PageParams(category, page));

  @override
  MovieListState get loadingState => const MovieListLoading();

  @override
  MovieListState get emptyState => const MovieListEmpty();

  @override
  MovieListState errorState(Failure failure) => MovieListError(failure);

  @override
  MovieListState loadedState(PageData<Movie> data) => MovieListLoaded(data);

  @override
  PageData<Movie>? pageDataOf(MovieListState state) => switch (state) {
    MovieListLoaded(:final data) => data,
    _ => null,
  };
}

final NotifierProviderFamily<MovieDetailNotifier, MovieDetailState, int>
movieDetailProvider = NotifierProvider.autoDispose
    .family<MovieDetailNotifier, MovieDetailState, int>(
      MovieDetailNotifier.new,
    );

/// Loading → Loaded | Error for one movie; [retry] starts over.
final class MovieDetailNotifier extends Notifier<MovieDetailState> {
  MovieDetailNotifier(this.id);

  final int id;

  /// Bumped by [retry], so an answer to an older request is ignored.
  int _generation = 0;

  @override
  MovieDetailState build() {
    _load(_generation);
    return const MovieDetailLoading();
  }

  void retry() {
    _generation++;
    state = const MovieDetailLoading();
    _load(_generation);
  }

  Future<void> _load(int generation) async {
    final result = await ref.read(getMovieDetailProvider)(id);
    if (!ref.mounted || generation != _generation) return;
    state = result.fold(MovieDetailError.new, MovieDetailLoaded.new);
  }
}
