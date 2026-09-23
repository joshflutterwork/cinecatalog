enum MediaType { movie, tv, person }

/// What the deck, rails and lists need from a movie or a TV show.
///
/// TMDB calls a movie's name `title` and a show's name `name`; both map to
/// [title] here so shared widgets do not care which one they get.
abstract class Media {
  const Media({
    required this.id,
    required this.title,
    required this.overview,
    required this.voteAverage,
    this.posterPath,
    this.backdropPath,
    this.date,
  });

  final int id;
  final String title;
  final String overview;
  final double voteAverage;
  final String? posterPath;
  final String? backdropPath;

  /// `release_date` for movies, `first_air_date` for TV. Null when unknown.
  final DateTime? date;

  MediaType get mediaType;

  int? get year => date?.year;
}

final class Genre {
  const Genre({required this.id, required this.name});

  final int id;
  final String name;
}

final class CastMember {
  const CastMember({
    required this.id,
    required this.name,
    required this.character,
    this.profilePath,
  });

  final int id;
  final String name;
  final String character;
  final String? profilePath;
}

/// A YouTube trailer. The data layer keeps only `site == YouTube` and
/// `type == Trailer`.
final class Trailer {
  const Trailer({required this.key, required this.name});

  final String key;
  final String name;
}
