import 'package:cinecatalog/core/config/app_config.dart';
import 'package:cinecatalog/core/network/api_client_provider.dart';
import 'package:cinecatalog/core/theme/app_tokens.dart';
import 'package:cinecatalog/features/home/presentation/browse_category.dart';
import 'package:cinecatalog/features/home/presentation/pages/category_list_page.dart';
import 'package:cinecatalog/features/home/presentation/pages/home_shell.dart';
import 'package:cinecatalog/features/movie/presentation/pages/movie_detail_page.dart';
import 'package:cinecatalog/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:cinecatalog/features/onboarding/presentation/pages/splash_page.dart';
import 'package:cinecatalog/features/people/presentation/pages/person_detail_page.dart';
import 'package:cinecatalog/features/people/presentation/pages/popular_people_page.dart';
import 'package:cinecatalog/features/search/presentation/pages/search_page.dart';
import 'package:cinecatalog/features/tv/presentation/pages/tv_detail_page.dart';
import 'package:cinecatalog/features/watchlist/presentation/pages/watchlist_page.dart';
import 'package:cinecatalog/router/routes.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    // Shared with Chucker and ApiClient's error toasts.
    navigatorKey: ref.watch(rootNavigatorKeyProvider),
    initialLocation: AppConfig.initialRoute.isEmpty
        ? Routes.splash.path
        : AppConfig.initialRoute,
    routes: [
      GoRoute(
        name: Routes.splash.name,
        path: Routes.splash.path,
        pageBuilder: (context, state) => _fade(state, const SplashPage()),
      ),
      GoRoute(
        name: Routes.onboarding.name,
        path: Routes.onboarding.path,
        pageBuilder: (context, state) => _fade(state, const OnboardingPage()),
      ),
      GoRoute(
        name: Routes.home.name,
        path: Routes.home.path,
        pageBuilder: (context, state) => _fade(state, const HomeShell()),
      ),
      GoRoute(
        name: Routes.search.name,
        path: Routes.search.path,
        pageBuilder: (context, state) =>
            _rise(state, AppMotion.searchIn, const SearchPage()),
      ),
      GoRoute(
        name: Routes.people.name,
        path: Routes.people.path,
        pageBuilder: (context, state) =>
            _rise(state, AppMotion.listIn, const PopularPeoplePage()),
      ),
      GoRoute(
        name: Routes.watchlist.name,
        path: Routes.watchlist.path,
        pageBuilder: (context, state) =>
            _rise(state, AppMotion.listIn, const WatchlistPage()),
      ),
      GoRoute(
        name: Routes.list.name,
        path: Routes.list.path,
        pageBuilder: (context, state) {
          final category = BrowseCategory.parse(
            state.pathParameters['media']!,
            state.pathParameters['category']!,
          );
          return _rise(
            state,
            AppMotion.listIn,
            category == null
                ? const UnknownCategoryPage()
                : CategoryListPage(category: category),
          );
        },
      ),
      GoRoute(
        name: Routes.movie.name,
        path: Routes.movie.path,
        pageBuilder: (context, state) =>
            _rise(state, AppMotion.detailIn, MovieDetailPage(id: _id(state))),
      ),
      GoRoute(
        name: Routes.tv.name,
        path: Routes.tv.path,
        pageBuilder: (context, state) =>
            _rise(state, AppMotion.detailIn, TvDetailPage(id: _id(state))),
      ),
      GoRoute(
        name: Routes.person.name,
        path: Routes.person.path,
        pageBuilder: (context, state) =>
            _rise(state, AppMotion.detailIn, PersonDetailPage(id: _id(state))),
      ),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
});

/// A bad id falls through to the detail page's "not found" state.
int _id(GoRouterState state) =>
    int.tryParse(state.pathParameters['id'] ?? '') ?? -1;

/// Slide up 24px and fade in (CSS `riseIn`).
CustomTransitionPage<void> _rise(
  GoRouterState state,
  Duration duration,
  Widget child,
) => CustomTransitionPage(
  key: state.pageKey,
  child: child,
  transitionDuration: duration,
  reverseTransitionDuration: duration,
  transitionsBuilder: (context, animation, _, child) {
    final curved = CurvedAnimation(parent: animation, curve: AppMotion.ease);
    return FadeTransition(
      opacity: curved,
      child: AnimatedBuilder(
        animation: curved,
        builder: (context, child) => Transform.translate(
          offset: Offset(0, 24 * (1 - curved.value)),
          child: child,
        ),
        child: child,
      ),
    );
  },
);

CustomTransitionPage<void> _fade(GoRouterState state, Widget child) =>
    CustomTransitionPage(
      key: state.pageKey,
      child: child,
      transitionDuration: const Duration(milliseconds: 400),
      transitionsBuilder: (context, animation, _, child) => FadeTransition(
        opacity: CurvedAnimation(parent: animation, curve: AppMotion.fade),
        child: child,
      ),
    );
