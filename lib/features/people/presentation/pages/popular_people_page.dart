import 'package:cinecatalog/core/config/tmdb_image.dart';
import 'package:cinecatalog/core/state/paging.dart';
import 'package:cinecatalog/core/theme/app_tokens.dart';
import 'package:cinecatalog/core/widgets/app_icon.dart';
import 'package:cinecatalog/core/widgets/app_refresh.dart';
import 'package:cinecatalog/core/widgets/glass.dart';
import 'package:cinecatalog/core/widgets/glow_background.dart';
import 'package:cinecatalog/core/widgets/headers.dart';
import 'package:cinecatalog/core/widgets/pagination.dart';
import 'package:cinecatalog/core/widgets/poster_image.dart';
import 'package:cinecatalog/core/widgets/pressable.dart';
import 'package:cinecatalog/core/widgets/search_field.dart';
import 'package:cinecatalog/core/widgets/shimmer_box.dart';
import 'package:cinecatalog/core/widgets/state_views.dart';
import 'package:cinecatalog/features/people/domain/entities/person.dart';
import 'package:cinecatalog/features/people/presentation/providers/people_providers.dart';
import 'package:cinecatalog/features/people/presentation/state/people_search_state.dart';
import 'package:cinecatalog/features/people/presentation/state/popular_people_state.dart';
import 'package:cinecatalog/router/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

const _gridDelegate = SliverGridDelegateWithFixedCrossAxisCount(
  crossAxisCount: 3,
  mainAxisSpacing: 20,
  crossAxisSpacing: 14,
  mainAxisExtent: 168,
);

/// Popular People, opened from the FAB: 3-column grid, infinite scroll.
/// The header's search button opens a people-only search that replaces the
/// grid with `/search/person` results until it is closed.
class PopularPeoplePage extends ConsumerStatefulWidget {
  const PopularPeoplePage({super.key});

  @override
  ConsumerState<PopularPeoplePage> createState() => _PopularPeoplePageState();
}

