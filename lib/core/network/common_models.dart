import 'package:cinecatalog/core/common/media.dart';
import 'package:cinecatalog/core/network/json.dart';

/// JSON pieces shared by the movie, TV and person detail endpoints.
abstract final class CommonModels {
  /// `genres: [{id, name}]`.
  static List<Genre> genres(Map<String, dynamic> json) => [
    for (final g in json.objects('genres'))
      Genre(id: g.requireInt('id'), name: g.stringOr('name')),
  ];

  /// `credits.cast` from `append_to_response=credits`.
  static List<CastMember> cast(Map<String, dynamic> json) => [
    for (final c in json.object('credits').objects('cast'))
      CastMember(
        id: c.requireInt('id'),
        name: c.stringOr('name'),
        character: c.stringOr('character'),
        profilePath: c.stringOrNull('profile_path'),
      ),
  ];

  /// `videos.results`, keeping only YouTube trailers.
  static List<Trailer> trailers(Map<String, dynamic> json) => [
    for (final v in json.object('videos').objects('results'))
      if (v['site'] == 'YouTube' && v['type'] == 'Trailer')
        Trailer(key: v.stringOr('key'), name: v.stringOr('name')),
  ];
}
