import 'dart:math' as math;
import 'dart:ui';

import 'package:cinecatalog/core/theme/app_tokens.dart';
import 'package:cinecatalog/core/widgets/app_icon.dart';
import 'package:cinecatalog/core/widgets/glass.dart';
import 'package:cinecatalog/core/widgets/pressable.dart';
import 'package:cinecatalog/core/widgets/sheen.dart';
import 'package:flutter/widgets.dart';

final class FabMenuItem {
  const FabMenuItem({
    required this.label,
    required this.icon,
    required this.onTap,
    this.active = false,
  });

  final String label;
  final AppIconData icon;
  final VoidCallback onTap;
  final bool active;
}

/// The "+" button and, when [open], the pills that swing out above it.
class FabMenu extends StatefulWidget {
  const FabMenu({
    required this.open,
    required this.onToggle,
    required this.items,
    super.key,
  });

  final bool open;
  final VoidCallback onToggle;

  /// Top to bottom.
  final List<FabMenuItem> items;

  @override
  State<FabMenu> createState() => _FabMenuState();
}

class _FabMenuState extends State<FabMenu> with TickerProviderStateMixin {
  late final AnimationController _ring = AnimationController(
    vsync: this,
    duration: AppMotion.ringTurn,
  )..repeat();

  /// Drives every pill; each one plays its own slice of it.
  late final AnimationController _items = AnimationController(
    vsync: this,
    duration: _itemsDuration,
  );

  Duration get _itemsDuration =>
      AppMotion.fabItem + AppMotion.fabItemStagger * widget.items.length;

  @override
  void didUpdateWidget(FabMenu old) {
    super.didUpdateWidget(old);
    if (widget.open && !old.open) {
      _items.forward(from: 0);
    } else if (!widget.open && old.open) {
      _items.value = 0;
    }
  }

  @override
  void dispose() {
    _ring.dispose();
    _items.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final count = widget.items.length;
    final total = _itemsDuration.inMilliseconds;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (widget.open) ...[
          for (final (i, item) in widget.items.indexed) ...[
            if (i > 0) const SizedBox(height: 11),
            _SpinIn(
              // The bottom pill starts first: delays 0.12 / 0.08 / 0.04 s.
              animation: CurvedAnimation(
                parent: _items,
                curve: Interval(
                  AppMotion.fabItemStagger.inMilliseconds * (count - i) / total,
                  (AppMotion.fabItemStagger.inMilliseconds * (count - i) +
                          AppMotion.fabItem.inMilliseconds) /
                      total,
                ),
              ),
              child: _FabPill(item: item),
            ),
          ],
          const SizedBox(height: 2 + 12),
        ],
        _FabButton(open: widget.open, ring: _ring, onTap: widget.onToggle),
      ],
    );
  }
}

/// CSS `spinIn`: 0% opacity 0, rotate -140°, scale .5, translateY 18 →
/// 60% opacity 1, rotate 8°, scale 1.03 → 100% rotate 0, scale 1. Pivot is
/// 26px in from the right edge and 110px down, near the FAB.
class _SpinIn extends StatelessWidget {
  const _SpinIn({required this.animation, required this.child});

  final Animation<double> animation;
  final Widget child;

  static double _seg(double p, double from, double to) =>
      AppMotion.ease.transform(((p - from) / (to - from)).clamp(0, 1));

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: animation,
    builder: (context, child) {
      final p = animation.value;
      final double opacity;
      final double degrees;
      final double scale;
      final double dy;
      if (p < 0.6) {
        final t = _seg(p, 0, 0.6);
        opacity = t;
        degrees = lerpDouble(-140, 8, t)!;
        scale = lerpDouble(0.5, 1.03, t)!;
        dy = lerpDouble(18, 0, t)!;
      } else {
        final t = _seg(p, 0.6, 1);
        opacity = 1;
        degrees = lerpDouble(8, 0, t)!;
        scale = lerpDouble(1.03, 1, t)!;
        dy = 0;
      }
      return Opacity(
        opacity: opacity.clamp(0, 1),
        child: Transform(
          alignment: Alignment.topRight,
          origin: const Offset(-26, 110),
          transform: Matrix4.identity()
            ..rotateZ(degrees * math.pi / 180)
            ..scaleByDouble(scale, scale, 1, 1)
            ..translateByDouble(0, dy, 0, 1),
          child: child,
        ),
      );
    },
    child: child,
  );
}

