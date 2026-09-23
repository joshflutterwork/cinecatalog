import 'package:cinecatalog/core/common/media.dart';
import 'package:cinecatalog/core/error/failure.dart';
import 'package:cinecatalog/features/watchlist/data/datasources/watchlist_local_datasource.dart';
import 'package:cinecatalog/features/watchlist/data/models/watchlist_item_model.dart';
import 'package:cinecatalog/features/watchlist/domain/repositories/watchlist_repository.dart';
import 'package:fpdart/fpdart.dart';

final class WatchlistRepositoryImpl implements WatchlistRepository {
  const WatchlistRepositoryImpl(this._local);

  final WatchlistLocalDataSource _local;

  @override
  Future<Either<Failure, List<Media>>> getWatchlist() =>
      _guard(() async => _local.read());

  @override
  Future<Either<Failure, List<Media>>> add(Media media) => _guard(() async {
    final items = [
      WatchlistItemModel.fromMedia(media),
      ..._local.read().where((i) => !_same(i, media)),
    ];
    await _local.write(items);
    return items;
  });

  @override
  Future<Either<Failure, List<Media>>> remove(Media media) => _guard(() async {
    final items = _local.read().where((i) => !_same(i, media)).toList();
    await _local.write(items);
    return items;
  });

  static bool _same(WatchlistItemModel item, Media media) =>
      item.id == media.id && item.mediaType == media.mediaType;

  /// Local counterpart of `guardRequest`: storage errors become a
  /// [StorageFailure], never an exception.
  static Future<Either<Failure, List<Media>>> _guard(
    Future<List<WatchlistItemModel>> Function() body,
  ) async {
    try {
      final items = await body();
      return Right([for (final item in items) item.toEntity()]);
    } on FormatException catch (e) {
      return Left(StorageFailure(e.message));
    } on WatchlistWriteException {
      return const Left(StorageFailure('The watchlist could not be saved'));
    }
  }
}
