import 'package:cinecatalog/core/common/paginated_entity.dart';
import 'package:cinecatalog/core/error/failure.dart';
import 'package:cinecatalog/features/people/domain/entities/person.dart';
import 'package:fpdart/fpdart.dart';

abstract interface class PeopleRepository {
  Future<Either<Failure, PaginatedEntity<Person>>> getPopularPeople(int page);

  Future<Either<Failure, PersonDetail>> getPersonDetail(int id);

  /// People whose name matches [query] (`/search/person`).
  Future<Either<Failure, PaginatedEntity<Person>>> searchPeople(
    String query,
    int page,
  );
}
