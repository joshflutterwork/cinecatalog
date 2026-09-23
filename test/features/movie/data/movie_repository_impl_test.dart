import 'package:cinecatalog/core/error/failure.dart';
import 'package:cinecatalog/core/network/paginated_response.dart';
import 'package:cinecatalog/features/movie/data/datasources/movie_remote_datasource.dart';
import 'package:cinecatalog/features/movie/data/models/movie_model.dart';
import 'package:cinecatalog/features/movie/data/repositories/movie_repository_impl.dart';
import 'package:cinecatalog/features/movie/domain/repositories/movie_repository.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

final class _MockRemote extends Mock implements MovieRemoteDataSource;

void main() {
  late _MockRemote remote;
  late MovieRepositoryImpl repository;

  setUp(() {
    remote = _MockRemote();
    repository = MovieRepositoryImpl(remote);
  });

  test('maps models to a paginated entity', () async {
    when(() => remote.getMovies(MovieCategory.popular, 2)).thenAnswer(
      (_) async => const PaginatedResponse(
        results: [MovieModel(id: 1, title: 'A', overview: '', voteAverage: 7)],
        page: 2,
        totalPages: 10,
        totalResults: 200,
      ),
    );

    final result = await repository.getMovies(MovieCategory.popular, 2);

    final page = result.getRight().toNullable()!;
    expect(page.items.single.title, 'A');
    expect(page.page, 2);
    expect(page.totalPages, 10);
  });

  test('turns a DioException into its Failure', () async {
    when(() => remote.getMovieDetail(1)).thenThrow(
      DioException(
        requestOptions: RequestOptions(),
        type: DioExceptionType.badResponse,
        response: Response(requestOptions: RequestOptions(), statusCode: 404),
      ),
    );

    final result = await repository.getMovieDetail(1);

    expect(result.getLeft().toNullable(), isA<NotFoundFailure>());
  });

  test('turns a FormatException into ParsingFailure', () async {
    when(() => remote.getMovies(MovieCategory.topRated, 1))
        .thenThrow(const FormatException('bad'));

    final result = await repository.getMovies(MovieCategory.topRated, 1);

    expect(result.getLeft().toNullable(), isA<ParsingFailure>());
  });
}
