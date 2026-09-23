import 'package:cached_network_image/cached_network_image.dart';
import 'package:cinecatalog/core/config/tmdb_image.dart';
import 'package:cinecatalog/core/theme/app_tokens.dart';
import 'package:flutter/widgets.dart';

/// A TMDB image that falls back to the design's gradient placeholder when the
/// path is null or the download fails.
class PosterImage extends StatelessWidget {
  const PosterImage({
    required this.path,
    required this.seed,
    super.key,
    this.size = TmdbImageSize.w342,
    this.label,
    this.labelSize = 25,
  });

  final String? path;

  /// Picks the placeholder gradient; pass the TMDB id so it stays stable.
  final int seed;
  final TmdbImageSize size;

  /// Shown on the placeholder, e.g. a person's initials.
  final String? label;
  final double labelSize;

  @override
  Widget build(BuildContext context) {
    final url = TmdbImage.url(path, size);
    final placeholder = PosterPlaceholder(
      seed: seed,
      label: label,
      labelSize: labelSize,
    );
    if (url == null) return placeholder;
    return CachedNetworkImage(
      imageUrl: url,
      fit: BoxFit.cover,
      fadeInDuration: const Duration(milliseconds: 250),
      placeholder: (_, _) => placeholder,
      errorWidget: (_, _, _) => placeholder,
    );
  }
}

class PosterPlaceholder extends StatelessWidget {
  const PosterPlaceholder({
    required this.seed,
    super.key,
    this.label,
    this.labelSize = 25,
  });

  final int seed;
  final String? label;
  final double labelSize;

  /// CSS `linear-gradient(155deg, a 0%, b 42%, c 100%)`.
  static LinearGradient gradientFor(int seed) {
    final colors = AppColors
        .posterGradients[seed.abs() % AppColors.posterGradients.length];
    return LinearGradient(
      begin: const Alignment(-0.42, -0.91),
      end: const Alignment(0.42, 0.91),
      colors: colors,
      stops: const [0, 0.42, 1],
    );
  }

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(gradient: gradientFor(seed)),
    child: label == null
        ? const SizedBox.expand()
        : Center(
            child: Text(
              label!,
              style: TextStyle(
                fontFamily: AppFonts.sora,
                fontSize: labelSize,
                fontWeight: FontWeight.w600,
                color: const Color.fromRGBO(255, 255, 255, 0.55),
              ),
            ),
          ),
  );
}

/// "Zendaya" → "Z", "Cillian Murphy" → "CM".
String initialsOf(String name) => name
    .split(' ')
    .where((w) => w.isNotEmpty)
    .take(2)
    .map((w) => w[0].toUpperCase())
    .join();
