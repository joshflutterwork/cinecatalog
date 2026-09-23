import 'package:cinecatalog/core/common/media.dart';
import 'package:cinecatalog/core/error/failure.dart';
import 'package:cinecatalog/core/usecase/usecase.dart';
import 'package:cinecatalog/features/watchlist/domain/repositories/watchlist_repository.dart';
import 'package:fpdart/fpdart.dart';

final class GetWatchlist implements UseCase<List<Media>, void> {
  const GetWatchlist(this._repository);

  final WatchlistRepository _repository;

  @override
  Future<Either<Failure, List<Media>>> call(void _) =>
      _repository.getWatchlist();
}

final class AddToWatchlist implements UseCase<List<Media>, Media> {
  const AddToWatchlist(this._repository);

  final WatchlistRepository _repository;

  @override
  Future<Either<Failure, List<Media>>> call(Media media) =>
      _repository.add(media);
}

final class RemoveFromWatchlist implements UseCase<List<Media>, Media> {
  const RemoveFromWatchlist(this._repository);

  final WatchlistRepository _repository;

  @override
  Future<Either<Failure, List<Media>>> call(Media media) =>
      _repository.remove(media);
}
