import 'package:cinecatalog/core/config/tmdb_image.dart';
import 'package:cinecatalog/core/theme/app_tokens.dart';
import 'package:cinecatalog/core/utils/formatters.dart';
import 'package:cinecatalog/core/widgets/detail_layout.dart';
import 'package:cinecatalog/core/widgets/glass.dart';
import 'package:cinecatalog/core/widgets/poster_image.dart';
import 'package:cinecatalog/core/widgets/trailer_player.dart';
import 'package:cinecatalog/features/tv/domain/entities/tv_detail.dart';
import 'package:cinecatalog/features/tv/presentation/providers/tv_providers.dart';
import 'package:cinecatalog/features/tv/presentation/state/tv_detail_state.dart';
import 'package:cinecatalog/features/watchlist/presentation/providers/watchlist_providers.dart';
import 'package:cinecatalog/features/watchlist/presentation/watchlist_actions.dart';
import 'package:cinecatalog/router/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class TvDetailPage extends ConsumerWidget {
  const TvDetailPage({required this.id, super.key});

  final int id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    void back() => context.popOrHome();
    return switch (ref.watch(tvDetailProvider(id))) {
      TvDetailLoading() => DetailSkeleton(onBack: back),
      TvDetailError(:final failure) => DetailErrorView(
        failure: failure,
        onRetry: () => ref.read(tvDetailProvider(id).notifier).retry(),
        onBack: back,
      ),
      TvDetailLoaded(:final detail) => _TvDetailView(detail: detail),
    };
  }
}

class _TvDetailView extends ConsumerWidget {
  const _TvDetailView({required this.detail});

  final TvDetail detail;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final show = detail.show;
    final trailer = detail.trailers.firstOrNull;
    return DetailLayout(
      imagePath: show.posterPath ?? show.backdropPath,
      seed: show.id,
      tags: [
        ?detail.genres.firstOrNull?.name,
        if (detail.numberOfSeasons case final n when n > 0)
          '$n Season${n > 1 ? 's' : ''}',
        formatYear(show.year),
      ],
      title: show.title,
      overview: show.overview,
      onBack: () => context.popOrHome(),
      cta: DetailCtaRow(
        onPlay: trailer == null ? null : () => showTrailer(context, trailer),
        playLabel: trailer == null ? 'No trailer yet' : 'Play',
        favourite: ref.watch(watchlistProvider).contains(show),
        onFavourite: () => toggleWatchlist(context, ref, show),
      ),
      extras: [
        InfoTiles(
          items: [
            ('Rating', formatRating(show.voteAverage)),
            ('Episodes', detail.numberOfEpisodes.toString()),
            ('Status', detail.status),
          ],
        ),
        if (detail.networks.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
            child: Text(
              'Airs on ${detail.networks.join(', ')}',
              style: AppText.meta,
            ),
          ),
        if (detail.seasons.isNotEmpty)
          DetailSection(
            title: 'Season',
            child: _SeasonRail(seasons: detail.seasons, seed: show.id),
          ),
        if (detail.cast.isNotEmpty)
          DetailSection(
            title: 'Cast',
            child: CastRail(
              cast: detail.cast,
              onTap: (c) => context.push(Routes.person.build([c.id])),
            ),
          ),
        if (detail.similar.isNotEmpty)
          DetailSection(
            title: 'Similar shows',
            child: PosterRail(
              items: detail.similar,
              onTap: (m) => context.push(Routes.media(m)),
            ),
          ),
      ],
    );
  }
}

class _SeasonRail extends StatelessWidget {
  const _SeasonRail({required this.seasons, required this.seed});

  final List<Season> seasons;
  final int seed;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 188,
    child: ListView.separated(
      scrollDirection: Axis.horizontal,
      clipBehavior: Clip.none,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
      itemCount: seasons.length,
      separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.railGap),
      itemBuilder: (context, i) {
        final season = seasons[i];
        return SizedBox(
          width: 96,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              OuterShadow(
                radius: 16,
                shadow: AppShadows.posterSmall,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: SizedBox(
                    width: 96,
                    height: 138,
                    child: PosterImage(
                      path: season.posterPath,
                      seed: seed + season.seasonNumber,
                      size: TmdbImageSize.w185,
                      label: '${season.seasonNumber}',
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                season.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppText.posterTitle.copyWith(color: AppColors.ink),
              ),
              Text(
                '${season.episodeCount} '
                '${season.episodeCount == 1 ? 'episode' : 'episodes'} · '
                '${formatYear(season.airDate?.year)}',
                style: AppText.meta.copyWith(fontSize: 10.5),
              ),
            ],
          ),
        );
      },
    ),
  );
}
