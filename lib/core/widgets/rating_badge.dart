import 'package:cinecatalog/core/theme/app_tokens.dart';
import 'package:cinecatalog/core/utils/formatters.dart';
import 'package:cinecatalog/core/widgets/app_icon.dart';
import 'package:cinecatalog/core/widgets/glass.dart';
import 'package:flutter/widgets.dart';

/// Glass pill with a blue star and the vote average (deck card).
class RatingBadge extends StatelessWidget {
  const RatingBadge({required this.vote, super.key});

  final double vote;

  @override
  Widget build(BuildContext context) => Glass(
    color: AppColors.glassCard,
    blur: 14,
    shadow: AppShadows.badge,
    padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const AppIcon(AppIcons.star, color: AppColors.accent, size: 12),
        const SizedBox(width: 5),
        Text(formatRating(vote), style: AppText.badge),
      ],
    ),
  );
}

/// Small rating chip on rail posters. No backdrop blur: it sits in a
/// horizontally scrolling list and at 82% white the blur is invisible.
class PosterRatingBadge extends StatelessWidget {
  const PosterRatingBadge({required this.vote, super.key});

  final double vote;

  @override
  Widget build(BuildContext context) => Glass(
    color: AppColors.glassBadge,
    blur: 0,
    shadow: const [],
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    child: Text(formatRating(vote), style: AppText.badgeSmall),
  );
}
