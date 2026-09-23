import 'package:cinecatalog/core/common/media.dart';
import 'package:cinecatalog/core/theme/app_tokens.dart';
import 'package:cinecatalog/core/widgets/headers.dart';
import 'package:cinecatalog/core/widgets/pagination.dart';
import 'package:cinecatalog/core/widgets/poster_card.dart';
import 'package:cinecatalog/core/widgets/shimmer_box.dart';
import 'package:cinecatalog/core/widgets/spinner.dart';
import 'package:cinecatalog/core/widgets/state_views.dart';
import 'package:cinecatalog/features/home/presentation/browse_category.dart';
import 'package:cinecatalog/features/home/presentation/state/media_list_view.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Section title + horizontal poster list for one category.
class MediaRail extends ConsumerWidget {
  const MediaRail({
    required this.category,
    required this.onOpen,
    required this.onViewAll,
    super.key,
  });

  final BrowseCategory category;
  final ValueChanged<Media> onOpen;
  final VoidCallback onViewAll;

  static const _height = 162.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = category.watch(ref);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(title: category.title, onViewAll: onViewAll),
        SizedBox(
          height: _height,
          child: switch (state) {
            MediaListLoading() => const RailSkeleton(),
            MediaListEmpty() => const _RailMessage(
              text: 'No titles in this category yet.',
            ),
            MediaListError(:final failure) => _RailMessage(
              text: failure.title,
              actionLabel: 'Try again',
              onAction: () => category.notifier(ref).retry(),
            ),
            MediaListLoaded(data: final value) => LoadMoreListener(
              axis: Axis.horizontal,
              onLoadMore: () => category.notifier(ref).loadNextPage(),
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                clipBehavior: Clip.none,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.page,
                ),
                itemCount: value.items.length + (value.isLoadingMore ? 1 : 0),
                separatorBuilder: (_, _) =>
                    const SizedBox(width: AppSpacing.railGap),
                itemBuilder: (context, i) => i == value.items.length
                    ? const SizedBox(width: 48, child: Center(child: Spinner()))
                    : PosterCard(
                        media: value.items[i],
                        onTap: () => onOpen(value.items[i]),
                      ),
              ),
            ),
          },
        ),
      ],
    );
  }
}

/// Three shimmering poster placeholders.
class RailSkeleton extends StatelessWidget {
  const RailSkeleton({super.key});

  @override
  Widget build(BuildContext context) => const AppShimmer(
    child: Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.page),
      child: Row(
        children: [
          ShimmerBox(width: 112, height: 162, radius: AppRadius.poster),
          SizedBox(width: AppSpacing.railGap),
          ShimmerBox(width: 112, height: 162, radius: AppRadius.poster),
          SizedBox(width: AppSpacing.railGap),
          ShimmerBox(width: 112, height: 162, radius: AppRadius.poster),
        ],
      ),
    ),
  );
}

class _RailMessage extends StatelessWidget {
  const _RailMessage({required this.text, this.actionLabel, this.onAction});

  final String text;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
    child: Row(
      children: [
        Flexible(
          child: Text(
            text,
            style: AppText.caption.copyWith(color: AppColors.inkMuted),
          ),
        ),
        if (actionLabel != null) ...[
          const SizedBox(width: 10),
          GestureDetector(
            onTap: onAction,
            child: Text(actionLabel!, style: AppText.pill),
          ),
        ],
      ],
    ),
  );
}
