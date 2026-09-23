import 'package:cinecatalog/core/error/failure.dart';
import 'package:cinecatalog/core/usecase/usecase.dart';
import 'package:cinecatalog/features/movie/domain/entities/movie_detail.dart';
import 'package:cinecatalog/features/movie/domain/repositories/movie_repository.dart';
import 'package:fpdart/fpdart.dart';

final class GetMovieDetail implements UseCase<MovieDetail, int> {
  const GetMovieDetail(this._repository);

  final MovieRepository _repository;

  @override
  Future<Either<Failure, MovieDetail>> call(int id) =>
      _repository.getMovieDetail(id);
}
