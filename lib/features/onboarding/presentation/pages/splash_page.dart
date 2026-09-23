import 'dart:async';

import 'package:cinecatalog/core/theme/app_tokens.dart';
import 'package:cinecatalog/core/widgets/glow_background.dart';
import 'package:cinecatalog/features/onboarding/presentation/providers/onboarding_provider.dart';
import 'package:cinecatalog/features/onboarding/presentation/widgets/splash_logo.dart';
import 'package:cinecatalog/router/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Breathing logo and a progress bar; after 2s goes to onboarding, or
/// straight home when it was already seen.
///
/// The native launch screen shows the same logo tile, still, at the same
/// place (screen centre). So the first Flutter frame matches it exactly:
/// the logo is already there and starts to move, while the glow, the
/// logo's shadow, the name and the progress bar fade in around it.
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

  /// Fades in everything the native launch screen does not show.
  late final AnimationController _intro = AnimationController(
    vsync: this,
    duration: AppMotion.scrim,
  )..forward();

  late final Animation<double> _introCurve = CurvedAnimation(
    parent: _intro,
    curve: AppMotion.fade,
  );

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
    _intro.dispose();
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
          Positioned.fill(
            child: FadeTransition(
              opacity: _introCurve,
              child: const GlowBackground.splash(),
            ),
          ),
          // Exactly at the screen centre, like the native launch image.
          Center(
            child: SplashLogo(
              breathe: _breathe,
              ring: _ring,
              shadowStrength: _introCurve,
            ),
          ),
          // Name and tagline just under the logo.
          Positioned.fill(
            child: LayoutBuilder(
              builder: (context, constraints) => Padding(
                padding: EdgeInsets.only(
                  top: constraints.maxHeight / 2 + SplashLogo.size / 2 + 22,
                ),
                child: Align(
                  alignment: Alignment.topCenter,
                  child: FadeTransition(
                    opacity: _introCurve,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('CineCatalog', style: AppText.brand),
                        const SizedBox(height: 5),
                        Text(
                          'Powered by TMDB',
                          style: AppText.body.copyWith(
                            color: AppColors.inkMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 70 + bottom / 2,
            child: FadeTransition(
              opacity: _introCurve,
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
          ),
        ],
      ),
    );
  }
}
