import 'package:cinecatalog/core/network/json.dart';
import 'package:cinecatalog/features/tv/domain/entities/tv_show.dart';

/// A show as TMDB lists it. TV uses `name` and `first_air_date` where movies
/// use `title` and `release_date`.
final class TvShowModel {
  const TvShowModel({
    required this.id,
    required this.name,
    required this.overview,
    required this.voteAverage,
    this.posterPath,
    this.backdropPath,
    this.firstAirDate,
  });

  factory TvShowModel.fromJson(Map<String, dynamic> json) => TvShowModel(
    id: json.requireInt('id'),
    name: json.stringOr('name'),
    overview: json.stringOr('overview'),
    voteAverage: json.doubleOr('vote_average'),
    posterPath: json.stringOrNull('poster_path'),
    backdropPath: json.stringOrNull('backdrop_path'),
    firstAirDate: json.dateOrNull('first_air_date'),
  );

  final int id;
  final String name;
  final String overview;
  final double voteAverage;
  final String? posterPath;
  final String? backdropPath;
  final DateTime? firstAirDate;

  TvShow toEntity() => TvShow(
    id: id,
    title: name,
    overview: overview,
    voteAverage: voteAverage,
    posterPath: posterPath,
    backdropPath: backdropPath,
    date: firstAirDate,
  );
}
