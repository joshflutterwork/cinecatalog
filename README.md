# CineCatalog

Movie, TV and people catalog on TMDB. Flutter + Riverpod 3 + go_router, clean architecture.
UI follows the design handoff (light "liquid glass" theme), kept locally in
`localdocs/design/` and not part of the repo.

## Setup

```sh
fvm install          # Flutter 3.47.5, pinned in .fvmrc
fvm flutter pub get
cp .env.example .env # then paste your TMDB "API Read Access Token"
fvm dart run build_runner build --delete-conflicting-outputs  # generates env.g.dart
fvm flutter run
```

## TMDB token

Every screen reads live TMDB data. Config lives in `.env` and is compiled in by
[`envied`](https://pub.dev/packages/envied) as `Env` (`lib/core/config/env.dart`);
the token is obfuscated (XOR-ed int arrays, not plain text in the binary). Both
`.env` and the generated `lib/core/config/env.g.dart` are git-ignored, so re-run
`build_runner` after cloning or after editing `.env`. Without a token each
request fails fast with the "Access denied" error card instead of calling TMDB.

## Architecture

```
Widget ─switch─▶ <Feature>State ◀─ Notifier ─▶ UseCase ─▶ *RepositoryImpl ─▶ RemoteDataSource ─▶ Dio
```

- **Network** (`lib/core/network`): one `ApiClient` (`apiClientProvider`) wraps
  Dio; datasources only call `_apiClient.get(path, query: ..., parser: Model.fromJson)`.
  It owns the bearer token (`TokenStorage`), `onUnauthorized(SessionEndReason)`,
  `onMaintenance` / `onServiceAvailable` (503 and recovery), TMDB params
  (`region`, `include_video_language`), retry on 429 (`Retry-After` or backoff,
  2 retries), an error toast per failed call (same type at most once per 3 s),
  `LogInterceptor` in debug and the Chucker inspector in the `dev` environment.
  Failed calls carry a `NetworkException` (`lib/core/error/network_exception.dart`);
  `guardRequest` turns it, or a JSON shape error, into a domain `Failure`.
- **Models** (`features/*/data/models`): hand-written `fromJson` + `toEntity`,
  tolerant of TMDB's nulls, empty dates and int/double mixups.
- **State**: every data call has its own sealed state in its feature
  (`features/*/presentation/state/`), which the page `switch`es over:
  - Details: `MovieDetailLoading` → `MovieDetailLoaded` | `MovieDetailError`
    (same for `TvDetail…`, `PersonDetail…`).
  - Lists: `MovieListLoading` → `MovieListLoaded` | `MovieListEmpty` |
    `MovieListError` (same for `TvList…`, `PopularPeople…`, `SearchResults…`).
    `…Loaded.data.loadMore` is `LoadMoreIdle` | `LoadMoreLoading` |
    `LoadMoreFailed`, so a failed next page keeps the items and only the
    footer offers a retry.
- **Pagination**: every TMDB list endpoint is paginated. Each list notifier
  keeps its own state but uses `PagingMixin` (`lib/core/state/paging.dart`):
  next page at 80 % scroll, one request at a time, stops at
  `min(total_pages, 500)`, stale answers after a retry are dropped. Search
  keeps one auto-disposed paginated provider per (debounced) query. Deck, rails
  and View all are shared by movies and TV, so `BrowseCategory` maps
  `MovieListState` / `TvListState` to the UI-only `MediaListView`.
- **Watchlist** (`features/watchlist`): the heart on a movie/TV detail page, or a
  swipe left then "Add" on a movie/TV View all row, saves the title (toast "Added
  to watchlist"). The FAB opens the Watchlist page, where a swipe left then
  "Remove" deletes one. Stored as JSON in `SharedPreferences`, so it survives
  closing and restarting the app; only uninstalling or clearing app data removes it.
- **Loading UI**: shimmer skeletons shaped like the real content on every screen
  (home deck + rails, View all, Popular People, search, detail); the next page
  shows a small spinner in the list footer.
- **Lazy loading**: lists and grids are builders; home rails below the fold only
  fetch when scrolled near; images load per item through `cached_network_image`
  at the TMDB size that fits (`w185` search, `w342` lists, `w780` hero).

## Build flags

| Flag | Default | Effect |
| --- | --- | --- |
| `TMDB_TOKEN` (`.env`) | – | TMDB API Read Access Token, obfuscated |
| `TMDB_LANGUAGE` (`.env`) | `en-US` | `language` sent with every request |
| `TMDB_REGION` (`.env`) | – | ISO 3166-1 country for the movie lists' release dates, e.g. `ID` |
| `APP_ENV` (`.env`, or `--dart-define` per run) | `dev` | `dev` / `staging` / `prod`; only `dev` enables Chucker |
| `INITIAL_ROUTE` | – | Open on a route, e.g. `/movie/27205`, for QA |

## Checks

```sh
fvm dart analyze   # must be 0 issues
fvm flutter test
```

Fonts (Sora, DM Sans) are bundled under `assets/fonts`, licensed under the SIL Open Font License.
