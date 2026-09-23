import 'package:cinecatalog/core/common/media.dart';
import 'package:cinecatalog/features/movie/domain/entities/movie.dart';

final class MovieDetail {
  const MovieDetail({
    required this.movie,
    required this.genres,
    required this.status,
    required this.cast,
    required this.trailers,
    required this.similar,
    this.runtime,
    this.tagline,
  });

  final Movie movie;
  final List<Genre> genres;

  /// Minutes. Null when TMDB does not know it yet.
  final int? runtime;
  final String? tagline;
  final String status;
  final List<CastMember> cast;
  final List<Trailer> trailers;
  final List<Movie> similar;
}
