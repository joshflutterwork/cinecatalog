import 'package:cinecatalog/core/common/paginated_entity.dart';
import 'package:cinecatalog/core/error/failure.dart';
import 'package:cinecatalog/core/usecase/usecase.dart';
import 'package:cinecatalog/features/people/domain/entities/person.dart';
import 'package:cinecatalog/features/people/domain/repositories/people_repository.dart';
import 'package:fpdart/fpdart.dart';

final class GetPopularPeople implements UseCase<PaginatedEntity<Person>, int> {
  const GetPopularPeople(this._repository);

  final PeopleRepository _repository;

  @override
  Future<Either<Failure, PaginatedEntity<Person>>> call(int page) =>
      _repository.getPopularPeople(page);
}
