import 'package:cinecatalog/core/common/media.dart';
import 'package:cinecatalog/core/config/shared_preferences_provider.dart';
import 'package:cinecatalog/core/error/failure.dart';
import 'package:cinecatalog/features/watchlist/data/datasources/watchlist_local_datasource.dart';
import 'package:cinecatalog/features/watchlist/data/repositories/watchlist_repository_impl.dart';
import 'package:cinecatalog/features/watchlist/domain/repositories/watchlist_repository.dart';
import 'package:cinecatalog/features/watchlist/domain/usecases/watchlist_usecases.dart';
import 'package:cinecatalog/features/watchlist/presentation/state/watchlist_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';

final watchlistLocalDataSourceProvider = Provider<WatchlistLocalDataSource>(
  (ref) => WatchlistLocalDataSourceImpl(ref.watch(sharedPreferencesProvider)),
);

/// Tests override this to keep the watchlist in memory.
final watchlistRepositoryProvider = Provider<WatchlistRepository>(
  (ref) => WatchlistRepositoryImpl(ref.watch(watchlistLocalDataSourceProvider)),
);

final getWatchlistProvider = Provider<GetWatchlist>(
  (ref) => GetWatchlist(ref.watch(watchlistRepositoryProvider)),
);

final addToWatchlistProvider = Provider<AddToWatchlist>(
  (ref) => AddToWatchlist(ref.watch(watchlistRepositoryProvider)),
);

final removeFromWatchlistProvider = Provider<RemoveFromWatchlist>(
  (ref) => RemoveFromWatchlist(ref.watch(watchlistRepositoryProvider)),
);

/// Kept alive: the detail pages' heart and the Watchlist page share it.
final watchlistProvider = NotifierProvider<WatchlistNotifier, WatchlistState>(
  WatchlistNotifier.new,
);

/// Loading → Loaded | Empty | Error. [toggle] and [remove] update the state
/// straight away and roll back if saving fails.
final class WatchlistNotifier extends Notifier<WatchlistState> {
  @override
  WatchlistState build() {
    _load();
    return const WatchlistLoading();
  }

  Future<void> _load() async {
    final result = await ref.read(getWatchlistProvider)(null);
    if (!ref.mounted) return;
    state = result.fold(WatchlistError.new, _stateOf);
  }

  void retry() {
    state = const WatchlistLoading();
    _load();
  }

  /// Saves [media], or removes it when already saved. Returns the failure
  /// when it could not be saved, so the page can say so.
  Future<Failure?> toggle(Media media) => state.contains(media)
      ? remove(media)
      : _apply(
          optimistic: [media, ...state.items],
          write: () => ref.read(addToWatchlistProvider)(media),
        );

  Future<Failure?> remove(Media media) => _apply(
    optimistic: state.items
        .where((m) => !(m.id == media.id && m.mediaType == media.mediaType))
        .toList(),
    write: () => ref.read(removeFromWatchlistProvider)(media),
  );

  Future<Failure?> _apply({
    required List<Media> optimistic,
    required Future<Either<Failure, List<Media>>> Function() write,
  }) async {
    final before = state;
    state = _stateOf(optimistic);
    final result = await write();
    if (!ref.mounted) return null;
    return result.fold<Failure?>(
      (failure) {
        state = before;
        return failure;
      },
      (items) {
        state = _stateOf(items);
        return null;
      },
    );
  }

  static WatchlistState _stateOf(List<Media> items) =>
      items.isEmpty ? const WatchlistEmpty() : WatchlistLoaded(items);
}
