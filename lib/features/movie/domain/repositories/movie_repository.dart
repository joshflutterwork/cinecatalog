import 'package:cinecatalog/core/common/paginated_entity.dart';
import 'package:cinecatalog/core/error/failure.dart';
import 'package:cinecatalog/features/movie/domain/entities/movie.dart';
import 'package:cinecatalog/features/movie/domain/entities/movie_detail.dart';
import 'package:fpdart/fpdart.dart';

enum MovieCategory { topRated, upcoming, nowPlaying, popular }

abstract interface class MovieRepository {
  Future<Either<Failure, PaginatedEntity<Movie>>> getMovies(
    MovieCategory category,
    int page,
  );

  Future<Either<Failure, MovieDetail>> getMovieDetail(int id);
}
