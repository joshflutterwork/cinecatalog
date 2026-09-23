import 'package:cinecatalog/core/common/media.dart';
import 'package:cinecatalog/core/error/failure.dart';

/// The saved movies and shows, read from the device.
sealed class WatchlistState {
  const WatchlistState();

  /// Saved titles; empty for every state but [WatchlistLoaded].
  List<Media> get items => const [];

  bool contains(Media media) =>
      items.any((m) => m.id == media.id && m.mediaType == media.mediaType);
}

final class WatchlistLoading extends WatchlistState {
  const WatchlistLoading();
}

/// Nothing saved yet.
final class WatchlistEmpty extends WatchlistState {
  const WatchlistEmpty();
}

/// The stored watchlist could not be read.
final class WatchlistError extends WatchlistState {
  const WatchlistError(this.failure);

  final Failure failure;
}

/// Most recently saved first.
final class WatchlistLoaded extends WatchlistState {
  const WatchlistLoaded(this.items);

  @override
  final List<Media> items;
}
