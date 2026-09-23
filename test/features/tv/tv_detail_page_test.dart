import 'package:cinecatalog/core/config/shared_preferences_provider.dart';
import 'package:cinecatalog/core/error/failure.dart';
import 'package:cinecatalog/core/theme/app_theme.dart';
import 'package:cinecatalog/features/tv/domain/entities/tv_detail.dart';
import 'package:cinecatalog/features/tv/domain/entities/tv_show.dart';
import 'package:cinecatalog/features/tv/presentation/pages/tv_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/stub_repositories.dart';

/// A long-running show: four seasons with hundreds of episodes each.
final class _TonightShow extends StubTvRepository {
  const _TonightShow();

  @override
  Future<Either<Failure, TvDetail>> getTvDetail(int id) async => Right(
    TvDetail(
      show: TvShow(
        id: id,
        title: 'The Tonight Show Starring Jimmy Fallon',
        overview: 'Late night.',
        voteAverage: 6,
      ),
      numberOfSeasons: 4,
      numberOfEpisodes: 806,
      seasons: [
        for (final (i, eps) in [191, 263, 144, 208].indexed)
          Season(
            id: i,
            name: 'Season ${i + 1}',
            seasonNumber: i + 1,
            episodeCount: eps,
            airDate: DateTime(2014 + i),
          ),
      ],
      networks: const ['NBC'],
      genres: const [],
      status: 'Returning Series',
      cast: const [],
      trailers: const [],
      similar: const [],
    ),
  );
}

void main() {
  for (final scale in [1.0, 1.3]) {
    testWidgets('season rail does not overflow at text scale $scale', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(402, 874) * 3;
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            ...stubRepositories(tv: const _TonightShow()),
            sharedPreferencesProvider.overrideWithValue(prefs),
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context)
                  .copyWith(textScaler: TextScaler.linear(scale)),
              child: child!,
            ),
            home: const TvDetailPage(id: 1),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      await tester.scrollUntilVisible(
        find.text('Season 2'),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pump();

      expect(find.text('263 episodes · 2015'), findsOneWidget);
      expect(tester.takeException(), isNull, reason: 'no RenderFlex overflow');
    });
  }
}
