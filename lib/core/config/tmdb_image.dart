/// TMDB image sizes used by the app.
enum TmdbImageSize {
  w185,
  w342,
  w500,
  w780,
  original;

  String get segment => name;
}

abstract final class TmdbImage {
  static const _base = 'https://image.tmdb.org/t/p';

  /// Full URL for a TMDB image path, or null when TMDB has no image.
  static String? url(String? path, TmdbImageSize size) {
    if (path == null || path.isEmpty) return null;
    return '$_base/${size.segment}$path';
  }
}
