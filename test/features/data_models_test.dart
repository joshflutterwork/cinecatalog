import 'package:cinecatalog/core/error/failure.dart';
import 'package:cinecatalog/core/network/guard_request.dart';
import 'package:cinecatalog/core/network/paginated_response.dart';
import 'package:cinecatalog/features/movie/data/models/movie_detail_model.dart';
import 'package:cinecatalog/features/movie/data/models/movie_model.dart';
import 'package:cinecatalog/features/movie/domain/entities/movie.dart';
import 'package:cinecatalog/features/people/data/models/person_model.dart';
import 'package:cinecatalog/features/search/data/datasources/search_remote_datasource.dart';
import 'package:cinecatalog/features/search/domain/entities/search_result.dart';
import 'package:cinecatalog/features/tv/data/models/tv_detail_model.dart';
import 'package:cinecatalog/features/tv/data/models/tv_show_model.dart';
import 'package:cinecatalog/features/tv/domain/entities/tv_show.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MovieModel', () {
    test('parses a full row', () {
      final movie = MovieModel.fromJson(const {
        'id': 27205,
        'title': 'Inception',
        'overview': 'Dreams.',
        'vote_average': 8.4,
        'poster_path': '/p.jpg',
        'backdrop_path': '/b.jpg',
        'release_date': '2010-07-15',
      }).toEntity();

      expect(movie.id, 27205);
      expect(movie.title, 'Inception');
      expect(movie.voteAverage, 8.4);
      expect(movie.posterPath, '/p.jpg');
      expect(movie.year, 2010);
    });

    test('survives null images, empty date and int vote', () {
      final movie = MovieModel.fromJson(const {
        'id': 1,
        'title': 'Untitled',
        'overview': null,
        'vote_average': 7,
        'poster_path': null,
        'release_date': '',
      }).toEntity();

      expect(movie.overview, '');
      expect(movie.voteAverage, 7.0);
      expect(movie.posterPath, isNull);
      expect(movie.backdropPath, isNull);
      expect(movie.date, isNull);
    });
  });

  test('TvShowModel maps name and first_air_date', () {
    final show = TvShowModel.fromJson(const {
      'id': 1396,
      'name': 'Breaking Bad',
      'first_air_date': '2008-01-20',
      'vote_average': 8.9,
    }).toEntity();

    expect(show.title, 'Breaking Bad');
    expect(show.year, 2008);
  });

  test('PaginatedResponse reads paging fields and caps via hasMore', () {
    final page = PaginatedResponse.fromJson(const {
      'page': 2,
      'total_pages': 38000,
      'total_results': 760000,
      'results': [
        {'id': 1, 'title': 'A'},
      ],
    }, MovieModel.fromJson).toEntity((m) => m.toEntity());

    expect(page.items.single.title, 'A');
    expect(page.page, 2);
    expect(page.lastPage, 500);
    expect(page.hasMore, isTrue);
  });

  test('MovieDetailModel keeps YouTube trailers, 0 runtime is null', () {
    final detail = MovieDetailModel.fromJson(const {
      'id': 1,
      'title': 'A',
      'runtime': 0,
      'status': 'Released',
      'tagline': '',
      'genres': [
        {'id': 18, 'name': 'Drama'},
      ],
      'credits': {
        'cast': [
          {'id': 5, 'name': 'Actor', 'character': 'Lead', 'profile_path': null},
        ],
      },
      'videos': {
        'results': [
          {'site': 'YouTube', 'type': 'Trailer', 'key': 'yt', 'name': 'T'},
          {'site': 'YouTube', 'type': 'Teaser', 'key': 'x', 'name': 'X'},
          {'site': 'Vimeo', 'type': 'Trailer', 'key': 'v', 'name': 'V'},
        ],
      },
      'similar': {
        'results': [
          {'id': 2, 'title': 'B'},
        ],
      },
    }).toEntity();

    expect(detail.runtime, isNull);
    expect(detail.tagline, isNull);
    expect(detail.genres.single.name, 'Drama');
    expect(detail.cast.single.profilePath, isNull);
    expect(detail.trailers.map((t) => t.key), ['yt']);
    expect(detail.similar.single.id, 2);
  });

  test('MovieDetailModel tolerates a missing append_to_response', () {
    final detail = MovieDetailModel.fromJson(const {'id': 1}).toEntity();
    expect(detail.cast, isEmpty);
    expect(detail.trailers, isEmpty);
    expect(detail.similar, isEmpty);
  });

  test('TvDetailModel reads seasons and networks', () {
    final detail = TvDetailModel.fromJson(const {
      'id': 1,
      'name': 'Show',
      'number_of_seasons': 2,
      'seasons': [
        {'id': 10, 'name': 'S1', 'season_number': 1, 'air_date': null},
      ],
      'networks': [
        {'name': 'HBO'},
        {'name': null},
      ],
    }).toEntity();

    expect(detail.numberOfSeasons, 2);
    expect(detail.seasons.single.airDate, isNull);
    expect(detail.networks, ['HBO']);
  });

  test('PersonModel splits known_for by media_type', () {
    final person = PersonModel.fromJson(const {
      'id': 1,
      'name': 'Zendaya',
      'known_for_department': 'Acting',
      'profile_path': null,
      'known_for': [
        {'media_type': 'movie', 'id': 2, 'title': 'Dune'},
        {'media_type': 'tv', 'id': 3, 'name': 'Euphoria'},
        {'media_type': 'unknown', 'id': 4},
      ],
    }).toEntity();

    expect(person.profilePath, isNull);
    expect(person.knownFor, hasLength(2));
    expect(person.knownFor[0], isA<Movie>());
    expect(person.knownFor[1], isA<TvShow>());
  });

  test('PersonDetailModel ranks roles by votes and drops repeats', () {
    final detail = PersonDetailModel.fromJson(const {
      'id': 1,
      'name': 'X',
      'biography': '',
      'birthday': '1996-09-01',
      'combined_credits': {
        'cast': [
          {
            'media_type': 'tv',
            'id': 3,
            'name': 'Small Show',
            'character': 'Rue',
            'vote_count': 40,
            'popularity': 90,
          },
          {
            'media_type': 'movie',
            'id': 2,
            'title': 'Big Movie',
            'character': 'MJ',
            'vote_count': 9000,
            'popularity': 5,
          },
          {
            'media_type': 'tv',
            'id': 3,
            'name': 'Small Show',
            'character': 'Rue (voice)',
            'vote_count': 40,
          },
        ],
      },
    }).toEntity();

    expect(detail.credits.map((m) => m.title), ['Big Movie', 'Small Show']);
    expect(detail.person.knownFor.first.title, 'Big Movie');
    expect(detail.birthday?.year, 1996);
    expect(detail.placeOfBirth, isNull);
  });

  test('PersonDetailModel leaves out talk-show and self appearances', () {
    final detail = PersonDetailModel.fromJson(const {
      'id': 1,
      'name': 'X',
      'combined_credits': {
        'cast': [
          {
            'media_type': 'tv',
            'id': 10,
            'name': 'The Late Show',
            'character': 'Self - Guest',
            'genre_ids': [35, 10767],
            'vote_count': 999999,
          },
          {
            'media_type': 'tv',
            'id': 11,
            'name': 'Award Night',
            'character': 'Herself',
            'vote_count': 88888,
          },
          {
            'media_type': 'movie',
            'id': 12,
            'title': 'Actual Role',
            'character': 'Lead',
            'vote_count': 10,
          },
        ],
      },
    }).toEntity();

    expect(detail.credits.map((m) => m.title), ['Actual Role']);
  });

  test('PersonDetailModel falls back to appearances for a host', () {
    final detail = PersonDetailModel.fromJson(const {
      'id': 1,
      'name': 'Host',
      'combined_credits': {
        'cast': [
          {
            'media_type': 'tv',
            'id': 20,
            'name': 'Guest Spot',
            'character': 'Self - Guest',
            'genre_ids': [10767],
            'vote_count': 10,
          },
          {
            'media_type': 'tv',
            'id': 21,
            'name': 'My Own Show',
            'character': 'Self - Host',
            'genre_ids': [10767],
            'vote_count': 500,
          },
        ],
      },
    }).toEntity();

    expect(detail.credits.map((m) => m.title), ['My Own Show', 'Guest Spot']);
  });

  test('search rows are split by media_type and unknown types dropped', () {
    final rows = [
      {'media_type': 'movie', 'id': 1, 'title': 'M'},
      {'media_type': 'tv', 'id': 2, 'name': 'T'},
      {'media_type': 'person', 'id': 3, 'name': 'P'},
      {'media_type': 'collection', 'id': 4},
    ].map(searchResultFromJson).nonNulls.toList();

    expect(rows.map((r) => r.runtimeType), [
      MovieResult,
      TvResult,
      PersonResult,
    ]);
  });

  test('a wrong type in the payload becomes ParsingFailure', () async {
    final result = await guardRequest(
      () async =>
          parseJson<MovieModel>({'id': 'not a number'}, MovieModel.fromJson),
    );
    expect(result.getLeft().toNullable(), isA<ParsingFailure>());
  });

  test('a non-object body becomes ParsingFailure', () async {
    final result = await guardRequest(
      () async => parseJson<MovieModel>('oops', MovieModel.fromJson),
    );
    expect(result.getLeft().toNullable(), isA<ParsingFailure>());
  });
}
