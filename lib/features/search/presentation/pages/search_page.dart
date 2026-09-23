import 'package:cinecatalog/core/config/tmdb_image.dart';
import 'package:cinecatalog/core/state/paging.dart';
import 'package:cinecatalog/core/theme/app_tokens.dart';
import 'package:cinecatalog/core/utils/formatters.dart';
import 'package:cinecatalog/core/widgets/app_icon.dart';
import 'package:cinecatalog/core/widgets/glass.dart';
import 'package:cinecatalog/core/widgets/glow_background.dart';
import 'package:cinecatalog/core/widgets/pagination.dart';
import 'package:cinecatalog/core/widgets/poster_image.dart';
import 'package:cinecatalog/core/widgets/pressable.dart';
import 'package:cinecatalog/core/widgets/search_field.dart';
import 'package:cinecatalog/core/widgets/shimmer_box.dart';
import 'package:cinecatalog/core/widgets/state_views.dart';
import 'package:cinecatalog/features/people/domain/entities/person.dart';
import 'package:cinecatalog/features/search/domain/entities/search_result.dart';
import 'package:cinecatalog/features/search/presentation/providers/search_providers.dart';
import 'package:cinecatalog/features/search/presentation/state/search_results_state.dart';
import 'package:cinecatalog/features/search/presentation/state/trending_state.dart';
import 'package:cinecatalog/router/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _setQuery(String q) {
    if (_controller.text != q) {
      _controller.value = TextEditingValue(
        text: q,
        selection: TextSelection.collapsed(offset: q.length),
      );
    }
    ref.read(searchProvider.notifier).setQuery(q);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(searchProvider);
    final notifier = ref.read(searchProvider.notifier);
    final top = MediaQuery.paddingOf(context).top;
    final bottom = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Stack(
        children: [
          const Positioned(
            top: -80,
            left: -60,
            child: StaticGlow(
              color: Color.fromRGBO(147, 197, 253, 0.5),
              size: Size(320, 300),
            ),
          ),
          const Positioned(
            top: 120,
            right: -90,
            child: StaticGlow(
              color: Color.fromRGBO(45, 212, 191, 0.28),
              size: Size.square(240),
              fadeStop: 0.7,
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(20, top + 4, 20, 14),
                child: Row(
                  children: [
                    Expanded(
                      child: SearchField(
                        controller: _controller,
                        onChanged: notifier.setQuery,
                        onClear: () => _setQuery(''),
                      ),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: () => context.popOrHome(),
                      child: Text(
                        'Cancel',
                        style: AppText.pill.copyWith(fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 36 + 16,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  clipBehavior: Clip.none,
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                  itemCount: SearchFilter.values.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (_, i) {
                    final filter = SearchFilter.values[i];
                    return _FilterChip(
                      label: filter.label,
                      active: state.filter == filter,
                      onTap: () => notifier.setFilter(filter),
                    );
                  },
                ),
              ),
              Expanded(
                child: _SearchBody(
                  state: state,
                  bottomPadding: 30 + bottom,
                  onSuggestion: _setQuery,
                  onOpen: (result) => context.push(result.route),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

extension on SearchFilter {
  String get label => switch (this) {
    SearchFilter.all => 'All',
    SearchFilter.movie => 'Movies',
    SearchFilter.tv => 'TV Shows',
    SearchFilter.person => 'People',
  };
}

extension on SearchResult {
  String get route => switch (this) {
    MovieResult(:final movie) => Routes.movie.build([movie.id]),
    TvResult(:final show) => Routes.tv.build([show.id]),
    PersonResult(:final person) => Routes.person.build([person.id]),
  };
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    selected: active,
    child: Pressable(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: AppMotion.ease,
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 15),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: active ? null : const Color.fromRGBO(255, 255, 255, 0.7),
          gradient: active
              ? const LinearGradient(
                  begin: Alignment(-0.9, -0.5),
                  end: Alignment(0.9, 0.5),
                  colors: [
                    Color.fromRGBO(208, 225, 255, 0.95),
                    Color.fromRGBO(230, 240, 255, 0.9),
                  ],
                )
              : null,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.glassBorderStrong, width: 0.5),
          boxShadow: active ? AppShadows.chipActive : AppShadows.chipIdle,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: AppFonts.dmSans,
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: active ? AppColors.accentInk : AppColors.inkNav,
          ),
        ),
      ),
    ),
  );
}

class _SearchBody extends ConsumerWidget {
  const _SearchBody({
    required this.state,
    required this.bottomPadding,
    required this.onSuggestion,
    required this.onOpen,
  });

  final SearchState state;
  final double bottomPadding;
  final ValueChanged<String> onSuggestion;
  final ValueChanged<SearchResult> onOpen;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!state.hasQuery) return _Suggestions(onTap: onSuggestion);
    // The request goes out after the debounce; show the skeleton already.
    if (state.isDebouncing) return const _SearchSkeleton();

    final provider = searchResultsProvider(state.committedQuery);
    final notifier = ref.read(provider.notifier);
    return switch (ref.watch(provider)) {
      SearchResultsLoading() => const _SearchSkeleton(),
      SearchResultsEmpty() => _NoResults(query: state.committedQuery),
      SearchResultsError(:final failure) => SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
        child: ErrorCard(error: failure, onRetry: notifier.retry),
      ),
      SearchResultsLoaded(data: final value) => _ResultList(
        value: value,
        visible: state.filter.apply(value.items),
        query: state.committedQuery,
        bottomPadding: bottomPadding,
        onLoadMore: notifier.loadNextPage,
        onOpen: onOpen,
      ),
    };
  }
}

