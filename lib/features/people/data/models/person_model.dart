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
    // Most popular first, which is what "known for" means on TMDB.
    final cast = [...json.object('combined_credits').objects('cast')]
      ..sort(
        (a, b) => b.doubleOr('popularity').compareTo(a.doubleOr('popularity')),
      );
    // A person can appear several times in one show (different characters).
    final seen = <(Object?, int)>{};
    final credits = [
      for (final c in cast)
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
