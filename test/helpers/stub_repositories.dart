import 'package:cinecatalog/core/common/paginated_entity.dart';
import 'package:cinecatalog/core/error/failure.dart';
import 'package:cinecatalog/features/movie/domain/entities/movie.dart';
import 'package:cinecatalog/features/movie/domain/entities/movie_detail.dart';
import 'package:cinecatalog/features/movie/domain/repositories/movie_repository.dart';
import 'package:cinecatalog/features/movie/presentation/providers/movie_providers.dart';
import 'package:cinecatalog/features/people/domain/entities/person.dart';
import 'package:cinecatalog/features/people/domain/repositories/people_repository.dart';
import 'package:cinecatalog/features/people/presentation/providers/people_providers.dart';
import 'package:cinecatalog/features/search/domain/entities/search_result.dart';
import 'package:cinecatalog/features/search/domain/repositories/search_repository.dart';
import 'package:cinecatalog/features/search/presentation/providers/search_providers.dart';
import 'package:cinecatalog/features/tv/domain/entities/tv_detail.dart';
import 'package:cinecatalog/features/tv/domain/entities/tv_show.dart';
import 'package:cinecatalog/features/tv/domain/repositories/tv_repository.dart';
import 'package:cinecatalog/features/tv/presentation/providers/tv_providers.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:fpdart/fpdart.dart';

import 'fixtures.dart';

/// In-memory repositories so widget tests never touch Dio or need a token.
/// Every list answers two pages of [moviePage]-style fixtures.
List<Override> stubRepositories({
  MovieRepository movies = const StubMovieRepository(),
}) => [
  movieRepositoryProvider.overrideWithValue(movies),
  tvRepositoryProvider.overrideWithValue(const StubTvRepository()),
  peopleRepositoryProvider.overrideWithValue(const StubPeopleRepository()),
  searchRepositoryProvider.overrideWithValue(const StubSearchRepository()),
];

class StubMovieRepository implements MovieRepository {
  const StubMovieRepository();

  @override
  Future<Either<Failure, PaginatedEntity<Movie>>> getMovies(
    MovieCategory category,
    int page,
  ) async => Right(moviePage(page, perPage: 5));

  @override
  Future<Either<Failure, MovieDetail>> getMovieDetail(int id) async =>
      const Left(NotFoundFailure());
}

final class StubTvRepository implements TvRepository {
  const StubTvRepository();

  @override
  Future<Either<Failure, PaginatedEntity<TvShow>>> getShows(
    TvCategory category,
    int page,
  ) async => Right(
    PaginatedEntity(
      items: [
        for (var i = 0; i < 5; i++)
          TvShow(id: i, title: 'Show $i', overview: '', voteAverage: 8),
      ],
      page: page,
      totalPages: 2,
      totalResults: 10,
    ),
  );

  @override
  Future<Either<Failure, TvDetail>> getTvDetail(int id) async =>
      const Left(NotFoundFailure());
}

final class StubPeopleRepository implements PeopleRepository {
  const StubPeopleRepository();

  @override
  Future<Either<Failure, PaginatedEntity<Person>>> getPopularPeople(
    int page,
  ) async => Right(
    PaginatedEntity(
      items: [
        for (var i = 0; i < 6; i++)
          Person(
            id: i,
            name: 'Person $i',
            knownForDepartment: 'Acting',
            knownFor: const [],
          ),
      ],
      page: page,
      totalPages: 2,
      totalResults: 12,
    ),
  );

  @override
  Future<Either<Failure, PersonDetail>> getPersonDetail(int id) async =>
      const Left(NotFoundFailure());

  /// "Person 0" … "Person 5", filtered by name.
  @override
  Future<Either<Failure, PaginatedEntity<Person>>> searchPeople(
    String query,
    int page,
  ) async {
    final hits = [
      for (var i = 0; i < 6; i++)
        if ('Person $i'.toLowerCase().contains(query.toLowerCase()))
          Person(
            id: i,
            name: 'Person $i',
            knownForDepartment: 'Acting',
            knownFor: const [],
          ),
    ];
    return Right(
      PaginatedEntity(
        items: hits,
        page: 1,
        totalPages: 1,
        totalResults: hits.length,
      ),
    );
  }
}

/// Matches titles containing the query, from three movie fixtures.
final class StubSearchRepository implements SearchRepository {
  const StubSearchRepository();

  static final _catalog = [
    MovieResult(movieFixture(1, title: 'The Dark Knight')),
    MovieResult(movieFixture(2, title: 'Dark Waters')),
    MovieResult(movieFixture(3, title: 'Inception')),
  ];

  @override
  Future<Either<Failure, PaginatedEntity<SearchResult>>> searchMulti(
    String query,
    int page,
  ) async {
    final q = query.toLowerCase();
    final hits = _catalog
        .where((r) => r.movie.title.toLowerCase().contains(q))
        .toList();
    return Right(
      PaginatedEntity(
        items: hits,
        page: 1,
        totalPages: 1,
        totalResults: hits.length,
      ),
    );
  }

  @override
  Future<Either<Failure, List<SearchResult>>> getTrending() async =>
      Right(_catalog);
}
