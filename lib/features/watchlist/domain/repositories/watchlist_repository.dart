import 'package:cinecatalog/core/common/media.dart';
import 'package:cinecatalog/core/error/failure.dart';
import 'package:fpdart/fpdart.dart';

/// Movies and shows the user saved, kept on the device.
abstract interface class WatchlistRepository {
  /// Most recently saved first.
  Future<Either<Failure, List<Media>>> getWatchlist();

  /// Saves [media] at the top; saving it again moves it to the top.
  Future<Either<Failure, List<Media>>> add(Media media);

  Future<Either<Failure, List<Media>>> remove(Media media);
}
