import 'package:cinecatalog/core/error/failure.dart';
import 'package:cinecatalog/features/people/domain/entities/person.dart';

/// `/person/{id}` with combined credits.
sealed class PersonDetailState {
  const PersonDetailState();
}

final class PersonDetailLoading extends PersonDetailState {
  const PersonDetailLoading();
}

final class PersonDetailLoaded extends PersonDetailState {
  const PersonDetailLoaded(this.detail);

  final PersonDetail detail;
}

final class PersonDetailError extends PersonDetailState {
  const PersonDetailError(this.failure);

  final Failure failure;
}
