import 'package:cinecatalog/core/common/paginated_entity.dart';
import 'package:cinecatalog/core/error/failure.dart';
import 'package:cinecatalog/core/usecase/usecase.dart';
import 'package:cinecatalog/features/tv/domain/entities/tv_show.dart';
import 'package:cinecatalog/features/tv/domain/repositories/tv_repository.dart';
import 'package:fpdart/fpdart.dart';

/// Popular, top rated, on the air or airing today shows, one page at a time.
final class GetTvShows
    implements UseCase<PaginatedEntity<TvShow>, PageParams<TvCategory>> {
  const GetTvShows(this._repository);

  final TvRepository _repository;

  @override
  Future<Either<Failure, PaginatedEntity<TvShow>>> call(
    PageParams<TvCategory> params,
  ) => _repository.getShows(params.category, params.page);
}
