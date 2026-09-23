import 'package:cinecatalog/core/common/media.dart';
import 'package:cinecatalog/core/network/common_models.dart';
import 'package:cinecatalog/core/network/json.dart';
import 'package:cinecatalog/features/movie/data/models/movie_model.dart';
import 'package:cinecatalog/features/movie/domain/entities/movie_detail.dart';

/// `/movie/{id}?append_to_response=credits,videos,similar`.
final class MovieDetailModel {
  const MovieDetailModel({
    required this.movie,
    required this.genres,
    required this.status,
    required this.cast,
    required this.trailers,
    required this.similar,
    this.runtime,
    this.tagline,
  });

  factory MovieDetailModel.fromJson(Map<String, dynamic> json) =>
      MovieDetailModel(
        movie: MovieModel.fromJson(json),
        genres: CommonModels.genres(json),
        // TMDB sends 0 for "unknown" on unreleased titles.
        runtime: switch (json.intOrNull('runtime')) {
          final r? when r > 0 => r,
          _ => null,
        },
        tagline: json.stringOrNull('tagline'),
        status: json.stringOr('status', '–'),
        cast: CommonModels.cast(json),
        trailers: CommonModels.trailers(json),
        similar: json
            .object('similar')
            .objects('results')
            .map(MovieModel.fromJson)
            .toList(),
      );

  final MovieModel movie;
  final List<Genre> genres;
  final int? runtime;
  final String? tagline;
  final String status;
  final List<CastMember> cast;
  final List<Trailer> trailers;
  final List<MovieModel> similar;

  MovieDetail toEntity() => MovieDetail(
    movie: movie.toEntity(),
    genres: genres,
    runtime: runtime,
    tagline: tagline,
    status: status,
    cast: cast,
    trailers: trailers,
    similar: similar.map((m) => m.toEntity()).toList(),
  );
}
