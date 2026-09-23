import 'package:cinecatalog/core/common/paginated_entity.dart';
import 'package:cinecatalog/core/error/failure.dart';
import 'package:cinecatalog/core/network/guard_request.dart';
import 'package:cinecatalog/features/search/data/datasources/search_remote_datasource.dart';
import 'package:cinecatalog/features/search/domain/entities/search_result.dart';
import 'package:cinecatalog/features/search/domain/repositories/search_repository.dart';
import 'package:fpdart/fpdart.dart';

final class SearchRepositoryImpl implements SearchRepository {
  const SearchRepositoryImpl(this._remote);

  final SearchRemoteDataSource _remote;

  @override
  Future<Either<Failure, PaginatedEntity<SearchResult>>> searchMulti(
    String query,
    int page,
  ) => guardRequest(() async {
    final response = await _remote.searchMulti(query, page);
    return response.toEntity((r) => r);
  });

  @override
  Future<Either<Failure, List<SearchResult>>> getTrending() =>
      guardRequest(() async => (await _remote.getTrending()).results);
}
