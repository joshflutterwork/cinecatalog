import 'package:cinecatalog/core/theme/app_tokens.dart';
import 'package:flutter/material.dart';

/// Pull to refresh in the app's style: accent spinner on a glass disc, no
/// Material elevation. [child] must be scrollable, and scroll even when its
/// content is short (`AlwaysScrollableScrollPhysics`).
class AppRefresh extends StatelessWidget {
  const AppRefresh({
    required this.onRefresh,
    required this.child,
    super.key,
    this.edgeOffset = 0,
  });

  /// Keeps the spinner until the returned future completes.
  final Future<void> Function() onRefresh;
  final Widget child;

  /// Room at the top, e.g. to start below a floating top bar.
  final double edgeOffset;

  @override
  Widget build(BuildContext context) => RefreshIndicator(
    onRefresh: onRefresh,
    edgeOffset: edgeOffset,
    color: AppColors.accent,
    backgroundColor: AppColors.glassStrong,
    elevation: 0,
    strokeWidth: 2.2,
    semanticsLabel: 'Refresh',
    child: child,
  );
}
