import 'package:cinecatalog/core/theme/app_tokens.dart';
import 'package:cinecatalog/core/widgets/app_icon.dart';
import 'package:cinecatalog/core/widgets/glow_background.dart';
import 'package:cinecatalog/features/home/presentation/browse_category.dart';
import 'package:cinecatalog/features/home/presentation/widgets/bottom_nav.dart';
import 'package:cinecatalog/features/home/presentation/widgets/fab_menu.dart';
import 'package:cinecatalog/features/home/presentation/widgets/home_feed.dart';
import 'package:cinecatalog/features/home/presentation/widgets/home_header.dart';
import 'package:cinecatalog/router/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Root screen. Layers, bottom to top: glow → header + feed → scrim → nav
/// → FAB.
class HomeShell extends ConsumerStatefulWidget {
  const HomeShell({super.key});

  @override
  ConsumerState<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends ConsumerState<HomeShell> {
  bool _fabOpen = false;

  void _toggleFab() => setState(() => _fabOpen = !_fabOpen);

  void _selectMode(HomeMode mode) {
    setState(() => _fabOpen = false);
    ref.read(homeModeProvider.notifier).select(mode);
  }

  @override
  Widget build(BuildContext context) {
    final mode = ref.watch(homeModeProvider);
    return PopScope(
      canPop: !_fabOpen,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && _fabOpen) _toggleFab();
      },
      child: Scaffold(
        backgroundColor: AppColors.bg,
        body: Stack(
          children: [
            const Positioned.fill(child: GlowBackground.home()),
            // Header and title stay put, like PageHeader on the list pages;
            // only the feed below scrolls, clipped at the header's edge.
            Positioned.fill(
              child: Column(
                children: [
                  HomeHeader(
                    title: mode.title,
                    onSearch: () => context.push(Routes.search.path),
                  ),
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: AppMotion.navPill,
                      switchInCurve: AppMotion.ease,
                      switchOutCurve: AppMotion.ease,
                      child: HomeFeed(key: ValueKey(mode), mode: mode),
                    ),
                  ),
                ],
              ),
            ),
            if (_fabOpen) Positioned.fill(child: _Scrim(onTap: _toggleFab)),
            // Keyed so the scrim appearing above does not shift these onto
            // other elements, which would reset the FAB's spin-in.
            Positioned(
              key: const ValueKey('nav'),
              left: 0,
              right: 0,
              bottom: 28,
              child: Center(
                child: BottomNav(mode: mode, onSelect: _selectMode),
              ),
            ),
            Positioned(
              key: const ValueKey('fab'),
              right: 20,
              bottom: 104,
              child: FabMenu(
                open: _fabOpen,
                onToggle: _toggleFab,
                items: [
                  FabMenuItem(
                    label: HomeMode.movies.title,
                    icon: AppIcons.movies,
                    active: mode == HomeMode.movies,
                    onTap: () => _selectMode(HomeMode.movies),
                  ),
                  FabMenuItem(
                    label: HomeMode.tv.title,
                    icon: AppIcons.tv,
                    active: mode == HomeMode.tv,
                    onTap: () => _selectMode(HomeMode.tv),
                  ),
                  FabMenuItem(
                    label: 'Popular People',
                    icon: AppIcons.people,
                    onTap: () {
                      setState(() => _fabOpen = false);
                      context.push(Routes.people.path);
                    },
                  ),
                  FabMenuItem(
                    label: 'Watchlist',
                    icon: AppIcons.heart,
                    onTap: () {
                      setState(() => _fabOpen = false);
                      context.push(Routes.watchlist.path);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Scrim extends StatelessWidget {
  const _Scrim({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: AppMotion.scrim,
      curve: AppMotion.fade,
      builder: (context, t, child) => Opacity(opacity: t, child: child),
      child: const DecoratedBox(
        decoration: BoxDecoration(gradient: AppColors.fabScrim),
      ),
    ),
  );
}
