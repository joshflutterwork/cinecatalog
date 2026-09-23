import 'package:cinecatalog/core/error/failure.dart';
import 'package:cinecatalog/core/state/paging.dart';
import 'package:cinecatalog/features/tv/domain/entities/tv_show.dart';

/// One TV category list (popular, top rated, on the air, airing today).
sealed class TvListState {
  const TvListState();
}

/// Page 1 is loading: show the skeleton.
final class TvListLoading extends TvListState {
  const TvListLoading();
}

/// Page 1 came back with no shows.
final class TvListEmpty extends TvListState {
  const TvListEmpty();
}

/// Page 1 failed: show the error card.
final class TvListError extends TvListState {
  const TvListError(this.failure);

  final Failure failure;
}

/// Shows on screen; [data] also says whether the next page is
/// loading or failed.
final class TvListLoaded extends TvListState {
  const TvListLoaded(this.data);

  final PageData<TvShow> data;

  List<TvShow> get shows => data.items;
}
