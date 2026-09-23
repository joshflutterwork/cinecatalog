import 'package:cinecatalog/core/common/media.dart';
import 'package:cinecatalog/core/network/json.dart';
import 'package:cinecatalog/features/movie/data/models/movie_model.dart';
import 'package:cinecatalog/features/people/domain/entities/person.dart';
import 'package:cinecatalog/features/tv/data/models/tv_show_model.dart';

/// A movie or a show from a mixed list, told apart by `media_type`.
/// Anything else (TMDB also sends `person`) is skipped.
Media? mediaFromJson(Map<String, dynamic> json) => switch (json['media_type']) {
  'movie' => MovieModel.fromJson(json).toEntity(),
  'tv' => TvShowModel.fromJson(json).toEntity(),
  _ => null,
};

/// `/person/popular` rows and `person` rows of `/search/multi`.
final class PersonModel {
  const PersonModel({
    required this.id,
    required this.name,
    required this.knownForDepartment,
    required this.knownFor,
    this.profilePath,
  });

  factory PersonModel.fromJson(Map<String, dynamic> json) => PersonModel(
    id: json.requireInt('id'),
    name: json.stringOr('name'),
    knownForDepartment: json.stringOr('known_for_department', 'Acting'),
    profilePath: json.stringOrNull('profile_path'),
    knownFor: json.objects('known_for').map(mediaFromJson).nonNulls.toList(),
  );

  final int id;
  final String name;
  final String knownForDepartment;
  final String? profilePath;
  final List<Media> knownFor;

  Person toEntity() => Person(
    id: id,
    name: name,
    knownForDepartment: knownForDepartment,
    profilePath: profilePath,
    knownFor: knownFor,
  );
}

/// `/person/{id}?append_to_response=combined_credits`.
final class PersonDetailModel {
  const PersonDetailModel({
    required this.person,
    required this.biography,
    required this.credits,
    this.birthday,
    this.placeOfBirth,
  });

  factory PersonDetailModel.fromJson(Map<String, dynamic> json) {
    final cast = json.object('combined_credits').objects('cast');
    // Guest spots on talk shows, news and reality TV are the most popular
    // titles on TMDB, so ranking them in would give nearly every celebrity
    // the same "known for". Drop them, unless that is all the person has
    // (a talk-show host, say).
    final roles = cast.where((c) => !_isAppearance(c)).toList();
    final ranked = [...(roles.isEmpty ? cast : roles)]..sort(_byRecognition);
    // A person can appear several times in one show (different characters).
    final seen = <(Object?, int)>{};
    final credits = [
      for (final c in ranked)
        if (seen.add((c['media_type'], c.requireInt('id')))) ?mediaFromJson(c),
    ];
    return PersonDetailModel(
      person: PersonModel(
        id: json.requireInt('id'),
        name: json.stringOr('name'),
        knownForDepartment: json.stringOr('known_for_department', 'Acting'),
        profilePath: json.stringOrNull('profile_path'),
        knownFor: credits.take(3).toList(),
      ),
      biography: json.stringOr('biography'),
      birthday: json.dateOrNull('birthday'),
      placeOfBirth: json.stringOrNull('place_of_birth'),
      credits: credits,
    );
  }

  /// TMDB genres for talk (10767), news (10763) and reality (10764) TV.
  static const _appearanceGenres = {10767, 10763, 10764};

  /// "Self", "Himself", "Self - Guest", "Themselves (voice)", ...
  static final _selfCharacter = RegExp(
    r'^\s*(self|himself|herself|themselves)\b',
    caseSensitive: false,
  );

  /// Appearing as oneself rather than playing a role.
  static bool _isAppearance(Map<String, dynamic> credit) {
    final genres = (credit['genre_ids'] as List<dynamic>? ?? const [])
        .whereType<num>()
        .map((g) => g.toInt());
    return genres.any(_appearanceGenres.contains) ||
        _selfCharacter.hasMatch(credit.stringOr('character'));
  }

  /// Best known first: most votes (a lasting measure of how widely a title
  /// was seen), then today's popularity.
  static int _byRecognition(Map<String, dynamic> a, Map<String, dynamic> b) {
    final votes = b.intOr('vote_count').compareTo(a.intOr('vote_count'));
    return votes != 0
        ? votes
        : b.doubleOr('popularity').compareTo(a.doubleOr('popularity'));
  }

  final PersonModel person;
  final String biography;
  final DateTime? birthday;
  final String? placeOfBirth;
  final List<Media> credits;

  PersonDetail toEntity() => PersonDetail(
    person: person.toEntity(),
    biography: biography,
    birthday: birthday,
    placeOfBirth: placeOfBirth,
    credits: credits,
  );
}
