import 'dart:async';
import 'dart:math' as math;

import 'package:cinecatalog/core/theme/app_tokens.dart';
import 'package:cinecatalog/core/widgets/app_icon.dart';
import 'package:cinecatalog/core/widgets/glass.dart';
import 'package:cinecatalog/core/widgets/glow_background.dart';
import 'package:cinecatalog/features/onboarding/presentation/providers/onboarding_provider.dart';
import 'package:cinecatalog/router/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Breathing logo and a progress bar; after 2s goes to onboarding, or
/// straight home when it was already seen.
class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage>
    with TickerProviderStateMixin {
  late final AnimationController _breathe = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..repeat(reverse: true);

  late final AnimationController _ring = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2600),
  )..repeat();

  late final AnimationController _bar = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  )..forward();

  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(AppMotion.splash, () {
      if (!mounted) return;
      final seen = ref.read(onboardingSeenProvider);
      context.go(seen ? Routes.home.path : Routes.onboarding.path);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _breathe.dispose();
    _ring.dispose();
    _bar.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Stack(
        children: [
          const Positioned.fill(child: GlowBackground.splash()),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _Logo(breathe: _breathe, ring: _ring),
                const SizedBox(height: 22),
                const Text('CineCatalog', style: AppText.brand),
                const SizedBox(height: 5),
                Text(
                  'Powered by TMDB',
                  style: AppText.body.copyWith(color: AppColors.inkMuted),
                ),
              ],
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 70 + bottom / 2,
            child: Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: Container(
                  width: 120,
                  height: 4,
                  color: AppColors.progressTrack,
                  alignment: Alignment.centerLeft,
                  child: AnimatedBuilder(
                    animation: _bar,
                    builder: (context, child) => FractionallySizedBox(
                      widthFactor: AppMotion.ease.transform(_bar.value),
                      child: child,
                    ),
                    child: const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: AppColors.progressGradient,
                      ),
                      child: SizedBox.expand(),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Logo extends StatelessWidget {
  const _Logo({required this.breathe, required this.ring});

  final Animation<double> breathe;
  final Animation<double> ring;

  static const _size = 104.0;
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
    child: OuterShadow(
      radius: _radius,
      shadow: AppShadows.logo,
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
              const _LogoMark(),
            ],
          ),
        ),
      ),
    ),
  );
}

/// Rounded screen outline with a blue play triangle.
class _LogoMark extends StatelessWidget {
  const _LogoMark();

  @override
  Widget build(BuildContext context) => const SizedBox.square(
    dimension: 42,
    child: Stack(
      children: [
        AppIcon(
          AppIconData(
            '<rect x="3" y="5" width="18" height="14" rx="3.5"/>',
            strokeWidth: 1.6,
          ),
          color: AppColors.accentInk,
          size: 42,
        ),
        AppIcon(
          AppIconData('<path d="M10 9.5v5l4.5-2.5z"/>', filled: true),
          color: AppColors.accent,
          size: 42,
        ),
      ],
    ),
  );
}
