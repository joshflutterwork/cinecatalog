import 'package:cinecatalog/core/common/media.dart';

final class Person {
  const Person({
    required this.id,
    required this.name,
    required this.knownForDepartment,
    required this.knownFor,
    this.profilePath,
  });

  final int id;
  final String name;
  final String? profilePath;
  final String knownForDepartment;

  /// Movies or shows this person is known for, told apart by
  /// [Media.mediaType].
  final List<Media> knownFor;
}

final class PersonDetail {
  const PersonDetail({
    required this.person,
    required this.biography,
    required this.credits,
    this.birthday,
    this.placeOfBirth,
  });

  final Person person;
  final String biography;
  final DateTime? birthday;
  final String? placeOfBirth;

  /// `combined_credits.cast`: movies and shows mixed.
  final List<Media> credits;
}
