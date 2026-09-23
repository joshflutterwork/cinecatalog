import 'package:cinecatalog/core/theme/app_tokens.dart';
import 'package:cinecatalog/core/utils/formatters.dart';
import 'package:cinecatalog/core/utils/open_trailer.dart';
import 'package:cinecatalog/core/widgets/detail_layout.dart';
import 'package:cinecatalog/features/movie/domain/entities/movie_detail.dart';
import 'package:cinecatalog/features/movie/presentation/providers/movie_providers.dart';
import 'package:cinecatalog/features/movie/presentation/state/movie_detail_state.dart';
import 'package:cinecatalog/features/watchlist/presentation/providers/watchlist_providers.dart';
import 'package:cinecatalog/features/watchlist/presentation/watchlist_actions.dart';
import 'package:cinecatalog/router/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class MovieDetailPage extends ConsumerWidget {
  const MovieDetailPage({required this.id, super.key});

  final int id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    void back() => context.popOrHome();
    return switch (ref.watch(movieDetailProvider(id))) {
      MovieDetailLoading() => DetailSkeleton(onBack: back),
      MovieDetailError(:final failure) => DetailErrorView(
        failure: failure,
        onRetry: () => ref.read(movieDetailProvider(id).notifier).retry(),
        onBack: back,
      ),
      MovieDetailLoaded(:final detail) => _MovieDetailView(detail: detail),
    };
  }
}

class _MovieDetailView extends ConsumerWidget {
  const _MovieDetailView({required this.detail});

  final MovieDetail detail;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final movie = detail.movie;
    final trailer = detail.trailers.firstOrNull;
    return DetailLayout(
      imagePath: movie.posterPath ?? movie.backdropPath,
      seed: movie.id,
      tags: [
        ...detail.genres.take(2).map((g) => g.name),
        formatYear(movie.year),
      ],
      title: movie.title,
      overview: movie.overview,
      onBack: () => context.popOrHome(),
      cta: DetailCtaRow(
        onPlay: trailer == null ? null : () => openTrailer(context, trailer),
        playLabel: trailer == null ? 'No trailer yet' : 'Play',
        favourite: ref.watch(watchlistProvider).contains(movie),
        onFavourite: () => toggleWatchlist(context, ref, movie),
      ),
      extras: [
        InfoTiles(
          items: [
            ('Rating', formatRating(movie.voteAverage)),
            (
              'Runtime',
              detail.runtime == null ? '–' : formatRuntime(detail.runtime!),
            ),
            ('Status', detail.status),
          ],
        ),
        if (detail.tagline case final tagline? when tagline.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 0),
            child: Text(
              '“$tagline”',
              style: AppText.detailBody.copyWith(
                fontStyle: FontStyle.italic,
                color: AppColors.inkSoft,
              ),
            ),
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
            title: 'Similar movies',
            child: PosterRail(
              items: detail.similar,
              onTap: (m) => context.push(Routes.media(m)),
            ),
          ),
      ],
    );
  }
}
