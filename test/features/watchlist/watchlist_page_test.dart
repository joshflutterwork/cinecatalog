import 'package:cinecatalog/core/config/shared_preferences_provider.dart';
import 'package:cinecatalog/core/error/failure.dart';
import 'package:cinecatalog/core/theme/app_theme.dart';
import 'package:cinecatalog/features/movie/domain/entities/movie_detail.dart';
import 'package:cinecatalog/features/movie/presentation/pages/movie_detail_page.dart';
import 'package:cinecatalog/features/watchlist/presentation/pages/watchlist_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/fixtures.dart';
import '../../helpers/stub_repositories.dart';

/// Answers the detail of any movie id with a fixture.
final class _DetailRepository extends StubMovieRepository {
  const _DetailRepository();

  @override
  Future<Either<Failure, MovieDetail>> getMovieDetail(int id) async => Right(
    MovieDetail(
      movie: movieFixture(id, title: 'Inception'),
      genres: const [],
      status: 'Released',
      cast: const [],
      trailers: const [],
      similar: const [],
    ),
  );
}

void main() {
  Future<void> pump(WidgetTester tester, Widget home) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          ...stubRepositories(movies: const _DetailRepository()),
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
        child: MaterialApp(theme: AppTheme.light, home: home),
      ),
    );
    await tester.pump();
  }

  Future<void> letToastExpire(WidgetTester tester) =>
      tester.pump(const Duration(seconds: 2));

  testWidgets('an empty watchlist shows the empty state', (tester) async {
    await pump(tester, const WatchlistPage());

    expect(find.text('Nothing saved yet'), findsOneWidget);
  });

  testWidgets('the heart adds with a toast, and removes with one', (
    tester,
  ) async {
    await pump(tester, const MovieDetailPage(id: 1));
    expect(find.bySemanticsLabel('Add to watchlist'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('Add to watchlist'));
    await tester.pump();
    expect(find.text('Added to watchlist'), findsOneWidget);
    expect(find.bySemanticsLabel('Remove from watchlist'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('Remove from watchlist'));
    await tester.pump();
    expect(find.text('Removed from watchlist'), findsOneWidget);
    await letToastExpire(tester);
  });

  Future<void> saveInception(WidgetTester tester) async {
    await pump(tester, const MovieDetailPage(id: 1));
    await tester.tap(find.bySemanticsLabel('Add to watchlist'));
    await tester.pump();
    await letToastExpire(tester);
    await tester.pumpWidget(const SizedBox());
    await pumpSaved(tester);
  }

  /// Lets the open/close animation finish (the glow background loops, so
  /// no pumpAndSettle).
  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  double rowLeft(WidgetTester tester) =>
      tester.getTopLeft(find.text('Inception')).dx;

  testWidgets('swiping left holds Remove open; tapping it removes', (
    tester,
  ) async {
    await saveInception(tester);
    final closedLeft = rowLeft(tester);

    await tester.drag(find.text('Inception'), const Offset(-120, 0));
    await settle(tester);
    expect(rowLeft(tester), lessThan(closedLeft), reason: 'held open');
    expect(find.text('Inception'), findsOneWidget, reason: 'not removed yet');

    await tester.tap(find.bySemanticsLabel('Remove'));
    await tester.pump();
    await tester.pump();
    expect(find.text('Inception'), findsNothing);
    expect(find.text('Nothing saved yet'), findsOneWidget);
    expect(find.text('Removed from watchlist'), findsOneWidget);
    await letToastExpire(tester);
  });

  testWidgets('a short swipe springs back; a tap on an open row closes it', (
    tester,
  ) async {
    await saveInception(tester);
    final closedLeft = rowLeft(tester);

    await tester.drag(find.text('Inception'), const Offset(-30, 0));
    await settle(tester);
    expect(rowLeft(tester), closedLeft);

    await tester.drag(find.text('Inception'), const Offset(-120, 0));
    await settle(tester);
    await tester.tap(find.text('Inception'));
    await settle(tester);
    expect(rowLeft(tester), closedLeft);
    expect(find.text('Inception'), findsOneWidget);
  });
}

/// Watchlist page on the prefs the previous pump wrote to.
Future<void> pumpSaved(WidgetTester tester) async {
  final prefs = await SharedPreferences.getInstance();
  await tester.pumpWidget(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      child: MaterialApp(theme: AppTheme.light, home: const WatchlistPage()),
    ),
  );
  await tester.pump();
}
