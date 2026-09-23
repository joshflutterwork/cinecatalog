import 'package:cinecatalog/core/common/paginated_entity.dart';
import 'package:cinecatalog/core/error/failure.dart';
import 'package:cinecatalog/core/usecase/usecase.dart';
import 'package:cinecatalog/features/search/domain/entities/search_result.dart';
import 'package:cinecatalog/features/search/domain/repositories/search_repository.dart';
import 'package:fpdart/fpdart.dart';

final class SearchParams {
  const SearchParams(this.query, this.page);

  final String query;
  final int page;
}

final class SearchMulti
    implements UseCase<PaginatedEntity<SearchResult>, SearchParams> {
  const SearchMulti(this._repository);

  final SearchRepository _repository;

  @override
  Future<Either<Failure, PaginatedEntity<SearchResult>>> call(
    SearchParams params,
  ) => _repository.searchMulti(params.query.trim(), params.page);
}
