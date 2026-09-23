import 'package:cinecatalog/core/network/api_client.dart';
import 'package:cinecatalog/core/network/api_endpoints.dart';
import 'package:cinecatalog/core/network/paginated_response.dart';
import 'package:cinecatalog/features/movie/data/models/movie_model.dart';
import 'package:cinecatalog/features/people/data/models/person_model.dart';
import 'package:cinecatalog/features/search/domain/entities/search_result.dart';
import 'package:cinecatalog/features/tv/data/models/tv_show_model.dart';

/// One `/search/multi` row by `media_type`; unknown types are dropped.
SearchResult? searchResultFromJson(Map<String, dynamic> json) =>
    switch (json['media_type']) {
      'movie' => MovieResult(MovieModel.fromJson(json).toEntity()),
      'tv' => TvResult(TvShowModel.fromJson(json).toEntity()),
      'person' => PersonResult(PersonModel.fromJson(json).toEntity()),
      _ => null,
    };

/// Raw TMDB search call. Errors surface as `ApiClient.get` throws them.
abstract interface class SearchRemoteDataSource {
  Future<PaginatedResponse<SearchResult>> searchMulti(String query, int page);

  Future<PaginatedResponse<SearchResult>> getTrending();
}

final class SearchRemoteDataSourceImpl implements SearchRemoteDataSource {
  const SearchRemoteDataSourceImpl(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<PaginatedResponse<SearchResult>> searchMulti(String query, int page) =>
      _apiClient.get<PaginatedResponse<SearchResult>>(
        ApiEndpoints.search.multi,
        query: {
          ApiParams.query: query,
          ApiParams.page: page,
          ApiParams.includeAdult: false,
        },
        parser: (json) =>
            PaginatedResponse.fromJson(json, searchResultFromJson),
      );

  @override
  Future<PaginatedResponse<SearchResult>> getTrending() =>
      _apiClient.get<PaginatedResponse<SearchResult>>(
        ApiEndpoints.trending.allDay,
        parser: (json) =>
            PaginatedResponse.fromJson(json, searchResultFromJson),
      );
}
