import 'package:cinecatalog/core/common/media.dart';
import 'package:cinecatalog/core/error/failure.dart';
import 'package:cinecatalog/features/tv/domain/entities/tv_show.dart';
import 'package:cinecatalog/features/watchlist/data/datasources/watchlist_local_datasource.dart';
import 'package:cinecatalog/features/watchlist/data/repositories/watchlist_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/fixtures.dart';

void main() {
  Future<WatchlistRepositoryImpl> repository([
    Map<String, Object> stored = const {},
  ]) async {
    SharedPreferences.setMockInitialValues(stored);
    final prefs = await SharedPreferences.getInstance();
    return WatchlistRepositoryImpl(WatchlistLocalDataSourceImpl(prefs));
  }

  List<String> titles(Iterable<Media> items) => [
    for (final m in items) m.title,
  ];

  test('starts empty', () async {
    final result = await (await repository()).getWatchlist();
    expect(result.getRight().toNullable(), isEmpty);
  });

  test('adds newest first; saving again moves it to the top', () async {
    final repo = await repository();
    await repo.add(movieFixture(1, title: 'A'));
    await repo.add(movieFixture(2, title: 'B'));
    final result = await repo.add(movieFixture(1, title: 'A'));

    expect(titles(result.getRight().toNullable()!), ['A', 'B']);
  });

  test('a movie and a show with the same id are different entries', () async {
    final repo = await repository();
    await repo.add(movieFixture(7, title: 'Movie 7'));
    final result = await repo.add(
      const TvShow(id: 7, title: 'Show 7', overview: '', voteAverage: 8),
    );

    final items = result.getRight().toNullable()!;
    expect(titles(items), ['Show 7', 'Movie 7']);
    expect(items.first, isA<TvShow>());
  });

  test('removes one title', () async {
    final repo = await repository();
    await repo.add(movieFixture(1, title: 'A'));
    await repo.add(movieFixture(2, title: 'B'));

    final result = await repo.remove(movieFixture(1, title: 'A'));

    expect(titles(result.getRight().toNullable()!), ['B']);
  });

  test('survives a restart: a new instance reads what was saved', () async {
    final repo = await repository();
    await repo.add(movieFixture(1, title: 'Inception'));
    final prefs = await SharedPreferences.getInstance();

    // Same stored values, fresh objects, as after reopening the app.
    final reopened = WatchlistRepositoryImpl(
      WatchlistLocalDataSourceImpl(prefs),
    );
    final items = (await reopened.getWatchlist()).getRight().toNullable()!;

    expect(titles(items), ['Inception']);
    expect(items.single.year, 2020);
  });

  test('a corrupt stored value becomes StorageFailure', () async {
    final repo = await repository({'watchlist.v1': 'not json ['});

    final result = await repo.getWatchlist();

    expect(result.getLeft().toNullable(), isA<StorageFailure>());
  });
}
