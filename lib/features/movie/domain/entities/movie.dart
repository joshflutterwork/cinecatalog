import 'package:cinecatalog/core/common/media.dart';

final class Movie extends Media {
  const Movie({
    required super.id,
    required super.title,
    required super.overview,
    required super.voteAverage,
    super.posterPath,
    super.backdropPath,
    super.date,
  });

  @override
  MediaType get mediaType => MediaType.movie;
}
