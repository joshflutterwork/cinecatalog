import 'package:cinecatalog/core/common/paginated_entity.dart';
import 'package:cinecatalog/core/error/failure.dart';
import 'package:cinecatalog/core/network/guard_request.dart';
import 'package:cinecatalog/features/tv/data/datasources/tv_remote_datasource.dart';
import 'package:cinecatalog/features/tv/domain/entities/tv_detail.dart';
import 'package:cinecatalog/features/tv/domain/entities/tv_show.dart';
import 'package:cinecatalog/features/tv/domain/repositories/tv_repository.dart';
import 'package:fpdart/fpdart.dart';

final class TvRepositoryImpl implements TvRepository {
  const TvRepositoryImpl(this._remote);

  final TvRemoteDataSource _remote;

  @override
  Future<Either<Failure, PaginatedEntity<TvShow>>> getShows(
    TvCategory category,
    int page,
  ) => guardRequest(() async {
    final response = await _remote.getShows(category, page);
    return response.toEntity((s) => s.toEntity());
  });

  @override
  Future<Either<Failure, TvDetail>> getTvDetail(int id) =>
      guardRequest(() async => (await _remote.getTvDetail(id)).toEntity());
}
