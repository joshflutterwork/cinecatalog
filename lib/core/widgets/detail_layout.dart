import 'package:cinecatalog/core/common/media.dart';
import 'package:cinecatalog/core/config/tmdb_image.dart';
import 'package:cinecatalog/core/error/failure.dart';
import 'package:cinecatalog/core/theme/app_tokens.dart';
import 'package:cinecatalog/core/widgets/app_icon.dart';
import 'package:cinecatalog/core/widgets/app_refresh.dart';
import 'package:cinecatalog/core/widgets/glass.dart';
import 'package:cinecatalog/core/widgets/gradient_button.dart';
import 'package:cinecatalog/core/widgets/headers.dart';
import 'package:cinecatalog/core/widgets/poster_card.dart';
import 'package:cinecatalog/core/widgets/poster_image.dart';
import 'package:cinecatalog/core/widgets/pressable.dart';
import 'package:cinecatalog/core/widgets/shimmer_box.dart';
import 'package:cinecatalog/core/widgets/state_views.dart';
import 'package:flutter/material.dart';

/// Full-bleed detail screen shared by movies, shows and people.
///
/// The first screenful matches the design: image, white fade, chips, title,
/// four lines of overview and the fixed CTA row. [extras] (cast, similar
/// titles…) continue below the fold.
class DetailLayout extends StatelessWidget {
  const DetailLayout({
    required this.imagePath,
    required this.seed,
    required this.tags,
    required this.title,
    required this.overview,
    required this.onBack,
    super.key,
    this.imageLabel,
    this.cta,
    this.extras = const [],
    this.onRefresh,
  });

  final String? imagePath;
  final int seed;
  final String? imageLabel;
  final List<String> tags;
  final String title;
  final String overview;
  final VoidCallback onBack;

  /// Pinned 30px above the bottom edge. Null leaves more room for text.
  final Widget? cta;
  final List<Widget> extras;

  /// Pull to refresh; null turns it off.
  final Future<void> Function()? onRefresh;

  /// Space under the overview inside the hero. With the tiles' own top
  /// padding of 8 this gives the 22 used between the other detail blocks.
  static const _textGap = 14.0;

  /// Space between the end of the poster and the chips.
  static const _textTop = 16.0;

  /// Bottom of the hero text on the first screen when there is a CTA row.
  /// The design says 108; 96 keeps 10px above the 56px CTA (bottom 30) and
  /// leaves more height to the poster above the text.
  static const textBottomWithCta = 96.0;

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.sizeOf(context);
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final textBottom = cta == null ? 40.0 : textBottomWithCta;
    return Scaffold(
      backgroundColor: AppColors.detailBottom,
      body: Stack(
        children: [
          _MaybeRefresh(
            onRefresh: onRefresh,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  // Ends just under the text rather than at the screen edge,
                  // so [extras] follow the overview without a gap. The fixed
                  // CTA covers the space the hero gives up.
                  child: _Hero(
                    collapsedHeight: screen.height - textBottom + _textGap,
                    imagePath: imagePath,
                    seed: seed,
                    imageLabel: imageLabel,
                    tags: tags,
                    title: title,
                    overview: overview,
                  ),
                ),
                ...extras.map((e) => SliverToBoxAdapter(child: e)),
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: (cta == null ? 40 : 120) + bottomInset,
                  ),
                ),
              ],
            ),
          ),
          DetailTopBar(onBack: onBack),
          if (cta != null) ...[
            const Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              // Stays under the hero text, which ends 96 from the bottom.
              height: 90,
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(gradient: AppColors.detailCtaFade),
                ),
              ),
            ),
            Positioned(left: 22, right: 22, bottom: 30, child: cta!),
          ],
        ],
      ),
    );
  }
}

class _HeroOverlay extends StatelessWidget {
  const _HeroOverlay();

  @override
  Widget build(BuildContext context) => const Stack(
    fit: StackFit.expand,
    children: [
      // radial-gradient(90% 55% at 35% 8%, white .34, transparent 58%)
      DecoratedBox(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(-0.3, -0.84),
            radius: 0.9,
            colors: [
              Color.fromRGBO(255, 255, 255, 0.34),
              Color.fromRGBO(255, 255, 255, 0),
            ],
            stops: [0, 0.58],
          ),
        ),
      ),
      DecoratedBox(
        decoration: BoxDecoration(gradient: AppColors.detailHeroTopFade),
      ),
    ],
  );
}

