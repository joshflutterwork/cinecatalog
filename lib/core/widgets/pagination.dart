import 'package:cinecatalog/core/error/failure.dart';
import 'package:cinecatalog/core/theme/app_tokens.dart';
import 'package:cinecatalog/core/widgets/glass.dart';
import 'package:cinecatalog/core/widgets/pressable.dart';
import 'package:cinecatalog/core/widgets/spinner.dart';
import 'package:cinecatalog/core/widgets/state_views.dart';
import 'package:flutter/widgets.dart';

/// Calls [onLoadMore] once the user has scrolled 80% of [axis].
///
/// The notifier ignores calls while a page is already loading, so firing on
/// every scroll update past the threshold is fine.
class LoadMoreListener extends StatelessWidget {
  const LoadMoreListener({
    required this.onLoadMore,
    required this.child,
    super.key,
    this.axis = Axis.vertical,
    this.threshold = 0.8,
  });

  final VoidCallback onLoadMore;
  final Widget child;
  final Axis axis;
  final double threshold;

  @override
  Widget build(BuildContext context) =>
      NotificationListener<ScrollUpdateNotification>(
        onNotification: (n) {
          final m = n.metrics;
          if (m.axis == axis &&
              m.maxScrollExtent > 0 &&
              m.pixels >= m.maxScrollExtent * threshold) {
            onLoadMore();
          }
          return false;
        },
        child: child,
      );
}

/// Bottom of a paginated list: spinner, a "load more" pill (also the retry
/// after a failed page), or the end-of-list note.
class ListFooter extends StatelessWidget {
  const ListFooter({
    required this.isLoading,
    required this.hasMore,
    required this.onLoadMore,
    super.key,
    this.failure,
    this.endLabel = 'All titles are shown',
  });

  final bool isLoading;
  final bool hasMore;
  final Failure? failure;
  final VoidCallback onLoadMore;
  final String endLabel;

  @override
  Widget build(BuildContext context) {
    final Widget child;
    if (isLoading) {
      child = const Spinner();
    } else if (hasMore) {
      child = Column(
        children: [
          if (failure != null) ...[
            Text(
              failure!.title,
              style: AppText.caption.copyWith(color: AppColors.errorInk),
            ),
            const SizedBox(height: 8),
          ],
          Pressable(
            onTap: onLoadMore,
            scale: 0.96,
            child: Glass(
              height: 44,
              blur: 0,
              color: AppColors.glassStrong,
              borderColor: AppColors.glassBorderStrong,
              shadow: AppShadows.loadMore,
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: Center(
                widthFactor: 1,
                child: Text(
                  failure == null ? 'Load more' : 'Try again',
                  style: AppText.pill.copyWith(fontSize: 13),
                ),
              ),
            ),
          ),
        ],
      );
    } else {
      child = Text(
        endLabel,
        style: AppText.caption.copyWith(color: AppColors.inkHint),
      );
    }
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Center(child: child),
    );
  }
}
