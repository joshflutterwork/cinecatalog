import 'dart:async';

import 'package:cinecatalog/core/common/paginated_entity.dart';
import 'package:cinecatalog/core/error/failure.dart';
import 'package:cinecatalog/core/network/api_client_provider.dart';
import 'package:cinecatalog/core/state/paging.dart';
import 'package:cinecatalog/core/theme/app_tokens.dart';
import 'package:cinecatalog/features/people/data/datasources/people_remote_datasource.dart';
import 'package:cinecatalog/features/people/data/repositories/people_repository_impl.dart';
import 'package:cinecatalog/features/people/domain/entities/person.dart';
import 'package:cinecatalog/features/people/domain/repositories/people_repository.dart';
import 'package:cinecatalog/features/people/domain/usecases/get_person_detail.dart';
import 'package:cinecatalog/features/people/domain/usecases/get_popular_people.dart';
import 'package:cinecatalog/features/people/domain/usecases/search_people.dart';
import 'package:cinecatalog/features/people/presentation/state/people_search_state.dart';
import 'package:cinecatalog/features/people/presentation/state/person_detail_state.dart';
import 'package:cinecatalog/features/people/presentation/state/popular_people_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:fpdart/fpdart.dart';

final peopleRemoteDataSourceProvider = Provider<PeopleRemoteDataSource>(
  (ref) => PeopleRemoteDataSourceImpl(ref.watch(apiClientProvider)),
);

/// Tests override this to avoid the network.
final peopleRepositoryProvider = Provider<PeopleRepository>(
  (ref) => PeopleRepositoryImpl(ref.watch(peopleRemoteDataSourceProvider)),
);

final Provider<GetPopularPeople> getPopularPeopleProvider = Provider(
  (ref) => GetPopularPeople(ref.watch(peopleRepositoryProvider)),
);

final Provider<GetPersonDetail> getPersonDetailProvider = Provider(
  (ref) => GetPersonDetail(ref.watch(peopleRepositoryProvider)),
);

final popularPeopleProvider =
    NotifierProvider<PopularPeopleNotifier, PopularPeopleState>(
      PopularPeopleNotifier.new,
    );

final class PopularPeopleNotifier extends Notifier<PopularPeopleState>
    with PagingMixin<Person, PopularPeopleState> {
  @override
  PopularPeopleState build() {
    loadFirstPage();
    return const PopularPeopleLoading();
  }

  @override
  Future<Either<Failure, PaginatedEntity<Person>>> fetchPage(int page) =>
      ref.read(getPopularPeopleProvider)(page);

  @override
  PopularPeopleState get loadingState => const PopularPeopleLoading();

  @override
  PopularPeopleState get emptyState => const PopularPeopleEmpty();

  @override
  PopularPeopleState errorState(Failure failure) => PopularPeopleError(failure);

  @override
  PopularPeopleState loadedState(PageData<Person> data) =>
      PopularPeopleLoaded(data);

  @override
  PageData<Person>? pageDataOf(PopularPeopleState state) => switch (state) {
    PopularPeopleLoaded(:final data) => data,
    _ => null,
  };
}

final NotifierProviderFamily<PersonDetailNotifier, PersonDetailState, int>
personDetailProvider = NotifierProvider.autoDispose
    .family<PersonDetailNotifier, PersonDetailState, int>(
      PersonDetailNotifier.new,
    );

/// Loading → Loaded | Error for one person; [retry] starts over.
final class PersonDetailNotifier extends Notifier<PersonDetailState> {
  PersonDetailNotifier(this.id);

  final int id;

  /// Bumped by [retry], so an answer to an older request is ignored.
  int _generation = 0;

  @override
  PersonDetailState build() {
    _load(_generation);
    return const PersonDetailLoading();
  }

  void retry() {
    _generation++;
    state = const PersonDetailLoading();
    _load(_generation);
  }

  /// Pull to refresh: reloads while the current detail stays on screen. A
  /// failure keeps it (the ApiClient toast says why).
  Future<void> refresh() async {
    final generation = ++_generation;
    final result = await ref.read(getPersonDetailProvider)(id);
    if (!ref.mounted || generation != _generation) return;
    state = result.fold(
      (failure) =>
          state is PersonDetailLoaded ? state : PersonDetailError(failure),
      PersonDetailLoaded.new,
    );
  }

  Future<void> _load(int generation) async {
    final result = await ref.read(getPersonDetailProvider)(id);
    if (!ref.mounted || generation != _generation) return;
    state = result.fold(PersonDetailError.new, PersonDetailLoaded.new);
  }
}

final Provider<SearchPeople> searchPeopleProvider = Provider(
  (ref) => SearchPeople(ref.watch(peopleRepositoryProvider)),
);

/// The Popular People search field: open or not, text and debounced query.
final NotifierProvider<PeopleQueryNotifier, PeopleQueryState>
peopleQueryProvider =
    NotifierProvider.autoDispose<PeopleQueryNotifier, PeopleQueryState>(
      PeopleQueryNotifier.new,
    );

final class PeopleQueryNotifier extends Notifier<PeopleQueryState> {
  Timer? _debounce;

  @override
  PeopleQueryState build() {
    ref.onDispose(() => _debounce?.cancel());
    return const PeopleQueryState();
  }

  void open() => state = state.copyWith(isOpen: true);

  /// Hides the field and goes back to the popular list.
  void close() {
    _debounce?.cancel();
    state = const PeopleQueryState();
  }

  void setQuery(String query) {
    _debounce?.cancel();
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      state = state.copyWith(query: query, committedQuery: '');
      return;
    }
    state = state.copyWith(query: query);
    _debounce = Timer(AppMotion.searchDebounce, () {
      if (ref.mounted) state = state.copyWith(committedQuery: trimmed);
    });
  }
}

/// Paginated `/search/person` results for one query. Auto-disposed, so a
/// query the user moved away from stops holding memory.
final NotifierProviderFamily<PeopleSearchNotifier, PeopleSearchState, String>
peopleSearchProvider = NotifierProvider.autoDispose
    .family<PeopleSearchNotifier, PeopleSearchState, String>(
      PeopleSearchNotifier.new,
    );

final class PeopleSearchNotifier extends Notifier<PeopleSearchState>
    with PagingMixin<Person, PeopleSearchState> {
  PeopleSearchNotifier(this.query);

  final String query;

  @override
  PeopleSearchState build() {
    loadFirstPage();
    return const PeopleSearchLoading();
  }

  @override
  Future<Either<Failure, PaginatedEntity<Person>>> fetchPage(int page) =>
      ref.read(searchPeopleProvider)(PeopleSearchParams(query, page));

  @override
  PeopleSearchState get loadingState => const PeopleSearchLoading();

  @override
  PeopleSearchState get emptyState => const PeopleSearchEmpty();

  @override
  PeopleSearchState errorState(Failure failure) => PeopleSearchError(failure);

  @override
  PeopleSearchState loadedState(PageData<Person> data) =>
      PeopleSearchLoaded(data);

  @override
  PageData<Person>? pageDataOf(PeopleSearchState state) => switch (state) {
    PeopleSearchLoaded(:final data) => data,
    _ => null,
  };
}
