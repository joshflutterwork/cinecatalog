import 'package:cinecatalog/core/theme/app_tokens.dart';
import 'package:cinecatalog/core/widgets/app_icon.dart';
import 'package:cinecatalog/core/widgets/glass.dart';
import 'package:cinecatalog/core/widgets/pressable.dart';
import 'package:cinecatalog/core/widgets/sheen.dart';
import 'package:flutter/widgets.dart';

/// The blue→light-blue call to action (Play, Next/Get started, Try again).
class GradientButton extends StatelessWidget {
  const GradientButton({
    required this.label,
    required this.onTap,
    super.key,
    this.leading,
    this.trailing,
    this.height = 56,
    this.padding = const EdgeInsets.symmetric(horizontal: 26),
    this.shadow = AppShadows.cta,
    this.textStyle = AppText.button,
    this.sheenPeriod,
    this.expand = false,
  });

  final String label;
  final VoidCallback? onTap;
  final AppIconData? leading;
  final AppIconData? trailing;
  final double height;
  final EdgeInsetsGeometry padding;
  final List<BoxShadow> shadow;
  final TextStyle textStyle;

  /// Null means no sheen animation.
  final Duration? sheenPeriod;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final radius = height / 2;
    final color = textStyle.color ?? AppColors.onAccent;
    final content = Row(
      mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (leading != null) ...[
          AppIcon(leading!, color: color, size: 15),
          const SizedBox(width: 9),
        ],
        // Shrinks with an ellipsis instead of overflowing the button when
        // the user's text size is large.
        Flexible(
          child: Text(
            label,
            style: textStyle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (trailing != null) ...[
          const SizedBox(width: 10),
          AppIcon(trailing!, color: color, size: 16),
        ],
      ],
    );
    return Opacity(
      opacity: onTap == null ? 0.55 : 1,
      child: Pressable(
        onTap: onTap,
        scale: 0.975,
        child: OuterShadow(
          radius: radius,
          shadow: shadow,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(radius),
            child: Container(
              height: height,
              decoration: BoxDecoration(
                gradient: AppColors.playGradient,
                borderRadius: BorderRadius.circular(radius),
                border: Border.all(
                  color: const Color.fromRGBO(255, 255, 255, 0.5),
                  width: 0.5,
                ),
              ),
              // The sheen spans the whole button, not just the padded
              // content box.
              child: Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  if (sheenPeriod != null)
                    Positioned.fill(child: Sheen(period: sheenPeriod!)),
                  Padding(padding: padding, child: content),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
