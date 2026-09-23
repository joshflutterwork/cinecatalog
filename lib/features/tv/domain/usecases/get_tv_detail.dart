import 'package:cinecatalog/core/error/failure.dart';
import 'package:cinecatalog/core/usecase/usecase.dart';
import 'package:cinecatalog/features/tv/domain/entities/tv_detail.dart';
import 'package:cinecatalog/features/tv/domain/repositories/tv_repository.dart';
import 'package:fpdart/fpdart.dart';

final class GetTvDetail implements UseCase<TvDetail, int> {
  const GetTvDetail(this._repository);

  final TvRepository _repository;

  @override
  Future<Either<Failure, TvDetail>> call(int id) => _repository.getTvDetail(id);
}
