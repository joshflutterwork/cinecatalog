import 'package:cinecatalog/core/common/paginated_entity.dart';
import 'package:cinecatalog/core/error/failure.dart';
import 'package:cinecatalog/features/tv/domain/entities/tv_detail.dart';
import 'package:cinecatalog/features/tv/domain/entities/tv_show.dart';
import 'package:fpdart/fpdart.dart';

enum TvCategory { popular, topRated, onTheAir, airingToday }

abstract interface class TvRepository {
  Future<Either<Failure, PaginatedEntity<TvShow>>> getShows(
    TvCategory category,
    int page,
  );

  Future<Either<Failure, TvDetail>> getTvDetail(int id);
}
