import 'dart:math' as math;

import 'package:cinecatalog/core/theme/app_tokens.dart';
import 'package:cinecatalog/core/widgets/app_icon.dart';
import 'package:cinecatalog/core/widgets/glass.dart';
import 'package:cinecatalog/core/widgets/glow_background.dart';
import 'package:cinecatalog/core/widgets/gradient_button.dart';
import 'package:cinecatalog/core/widgets/pressable.dart';
import 'package:cinecatalog/features/onboarding/presentation/providers/onboarding_provider.dart';
import 'package:cinecatalog/router/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

typedef _Step = ({String title, String body, String chip, AppIconData icon});

const List<_Step> _steps = [
  (
    title: 'All movies & shows in one place',
    body:
        'Browse the TMDB catalog: top rated, upcoming, now playing and what is '
        'airing today.',
    chip: 'Movies & TV Shows',
    icon: AppIcons.movies,
  ),
  (
    title: 'Swipe to choose',
    body:
        'Stacked cards make browsing faster. Swipe sideways for the next '
        'title, tap for details.',
    chip: 'Swipe · Tap · Detail',
    icon: AppIcons.swipe,
  ),
  (
    title: 'Meet the people behind the screen',
    body:
        'Find popular actors and directors, then see the work they are '
        'known for.',
    chip: 'Popular People',
    icon: AppIcons.people,
  ),
];

class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  int _step = 0;

  bool get _isLast => _step == _steps.length - 1;

  Future<void> _finish() async {
    await ref.read(onboardingSeenProvider.notifier).markSeen();
    if (mounted) context.go(Routes.home.path);
  }

  void _next() => _isLast ? _finish() : setState(() => _step++);

  @override
  Widget build(BuildContext context) {
    final step = _steps[_step];
    final padding = MediaQuery.paddingOf(context);
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Stack(
        children: [
          const Positioned.fill(child: GlowBackground.splash()),
          Padding(
            padding: EdgeInsets.fromLTRB(
              22,
              padding.top + 8,
              22,
              math.max(40, padding.bottom + 16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: Pressable(
                    onTap: _finish,
                    child: Glass(
                      height: 36,
                      blur: 0,
                      color: const Color.fromRGBO(255, 255, 255, 0.75),
                      borderColor: AppColors.glassBorderStrong,
                      shadow: AppShadows.soft,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Center(
                        widthFactor: 1,
                        child: Text(
                          'Skip',
                          style: AppText.pill.copyWith(fontSize: 13),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: _Fan(step: _step, current: step),
                ),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Column(
                    key: ValueKey(_step),
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(step.title, style: AppText.onboardTitle),
                      const SizedBox(height: 10),
                      Text(
                        step.body,
                        style: AppText.body.copyWith(
                          fontSize: 14,
                          height: 1.6,
                          color: AppColors.inkBody,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 26),
                Row(
                  children: [
                    for (var i = 0; i < _steps.length; i++) ...[
                      if (i > 0) const SizedBox(width: 6),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 350),
                        curve: AppMotion.ease,
                        width: i == _step ? 24 : 7,
                        height: 7,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color: i == _step ? null : AppColors.dotInactive,
                          gradient: i == _step
                              ? AppColors.progressGradient
                              : null,
                        ),
                      ),
                    ],
                    const Spacer(),
                    GradientButton(
                      label: _isLast ? 'Get started' : 'Next',
                      onTap: _next,
                      trailing: AppIcons.arrowRight,
                      sheenPeriod: const Duration(milliseconds: 4500),
                      textStyle: AppText.button.copyWith(
                        color: const Color(0xFFFFFFFF),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Three cards fanned out; the active one sits in front, slightly raised.
class _Fan extends StatelessWidget {
  const _Fan({required this.step, required this.current});

  final int step;
  final _Step current;

  /// Front, right, left.
  static const _poses = [
    _FanPose(0, -10, 0, 1),
    _FanPose(58, -4, 9, 0.86),
    _FanPose(-58, -4, -9, 0.86),
  ];

  /// Bundled posters, so onboarding looks right before any network call.
  static const _posters = [
    'assets/images/godfather_movie.png',
    'assets/images/fightclub.png',
    'assets/images/kagemusha1990.png',
  ];

  @override
  Widget build(BuildContext context) {
    final cards = [
      for (var k = 0; k < 3; k++) (k: k, rel: ((k - step) % 3 + 3) % 3),
    ]..sort((a, b) => b.rel.compareTo(a.rel));

    return Stack(
      alignment: Alignment.center,
      children: [
        for (final c in cards)
          TweenAnimationBuilder<_FanPose>(
            key: ValueKey(c.k),
            tween: _FanPoseTween(end: _poses[c.rel]),
            duration: const Duration(milliseconds: 600),
            curve: AppMotion.ease,
            builder: (context, pose, child) {
              return Transform.translate(
                offset: Offset(pose.dx, pose.dy),
                child: Transform.rotate(
                  angle: pose.deg * math.pi / 180,
                  child: Transform.scale(scale: pose.scale, child: child),
                ),
              );
            },
            child: OuterShadow(
              radius: 30,
              shadow: AppShadows.onboardCard,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: SizedBox(
                  width: 236,
                  height: 340,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.asset(
                        _posters[c.k],
                        fit: BoxFit.cover,
                        // Decode at card size, not the full poster.
                        cacheWidth: 472,
                      ),
                      const DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: RadialGradient(
                            center: Alignment(-0.4, -0.76),
                            radius: 0.9,
                            colors: [
                              Color.fromRGBO(255, 255, 255, 0.35),
                              Color.fromRGBO(255, 255, 255, 0),
                            ],
                            stops: [0, 0.6],
                          ),
                        ),
                      ),
                      DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            color: AppColors.glassBorder,
                            width: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        Positioned(
          bottom: 26,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Glass(
              key: ValueKey(current.chip),
              height: 48,
              radius: 24,
              blur: 24,
              borderColor: AppColors.glassBorderStrong,
              shadow: AppShadows.onboardChip,
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppIcon(current.icon, color: AppColors.accent, size: 18),
                  const SizedBox(width: 10),
                  Text(
                    current.chip,
                    style: AppText.pill.copyWith(
                      fontSize: 13,
                      color: AppColors.inkBadge,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

@immutable
class _FanPose {
  const _FanPose(this.dx, this.dy, this.deg, this.scale);

  final double dx;
  final double dy;
  final double deg;
  final double scale;
}

class _FanPoseTween extends Tween<_FanPose> {
  _FanPoseTween({super.end});

  @override
  _FanPose lerp(double t) {
    double mix(double a, double b) => a + (b - a) * t;
    final a = begin!;
    final b = end!;
    return _FanPose(
      mix(a.dx, b.dx),
      mix(a.dy, b.dy),
      mix(a.deg, b.deg),
      mix(a.scale, b.scale),
    );
  }
}
