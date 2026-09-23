import 'package:cinecatalog/core/common/paginated_entity.dart';
import 'package:cinecatalog/core/error/failure.dart';
import 'package:cinecatalog/core/usecase/usecase.dart';
import 'package:cinecatalog/features/movie/domain/entities/movie.dart';
import 'package:cinecatalog/features/movie/domain/repositories/movie_repository.dart';
import 'package:fpdart/fpdart.dart';

/// Top rated, upcoming, now playing or popular movies, one page at a time.
final class GetMovies
    implements UseCase<PaginatedEntity<Movie>, PageParams<MovieCategory>> {
  const GetMovies(this._repository);

  final MovieRepository _repository;

  @override
  Future<Either<Failure, PaginatedEntity<Movie>>> call(
    PageParams<MovieCategory> params,
  ) => _repository.getMovies(params.category, params.page);
}
