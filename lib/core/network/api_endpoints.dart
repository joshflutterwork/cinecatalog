/// Every TMDB path the app calls, grouped by resource:
/// `ApiEndpoints.movie.topRated`, `ApiEndpoints.movie.detail(id)`.
///
/// Datasources and interceptors read paths from here only; no path string
/// is written anywhere else.
abstract final class ApiEndpoints {
  static const movie = MovieEndpoints._();
  static const tv = TvEndpoints._();
  static const person = PersonEndpoints._();
  static const search = SearchEndpoints._();
  static const trending = TrendingEndpoints._();

  /// Checks that the bearer token is valid.
  static const authentication = '/authentication';
}

final class MovieEndpoints {
  const MovieEndpoints._();

  String get topRated => '/movie/top_rated';
  String get upcoming => '/movie/upcoming';
  String get nowPlaying => '/movie/now_playing';
  String get popular => '/movie/popular';

  /// The four category lists, which accept `region`.
  Set<String> get lists => {topRated, upcoming, nowPlaying, popular};

  String detail(int id) => '/movie/$id';
}

final class TvEndpoints {
  const TvEndpoints._();

  String get popular => '/tv/popular';
  String get topRated => '/tv/top_rated';
  String get onTheAir => '/tv/on_the_air';
  String get airingToday => '/tv/airing_today';

  String detail(int id) => '/tv/$id';
}

final class PersonEndpoints {
  const PersonEndpoints._();

  String get popular => '/person/popular';

  String detail(int id) => '/person/$id';
}

final class SearchEndpoints {
  const SearchEndpoints._();

  /// Movies, shows and people in one list, told apart by `media_type`.
  String get multi => '/search/multi';

  /// People only.
  String get person => '/search/person';
}

final class TrendingEndpoints {
  const TrendingEndpoints._();

  String get allDay => '/trending/all/day';
}

/// TMDB query parameter names.
abstract final class ApiParams {
  static const page = 'page';
  static const query = 'query';
  static const language = 'language';
  static const region = 'region';
  static const includeAdult = 'include_adult';
  static const appendToResponse = 'append_to_response';
  static const includeVideoLanguage = 'include_video_language';
}

/// Values for [ApiParams.appendToResponse]; join several with [join].
abstract final class ApiAppend {
  static const credits = 'credits';
  static const combinedCredits = 'combined_credits';
  static const videos = 'videos';
  static const similar = 'similar';

  static String join(List<String> parts) => parts.join(',');
}
