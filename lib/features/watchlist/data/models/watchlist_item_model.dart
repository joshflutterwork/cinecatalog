import 'package:cinecatalog/core/common/media.dart';
import 'package:cinecatalog/core/network/json.dart';
import 'package:cinecatalog/features/movie/domain/entities/movie.dart';
import 'package:cinecatalog/features/tv/domain/entities/tv_show.dart';

/// What the watchlist keeps per title: enough to draw the row and open the
/// detail page without a network call.
final class WatchlistItemModel {
  const WatchlistItemModel({
    required this.mediaType,
    required this.id,
    required this.title,
    required this.overview,
    required this.voteAverage,
    this.posterPath,
    this.backdropPath,
    this.date,
  });

  factory WatchlistItemModel.fromMedia(Media media) => WatchlistItemModel(
    mediaType: media.mediaType,
    id: media.id,
    title: media.title,
    overview: media.overview,
    voteAverage: media.voteAverage,
    posterPath: media.posterPath,
    backdropPath: media.backdropPath,
    date: media.date,
  );

  factory WatchlistItemModel.fromJson(Map<String, dynamic> json) =>
      WatchlistItemModel(
        mediaType: MediaType.values.byName(json.stringOr('media_type')),
        id: json.requireInt('id'),
        title: json.stringOr('title'),
        overview: json.stringOr('overview'),
        voteAverage: json.doubleOr('vote_average'),
        posterPath: json.stringOrNull('poster_path'),
        backdropPath: json.stringOrNull('backdrop_path'),
        date: json.dateOrNull('date'),
      );

  final MediaType mediaType;
  final int id;
  final String title;
  final String overview;
  final double voteAverage;
  final String? posterPath;
  final String? backdropPath;
  final DateTime? date;

  Map<String, dynamic> toJson() => {
    'media_type': mediaType.name,
    'id': id,
    'title': title,
    'overview': overview,
    'vote_average': voteAverage,
    'poster_path': posterPath,
    'backdrop_path': backdropPath,
    'date': date?.toIso8601String().substring(0, 10),
  };

  Media toEntity() => switch (mediaType) {
    MediaType.tv => TvShow(
      id: id,
      title: title,
      overview: overview,
      voteAverage: voteAverage,
      posterPath: posterPath,
      backdropPath: backdropPath,
      date: date,
    ),
    // Only movies and shows are ever saved.
    MediaType.movie || MediaType.person => Movie(
      id: id,
      title: title,
      overview: overview,
      voteAverage: voteAverage,
      posterPath: posterPath,
      backdropPath: backdropPath,
      date: date,
    ),
  };
}
