import 'package:cinecatalog/core/theme/app_tokens.dart';
import 'package:cinecatalog/core/widgets/app_refresh.dart';
import 'package:cinecatalog/core/widgets/headers.dart';
import 'package:cinecatalog/core/widgets/state_views.dart';
import 'package:cinecatalog/features/home/presentation/browse_category.dart';
import 'package:cinecatalog/features/home/presentation/state/media_list_view.dart';
import 'package:cinecatalog/features/home/presentation/widgets/home_skeleton.dart';
import 'package:cinecatalog/features/home/presentation/widgets/media_rail.dart';
import 'package:cinecatalog/features/home/presentation/widgets/stacked_deck.dart';
import 'package:cinecatalog/router/routes.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Scrollable content of one home tab: deck and three rails. `HomeShell`
/// pins the header and title above it.
///
/// The deck's list decides the loading and error state of the whole tab,
/// as in the design; each rail then loads on its own.
class HomeFeed extends ConsumerWidget {
  const HomeFeed({required this.mode, super.key});

  final HomeMode mode;

  void _retryAll(WidgetRef ref) {
    for (final category in [mode.deck, ...mode.rails]) {
      if (category.read(ref) is MediaListError) {
        category.notifier(ref).retry();
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deck = mode.deck;
    final state = deck.watch(ref);

    return AppRefresh(
      // Reloads the deck and the tab's three rails together.
      onRefresh: () => Future.wait([
        for (final category in [deck, ...mode.rails])
          category.notifier(ref).refresh(),
      ]),
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          const SliverToBoxAdapter(child: SizedBox(height: 4)),
          ...switch (state) {
            MediaListLoading() => [
              const SliverToBoxAdapter(child: HomeSkeleton()),
            ],
            MediaListError(:final failure) => [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
                  child: ErrorCard(
                    error: failure,
                    onRetry: () => _retryAll(ref),
                  ),
                ),
              ),
            ],
            MediaListEmpty() || MediaListLoaded() => [
              SliverToBoxAdapter(
                child: SectionHeader(
                  title: deck.title,
                  style: AppText.sectionTitle,
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
                  onViewAll: () => context.push(deck.path),
                ),
              ),
              SliverToBoxAdapter(
                child: state is! MediaListLoaded
                    ? const EmptyState(
                        title: 'No titles yet',
                        body: 'This category is still empty on TMDB.',
                      )
                    : Padding(
                        padding: const EdgeInsets.fromLTRB(20, 72, 20, 10),
                        child: StackedDeck(
                          items: state.data.items,
                          onTap: (media) => context.push(Routes.media(media)),
                        ),
                      ),
              ),
              for (final rail in mode.rails)
                SliverToBoxAdapter(
                  child: MediaRail(
                    category: rail,
                    onOpen: (media) => context.push(Routes.media(media)),
                    onViewAll: () => context.push(rail.path),
                  ),
                ),
            ],
          },
          const SliverToBoxAdapter(child: SizedBox(height: 120)),
        ],
      ),
    );
  }
}