/// The poster with the design's top sheen and a 24px fade at its bottom
/// edge into the page, where the hero text starts.
class _HeroImage extends StatelessWidget {
  const _HeroImage({required this.child});

  final Widget child;

  static const _bottomFade = 24.0;

  @override
  Widget build(BuildContext context) => Stack(
    fit: StackFit.expand,
    children: [
      child,
      const _HeroOverlay(),
      const Positioned(
        left: 0,
        right: 0,
        bottom: 0,
        height: _bottomFade,
        child: DecoratedBox(
          decoration: BoxDecoration(gradient: AppColors.detailImageBottomFade),
        ),
      ),
    ],
  );
}

/// Poster, then chips, title and overview. Collapsed, it is exactly one
/// screen tall minus the CTA row, with the poster filling what the text
/// leaves. "Show more" keeps the poster at that height and lets the full
/// overview grow below it, pushing the rest of the page down.
class _Hero extends StatefulWidget {
  const _Hero({
    required this.collapsedHeight,
    required this.imagePath,
    required this.seed,
    required this.imageLabel,
    required this.tags,
    required this.title,
    required this.overview,
  });

  final double collapsedHeight;
  final String? imagePath;
  final int seed;
  final String? imageLabel;
  final List<String> tags;
  final String title;
  final String overview;

  @override
  State<_Hero> createState() => _HeroState();
}

class _HeroState extends State<_Hero> {
  bool _expanded = false;

  /// The poster's height while collapsed, kept when the text expands.
  double _posterHeight = 0;

  @override
  Widget build(BuildContext context) {
    final poster = _HeroImage(
      child: PosterImage(
        path: widget.imagePath,
        seed: widget.seed,
        size: TmdbImageSize.w780,
        label: widget.imageLabel,
        labelSize: 96,
      ),
    );
    final text = Padding(
      padding: const EdgeInsets.fromLTRB(
        22,
        DetailLayout._textTop,
        22,
        DetailLayout._textGap,
      ),
      child: _HeroText(
        tags: widget.tags,
        title: widget.title,
        overview: widget.overview,
        expanded: _expanded,
        onToggle: () => setState(() => _expanded = !_expanded),
      ),
    );

    return AnimatedSize(
      duration: AppMotion.navPill,
      curve: AppMotion.ease,
      alignment: Alignment.topCenter,
      child: _expanded
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: _posterHeight, child: poster),
                text,
              ],
            )
          : SizedBox(
              height: widget.collapsedHeight,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // The poster stops right above the text; only its last
                  // 24px fade into the page.
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        _posterHeight = constraints.maxHeight;
                        return poster;
                      },
                    ),
                  ),
                  text,
                ],
              ),
            ),
    );
  }
}

class _HeroText extends StatelessWidget {
  const _HeroText({
    required this.tags,
    required this.title,
    required this.overview,
    required this.expanded,
    required this.onToggle,
  });

  final List<String> tags;
  final String title;
  final String overview;
  final bool expanded;
  final VoidCallback onToggle;

  /// Three, not the design's four, so the poster above keeps more height.
  static const _collapsedLines = 3;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: [
      if (tags.isNotEmpty) ...[
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [for (final t in tags) TagChip(label: t)],
        ),
        const SizedBox(height: 14),
      ],
      Text(title, style: AppText.detailTitle),
      if (overview.isNotEmpty) ...[
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            // Only offer "Show more" when the text really is cut off.
            final painter = TextPainter(
              text: TextSpan(text: overview, style: AppText.detailBody),
              maxLines: _collapsedLines,
              textDirection: Directionality.of(context),
              textScaler: MediaQuery.textScalerOf(context),
            )..layout(maxWidth: constraints.maxWidth);
            final overflows = painter.didExceedMaxLines;
            painter.dispose();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  overview,
                  style: AppText.detailBody,
                  maxLines: expanded ? null : _collapsedLines,
                  overflow: expanded ? null : TextOverflow.ellipsis,
                ),
                if (overflows || expanded)
                  Semantics(
                    button: true,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: onToggle,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 6, bottom: 2),
                        child: Text(
                          expanded ? 'Show less' : 'Show more',
                          style: AppText.pill.copyWith(
                            fontSize: 13,
                            color: AppColors.accent,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    ],
  );
}

