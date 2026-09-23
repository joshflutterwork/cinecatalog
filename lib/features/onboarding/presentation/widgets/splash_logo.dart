import 'dart:math' as math;

import 'package:cinecatalog/core/theme/app_tokens.dart';
import 'package:cinecatalog/core/widgets/app_icon.dart';
import 'package:cinecatalog/core/widgets/glass.dart';
import 'package:flutter/material.dart';

/// The splash logo: a glass tile with a spinning ring and the screen-and-play
/// mark, breathing in and out.
///
/// The native launch screen shows this exact tile as a still image (see
/// `test/tool/render_splash_assets_test.dart`), so when Flutter takes over
/// nothing jumps: the tile sits at the same size and place and simply starts
/// to move.
class SplashLogo extends StatelessWidget {
  const SplashLogo({
    required this.breathe,
    required this.ring,
    super.key,
    this.shadowStrength = const AlwaysStoppedAnimation(1),
  });

  final Animation<double> breathe;
  final Animation<double> ring;

  /// 0 hides the drop shadow, 1 shows it fully. The Android 12+ launch icon
  /// cannot carry the shadow (the system masks it to a circle), so the
  /// splash fades it in.
  final Animation<double> shadowStrength;

  static const size = 104.0;
  static const double _size = size;
  static const _radius = 34.0;

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: breathe,
    builder: (context, child) {
      final t = AppMotion.loop.transform(breathe.value);
      return Opacity(
        opacity: 0.85 + 0.15 * t,
        child: Transform.scale(scale: 1 + 0.08 * t, child: child),
      );
    },
    child: AnimatedBuilder(
      animation: shadowStrength,
      builder: (context, child) => OuterShadow(
        radius: _radius,
        shadow: BoxShadow.lerpList(
          null,
          AppShadows.logo,
          shadowStrength.value,
        )!,
        child: child!,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(_radius),
        child: Container(
          width: _size,
          height: _size,
          decoration: BoxDecoration(
            gradient: AppColors.logoGradient,
            borderRadius: BorderRadius.circular(_radius),
            border: Border.all(color: AppColors.glassBorderStrong, width: 0.5),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              OverflowBox(
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
                          Color.fromRGBO(59, 130, 246, 0.55),
                          Color.fromRGBO(45, 212, 191, 0.4),
                          Color.fromRGBO(45, 212, 191, 0),
                          Color.fromRGBO(45, 212, 191, 0),
                        ],
                        stops: [0, 80 / 360, 140 / 360, 200 / 360, 1],
                      ),
                    ),
                    child: SizedBox.square(dimension: _size * 1.8),
                  ),
                ),
              ),
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: const Color.fromRGBO(255, 255, 255, 0.8),
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
              ),
              const LogoMark(),
            ],
          ),
        ),
      ),
    ),
  );
}

/// Rounded screen outline with a blue play triangle: the brand mark, also
/// used for the app icon.
class LogoMark extends StatelessWidget {
  const LogoMark({super.key, this.size = 42});

  final double size;

  @override
  Widget build(BuildContext context) => SizedBox.square(
    dimension: size,
    child: Stack(
      children: [
        AppIcon(
          const AppIconData(
            '<rect x="3" y="5" width="18" height="14" rx="3.5"/>',
            strokeWidth: 1.6,
          ),
          color: AppColors.accentInk,
          size: size,
        ),
        AppIcon(
          const AppIconData('<path d="M10 9.5v5l4.5-2.5z"/>', filled: true),
          color: AppColors.accent,
          size: size,
        ),
      ],
    ),
  );
}