class _PopularPeoplePageState extends ConsumerState<PopularPeoplePage> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _closeSearch() {
    _controller.clear();
    FocusScope.of(context).unfocus();
    ref.read(peopleQueryProvider.notifier).close();
  }

  void _clearQuery() {
    _controller.clear();
    ref.read(peopleQueryProvider.notifier).setQuery('');
  }

  @override
  Widget build(BuildContext context) {
    final query = ref.watch(peopleQueryProvider);
    final queryNotifier = ref.read(peopleQueryProvider.notifier);
    final bottom = MediaQuery.paddingOf(context).bottom;

    return PopScope(
      // Back closes the search first, then leaves the page.
      canPop: !query.isOpen,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _closeSearch();
      },
      child: Scaffold(
        backgroundColor: AppColors.bg,
        body: Stack(
          children: [
            const Positioned.fill(child: GlowBackground.home()),
            Column(
              children: [
                PageHeader(
                  kicker: 'TMDB',
                  title: 'Popular People',
                  onBack: () => context.popOrHome(),
                  trailing: query.isOpen
                      ? null
                      : GlassIconButton(
                          icon: AppIcons.search,
                          onTap: queryNotifier.open,
                          semanticLabel: 'Search people',
                        ),
                ),
                if (query.isOpen)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
                    child: Row(
                      children: [
                        Expanded(
                          child: SearchField(
                            controller: _controller,
                            onChanged: queryNotifier.setQuery,
                            onClear: _clearQuery,
                            hintText: 'Search people',
                          ),
                        ),
                        const SizedBox(width: 12),
                        GestureDetector(
                          onTap: _closeSearch,
                          child: Text(
                            'Cancel',
                            style: AppText.pill.copyWith(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  ),
                Expanded(
                  child: !query.hasQuery
                      ? _PopularBody(bottomPadding: 34 + bottom)
                      // The request goes out after the debounce; show the
                      // skeleton already.
                      : query.isDebouncing
                      ? const _PeopleSkeleton()
                      : _SearchBody(
                          query: query.committedQuery,
                          bottomPadding: 34 + bottom,
                        ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PopularBody extends ConsumerWidget {
  const _PopularBody({required this.bottomPadding});

  final double bottomPadding;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(popularPeopleProvider.notifier);
    return switch (ref.watch(popularPeopleProvider)) {
      PopularPeopleLoading() => const _PeopleSkeleton(),
      PopularPeopleEmpty() => const EmptyState(
        title: 'No data yet',
        body: 'The popular people list is still empty.',
      ),
      PopularPeopleError(:final failure) => SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
        child: ErrorCard(error: failure, onRetry: notifier.retry),
      ),
      PopularPeopleLoaded(:final data) => _PeopleGrid(
        data: data,
        onLoadMore: notifier.loadNextPage,
        onRefresh: notifier.refresh,
        endLabel: 'Everyone is shown',
        bottomPadding: bottomPadding,
      ),
    };
  }
}

class _SearchBody extends ConsumerWidget {
  const _SearchBody({required this.query, required this.bottomPadding});

  final String query;
  final double bottomPadding;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = peopleSearchProvider(query);
    final notifier = ref.read(provider.notifier);
    return switch (ref.watch(provider)) {
      PeopleSearchLoading() => const _PeopleSkeleton(),
      PeopleSearchEmpty() => EmptyState(
        title: 'Not found',
        body: 'Nobody on TMDB matches “$query”. Try another name.',
      ),
      PeopleSearchError(:final failure) => SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
        child: ErrorCard(error: failure, onRetry: notifier.retry),
      ),
      PeopleSearchLoaded(:final data) => _PeopleGrid(
        data: data,
        onLoadMore: notifier.loadNextPage,
        onRefresh: notifier.refresh,
        endLabel: 'All results are shown',
        bottomPadding: bottomPadding,
      ),
    };
  }
}

/// 3-column grid of [PersonTile]s with the load-more footer.
class _PeopleGrid extends StatelessWidget {
  const _PeopleGrid({
    required this.data,
    required this.onLoadMore,
    required this.onRefresh,
    required this.endLabel,
    required this.bottomPadding,
  });

  final PageData<Person> data;
  final VoidCallback onLoadMore;
  final Future<void> Function() onRefresh;
  final String endLabel;
  final double bottomPadding;

  @override
  Widget build(BuildContext context) => AppRefresh(
    onRefresh: onRefresh,
    child: LoadMoreListener(
      onLoadMore: onLoadMore,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
            sliver: SliverGrid.builder(
              gridDelegate: _gridDelegate,
              itemCount: data.items.length,
              itemBuilder: (context, i) => PersonTile(
                person: data.items[i],
                onTap: () =>
                    context.push(Routes.person.build([data.items[i].id])),
              ),
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.only(bottom: bottomPadding),
            sliver: SliverToBoxAdapter(
              child: ListFooter(
                isLoading: data.isLoadingMore,
                hasMore: data.hasMore,
                failure: data.loadMoreFailure,
                onLoadMore: onLoadMore,
                endLabel: endLabel,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

/// 96px round avatar, name, and what the person is known for.
class PersonTile extends StatelessWidget {
  const PersonTile({required this.person, required this.onTap, super.key});

  final Person person;
  final VoidCallback onTap;

  String get _knownFor => person.knownFor.isEmpty
      ? person.knownForDepartment
      : person.knownFor.first.title;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: person.name,
    child: Pressable(
      onTap: onTap,
      child: Column(
        children: [
          PersonAvatar(
            path: person.profilePath,
            id: person.id,
            name: person.name,
          ),
          const SizedBox(height: 9),
          Text(
            person.name,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: AppFonts.dmSans,
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              height: 1.25,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            _knownFor,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: AppFonts.dmSans,
              fontSize: 10.5,
              color: AppColors.inkMuted,
            ),
          ),
        ],
      ),
    ),
  );
}

/// Round profile photo with initials as the fallback.
class PersonAvatar extends StatelessWidget {
  const PersonAvatar({
    required this.path,
    required this.id,
    required this.name,
    super.key,
    this.size = 96,
    this.shadow = AppShadows.avatar,
  });

  final String? path;
  final int id;
  final String name;
  final double size;
  final List<BoxShadow> shadow;

  @override
  Widget build(BuildContext context) => OuterShadow(
    radius: size / 2,
    shadow: shadow,
    child: ClipOval(
      child: SizedBox.square(
        dimension: size,
        child: Stack(
          fit: StackFit.expand,
          children: [
            PosterImage(
              path: path,
              seed: id + 2,
              size: TmdbImageSize.w185,
              label: initialsOf(name),
              labelSize: size * 0.26,
            ),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment(-0.34, -0.94),
                  end: Alignment(0.34, 0.94),
                  colors: [
                    Color.fromRGBO(255, 255, 255, 0.24),
                    Color.fromRGBO(255, 255, 255, 0),
                  ],
                  stops: [0, 0.46],
                ),
              ),
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.glassBorder, width: 0.5),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _PeopleSkeleton extends StatelessWidget {
  const _PeopleSkeleton();

  @override
  Widget build(BuildContext context) => AppShimmer(
    child: GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
      gridDelegate: _gridDelegate,
      itemCount: 9,
      itemBuilder: (_, _) => const Column(
        children: [
          ShimmerBox(width: 96, height: 96, circle: true),
          SizedBox(height: 11),
          ShimmerBox(width: 70, height: 12),
          SizedBox(height: 6),
          ShimmerBox(width: 50, height: 10),
        ],
      ),
    ),
  );
}
