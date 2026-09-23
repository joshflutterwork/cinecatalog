import 'package:cinecatalog/core/common/media.dart';
import 'package:cinecatalog/core/widgets/state_views.dart';
import 'package:cinecatalog/core/widgets/toast.dart';
import 'package:cinecatalog/features/watchlist/presentation/providers/watchlist_providers.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The detail pages' heart: the only way to add a title to the watchlist.
/// Saves or removes [media] and confirms with a toast; if saving fails the
/// heart goes back and the toast says why.
Future<void> toggleWatchlist(
  BuildContext context,
  WidgetRef ref,
  Media media,
) async {
  final wasSaved = ref.read(watchlistProvider).contains(media);
  final failure = await ref.read(watchlistProvider.notifier).toggle(media);
  if (!context.mounted) return;
  showToast(
    context,
    failure?.title ??
        (wasSaved ? 'Removed from watchlist' : 'Added to watchlist'),
  );
}
