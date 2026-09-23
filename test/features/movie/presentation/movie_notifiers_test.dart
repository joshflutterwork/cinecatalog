import 'dart:async';

import 'package:cinecatalog/core/common/paginated_entity.dart';
import 'package:cinecatalog/core/error/failure.dart';
import 'package:cinecatalog/core/state/paging.dart';
import 'package:cinecatalog/features/movie/domain/entities/movie.dart';
import 'package:cinecatalog/features/movie/domain/entities/movie_detail.dart';
import 'package:cinecatalog/features/movie/domain/repositories/movie_repository.dart';
import 'package:cinecatalog/features/movie/presentation/providers/movie_providers.dart';
import 'package:cinecatalog/features/movie/presentation/state/movie_detail_state.dart';
import 'package:cinecatalog/features/movie/presentation/state/movie_list_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';

import '../../../helpers/fixtures.dart';

typedef _PageResponder =
    Future<Either<Failure, PaginatedEntity<Movie>>> Function(int page);
typedef _DetailResponder = Future<Either<Failure, MovieDetail>> Function();

/// Each test decides what every call answers and when.
final class _StubRepository implements MovieRepository {
  _StubRepository({this.onPage, this.onDetail});

  final _PageResponder? onPage;
  final _DetailResponder? onDetail;
  final requestedPages = <int>[];

  @override
  Future<Either<Failure, PaginatedEntity<Movie>>> getMovies(
    MovieCategory category,
    int page,
  ) {
    requestedPages.add(page);
    return onPage!(page);
  }

  @override
  Future<Either<Failure, MovieDetail>> getMovieDetail(int id) => onDetail!();
}

MovieDetail _detail() => MovieDetail(
  movie: movieFixture(1),
  genres: const [],
  status: 'Released',
  cast: const [],
  trailers: const [],
  similar: const [],
);

void main() {
  late ProviderContainer container;
  late _StubRepository repository;

  void setUpRepository(_StubRepository stub) {
    repository = stub;
    container = ProviderContainer(
      overrides: [movieRepositoryProvider.overrideWithValue(stub)],
    );
    addTearDown(container.dispose);
  }

  /// Lets pending stub responses complete.
  Future<void> settle() => Future<void>.delayed(Duration.zero);

  group('MovieListNotifier', () {
    final provider = movieListProvider(MovieCategory.popular);

    MovieListState read() => container.read(provider);
    MovieListNotifier notifier() => container.read(provider.notifier);

    void create(_PageResponder onPage) {
      setUpRepository(_StubRepository(onPage: onPage));
      // Keep the provider alive between reads, as a watching screen would.
      container.listen(provider, (_, _) {});
    }

    test('MovieListLoading, then MovieListLoaded with page 1', () async {
      create((page) async => Right(moviePage(page)));
      expect(read(), isA<MovieListLoading>());

      await settle();
      final state = read() as MovieListLoaded;
      expect(state.movies.map((m) => m.id), [0, 1, 2]);
      expect(state.data.hasMore, isTrue);
      expect(state.data.loadMore, isA<LoadMoreIdle>());
    });

    test('appends page 2, then stops at the last page', () async {
      create((page) async => Right(moviePage(page)));
      await settle();

      await notifier().loadNextPage();
      final state = read() as MovieListLoaded;
      expect(state.movies.map((m) => m.id), [0, 1, 2, 3, 4, 5]);
      expect(state.data.hasMore, isFalse);

      await notifier().loadNextPage();
      expect(repository.requestedPages, [1, 2]);
    });

    test('an empty page 1 gives MovieListEmpty', () async {
      create(
        (_) async => const Right(
          PaginatedEntity<Movie>(
            items: [],
            page: 1,
            totalPages: 1,
            totalResults: 0,
          ),
        ),
      );
      await settle();
      expect(read(), isA<MovieListEmpty>());
    });

    test('ignores loadNextPage while a page is already loading', () async {
      final pending = Completer<Either<Failure, PaginatedEntity<Movie>>>();
      create(
        (page) =>
            page == 1 ? Future.value(Right(moviePage(1))) : pending.future,
      );
      await settle();

      final firstCall = notifier().loadNextPage();
      expect((read() as MovieListLoaded).data.loadMore, isA<LoadMoreLoading>());
      await notifier().loadNextPage();
      await notifier().loadNextPage();

      pending.complete(Right(moviePage(2)));
      await firstCall;
      expect(repository.requestedPages, [1, 2]);
    });

    test('a failed page 1 gives MovieListError; retry recovers', () async {
      var fail = true;
      create(
        (page) async =>
            fail ? const Left(NetworkFailure()) : Right(moviePage(page)),
      );
      await settle();
      expect((read() as MovieListError).failure, isA<NetworkFailure>());

      fail = false;
      notifier().retry();
      expect(read(), isA<MovieListLoading>());
      await settle();
      expect(read(), isA<MovieListLoaded>());
    });

    test('a failed next page keeps the movies and records it', () async {
      create(
        (page) async =>
            page == 1 ? Right(moviePage(1)) : const Left(ServerFailure()),
      );
      await settle();

      await notifier().loadNextPage();

      final state = read() as MovieListLoaded;
      expect(state.movies, hasLength(3));
      expect(state.data.loadMoreFailure, isA<ServerFailure>());
      expect(state.data.hasMore, isTrue, reason: 'the page can be retried');
    });

    test('drops a page-1 answer that arrives after retry', () async {
      final slow = Completer<Either<Failure, PaginatedEntity<Movie>>>();
      var calls = 0;
      create(
        (page) =>
            ++calls == 1 ? slow.future : Future.value(Right(moviePage(1))),
      );

      notifier().retry();
      await settle();
      expect(read(), isA<MovieListLoaded>());

      slow.complete(const Left(NetworkFailure()));
      await settle();
      expect(read(), isA<MovieListLoaded>(), reason: 'stale error ignored');
    });

    test('never goes past TMDB page 500', () {
      const data = PageData<Movie>(items: [], page: 500, totalPages: 38000);
      expect(data.hasMore, isFalse);
    });
  });

  group('MovieDetailNotifier', () {
    final provider = movieDetailProvider(1);

    MovieDetailState read() => container.read(provider);

    void create(_DetailResponder onDetail) {
      setUpRepository(_StubRepository(onDetail: onDetail));
      container.listen(provider, (_, _) {});
    }

    test('MovieDetailLoading, then MovieDetailLoaded', () async {
      create(() async => Right(_detail()));
      expect(read(), isA<MovieDetailLoading>());

      await settle();
      expect((read() as MovieDetailLoaded).detail.movie.id, 1);
    });

    test('MovieDetailError, then retry recovers', () async {
      var fail = true;
      create(
        () async => fail ? const Left(NotFoundFailure()) : Right(_detail()),
      );
      await settle();
      expect((read() as MovieDetailError).failure, isA<NotFoundFailure>());

      fail = false;
      container.read(provider.notifier).retry();
      expect(read(), isA<MovieDetailLoading>());
      await settle();
      expect(read(), isA<MovieDetailLoaded>());
    });
  });
}
