import 'package:cinecatalog/core/network/api_client.dart';
import 'package:cinecatalog/core/network/api_endpoints.dart';
import 'package:cinecatalog/core/network/paginated_response.dart';
import 'package:cinecatalog/features/people/data/models/person_model.dart';

/// Raw TMDB people calls. Errors surface as `ApiClient.get` throws them.
abstract interface class PeopleRemoteDataSource {
  Future<PaginatedResponse<PersonModel>> getPopularPeople(int page);

  Future<PersonDetailModel> getPersonDetail(int id);

  Future<PaginatedResponse<PersonModel>> searchPeople(String query, int page);
}

final class PeopleRemoteDataSourceImpl implements PeopleRemoteDataSource {
  const PeopleRemoteDataSourceImpl(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<PaginatedResponse<PersonModel>> getPopularPeople(int page) =>
      _apiClient.get<PaginatedResponse<PersonModel>>(
        ApiEndpoints.person.popular,
        query: {ApiParams.page: page},
        parser: (json) =>
            PaginatedResponse.fromJson(json, PersonModel.fromJson),
      );

  @override
  Future<PersonDetailModel> getPersonDetail(int id) =>
      _apiClient.get<PersonDetailModel>(
        ApiEndpoints.person.detail(id),
        query: {ApiParams.appendToResponse: ApiAppend.combinedCredits},
        parser: PersonDetailModel.fromJson,
      );

  @override
  Future<PaginatedResponse<PersonModel>> searchPeople(String query, int page) =>
      _apiClient.get<PaginatedResponse<PersonModel>>(
        ApiEndpoints.search.person,
        query: {
          ApiParams.query: query,
          ApiParams.page: page,
          ApiParams.includeAdult: false,
        },
        parser: (json) =>
            PaginatedResponse.fromJson(json, PersonModel.fromJson),
      );
}
