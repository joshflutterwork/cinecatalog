import 'dart:ui';

import 'package:cinecatalog/core/theme/app_tokens.dart';
import 'package:cinecatalog/core/widgets/app_icon.dart';
import 'package:cinecatalog/core/widgets/glass.dart';
import 'package:cinecatalog/core/widgets/pressable.dart';
import 'package:cinecatalog/features/home/presentation/browse_category.dart';
import 'package:flutter/widgets.dart';

/// Two floating pills. The active one grows, turns blue and shows its label.
class BottomNav extends StatelessWidget {
  const BottomNav({required this.mode, required this.onSelect, super.key});

  final HomeMode mode;
  final ValueChanged<HomeMode> onSelect;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      _NavPill(
        icon: AppIcons.movies,
        label: HomeMode.movies.title,
        active: mode == HomeMode.movies,
        onTap: () => onSelect(HomeMode.movies),
      ),
      const SizedBox(width: 10),
      _NavPill(
        icon: AppIcons.tv,
        label: HomeMode.tv.title,
        active: mode == HomeMode.tv,
        onTap: () => onSelect(HomeMode.tv),
      ),
    ],
  );
}

class _NavPill extends StatelessWidget {
  const _NavPill({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  final AppIconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  static const double _radius = AppRadius.pill;

  @override
  Widget build(BuildContext context) {
    final color = active ? AppColors.accentInk : AppColors.inkNav;
    return Semantics(
      button: true,
      selected: active,
      label: label,
      child: Pressable(
        onTap: onTap,
        scale: 0.94,
        child: OuterShadow(
          radius: _radius,
          shadow: active ? AppShadows.navActive : AppShadows.navIdle,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(_radius),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 26, sigmaY: 26),
              child: AnimatedContainer(
                duration: AppMotion.navPill,
                curve: AppMotion.ease,
                height: 56,
                padding: active
                    ? const EdgeInsets.fromLTRB(20, 0, 24, 0)
                    : const EdgeInsets.symmetric(horizontal: 18),
                decoration: BoxDecoration(
                  color: active ? null : AppColors.glassCard,
                  gradient: active ? AppColors.activePill : null,
                  borderRadius: BorderRadius.circular(_radius),
                  border: Border.all(color: AppColors.glassBorder, width: 0.5),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TweenAnimationBuilder<Color?>(
                      tween: ColorTween(end: color),
                      duration: AppMotion.navPill,
                      builder: (_, c, _) => AppIcon(icon, color: c!, size: 20),
                    ),
                    AnimatedSize(
                      duration: AppMotion.navPill,
                      curve: AppMotion.ease,
                      child: active
                          ? Padding(
                              padding: const EdgeInsets.only(left: 9),
                              child: Text(
                                label,
                                style: AppText.pill,
                                maxLines: 1,
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
