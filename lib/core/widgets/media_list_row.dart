import 'package:cinecatalog/core/common/media.dart';
import 'package:cinecatalog/core/theme/app_tokens.dart';
import 'package:cinecatalog/core/utils/formatters.dart';
import 'package:cinecatalog/core/widgets/app_icon.dart';
import 'package:cinecatalog/core/widgets/glass.dart';
import 'package:cinecatalog/core/widgets/poster_image.dart';
import 'package:cinecatalog/core/widgets/pressable.dart';
import 'package:cinecatalog/core/widgets/shimmer_box.dart';
import 'package:flutter/widgets.dart';

/// View all row: 68×98 poster, title, rating · year, two-line synopsis,
/// round chevron.
class MediaListRow extends StatelessWidget {
  const MediaListRow({required this.media, required this.onTap, super.key});

  final Media media;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: media.title,
    child: Pressable(
      onTap: onTap,
      scale: 0.985,
      child: Glass(
        radius: AppRadius.listRow,
        blur: 0,
        color: AppColors.glassCard,
        borderColor: AppColors.glassBorderStrong,
        shadow: AppShadows.listRow,
        padding: const EdgeInsets.fromLTRB(10, 10, 14, 10),
        child: Row(
          children: [
            OuterShadow(
              radius: AppRadius.listPoster,
              shadow: AppShadows.posterSmall,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.listPoster),
                child: SizedBox(
                  width: 68,
                  height: 98,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      PosterImage(path: media.posterPath, seed: media.id),
                      const DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment(-0.42, -0.91),
                            end: Alignment(0.42, 0.91),
                            colors: [
                              Color.fromRGBO(255, 255, 255, 0.25),
                              Color.fromRGBO(255, 255, 255, 0),
                            ],
                            stops: [0, 0.45],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    media.title,
                    style: AppText.rowTitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const AppIcon(
                        AppIcons.star,
                        color: AppColors.accent,
                        size: 11,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        formatRating(media.voteAverage),
                        style: AppText.meta.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.inkBadge,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Text('·', style: AppText.meta),
                      const SizedBox(width: 6),
                      Text(formatYear(media.year), style: AppText.meta),
                    ],
                  ),
                  if (media.overview.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      media.overview,
                      style: AppText.caption,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 14),
            Container(
              width: 30,
              height: 30,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.chevronBg,
              ),
              alignment: Alignment.center,
              child: const AppIcon(
                AppIcons.chevronRight,
                color: AppColors.accentInk,
                size: 13,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

/// Loading placeholder with the same shape as [MediaListRow].
class MediaListRowSkeleton extends StatelessWidget {
  const MediaListRowSkeleton({super.key});

  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.fromLTRB(10, 10, 14, 10),
    child: Row(
      children: [
        ShimmerBox(width: 68, height: 98, radius: AppRadius.listPoster),
        SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ShimmerBox(width: 150, height: 15),
              SizedBox(height: 10),
              ShimmerBox(width: 80, height: 11),
              SizedBox(height: 10),
              ShimmerBox(height: 11),
              SizedBox(height: 6),
              ShimmerBox(width: 120, height: 11),
            ],
          ),
        ),
      ],
    ),
  );
}
