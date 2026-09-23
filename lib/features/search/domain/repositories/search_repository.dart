import 'package:cinecatalog/core/common/paginated_entity.dart';
import 'package:cinecatalog/core/error/failure.dart';
import 'package:cinecatalog/features/search/domain/entities/search_result.dart';
import 'package:fpdart/fpdart.dart';

abstract interface class SearchRepository {
  Future<Either<Failure, PaginatedEntity<SearchResult>>> searchMulti(
    String query,
    int page,
  );

  /// Today's trending movies, shows and people (`/trending/all/day`).
  Future<Either<Failure, List<SearchResult>>> getTrending();
}