class TagChip extends StatelessWidget {
  const TagChip({required this.label, super.key});

  final String label;

  @override
  Widget build(BuildContext context) => Glass(
    blur: 14,
    color: const Color.fromRGBO(255, 255, 255, 0.75),
    shadow: AppShadows.chip,
    padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 6),
    child: Text(label, style: AppText.chip),
  );
}

/// Back on the left, cast and share on the right; stays put while scrolling.
class DetailTopBar extends StatelessWidget {
  const DetailTopBar({required this.onBack, super.key});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    return Positioned(
      top: top + 4,
      left: 18,
      right: 18,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _TopButton(icon: AppIcons.back, onTap: onBack, label: 'Back'),
        ],
      ),
    );
  }
}

class _TopButton extends StatelessWidget {
  const _TopButton({
    required this.icon,
    required this.onTap,
    required this.label,
  });

  final AppIconData icon;
  final VoidCallback onTap;
  final String label;

  @override
  Widget build(BuildContext context) => GlassIconButton(
    icon: icon,
    onTap: onTap,
    size: 40,
    blur: 16,
    color: const Color.fromRGBO(255, 255, 255, 0.7),
    iconColor: AppColors.inkButton,
    shadow: AppShadows.button,
    semanticLabel: label,
  );
}

/// Play + watchlist heart, pinned at the bottom of movie and TV detail.
class DetailCtaRow extends StatelessWidget {
  const DetailCtaRow({
    required this.onPlay,
    required this.favourite,
    required this.onFavourite,
    super.key,
    this.playLabel = 'Play',
  });

  /// Null when there is no trailer; the button is dimmed.
  final VoidCallback? onPlay;
  final bool favourite;
  final VoidCallback onFavourite;
  final String playLabel;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: GradientButton(
          label: playLabel,
          onTap: onPlay,
          leading: AppIcons.play,
          sheenPeriod: const Duration(seconds: 5),
          expand: true,
        ),
      ),
      const SizedBox(width: 12),
      Semantics(
        button: true,
        toggled: favourite,
        label: favourite ? 'Remove from watchlist' : 'Add to watchlist',
        child: Pressable(
          onTap: onFavourite,
          scale: 0.92,
          child: Glass(
            width: 56,
            height: 56,
            blur: 20,
            color: const Color.fromRGBO(255, 255, 255, 0.8),
            borderColor: AppColors.glassBorderStrong,
            shadow: AppShadows.favButton,
            child: Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                transitionBuilder: (child, animation) =>
                    ScaleTransition(scale: animation, child: child),
                child: AppIcon(
                  favourite ? AppIcons.heartFilled : AppIcons.heart,
                  key: ValueKey(favourite),
                  color: favourite ? AppColors.errorInk : AppColors.inkButton,
                  size: 20,
                ),
              ),
            ),
          ),
        ),
      ),
    ],
  );
}

/// [AppRefresh] when [onRefresh] is set, starting below the floating top
/// bar so the spinner is not hidden behind the back button.
class _MaybeRefresh extends StatelessWidget {
  const _MaybeRefresh({required this.onRefresh, required this.child});

  final Future<void> Function()? onRefresh;
  final Widget child;

  @override
  Widget build(BuildContext context) => onRefresh == null
      ? child
      : AppRefresh(
          onRefresh: onRefresh!,
          edgeOffset: MediaQuery.paddingOf(context).top + 48,
          child: child,
        );
}

/// Full-screen error card for a detail page, with the back button kept.
class DetailErrorView extends StatelessWidget {
  const DetailErrorView({
    required this.failure,
    required this.onRetry,
    required this.onBack,
    super.key,
  });

