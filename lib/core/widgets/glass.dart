import 'dart:ui';

import 'package:cinecatalog/core/theme/app_tokens.dart';
import 'package:cinecatalog/core/widgets/app_icon.dart';
import 'package:cinecatalog/core/widgets/pressable.dart';
import 'package:flutter/widgets.dart';

/// A frosted surface: blurred backdrop, translucent fill, 0.5px white edge.
///
/// The shadow is painted only outside the shape, like CSS `box-shadow`, so it
/// does not tint the translucent fill.
class Glass extends StatelessWidget {
  const Glass({
    required this.child,
    super.key,
    this.radius = 999,
    this.blur = 18,
    this.color = AppColors.glass,
    this.gradient,
    this.shadow = AppShadows.md,
    this.borderColor = AppColors.glassBorder,
    this.padding,
    this.width,
    this.height,
  });

  final Widget child;
  final double radius;

  /// Backdrop blur sigma. 0 skips the BackdropFilter, which is much cheaper
  /// inside scrolling lists.
  final double blur;
  final Color color;
  final Gradient? gradient;
  final List<BoxShadow> shadow;
  final Color borderColor;
  final EdgeInsetsGeometry? padding;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(radius);
    Widget surface = Container(
      width: width,
      height: height,
      padding: padding,
      decoration: BoxDecoration(
        color: gradient == null ? color : null,
        gradient: gradient,
        borderRadius: borderRadius,
        border: Border.all(color: borderColor, width: 0.5),
      ),
      child: child,
    );
    if (blur > 0) {
      surface = ClipRRect(
        borderRadius: borderRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: surface,
        ),
      );
    }
    return OuterShadow(radius: radius, shadow: shadow, child: surface);
  }
}

/// Paints [shadow] around a rounded rect but never underneath it.
class OuterShadow extends StatelessWidget {
  const OuterShadow({
    required this.radius,
    required this.shadow,
    required this.child,
    super.key,
  });

  final double radius;
  final List<BoxShadow> shadow;
  final Widget child;

  @override
  Widget build(BuildContext context) => shadow.isEmpty
      ? child
      : CustomPaint(painter: _OuterShadowPainter(radius, shadow), child: child);
}

class _OuterShadowPainter extends CustomPainter {
  const _OuterShadowPainter(this.radius, this.shadow);

  final double radius;
  final List<BoxShadow> shadow;

  @override
  void paint(Canvas canvas, Size size) {
    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(radius),
    );
    final outside = Path.combine(
      PathOperation.difference,
      Path()..addRect(rrect.outerRect.inflate(200)),
      Path()..addRRect(rrect),
    );
    canvas
      ..save()
      ..clipPath(outside);
    for (final s in shadow) {
      canvas.drawRRect(
        rrect.shift(s.offset).inflate(s.spreadRadius),
        s.toPaint(),
      );
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_OuterShadowPainter old) =>
      old.radius != radius || old.shadow != shadow;
}

/// Round glass button with one icon, used in headers and the detail top bar.
class GlassIconButton extends StatelessWidget {
  const GlassIconButton({
    required this.icon,
    required this.onTap,
    super.key,
    this.size = 42,
    this.iconSize = 17,
    this.iconColor = AppColors.icon,
    this.color = AppColors.glass,
    this.blur = 18,
    this.shadow = AppShadows.md,
    this.borderColor = AppColors.glassBorder,
    this.badge,
    this.semanticLabel,
  });

  final AppIconData icon;
  final VoidCallback? onTap;
  final double size;
  final double iconSize;
  final Color iconColor;
  final Color color;
  final double blur;
  final List<BoxShadow> shadow;
  final Color borderColor;

  /// Drawn on top of the button, e.g. the notification dot.
  final Widget? badge;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: semanticLabel,
    child: Pressable(
      onTap: onTap,
      scale: 0.92,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Glass(
            width: size,
            height: size,
            color: color,
            blur: blur,
            shadow: shadow,
            borderColor: borderColor,
            child: Center(
              child: AppIcon(icon, color: iconColor, size: iconSize),
            ),
          ),
          ?badge,
        ],
      ),
    ),
  );
}
