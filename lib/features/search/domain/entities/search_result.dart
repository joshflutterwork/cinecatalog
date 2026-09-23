import 'package:cinecatalog/features/movie/domain/entities/movie.dart';
import 'package:cinecatalog/features/people/domain/entities/person.dart';
import 'package:cinecatalog/features/tv/domain/entities/tv_show.dart';

/// One row of `/search/multi`, split by `media_type`.
sealed class SearchResult {
  const SearchResult();

  int get id;
}

final class MovieResult extends SearchResult {
  const MovieResult(this.movie);

  final Movie movie;

  @override
  int get id => movie.id;
}

final class TvResult extends SearchResult {
  const TvResult(this.show);

  final TvShow show;

  @override
  int get id => show.id;
}

final class PersonResult extends SearchResult {
  const PersonResult(this.person);

  final Person person;

  @override
  int get id => person.id;
}
