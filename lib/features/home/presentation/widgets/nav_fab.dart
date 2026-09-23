import 'package:cinecatalog/core/widgets/app_icon.dart';
import 'package:cinecatalog/core/widgets/fab_menu.dart';
import 'package:cinecatalog/features/home/presentation/browse_category.dart';
import 'package:cinecatalog/router/routes.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Where the [NavFab] is shown; that item is marked active.
enum NavFabPage { movies, tv, people, watchlist }

/// The app's floating menu (Movies, TV Shows, Popular People, Watchlist),
/// the same on every page that has it.
///
/// Put it as the last child of the page's root `Stack`, filling it, so the
/// FAB sits above everything:
///
/// ```dart
/// const Positioned.fill(child: NavFab(current: NavFabPage.watchlist)),
/// ```
///
/// It owns the open state, the scrim (tap to close) and the back button
/// (closes the menu first). Where the page has nothing under it, touches
/// pass through to the page.
class NavFab extends ConsumerStatefulWidget {
  const NavFab({required this.current, super.key});

  final NavFabPage current;

  @override
  ConsumerState<NavFab> createState() => _NavFabState();
}

class _NavFabState extends ConsumerState<NavFab> {
  bool _open = false;

  void _toggle() => setState(() => _open = !_open);

  void _close() => setState(() => _open = false);

  bool get _onHome =>
      widget.current == NavFabPage.movies || widget.current == NavFabPage.tv;

  /// Movies / TV Shows: switch the home tab, going home first if needed.
  void _goHome(HomeMode mode) {
    _close();
    ref.read(homeModeProvider.notifier).select(mode);
    if (!_onHome) context.go(Routes.home.path);
  }

  /// Popular People / Watchlist: open the page unless already on it.
  void _visit(NavFabPage page, String path) {
    _close();
    if (widget.current != page) context.push(path);
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !_open,
    onPopInvokedWithResult: (didPop, _) {
      if (!didPop && _open) _close();
    },
    child: Stack(
      children: [
        if (_open) Positioned.fill(child: FabScrim(onTap: _close)),
        // Keyed so the scrim appearing above does not shift the FAB onto
        // another element, which would reset the pills' spin-in and leave
        // them invisible.
        Positioned(
          key: const ValueKey('fab'),
          right: 20,
          bottom: 104,
          child: FabMenu(
            open: _open,
            onToggle: _toggle,
            items: [
              FabMenuItem(
                label: HomeMode.movies.title,
                icon: AppIcons.movies,
                active: widget.current == NavFabPage.movies,
                onTap: () => _goHome(HomeMode.movies),
              ),
              FabMenuItem(
                label: HomeMode.tv.title,
                icon: AppIcons.tv,
                active: widget.current == NavFabPage.tv,
                onTap: () => _goHome(HomeMode.tv),
              ),
              FabMenuItem(
                label: 'Popular People',
                icon: AppIcons.people,
                active: widget.current == NavFabPage.people,
                onTap: () => _visit(NavFabPage.people, Routes.people.path),
              ),
              FabMenuItem(
                label: 'Watchlist',
                icon: AppIcons.heart,
                active: widget.current == NavFabPage.watchlist,
                onTap: () =>
                    _visit(NavFabPage.watchlist, Routes.watchlist.path),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
