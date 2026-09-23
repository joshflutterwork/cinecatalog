import 'package:cinecatalog/core/error/failure.dart';
import 'package:cinecatalog/core/state/paging.dart';
import 'package:cinecatalog/features/movie/domain/entities/movie.dart';

/// One movie category list (top rated, upcoming, now playing, popular).
sealed class MovieListState {
  const MovieListState();
}

/// Page 1 is loading: show the skeleton.
final class MovieListLoading extends MovieListState {
  const MovieListLoading();
}

/// Page 1 came back with no movies.
final class MovieListEmpty extends MovieListState {
  const MovieListEmpty();
}

/// Page 1 failed: show the error card.
final class MovieListError extends MovieListState {
  const MovieListError(this.failure);

  final Failure failure;
}

/// Movies on screen; [data] also says whether the next page is loading or
/// failed.
final class MovieListLoaded extends MovieListState {
  const MovieListLoaded(this.data);

  final PageData<Movie> data;

  List<Movie> get movies => data.items;
}