class _FabPill extends StatelessWidget {
  const _FabPill({required this.item});

  final FabMenuItem item;

  @override
  Widget build(BuildContext context) {
    final color = item.active ? AppColors.accentInk : AppColors.inkFabItem;
    return Semantics(
      button: true,
      label: item.label,
      child: Pressable(
        onTap: item.onTap,
        child: Glass(
          height: 44,
          radius: AppRadius.fabItem,
          blur: 24,
          color: AppColors.glassStrong,
          gradient: item.active ? AppColors.activePill : null,
          shadow: AppShadows.fabItem,
          padding: const EdgeInsets.symmetric(horizontal: 17),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppIcon(item.icon, color: color, size: 18),
              const SizedBox(width: 10),
              Text(item.label, style: AppText.pill.copyWith(color: color)),
            ],
          ),
        ),
      ),
    );
  }
}

class _FabButton extends StatelessWidget {
  const _FabButton({
    required this.open,
    required this.ring,
    required this.onTap,
  });

  final bool open;
  final Animation<double> ring;
  final VoidCallback onTap;

  static const _size = 52.0;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: open ? 'Close menu' : 'Open menu',
    child: Pressable(
      onTap: onTap,
      scale: 0.93,
      child: OuterShadow(
        radius: AppRadius.fab,
        shadow: AppShadows.fab,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.fab),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
            child: Container(
              width: _size,
              height: _size,
              decoration: BoxDecoration(
                gradient: AppColors.fabGradient,
                borderRadius: BorderRadius.circular(AppRadius.fab),
                border: Border.all(color: AppColors.glassBorder, width: 0.5),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Conic ring, 40% larger than the button on every side.
                  AnimatedOpacity(
                    opacity: open ? 1 : 0.45,
                    duration: AppMotion.navPill,
                    child: OverflowBox(
                      maxWidth: _size * 1.8,
                      maxHeight: _size * 1.8,
                      child: RotationTransition(
                        turns: ring,
                        child: const DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: SweepGradient(
                              transform: GradientRotation(-math.pi / 2),
                              colors: [
                                Color.fromRGBO(59, 130, 246, 0),
                                Color.fromRGBO(59, 130, 246, 0.5),
                                Color.fromRGBO(45, 212, 191, 0.35),
                                Color.fromRGBO(45, 212, 191, 0),
                                Color.fromRGBO(45, 212, 191, 0),
                              ],
                              stops: [0, 70 / 360, 120 / 360, 170 / 360, 1],
                            ),
                          ),
                          child: SizedBox.square(dimension: _size * 1.8),
                        ),
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: Padding(
                      padding: const EdgeInsets.all(3),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: AppColors.glassSoft,
                          borderRadius: BorderRadius.circular(23),
                        ),
                      ),
                    ),
                  ),
                  const Positioned.fill(
                    child: Sheen(
                      period: Duration(milliseconds: 5500),
                      opacity: 0.75,
                    ),
                  ),
                  AnimatedRotation(
                    turns: open ? 135 / 360 : 0,
                    duration: AppMotion.fabRotate,
                    curve: AppMotion.ease,
                    child: const AppIcon(
                      AppIcons.plus,
                      color: AppColors.fabIcon,
                      size: 21,
                    ),
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

/// Soft wash behind the open FAB menu; a tap closes the menu. Sits under
/// the FAB, above the page.
class FabScrim extends StatelessWidget {
  const FabScrim({required this.onTap, super.key});

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