class _ResultList extends StatelessWidget {
  const _ResultList({
    required this.value,
    required this.visible,
    required this.query,
    required this.bottomPadding,
    required this.onLoadMore,
    required this.onOpen,
  });

  final PageData<SearchResult> value;

  /// [value]'s items after the filter.
  final List<SearchResult> visible;
  final String query;
  final double bottomPadding;
  final VoidCallback onLoadMore;
  final ValueChanged<SearchResult> onOpen;

  @override
  Widget build(BuildContext context) {
    final footer = ListFooter(
      isLoading: value.isLoadingMore,
      hasMore: value.hasMore,
      failure: value.loadMoreFailure,
      onLoadMore: onLoadMore,
      endLabel: 'All results are shown',
    );
    // Loaded, but nothing matches the filter: later pages might.
    if (visible.isEmpty) {
      return ListView(
        children: [
          _NoResults(query: query),
          if (value.hasMore) footer,
        ],
      );
    }
    return LoadMoreListener(
      onLoadMore: onLoadMore,
      child: ListView.separated(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: EdgeInsets.fromLTRB(20, 0, 20, bottomPadding),
        itemCount: visible.length + 2,
        separatorBuilder: (_, i) => SizedBox(height: i == 0 ? 0 : 10),
        itemBuilder: (context, i) {
          if (i == 0) {
            return _Kicker(
              '${visible.length} result${visible.length == 1 ? '' : 's'}',
            );
          }
          if (i == visible.length + 1) return footer;
          final result = visible[i - 1];
          return _ResultRow(result: result, onTap: () => onOpen(result));
        },
      ),
    );
  }
}

class _NoResults extends StatelessWidget {
  const _NoResults({required this.query});

  final String query;

  @override
  Widget build(BuildContext context) => EmptyState(
    title: 'Not found',
    body:
        'No results for “$query”. Try another keyword or change the '
        'filter.',
  );
}

/// Shimmering stand-ins shaped like [_ResultRow].
class _SearchSkeleton extends StatelessWidget {
  const _SearchSkeleton();

  @override
  Widget build(BuildContext context) => AppShimmer(
    child: ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 6, 20, 0),
      itemCount: 6,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (_, _) => const Padding(
        padding: EdgeInsets.fromLTRB(9, 9, 14, 9),
        child: Row(
          children: [
            ShimmerBox(width: 48, height: 66, radius: AppRadius.searchPoster),
            SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShimmerBox(width: 160, height: 14),
                  SizedBox(height: 8),
                  ShimmerBox(width: 90, height: 11),
                ],
              ),
            ),
            SizedBox(width: 10),
            ShimmerBox(width: 52, height: 22, radius: 11),
          ],
        ),
      ),
    ),
  );
}

