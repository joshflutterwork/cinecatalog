import 'package:cinecatalog/core/common/media.dart';
import 'package:cinecatalog/core/theme/app_tokens.dart';
import 'package:cinecatalog/core/widgets/glass.dart';
import 'package:cinecatalog/core/widgets/poster_image.dart';
import 'package:cinecatalog/core/widgets/pressable.dart';
import 'package:cinecatalog/core/widgets/rating_badge.dart';
import 'package:flutter/widgets.dart';

/// 112×162 rail poster: image, dark bottom fade, white title, rating chip.
class PosterCard extends StatelessWidget {
  const PosterCard({
    required this.media,
    required this.onTap,
    super.key,
    this.width = 112,
    this.height = 162,
  });

  final Media media;
  final VoidCallback onTap;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: media.title,
    child: Pressable(
      onTap: onTap,
      scale: 0.96,
      child: OuterShadow(
        radius: AppRadius.poster,
        shadow: AppShadows.rail,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.poster),
          child: SizedBox(
            width: width,
            height: height,
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
                        Color.fromRGBO(255, 255, 255, 0.2),
                        Color.fromRGBO(255, 255, 255, 0),
                      ],
                      stops: [0, 0.45],
                    ),
                  ),
                ),
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color.fromRGBO(10, 6, 18, 0),
                        Color.fromRGBO(10, 6, 18, 0.85),
                      ],
                      stops: [0.52, 1],
                    ),
                  ),
                ),
                Positioned(
                  left: 10,
                  right: 10,
                  bottom: 9,
                  child: Text(
                    media.title,
                    style: AppText.posterTitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: PosterRatingBadge(vote: media.voteAverage),
                ),
                DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppRadius.poster),
                    border: Border.all(
                      color: const Color.fromRGBO(255, 255, 255, 0.7),
                      width: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
