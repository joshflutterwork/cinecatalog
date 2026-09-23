import 'package:cinecatalog/core/error/failure.dart';
import 'package:cinecatalog/core/usecase/usecase.dart';
import 'package:cinecatalog/features/search/domain/entities/search_result.dart';
import 'package:cinecatalog/features/search/domain/repositories/search_repository.dart';
import 'package:fpdart/fpdart.dart';

/// Today's trending titles and people, offered before the user types.
final class GetTrending implements UseCase<List<SearchResult>, void> {
  const GetTrending(this._repository);

  final SearchRepository _repository;

  @override
  Future<Either<Failure, List<SearchResult>>> call(void _) =>
      _repository.getTrending();
}
