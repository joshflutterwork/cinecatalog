import 'package:cinecatalog/core/error/failure.dart';
import 'package:fpdart/fpdart.dart';

/// A single application action. Implementations stay free of Flutter and Dio.
abstract interface class UseCase<T, Params> {
  Future<Either<Failure, T>> call(Params params);
}

/// Params for list use cases: a category plus a 1-based page.
final class PageParams<C> {
  const PageParams(this.category, this.page);

  final C category;
  final int page;
}
