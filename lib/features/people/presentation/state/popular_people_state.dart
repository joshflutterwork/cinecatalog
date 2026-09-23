import 'package:cinecatalog/core/error/failure.dart';
import 'package:cinecatalog/core/state/paging.dart';
import 'package:cinecatalog/features/people/domain/entities/person.dart';

/// `/person/popular`, shown as a grid.
sealed class PopularPeopleState {
  const PopularPeopleState();
}

/// Page 1 is loading: show the skeleton.
final class PopularPeopleLoading extends PopularPeopleState {
  const PopularPeopleLoading();
}

/// Page 1 came back with no people.
final class PopularPeopleEmpty extends PopularPeopleState {
  const PopularPeopleEmpty();
}

/// Page 1 failed: show the error card.
final class PopularPeopleError extends PopularPeopleState {
  const PopularPeopleError(this.failure);

  final Failure failure;
}

/// People on screen; [data] also says whether the next page is
/// loading or failed.
final class PopularPeopleLoaded extends PopularPeopleState {
  const PopularPeopleLoaded(this.data);

  final PageData<Person> data;

  List<Person> get people => data.items;
}
