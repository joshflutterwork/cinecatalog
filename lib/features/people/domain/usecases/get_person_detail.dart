import 'package:cinecatalog/core/error/failure.dart';
import 'package:cinecatalog/core/usecase/usecase.dart';
import 'package:cinecatalog/features/people/domain/entities/person.dart';
import 'package:cinecatalog/features/people/domain/repositories/people_repository.dart';
import 'package:fpdart/fpdart.dart';

final class GetPersonDetail implements UseCase<PersonDetail, int> {
  const GetPersonDetail(this._repository);

  final PeopleRepository _repository;

  @override
  Future<Either<Failure, PersonDetail>> call(int id) =>
      _repository.getPersonDetail(id);
}
