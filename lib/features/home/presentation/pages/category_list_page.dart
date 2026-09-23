import 'package:cinecatalog/core/theme/app_tokens.dart';
import 'package:cinecatalog/core/widgets/app_icon.dart';
import 'package:cinecatalog/core/widgets/app_refresh.dart';
import 'package:cinecatalog/core/widgets/glow_background.dart';
import 'package:cinecatalog/core/widgets/headers.dart';
import 'package:cinecatalog/core/widgets/media_list_row.dart';
import 'package:cinecatalog/core/widgets/pagination.dart';
import 'package:cinecatalog/core/widgets/rise_in.dart';
import 'package:cinecatalog/core/widgets/shimmer_box.dart';
import 'package:cinecatalog/core/widgets/state_views.dart';
import 'package:cinecatalog/core/widgets/swipe_to_reveal.dart';
import 'package:cinecatalog/features/home/presentation/browse_category.dart';
import 'package:cinecatalog/features/home/presentation/state/media_list_view.dart';
import 'package:cinecatalog/features/watchlist/presentation/providers/watchlist_providers.dart';
import 'package:cinecatalog/features/watchlist/presentation/watchlist_actions.dart';
import 'package:cinecatalog/router/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// "View all": the full list of one category with infinite scroll.
///
/// Shares its provider with the home rail, so pages loaded here are already
/// there when the user goes back.
class CategoryListPage extends ConsumerStatefulWidget {
  const CategoryListPage({required this.category, super.key});

  final BrowseCategory category;

  @override
  ConsumerState<CategoryListPage> createState() => _CategoryListPageState();
}

class _CategoryListPageState extends ConsumerState<CategoryListPage> {
  /// Rows that already played their rise-in, so scrolling back up does not
  /// replay it.
  final _seen = <int>{};

  /// The row held open by a swipe, so opening another one closes it.
  final _openRow = ValueNotifier<Object?>(null);

  @override
  void dispose() {
    _openRow.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final category = widget.category;
    final state = category.watch(ref);
    final watchlist = ref.watch(watchlistProvider);
    final bottom = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Stack(
        children: [
          const Positioned(
            top: -60,
            right: -80,
            child: StaticGlow(
              color: Color.fromRGBO(147, 197, 253, 0.45),
              size: Size.square(300),
            ),
          ),
          Column(
            children: [
              PageHeader(
                kicker: category.kicker,
                title: category.title,
                onBack: () => context.popOrHome(),
              ),
              Expanded(
                child: switch (state) {
                  MediaListLoading() => const _ListSkeleton(),
                  MediaListEmpty() => const EmptyState(
                    title: 'No titles yet',
                    body: 'This category is still empty on TMDB.',
                  ),
                  MediaListError(:final failure) => SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                    child: ErrorCard(
                      error: failure,
                      onRetry: () => category.notifier(ref).retry(),
                    ),
                  ),
                  MediaListLoaded(data: final value) => AppRefresh(
                    onRefresh: category.notifier(ref).refresh,
                    child: LoadMoreListener(
                      onLoadMore: () => category.notifier(ref).loadNextPage(),
                      child: ListView.separated(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: EdgeInsets.fromLTRB(20, 6, 20, 34 + bottom),
                        itemCount: value.items.length + 1,
                        separatorBuilder: (_, _) => const SizedBox(height: 12),
                        itemBuilder: (context, i) {
                          if (i == value.items.length) {
                            return ListFooter(
                              isLoading: value.isLoadingMore,
                              hasMore: value.hasMore,
                              failure: value.loadMoreFailure,
                              onLoadMore: () =>
                                  category.notifier(ref).loadNextPage(),
                            );
                          }
                          final media = value.items[i];
                          final saved = watchlist.contains(media);
                          return RiseIn(
                            enabled: _seen.add(i),
                            // Swipe left to add to (or remove from) the
                            // watchlist, like the heart on the detail page.
                            child: SwipeToReveal(
                              id: '${media.mediaType.name}-${media.id}',
                              openRow: _openRow,
                              actionLabel: saved ? 'Remove' : 'Add',
                              // Same × as Remove on the Watchlist page.
                              actionIcon: saved
                                  ? AppIcons.close
                                  : AppIcons.heart,
                              actionColor: saved
                                  ? AppColors.errorInk
                                  : AppColors.accent,
                              onAction: () =>
                                  toggleWatchlist(context, ref, media),
                              child: MediaListRow(
                                media: media,
                                onTap: () => context.push(Routes.media(media)),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ListSkeleton extends StatelessWidget {
  const _ListSkeleton();

  @override
  Widget build(BuildContext context) => AppShimmer(
    child: ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 6, 20, 0),
      itemCount: 6,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (_, _) => const MediaListRowSkeleton(),
    ),
  );
}

/// Shown when a `/list/...` URL names a category that does not exist.
class UnknownCategoryPage extends StatelessWidget {
  const UnknownCategoryPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.bg,
    body: Column(
      children: [
        PageHeader(
          kicker: 'Catalog',
          title: 'Not found',
          onBack: () => context.popOrHome(),
        ),
        const EmptyState(
          title: 'Unknown category',
          body: 'This link does not point to an existing list.',
        ),
      ],
    ),
  );
}
