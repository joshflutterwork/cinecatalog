// Renders the branding images in assets/branding from the real widgets, so
// the app icon, the native launch screen and the Flutter splash all match.
// Skipped in normal test runs; regenerate with:
//
//   RENDER_ASSETS=1 fvm flutter test test/tool/render_splash_assets_test.dart
//   fvm dart run flutter_launcher_icons
//   fvm dart run flutter_native_splash:create
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:cinecatalog/core/theme/app_tokens.dart';
import 'package:cinecatalog/features/onboarding/presentation/widgets/splash_logo.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _render(
  WidgetTester tester, {
  required double canvas,
  required double scale,
  required Widget child,
  required String file,
}) async {
  tester.view.devicePixelRatio = scale;
  tester.view.physicalSize = Size.square(canvas * scale);
  await tester.pumpWidget(
    Directionality(
      textDirection: TextDirection.ltr,
      child: RepaintBoundary(
        key: const ValueKey('asset'),
        child: SizedBox.square(dimension: canvas, child: child),
      ),
    ),
  );
  await tester.runAsync(() async {
    final image = await tester
        .renderObject<RenderRepaintBoundary>(
          find.byKey(const ValueKey('asset')),
        )
        .toImage(pixelRatio: scale);
    final png = await image.toByteData(format: ui.ImageByteFormat.png);
    File('assets/branding/$file').writeAsBytesSync(png!.buffer.asUint8List());
  });
}

/// The splash logo frozen on the Flutter splash's first frame.
Widget _splashLogo({required double shadow}) => Center(
  child: SplashLogo(
    breathe: const AlwaysStoppedAnimation(0),
    ring: const AlwaysStoppedAnimation(0),
    shadowStrength: AlwaysStoppedAnimation(shadow),
  ),
);

/// Icon background: opaque white, the logo gradient and a soft ring.
/// [visible] is the side of the part the launcher actually shows.
Widget _iconBackground(double visible) => ClipRect(
  child: Stack(
    alignment: Alignment.center,
    children: [
      const Positioned.fill(child: ColoredBox(color: Color(0xFFFFFFFF))),
      const Positioned.fill(
        child: DecoratedBox(
          decoration: BoxDecoration(gradient: AppColors.logoGradient),
        ),
      ),
      OverflowBox(
        maxWidth: visible * 1.6,
        maxHeight: visible * 1.6,
        child: Opacity(
          opacity: 0.55,
          child: DecoratedBox(
            decoration: const BoxDecoration(
              gradient: SweepGradient(
                transform: GradientRotation(-math.pi / 2 + 0.6),
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
            child: SizedBox.square(dimension: visible * 1.6),
          ),
        ),
      ),
    ],
  ),
);

/// Icon foreground: a soft white disc with the mark.
Widget _iconForeground(double visible) => Center(
  child: Stack(
    alignment: Alignment.center,
    children: [
      Container(
        width: visible * 0.66,
        height: visible * 0.66,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Color.fromRGBO(255, 255, 255, 0.75),
        ),
      ),
      LogoMark(size: visible * 0.5),
    ],
  ),
);

void main() {
  testWidgets('render branding images', (tester) async {
    // iOS / legacy app icon: one opaque square; the OS rounds it.
    await _render(
      tester,
      canvas: 1024,
      scale: 1,
      file: 'app_icon.png',
      child: Stack(
        children: [
          Positioned.fill(child: _iconBackground(1024)),
          Positioned.fill(child: _iconForeground(1024)),
        ],
      ),
    );
    // Android adaptive icon: 108dp layers of which the launcher shows the
    // middle 72dp (2/3), masked to its own shape.
    const adaptiveVisible = 1024 * 2 / 3;
    await _render(
      tester,
      canvas: 1024,
      scale: 1,
      file: 'app_icon_background.png',
      child: _iconBackground(adaptiveVisible),
    );
    await _render(
      tester,
      canvas: 1024,
      scale: 1,
      file: 'app_icon_foreground.png',
      child: _iconForeground(adaptiveVisible),
    );
    // Launch screen (4x, as flutter_native_splash expects). No shadow on
    // any platform: Android 12+ would cut it at its circle, and the
    // Flutter splash fades the shadow in anyway, so every platform starts
    // from the same plain tile.
    // iOS and Android < 12.
    await _render(
      tester,
      canvas: 288,
      scale: 4,
      file: 'splash_logo.png',
      child: _splashLogo(shadow: 0),
    );
    // Android 12+: 288dp canvas whose centre circle the system keeps.
    await _render(
      tester,
      canvas: 288,
      scale: 4,
      file: 'splash_logo_android12.png',
      child: _splashLogo(shadow: 0),
    );
  }, skip: !Platform.environment.containsKey('RENDER_ASSETS'));
}
