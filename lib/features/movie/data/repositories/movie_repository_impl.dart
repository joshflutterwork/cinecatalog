import 'package:cinecatalog/core/common/paginated_entity.dart';
import 'package:cinecatalog/core/error/failure.dart';
import 'package:cinecatalog/core/network/guard_request.dart';
import 'package:cinecatalog/features/movie/data/datasources/movie_remote_datasource.dart';
import 'package:cinecatalog/features/movie/domain/entities/movie.dart';
import 'package:cinecatalog/features/movie/domain/entities/movie_detail.dart';
import 'package:cinecatalog/features/movie/domain/repositories/movie_repository.dart';
import 'package:fpdart/fpdart.dart';

final class MovieRepositoryImpl implements MovieRepository {
  const MovieRepositoryImpl(this._remote);

  final MovieRemoteDataSource _remote;

  @override
  Future<Either<Failure, PaginatedEntity<Movie>>> getMovies(
    MovieCategory category,
    int page,
  ) => guardRequest(() async {
    final response = await _remote.getMovies(category, page);
    return response.toEntity((m) => m.toEntity());
  });

  @override
  Future<Either<Failure, MovieDetail>> getMovieDetail(int id) =>
      guardRequest(() async => (await _remote.getMovieDetail(id)).toEntity());
}
