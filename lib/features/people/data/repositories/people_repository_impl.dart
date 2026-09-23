import 'package:cinecatalog/core/common/paginated_entity.dart';
import 'package:cinecatalog/core/error/failure.dart';
import 'package:cinecatalog/core/network/guard_request.dart';
import 'package:cinecatalog/features/people/data/datasources/people_remote_datasource.dart';
import 'package:cinecatalog/features/people/domain/entities/person.dart';
import 'package:cinecatalog/features/people/domain/repositories/people_repository.dart';
import 'package:fpdart/fpdart.dart';

final class PeopleRepositoryImpl implements PeopleRepository {
  const PeopleRepositoryImpl(this._remote);

  final PeopleRemoteDataSource _remote;

  @override
  Future<Either<Failure, PaginatedEntity<Person>>> getPopularPeople(int page) =>
      guardRequest(() async {
        final response = await _remote.getPopularPeople(page);
        return response.toEntity((p) => p.toEntity());
      });

  @override
  Future<Either<Failure, PersonDetail>> getPersonDetail(int id) =>
      guardRequest(() async => (await _remote.getPersonDetail(id)).toEntity());

  @override
  Future<Either<Failure, PaginatedEntity<Person>>> searchPeople(
    String query,
    int page,
  ) => guardRequest(() async {
    final response = await _remote.searchPeople(query, page);
    return response.toEntity((p) => p.toEntity());
  });
}
