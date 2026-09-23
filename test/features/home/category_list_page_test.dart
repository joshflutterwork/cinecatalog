import 'package:cinecatalog/core/common/paginated_entity.dart';
import 'package:cinecatalog/core/config/shared_preferences_provider.dart';
import 'package:cinecatalog/core/error/failure.dart';
import 'package:cinecatalog/core/theme/app_theme.dart';
import 'package:cinecatalog/core/widgets/media_list_row.dart';
import 'package:cinecatalog/features/home/presentation/browse_category.dart';
import 'package:cinecatalog/features/home/presentation/pages/category_list_page.dart';
import 'package:cinecatalog/features/movie/domain/entities/movie.dart';
import 'package:cinecatalog/features/movie/domain/entities/movie_detail.dart';
import 'package:cinecatalog/features/movie/domain/repositories/movie_repository.dart';
import 'package:cinecatalog/features/movie/presentation/providers/movie_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/fixtures.dart';

/// Answers instantly; fails every call while [failing] is true.
final class _StubMovieRepository implements MovieRepository {
  bool failing = false;
  int calls = 0;

  @override
  Future<Either<Failure, PaginatedEntity<Movie>>> getMovies(
    MovieCategory category,
    int page,
  ) async {
    calls++;
    if (failing) return const Left(NetworkFailure());
    return Right(moviePage(page, perPage: 6));
  }

  @override
  Future<Either<Failure, MovieDetail>> getMovieDetail(int id) async =>
      const Left(NotFoundFailure());
}

void main() {
  late _StubMovieRepository repository;

  setUp(() => repository = _StubMovieRepository());

  Future<void> pumpPage(WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          movieRepositoryProvider.overrideWithValue(repository),
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
        retry: (_, _) => null,
        child: MaterialApp(
          theme: AppTheme.light,
          home: const CategoryListPage(
            category: MovieBrowse(MovieCategory.topRated),
          ),
        ),
      ),
    );
    // Shimmer and rise-in animations never settle, so pump a fixed time.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
  }

  testWidgets('shows the category title and the first page of rows', (
    tester,
  ) async {
    await pumpPage(tester);

    expect(find.text('Top Rated Movies'), findsOneWidget);
    expect(find.text('MOVIES'), findsOneWidget);
    expect(find.byType(MediaListRow), findsWidgets);
    expect(find.text('Movie 0'), findsOneWidget);
  });

  testWidgets('scrolling to the end loads page 2 and then the end note', (
    tester,
  ) async {
    await pumpPage(tester);

    await tester.fling(find.byType(ListView), const Offset(0, -3000), 3000);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.fling(find.byType(ListView), const Offset(0, -3000), 3000);
    await tester.pump(const Duration(milliseconds: 500));

    expect(repository.calls, 2);
    expect(find.text('Movie 11'), findsOneWidget);
    expect(find.text('All titles are shown'), findsOneWidget);
  });

  testWidgets('shows the error card and recovers on retry', (tester) async {
    repository.failing = true;
    await pumpPage(tester);

    expect(find.text('No connection'), findsOneWidget);
    expect(find.text('Try again'), findsOneWidget);

    repository.failing = false;
    await tester.tap(find.text('Try again'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('No connection'), findsNothing);
    expect(find.text('Movie 0'), findsOneWidget);
  });

  testWidgets('swipe left adds to the watchlist, then offers Remove', (
    tester,
  ) async {
    await pumpPage(tester);

    Future<void> swipeOpen() async {
      await tester.drag(find.text('Movie 0'), const Offset(-120, 0));
      for (var i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
    }

    await swipeOpen();
    await tester.tap(find.bySemanticsLabel('Add'));
    await tester.pump();
    expect(find.text('Added to watchlist'), findsOneWidget);

    await tester.pump(const Duration(seconds: 2));
    await swipeOpen();
    expect(find.bySemanticsLabel('Remove'), findsOneWidget);
    await tester.tap(find.bySemanticsLabel('Remove'));
    await tester.pump();
    expect(find.text('Removed from watchlist'), findsOneWidget);
    await tester.pump(const Duration(seconds: 2));
  });
}
