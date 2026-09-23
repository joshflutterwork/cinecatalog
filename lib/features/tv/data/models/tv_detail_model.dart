import 'package:cinecatalog/core/common/media.dart';
import 'package:cinecatalog/core/network/common_models.dart';
import 'package:cinecatalog/core/network/json.dart';
import 'package:cinecatalog/features/tv/data/models/tv_show_model.dart';
import 'package:cinecatalog/features/tv/domain/entities/tv_detail.dart';

/// `/tv/{id}?append_to_response=credits,videos,similar`.
final class TvDetailModel {
  const TvDetailModel({
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

  factory TvDetailModel.fromJson(Map<String, dynamic> json) => TvDetailModel(
    show: TvShowModel.fromJson(json),
    numberOfSeasons: json.intOr('number_of_seasons'),
    numberOfEpisodes: json.intOr('number_of_episodes'),
    seasons: [
      for (final s in json.objects('seasons'))
        Season(
          id: s.requireInt('id'),
          name: s.stringOr('name'),
          seasonNumber: s.intOr('season_number'),
          episodeCount: s.intOr('episode_count'),
          posterPath: s.stringOrNull('poster_path'),
          airDate: s.dateOrNull('air_date'),
        ),
    ],
    networks: [
      for (final n in json.objects('networks')) ?n.stringOrNull('name'),
    ],
    genres: CommonModels.genres(json),
    status: json.stringOr('status', '–'),
    cast: CommonModels.cast(json),
    trailers: CommonModels.trailers(json),
    similar: json
        .object('similar')
        .objects('results')
        .map(TvShowModel.fromJson)
        .toList(),
  );

  final TvShowModel show;
  final int numberOfSeasons;
  final int numberOfEpisodes;
  final List<Season> seasons;
  final List<String> networks;
  final List<Genre> genres;
  final String status;
  final List<CastMember> cast;
  final List<Trailer> trailers;
  final List<TvShowModel> similar;

  TvDetail toEntity() => TvDetail(
    show: show.toEntity(),
    numberOfSeasons: numberOfSeasons,
    numberOfEpisodes: numberOfEpisodes,
    seasons: seasons,
    networks: networks,
    genres: genres,
    status: status,
    cast: cast,
    trailers: trailers,
    similar: similar.map((s) => s.toEntity()).toList(),
  );
}
