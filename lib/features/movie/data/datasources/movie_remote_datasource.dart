import 'package:cinecatalog/core/network/api_client.dart';
import 'package:cinecatalog/core/network/api_endpoints.dart';
import 'package:cinecatalog/core/network/paginated_response.dart';
import 'package:cinecatalog/features/movie/data/models/movie_detail_model.dart';
import 'package:cinecatalog/features/movie/data/models/movie_model.dart';
import 'package:cinecatalog/features/movie/domain/repositories/movie_repository.dart';

extension MovieCategoryPath on MovieCategory {
  String get path => switch (this) {
    MovieCategory.topRated => ApiEndpoints.movie.topRated,
    MovieCategory.upcoming => ApiEndpoints.movie.upcoming,
    MovieCategory.nowPlaying => ApiEndpoints.movie.nowPlaying,
    MovieCategory.popular => ApiEndpoints.movie.popular,
  };
}

/// Raw TMDB movie calls. Errors surface as `ApiClient.get` throws them; the
/// repository turns them into failures.
abstract interface class MovieRemoteDataSource {
  Future<PaginatedResponse<MovieModel>> getMovies(
    MovieCategory category,
    int page,
  );

  Future<MovieDetailModel> getMovieDetail(int id);
}

final class MovieRemoteDataSourceImpl implements MovieRemoteDataSource {
  const MovieRemoteDataSourceImpl(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<PaginatedResponse<MovieModel>> getMovies(
    MovieCategory category,
    int page,
  ) => _apiClient.get<PaginatedResponse<MovieModel>>(
    category.path,
    query: {ApiParams.page: page},
    parser: (json) => PaginatedResponse.fromJson(json, MovieModel.fromJson),
  );

  @override
  Future<MovieDetailModel> getMovieDetail(int id) =>
      _apiClient.get<MovieDetailModel>(
        ApiEndpoints.movie.detail(id),
        query: {
          ApiParams.appendToResponse: ApiAppend.join([
            ApiAppend.credits,
            ApiAppend.videos,
            ApiAppend.similar,
          ]),
        },
        parser: MovieDetailModel.fromJson,
      );
}
