import 'package:cinecatalog/core/common/media.dart';

final class TvShow extends Media {
  const TvShow({
    required super.id,
    required super.title,
    required super.overview,
    required super.voteAverage,
    super.posterPath,
    super.backdropPath,
    super.date,
  });

  @override
  MediaType get mediaType => MediaType.tv;
}
