import 'package:cinecatalog/core/common/media.dart';
import 'package:cinecatalog/router/path_route.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

/// App routes, so pages never build URL strings by hand.
abstract final class Routes {
  static const splash = PathRoute(name: 'splash', path: '/splash');
  static const onboarding = PathRoute(name: 'onboarding', path: '/onboarding');
  static const home = PathRoute(name: 'home', path: '/');
  static const search = PathRoute(name: 'search', path: '/search');
  static const people = PathRoute(name: 'people', path: '/people');
  static const watchlist = PathRoute(name: 'watchlist', path: '/watchlist');
  static const list = PathRoute(name: 'list', path: '/list/:media/:category');
  static const movie = PathRoute(name: 'movie', path: '/movie/:id');
  static const tv = PathRoute(name: 'tv', path: '/tv/:id');
  static const person = PathRoute(name: 'person', path: '/person/:id');

  static String media(Media media) => switch (media.mediaType) {
    MediaType.movie => movie.build([media.id]),
    MediaType.tv => tv.build([media.id]),
    MediaType.person => person.build([media.id]),
  };
}

extension PopOrHome on BuildContext {
  /// Back when there is somewhere to go back to; home when the page was
  /// opened directly (deep link, QA route).
  void popOrHome() => canPop() ? pop() : go(Routes.home.path);
}
