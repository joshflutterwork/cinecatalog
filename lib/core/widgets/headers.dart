import 'package:cinecatalog/core/theme/app_tokens.dart';
import 'package:cinecatalog/core/widgets/app_icon.dart';
import 'package:cinecatalog/core/widgets/glass.dart';
import 'package:flutter/widgets.dart';

/// Back button + kicker + title, used by View all and Popular People.
class PageHeader extends StatelessWidget {
  const PageHeader({
    required this.kicker,
    required this.title,
    required this.onBack,
    super.key,
    this.trailing,
  });

  final String kicker;
  final String title;
  final VoidCallback onBack;

  /// On the right, e.g. a search button.
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    return Padding(
      padding: EdgeInsets.fromLTRB(20, top + 4, 20, 14),
      child: Row(
        children: [
          GlassIconButton(
            icon: AppIcons.back,
            iconColor: AppColors.inkButton,
            color: AppColors.glassCard,
            borderColor: AppColors.glassBorderStrong,
            shadow: AppShadows.backButton,
            onTap: onBack,
            semanticLabel: 'Back',
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(kicker.toUpperCase(), style: AppText.kicker),
                const SizedBox(height: 2),
                Text(
                  title,
                  style: AppText.listTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (trailing != null) ...[const SizedBox(width: 12), trailing!],
        ],
      ),
    );
  }
}

/// Section title with an optional "View all ›" link on the right.
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    required this.title,
    super.key,
    this.style = AppText.railTitle,
    this.onViewAll,
    this.padding = const EdgeInsets.fromLTRB(20, 26, 20, 12),
  });

  final String title;
  final TextStyle style;
  final VoidCallback? onViewAll;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) => Padding(
    padding: padding,
    child: Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: style,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (onViewAll != null)
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onViewAll,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  const Text('View all', style: AppText.viewAll),
                  const SizedBox(width: 4),
                  AppIcon(
                    AppIcons.chevronRight,
                    color: AppText.viewAll.color!,
                    size: 13,
                  ),
                ],
              ),
            ),
          ),
      ],
    ),
  );
}
