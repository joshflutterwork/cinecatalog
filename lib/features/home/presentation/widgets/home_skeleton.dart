import 'package:cinecatalog/core/theme/app_tokens.dart';
import 'package:cinecatalog/core/widgets/shimmer_box.dart';
import 'package:flutter/widgets.dart';

/// Loading state for the home tab, in the shape of the real content:
/// section title, deck, rail title, three posters.
class HomeSkeleton extends StatelessWidget {
  const HomeSkeleton({super.key});

  @override
  Widget build(BuildContext context) => const AppShimmer(
    child: Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.page),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShimmerBox(width: 170, height: 16),
          SizedBox(height: 14 + 58),
          ShimmerBox(height: 490, radius: AppRadius.deck),
          SizedBox(height: 14 + 14),
          ShimmerBox(width: 140, height: 14, radius: 7),
          SizedBox(height: 14),
          Row(
            children: [
              ShimmerBox(width: 112, height: 162, radius: AppRadius.poster),
              SizedBox(width: AppSpacing.railGap),
              ShimmerBox(width: 112, height: 162, radius: AppRadius.poster),
              SizedBox(width: AppSpacing.railGap),
              ShimmerBox(width: 112, height: 162, radius: AppRadius.poster),
            ],
          ),
        ],
      ),
    ),
  );
}
