import 'package:cinecatalog/core/common/media.dart';
import 'package:cinecatalog/core/state/paging.dart';
import 'package:cinecatalog/features/home/presentation/state/media_list_view.dart';
import 'package:cinecatalog/features/movie/domain/repositories/movie_repository.dart';
import 'package:cinecatalog/features/movie/presentation/providers/movie_providers.dart';
import 'package:cinecatalog/features/movie/presentation/state/movie_list_state.dart';
import 'package:cinecatalog/features/tv/domain/repositories/tv_repository.dart';
import 'package:cinecatalog/features/tv/presentation/providers/tv_providers.dart';
import 'package:cinecatalog/features/tv/presentation/state/tv_list_state.dart';
import 'package:cinecatalog/router/routes.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum HomeMode { movies, tv }

/// One of the 8 movie/TV lists, seen through [Media] so the deck, rails and
/// View all page do not care whether it holds movies or shows.
sealed class BrowseCategory {
  const BrowseCategory();

  String get title;
  String get kicker;
  String get mediaSegment;
  String get categorySegment;

  /// This list's state, mapped for the shared widgets. Rebuilds on change.
  MediaListView watch(WidgetRef ref);

  /// Current state without listening, e.g. inside a callback.
  MediaListView read(WidgetRef ref);

  PagingActions notifier(WidgetRef ref);

  String get path => Routes.list.build([mediaSegment, categorySegment]);

  /// Reverse of [path]; null for an unknown URL.
  static BrowseCategory? parse(String media, String category) =>
      switch (media) {
        'movie' =>
          MovieCategory.values
              .where((c) => c.name == category)
              .map(MovieBrowse.new)
              .firstOrNull,
        'tv' =>
          TvCategory.values
              .where((c) => c.name == category)
              .map(TvBrowse.new)
              .firstOrNull,
        _ => null,
      };
}

final class MovieBrowse extends BrowseCategory {
  const MovieBrowse(this.category);

  final MovieCategory category;

  @override
  String get title => switch (category) {
    MovieCategory.topRated => 'Top Rated Movies',
    MovieCategory.upcoming => 'Upcoming Movies',
    MovieCategory.nowPlaying => 'Now Playing Movies',
    MovieCategory.popular => 'Popular Movies',
  };

  @override
  String get kicker => 'Movies';

  @override
  String get mediaSegment => 'movie';

  @override
  String get categorySegment => category.name;

  @override
  MediaListView watch(WidgetRef ref) =>
      _view(ref.watch(movieListProvider(category)));

  @override
  MediaListView read(WidgetRef ref) =>
      _view(ref.read(movieListProvider(category)));

  @override
  PagingActions notifier(WidgetRef ref) =>
      ref.read(movieListProvider(category).notifier);

  static MediaListView _view(MovieListState state) => switch (state) {
    MovieListLoading() => const MediaListLoading(),
    MovieListEmpty() => const MediaListEmpty(),
    MovieListError(:final failure) => MediaListError(failure),
    MovieListLoaded(:final data) => MediaListLoaded(data),
  };
}

final class TvBrowse extends BrowseCategory {
  const TvBrowse(this.category);

  final TvCategory category;

  @override
  String get title => switch (category) {
    TvCategory.popular => 'Popular TV Shows',
    TvCategory.topRated => 'Top Rated TV Shows',
    TvCategory.onTheAir => 'On The Air',
    TvCategory.airingToday => 'Airing Today',
  };

  @override
  String get kicker => 'TV Shows';

  @override
  String get mediaSegment => 'tv';

  @override
  String get categorySegment => category.name;

  @override
  MediaListView watch(WidgetRef ref) =>
      _view(ref.watch(tvListProvider(category)));

  @override
  MediaListView read(WidgetRef ref) =>
      _view(ref.read(tvListProvider(category)));

  @override
  PagingActions notifier(WidgetRef ref) =>
      ref.read(tvListProvider(category).notifier);

  static MediaListView _view(TvListState state) => switch (state) {
    TvListLoading() => const MediaListLoading(),
    TvListEmpty() => const MediaListEmpty(),
    TvListError(:final failure) => MediaListError(failure),
    TvListLoaded(:final data) => MediaListLoaded(data),
  };
}

/// What each home tab shows: the stacked deck list, then three rails.
extension HomeModeSections on HomeMode {
  String get title => switch (this) {
    HomeMode.movies => 'Movies',
    HomeMode.tv => 'TV Shows',
  };

  BrowseCategory get deck => switch (this) {
    HomeMode.movies => const MovieBrowse(MovieCategory.topRated),
    HomeMode.tv => const TvBrowse(TvCategory.popular),
  };

  List<BrowseCategory> get rails => switch (this) {
    HomeMode.movies => const [
      MovieBrowse(MovieCategory.upcoming),
      MovieBrowse(MovieCategory.nowPlaying),
      MovieBrowse(MovieCategory.popular),
    ],
    HomeMode.tv => const [
      TvBrowse(TvCategory.topRated),
      TvBrowse(TvCategory.onTheAir),
      TvBrowse(TvCategory.airingToday),
    ],
  };
}

final homeModeProvider = NotifierProvider<HomeModeNotifier, HomeMode>(
  HomeModeNotifier.new,
);

final class HomeModeNotifier extends Notifier<HomeMode> {
  @override
  HomeMode build() => HomeMode.movies;

  // A setter would read oddly at call sites: `notifier.select(mode)`.
  // ignore: use_setters_to_change_properties
  void select(HomeMode mode) => state = mode;
}
