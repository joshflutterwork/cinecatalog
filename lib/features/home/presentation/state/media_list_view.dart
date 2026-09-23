import 'package:cinecatalog/core/common/media.dart';
import 'package:cinecatalog/core/error/failure.dart';
import 'package:cinecatalog/core/state/paging.dart';

/// UI-only view of a movie or TV list for the widgets both share (deck,
/// rails, View all). `BrowseCategory` maps `MovieListState` and
/// `TvListState` onto it; the features themselves never see this type.
sealed class MediaListView {
  const MediaListView();
}

final class MediaListLoading extends MediaListView {
  const MediaListLoading();
}

final class MediaListEmpty extends MediaListView {
  const MediaListEmpty();
}

final class MediaListError extends MediaListView {
  const MediaListError(this.failure);

  final Failure failure;
}

final class MediaListLoaded extends MediaListView {
  const MediaListLoaded(this.data);

  final PageData<Media> data;
}
