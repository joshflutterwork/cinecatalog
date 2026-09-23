import 'package:cinecatalog/core/theme/app_tokens.dart';
import 'package:cinecatalog/core/widgets/glow_background.dart';
import 'package:cinecatalog/features/home/presentation/browse_category.dart';
import 'package:cinecatalog/features/home/presentation/widgets/bottom_nav.dart';
import 'package:cinecatalog/features/home/presentation/widgets/home_feed.dart';
import 'package:cinecatalog/features/home/presentation/widgets/home_header.dart';
import 'package:cinecatalog/features/home/presentation/widgets/nav_fab.dart';
import 'package:cinecatalog/router/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Root screen. Layers, bottom to top: glow → header + feed → nav → FAB
/// (with its scrim).
class HomeShell extends ConsumerStatefulWidget {
  const HomeShell({super.key});

  @override
  ConsumerState<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends ConsumerState<HomeShell> {
  void _selectMode(HomeMode mode) =>
      ref.read(homeModeProvider.notifier).select(mode);

  @override
  Widget build(BuildContext context) {
    final mode = ref.watch(homeModeProvider);
    return Scaffold(
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
          Positioned(
            left: 0,
            right: 0,
            bottom: 28,
            child: Center(
              child: BottomNav(mode: mode, onSelect: _selectMode),
            ),
          ),
          // Last, so the FAB sits above everything (its scrim included).
          Positioned.fill(
            child: NavFab(
              current: mode == HomeMode.movies
                  ? NavFabPage.movies
                  : NavFabPage.tv,
            ),
          ),
        ],
      ),
    );
  }
}
