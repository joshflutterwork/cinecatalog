import 'package:cinecatalog/core/theme/app_tokens.dart';
import 'package:cinecatalog/core/widgets/app_icon.dart';
import 'package:cinecatalog/core/widgets/glow_background.dart';
import 'package:cinecatalog/core/widgets/headers.dart';
import 'package:cinecatalog/core/widgets/media_list_row.dart';
import 'package:cinecatalog/core/widgets/shimmer_box.dart';
import 'package:cinecatalog/core/widgets/state_views.dart';
import 'package:cinecatalog/core/widgets/swipe_to_reveal.dart';
import 'package:cinecatalog/core/widgets/toast.dart';
import 'package:cinecatalog/features/home/presentation/widgets/nav_fab.dart';
import 'package:cinecatalog/features/watchlist/presentation/providers/watchlist_providers.dart';
import 'package:cinecatalog/features/watchlist/presentation/state/watchlist_state.dart';
import 'package:cinecatalog/router/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Saved movies and shows, opened from the FAB. Tap a row for its detail;
/// swipe it left to reveal Remove, which deletes it only when tapped. The
/// FAB stays here too ([NavFab]), with Watchlist marked active.
class WatchlistPage extends ConsumerStatefulWidget {
  const WatchlistPage({super.key});

  @override
  ConsumerState<WatchlistPage> createState() => _WatchlistPageState();
}

class _WatchlistPageState extends ConsumerState<WatchlistPage> {
  /// The row held open, so opening another one closes it.
  final _openRow = ValueNotifier<Object?>(null);

  @override
  void dispose() {
    _openRow.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;
    final notifier = ref.read(watchlistProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Stack(
        children: [
          const Positioned.fill(child: GlowBackground.home()),
          Column(
            children: [
              PageHeader(
                kicker: 'Saved',
                title: 'Watchlist',
                onBack: () => context.popOrHome(),
              ),
              Expanded(
                child: switch (ref.watch(watchlistProvider)) {
                  WatchlistLoading() => const _WatchlistSkeleton(),
                  WatchlistEmpty() => const EmptyState(
                    title: 'Nothing saved yet',
                    body:
                        'Tap the heart on a movie or show to keep it here '
                        'for later.',
                  ),
                  WatchlistError(:final failure) => SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                    child: ErrorCard(error: failure, onRetry: notifier.retry),
                  ),
                  WatchlistLoaded(:final items) => ListView.separated(
                    // Room for the FAB (bottom 104, 52 tall) under the
                    // last row.
                    padding: EdgeInsets.fromLTRB(20, 6, 20, 170 + bottom),
                    itemCount: items.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, i) {
                      final media = items[i];
                      return SwipeToReveal(
                        key: ValueKey('${media.mediaType.name}-${media.id}'),
                        id: '${media.mediaType.name}-${media.id}',
                        openRow: _openRow,
                        actionLabel: 'Remove',
                        actionIcon: AppIcons.close,
                        onAction: () async {
                          final failure = await notifier.remove(media);
                          if (!context.mounted) return;
                          showToast(
                            context,
                            failure?.title ?? 'Removed from watchlist',
                          );
                        },
                        child: MediaListRow(
                          media: media,
                          onTap: () => context.push(Routes.media(media)),
                        ),
                      );
                    },
                  ),
                },
              ),
            ],
          ),
          // Last, so the FAB sits above everything, as on home.
          const Positioned.fill(child: NavFab(current: NavFabPage.watchlist)),
        ],
      ),
    );
  }
}

class _WatchlistSkeleton extends StatelessWidget {
  const _WatchlistSkeleton();

  @override
  Widget build(BuildContext context) => AppShimmer(
    child: ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 6, 20, 0),
      itemCount: 4,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (_, _) => const MediaListRowSkeleton(),
    ),
  );
}
