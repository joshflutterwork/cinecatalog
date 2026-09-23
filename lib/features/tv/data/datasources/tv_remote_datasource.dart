import 'package:cinecatalog/core/network/api_client.dart';
import 'package:cinecatalog/core/network/api_endpoints.dart';
import 'package:cinecatalog/core/network/paginated_response.dart';
import 'package:cinecatalog/features/tv/data/models/tv_detail_model.dart';
import 'package:cinecatalog/features/tv/data/models/tv_show_model.dart';
import 'package:cinecatalog/features/tv/domain/repositories/tv_repository.dart';

extension TvCategoryPath on TvCategory {
  String get path => switch (this) {
    TvCategory.popular => ApiEndpoints.tv.popular,
    TvCategory.topRated => ApiEndpoints.tv.topRated,
    TvCategory.onTheAir => ApiEndpoints.tv.onTheAir,
    TvCategory.airingToday => ApiEndpoints.tv.airingToday,
  };
}

/// Raw TMDB TV calls. Errors surface as `ApiClient.get` throws them.
abstract interface class TvRemoteDataSource {
  Future<PaginatedResponse<TvShowModel>> getShows(
    TvCategory category,
    int page,
  );

  Future<TvDetailModel> getTvDetail(int id);
}

final class TvRemoteDataSourceImpl implements TvRemoteDataSource {
  const TvRemoteDataSourceImpl(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<PaginatedResponse<TvShowModel>> getShows(
    TvCategory category,
    int page,
  ) => _apiClient.get<PaginatedResponse<TvShowModel>>(
    category.path,
    query: {ApiParams.page: page},
    parser: (json) => PaginatedResponse.fromJson(json, TvShowModel.fromJson),
  );

  @override
  Future<TvDetailModel> getTvDetail(int id) => _apiClient.get<TvDetailModel>(
    ApiEndpoints.tv.detail(id),
    query: {
      ApiParams.appendToResponse: ApiAppend.join([
        ApiAppend.credits,
        ApiAppend.videos,
        ApiAppend.similar,
      ]),
    },
    parser: TvDetailModel.fromJson,
  );
}
