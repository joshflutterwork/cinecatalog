import 'package:cinecatalog/core/common/paginated_entity.dart';
import 'package:cinecatalog/core/error/failure.dart';
import 'package:cinecatalog/core/usecase/usecase.dart';
import 'package:cinecatalog/features/people/domain/entities/person.dart';
import 'package:cinecatalog/features/people/domain/repositories/people_repository.dart';
import 'package:fpdart/fpdart.dart';

final class PeopleSearchParams {
  const PeopleSearchParams(this.query, this.page);

  final String query;
  final int page;
}

/// People by name, one page at a time, for the Popular People search.
final class SearchPeople
    implements UseCase<PaginatedEntity<Person>, PeopleSearchParams> {
  const SearchPeople(this._repository);

  final PeopleRepository _repository;

  @override
  Future<Either<Failure, PaginatedEntity<Person>>> call(
    PeopleSearchParams params,
  ) => _repository.searchPeople(params.query.trim(), params.page);
}