  final Failure failure;
  final VoidCallback onRetry;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.bg,
    body: Stack(
      children: [
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ErrorCard(error: failure, onRetry: onRetry),
          ),
        ),
        DetailTopBar(onBack: onBack),
      ],
    ),
  );
}

class DetailSkeleton extends StatelessWidget {
  const DetailSkeleton({required this.onBack, super.key});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.detailBottom,
    body: Stack(
      children: [
        const Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: _HeroImage(
                child: AppShimmer(child: ShimmerBox(radius: 0)),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                22,
                DetailLayout._textTop,
                22,
                DetailLayout.textBottomWithCta,
              ),
              child: AppShimmer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        ShimmerBox(width: 64, height: 26, radius: 13),
                        SizedBox(width: 8),
                        ShimmerBox(width: 72, height: 26, radius: 13),
                        SizedBox(width: 8),
                        ShimmerBox(width: 48, height: 26, radius: 13),
                      ],
                    ),
                    SizedBox(height: 16),
                    ShimmerBox(width: 240, height: 30, radius: 10),
                    SizedBox(height: 16),
                    ShimmerBox(height: 12),
                    SizedBox(height: 8),
                    ShimmerBox(height: 12),
                    SizedBox(height: 8),
                    ShimmerBox(width: 200, height: 12),
                  ],
                ),
              ),
            ),
          ],
        ),
        DetailTopBar(onBack: onBack),
      ],
    ),
  );
}

/// Title + content block below the fold.
class DetailSection extends StatelessWidget {
  const DetailSection({required this.title, required this.child, super.key});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      SectionHeader(title: title),
      child,
    ],
  );
}

/// Row of small glass stat cards (rating, runtime, status…).
class InfoTiles extends StatelessWidget {
  const InfoTiles({required this.items, super.key});

  final List<(String label, String value)> items;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
    child: Row(
      children: [
        for (final (i, (label, value)) in items.indexed) ...[
          if (i > 0) const SizedBox(width: 10),
          Expanded(
            child: Glass(
              radius: 20,
              blur: 0,
              color: AppColors.glassCard,
              borderColor: AppColors.glassBorderStrong,
              shadow: AppShadows.searchRow,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label.toUpperCase(),
                    style: AppText.kicker.copyWith(
                      fontSize: 9.5,
                      letterSpacing: 1.4,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.rowTitle.copyWith(fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    ),
  );
}

/// Horizontal list of cast avatars with name and character.
class CastRail extends StatelessWidget {
  const CastRail({required this.cast, required this.onTap, super.key});

  final List<CastMember> cast;
  final ValueChanged<CastMember> onTap;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 128,
    child: ListView.separated(
      scrollDirection: Axis.horizontal,
      clipBehavior: Clip.none,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
      itemCount: cast.length,
      separatorBuilder: (_, _) => const SizedBox(width: 14),
      itemBuilder: (context, i) {
        final member = cast[i];
        return Pressable(
          onTap: () => onTap(member),
          child: SizedBox(
            width: 76,
            child: Column(
              children: [
                OuterShadow(
                  radius: 36,
                  shadow: AppShadows.rail,
                  child: ClipOval(
                    child: SizedBox.square(
                      dimension: 72,
                      child: PosterImage(
                        path: member.profilePath,
                        seed: member.id + 2,
                        size: TmdbImageSize.w185,
                        label: initialsOf(member.name),
                        labelSize: 20,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  member.name,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: AppFonts.dmSans,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.ink,
                  ),
                ),
                if (member.character.isNotEmpty)
                  Text(
                    member.character,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: AppFonts.dmSans,
                      fontSize: 10.5,
                      color: AppColors.inkMuted,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    ),
  );
}

/// Horizontal poster list for similar titles or a person's credits.
class PosterRail extends StatelessWidget {
  const PosterRail({required this.items, required this.onTap, super.key});

  final List<Media> items;
  final ValueChanged<Media> onTap;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 162,
    child: ListView.separated(
      scrollDirection: Axis.horizontal,
      clipBehavior: Clip.none,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
      itemCount: items.length,
      separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.railGap),
      itemBuilder: (context, i) =>
          PosterCard(media: items[i], onTap: () => onTap(items[i])),
    ),
  );
}
