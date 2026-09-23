import 'package:cinecatalog/core/theme/app_tokens.dart';
import 'package:cinecatalog/core/widgets/app_icon.dart';
import 'package:cinecatalog/core/widgets/glass.dart';
import 'package:flutter/widgets.dart';

/// Top of the home screen, pinned like `PageHeader` on the list pages:
/// profile pill and search, then the "BROWSE" kicker and the tab's [title].
/// The feed scrolls below it and is clipped at its bottom edge.
class HomeHeader extends StatelessWidget {
  const HomeHeader({required this.title, required this.onSearch, super.key});

  /// "Movies" or "TV Shows"; cross-fades when the tab changes.
  final String title;
  final VoidCallback onSearch;

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    return Padding(
      padding: EdgeInsets.fromLTRB(20, top + 6, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const _ProfilePill(),
              GlassIconButton(
                icon: AppIcons.search,
                onTap: onSearch,
                semanticLabel: 'Search',
              ),
            ],
          ),
          const SizedBox(height: 18),
          const Text('BROWSE', style: AppText.kicker),
          const SizedBox(height: 5),
          AnimatedSwitcher(
            duration: AppMotion.navPill,
            switchInCurve: AppMotion.ease,
            switchOutCurve: AppMotion.ease,
            layoutBuilder: (current, previous) => Stack(
              alignment: Alignment.centerLeft,
              children: [...previous, ?current],
            ),
            child: Text(title, key: ValueKey(title), style: AppText.pageTitle),
          ),
        ],
      ),
    );
  }
}

class _ProfilePill extends StatelessWidget {
  const _ProfilePill();

  @override
  Widget build(BuildContext context) => Glass(
    padding: const EdgeInsets.fromLTRB(12, 5, 6, 5),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(
          width: 10,
          height: 10,
          child: Wrap(
            spacing: 3,
            runSpacing: 3,
            children: [_Dot(), _Dot(), _Dot(), _Dot()],
          ),
        ),
        const SizedBox(width: 11),
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: AppColors.avatarGradient,
            border: Border.all(color: AppColors.glassBorderStrong, width: 0.5),
          ),
          alignment: Alignment.center,
          // No accounts in the app, so a neutral person icon, not initials.
          child: const AppIcon(
            AppIcons.people,
            color: AppColors.avatarInk,
            size: 16,
          ),
        ),
      ],
    ),
  );
}

class _Dot extends StatelessWidget {
  const _Dot();

  @override
  Widget build(BuildContext context) => const DecoratedBox(
    decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.dot),
    child: SizedBox.square(dimension: 3.5),
  );
}