class _Kicker extends StatelessWidget {
  const _Kicker(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 6, bottom: 12),
    child: Text(
      text.toUpperCase(),
      style: AppText.kicker.copyWith(
        color: const Color.fromRGBO(40, 70, 120, 0.55),
      ),
    ),
  );
}

/// Title a trending row is searched by.
String _titleOf(SearchResult result) => switch (result) {
  MovieResult(:final movie) => movie.title,
  TvResult(:final show) => show.title,
  PersonResult(:final person) => person.name,
};

/// "Popular searches": today's trending titles from TMDB, as chips.
class _Suggestions extends ConsumerWidget {
  const _Suggestions({required this.onTap});

  final ValueChanged<String> onTap;

  static const _max = 8;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final body = switch (ref.watch(trendingProvider)) {
      TrendingLoading() => AppShimmer(
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final w in const [96.0, 120.0, 84.0, 110.0, 72.0, 100.0])
              ShimmerBox(width: w, height: 36, radius: 18),
          ],
        ),
      ),
      TrendingEmpty() => const SizedBox.shrink(),
      TrendingError(:final failure) => Row(
        children: [
          Flexible(
            child: Text(
              failure.title,
              style: AppText.caption.copyWith(color: AppColors.inkMuted),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: ref.read(trendingProvider.notifier).retry,
            child: const Text('Try again', style: AppText.pill),
          ),
        ],
      ),
      TrendingLoaded(:final results) => Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final title in results.take(_max).map(_titleOf))
            Pressable(
              onTap: () => onTap(title),
              child: Glass(
                height: 36,
                blur: 0,
                color: AppColors.glassCard,
                borderColor: AppColors.glassBorderStrong,
                shadow: AppShadows.soft,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const AppIcon(
                      AppIcons.trending,
                      color: AppColors.accent,
                      size: 12,
                    ),
                    const SizedBox(width: 7),
                    Text(
                      title,
                      style: const TextStyle(
                        fontFamily: AppFonts.dmSans,
                        fontSize: 12.5,
                        color: AppColors.inkButton,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    };
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [const _Kicker('Popular searches'), body],
      ),
    );
  }
}

String _knownFor(Person person) =>
    person.knownFor.firstOrNull?.title ?? person.knownForDepartment;

class _ResultRow extends StatelessWidget {
  const _ResultRow({required this.result, required this.onTap});

  final SearchResult result;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final (title, meta, type, path, isPerson) = switch (result) {
      MovieResult(:final movie) => (
        movie.title,
        ratingAndYear(movie.voteAverage, movie.year),
        'Movies',
        movie.posterPath,
        false,
      ),
      TvResult(:final show) => (
        show.title,
        ratingAndYear(show.voteAverage, show.year),
        'TV Shows',
        show.posterPath,
        false,
      ),
      PersonResult(:final person) => (
        person.name,
        'Known for ${_knownFor(person)}',
        'People',
        person.profilePath,
        true,
      ),
    };

    return Semantics(
      button: true,
      label: '$type: $title',
      child: Pressable(
        onTap: onTap,
        scale: 0.985,
        child: Glass(
          radius: AppRadius.searchRow,
          blur: 0,
          color: AppColors.glassCard,
          borderColor: AppColors.glassBorderStrong,
          shadow: AppShadows.searchRow,
          padding: const EdgeInsets.fromLTRB(9, 9, 14, 9),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(
                  isPerson ? 24 : AppRadius.searchPoster,
                ),
                child: SizedBox(
                  width: 48,
                  height: isPerson ? 48 : 66,
                  child: PosterImage(
                    path: path,
                    seed: result.id + (isPerson ? 2 : 0),
                    size: TmdbImageSize.w185,
                    label: isPerson ? initialsOf(title) : null,
                    labelSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: AppFonts.dmSans,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        height: 1.3,
                        color: AppColors.ink,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      meta,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.meta.copyWith(
                        color: const Color.fromRGBO(40, 70, 120, 0.6),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.typeBadgeBg,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  type,
                  style: AppText.badgeSmall.copyWith(
                    color: AppColors.accentInk,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
