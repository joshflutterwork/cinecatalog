import 'package:cinecatalog/core/common/media.dart';
import 'package:cinecatalog/features/tv/domain/entities/tv_show.dart';

final class TvDetail {
  const TvDetail({
    required this.show,
    required this.numberOfSeasons,
    required this.numberOfEpisodes,
    required this.seasons,
    required this.networks,
    required this.genres,
    required this.status,
    required this.cast,
    required this.trailers,
    required this.similar,
  });

  final TvShow show;
  final int numberOfSeasons;
  final int numberOfEpisodes;
  final List<Season> seasons;
  final List<String> networks;
  final List<Genre> genres;
  final String status;
  final List<CastMember> cast;
  final List<Trailer> trailers;
  final List<TvShow> similar;
}

final class Season {
  const Season({
    required this.id,
    required this.name,
    required this.seasonNumber,
    required this.episodeCount,
    this.posterPath,
    this.airDate,
  });

  final int id;
  final String name;
  final int seasonNumber;
  final int episodeCount;
  final String? posterPath;
  final DateTime? airDate;
}
