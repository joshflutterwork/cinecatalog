import 'package:cinecatalog/core/error/failure.dart';
import 'package:cinecatalog/core/usecase/usecase.dart';
import 'package:cinecatalog/features/movie/domain/repositories/movie_repository.dart';
import 'package:cinecatalog/features/movie/domain/usecases/get_movies.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/fixtures.dart';

class _MockMovieRepository extends Mock implements MovieRepository;

void main() {
  late _MockMovieRepository repository;
  late GetMovies getMovies;

  setUp(() {
    repository = _MockMovieRepository();
    getMovies = GetMovies(repository);
  });

  test('passes category and page to the repository', () async {
    final page = moviePage(2);
    when(() => repository.getMovies(MovieCategory.upcoming, 2))
        .thenAnswer((_) async => Right(page));

    final result = await getMovies(const PageParams(MovieCategory.upcoming, 2));

    expect(result, Right<Failure, dynamic>(page));
    verify(() => repository.getMovies(MovieCategory.upcoming, 2)).called(1);
    verifyNoMoreInteractions(repository);
  });

  test('returns the repository failure unchanged', () async {
    when(() => repository.getMovies(MovieCategory.popular, 1))
        .thenAnswer((_) async => const Left(NetworkFailure()));

    final result = await getMovies(const PageParams(MovieCategory.popular, 1));

    expect(result.getLeft().toNullable(), isA<NetworkFailure>());
  });
}
