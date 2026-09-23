import 'package:cinecatalog/core/network/json.dart';
import 'package:cinecatalog/features/movie/domain/entities/movie.dart';

/// A movie as TMDB lists it (`/movie/*`, `similar`, `known_for`, search).
final class MovieModel {
  const MovieModel({
    required this.id,
    required this.title,
    required this.overview,
    required this.voteAverage,
    this.posterPath,
    this.backdropPath,
    this.releaseDate,
  });

  factory MovieModel.fromJson(Map<String, dynamic> json) => MovieModel(
    id: json.requireInt('id'),
    title: json.stringOr('title'),
    overview: json.stringOr('overview'),
    voteAverage: json.doubleOr('vote_average'),
    posterPath: json.stringOrNull('poster_path'),
    backdropPath: json.stringOrNull('backdrop_path'),
    releaseDate: json.dateOrNull('release_date'),
  );

  final int id;
  final String title;
  final String overview;
  final double voteAverage;
  final String? posterPath;
  final String? backdropPath;
  final DateTime? releaseDate;

  Movie toEntity() => Movie(
    id: id,
    title: title,
    overview: overview,
    voteAverage: voteAverage,
    posterPath: posterPath,
    backdropPath: backdropPath,
    date: releaseDate,
  );
}
