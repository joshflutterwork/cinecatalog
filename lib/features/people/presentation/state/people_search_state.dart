import 'package:cinecatalog/core/error/failure.dart';
import 'package:cinecatalog/core/state/paging.dart';
import 'package:cinecatalog/features/people/domain/entities/person.dart';

/// What the user typed in the Popular People search, and the query actually
/// sent after the debounce.
final class PeopleQueryState {
  const PeopleQueryState({
    this.isOpen = false,
    this.query = '',
    this.committedQuery = '',
  });

  /// The search field is showing.
  final bool isOpen;
  final String query;

  /// Trimmed [query] once it has been stable for the debounce delay.
  final String committedQuery;

  bool get hasQuery => query.trim().isNotEmpty;

  /// Typing, waiting for the debounce: show the skeleton straight away.
  bool get isDebouncing => hasQuery && query.trim() != committedQuery;

  PeopleQueryState copyWith({
    bool? isOpen,
    String? query,
    String? committedQuery,
  }) => PeopleQueryState(
    isOpen: isOpen ?? this.isOpen,
    query: query ?? this.query,
    committedQuery: committedQuery ?? this.committedQuery,
  );
}

/// `/search/person` results for one (debounced) query.
sealed class PeopleSearchState {
  const PeopleSearchState();
}

/// Page 1 is loading: show the skeleton.
final class PeopleSearchLoading extends PeopleSearchState {
  const PeopleSearchLoading();
}

/// Nobody matches the query.
final class PeopleSearchEmpty extends PeopleSearchState {
  const PeopleSearchEmpty();
}

/// Page 1 failed: show the error card.
final class PeopleSearchError extends PeopleSearchState {
  const PeopleSearchError(this.failure);

  final Failure failure;
}

/// Matching people on screen; [data] also says whether the next page is
/// loading or failed.
final class PeopleSearchLoaded extends PeopleSearchState {
  const PeopleSearchLoaded(this.data);

  final PageData<Person> data;

  List<Person> get people => data.items;
}
