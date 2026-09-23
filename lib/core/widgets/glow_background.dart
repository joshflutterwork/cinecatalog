import 'dart:math' as math;
import 'dart:ui';

import 'package:cinecatalog/core/theme/app_tokens.dart';
import 'package:flutter/widgets.dart';

/// One blurred colour blob that drifts back and forth.
final class GlowBlob {
  const GlowBlob({
    required this.color,
    required this.rect,
    required this.fadeStop,
    required this.cycle,
    required this.from,
    required this.to,
  });

  final Color color;

  /// Position and size as fractions of the glow area (left, top, w, h).
  final Rect rect;

  /// Where the radial gradient reaches transparent (CSS `transparent 68%`).
  final double fadeStop;

  /// A full there-and-back loop.
  final Duration cycle;

  /// Translate (fractions of the blob's own size) and scale at each end.
  final (Offset, double) from;
  final (Offset, double) to;
}

/// The slow animated colour glow behind the content.
class GlowBackground extends StatefulWidget {
  const GlowBackground.home({super.key})
    : blobs = _home,
      inset = 0.15,
      blur = 58,
      opacity = 0.62;

  const GlowBackground.splash({super.key})
    : blobs = _splash,
      inset = 0,
      blur = 40,
      opacity = 1;

  final List<GlowBlob> blobs;

  /// The glow area overflows the screen by this fraction on every side.
  final double inset;
  final double blur;
  final double opacity;

  static const _home = [
    GlowBlob(
      color: AppColors.glowBlue,
      rect: Rect.fromLTWH(-0.08, 0, 0.64, 0.4),
      fadeStop: 0.68,
      cycle: Duration(seconds: 18),
      from: (Offset(-0.06, -0.04), 1),
      to: (Offset(0.14, 0.10), 1.22),
    ),
    GlowBlob(
      color: AppColors.glowTeal,
      rect: Rect.fromLTWH(0.5, 0.6, 0.6, 0.38),
      fadeStop: 0.7,
      cycle: Duration(seconds: 24),
      from: (Offset(0.10, 0.06), 1.12),
      to: (Offset(-0.12, -0.10), 0.92),
    ),
  ];

  static const _splash = [
    GlowBlob(
      color: Color.fromRGBO(147, 197, 253, 0.6),
      rect: Rect.fromLTWH(-0.3, -0.1, 1.2, 0.6),
      fadeStop: 0.66,
      cycle: Duration(seconds: 14),
      from: (Offset(-0.06, -0.04), 1),
      to: (Offset(0.14, 0.10), 1.22),
    ),
    GlowBlob(
      color: Color.fromRGBO(45, 212, 191, 0.38),
      rect: Rect.fromLTWH(0.3, 0.55, 1, 0.5),
      fadeStop: 0.68,
      cycle: Duration(seconds: 18),
      from: (Offset(0.10, 0.06), 1.12),
      to: (Offset(-0.12, -0.10), 0.92),
    ),
  ];

  @override
  State<GlowBackground> createState() => _GlowBackgroundState();
}

class _GlowBackgroundState extends State<GlowBackground>
    with TickerProviderStateMixin {
  late final List<AnimationController> _controllers = [
    for (final blob in widget.blobs)
      AnimationController(vsync: this, duration: blob.cycle ~/ 2)
        ..repeat(reverse: true),
  ];

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: RepaintBoundary(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final screen = constraints.biggest;
            final area = Size(
              screen.width * (1 + widget.inset * 2),
              screen.height * (1 + widget.inset * 2),
            );
            return OverflowBox(
              maxWidth: area.width,
              maxHeight: area.height,
              child: Opacity(
                opacity: widget.opacity,
                child: ImageFiltered(
                  imageFilter: ImageFilter.blur(
                    sigmaX: widget.blur,
                    sigmaY: widget.blur,
                    tileMode: TileMode.decal,
                  ),
                  child: SizedBox.fromSize(
                    size: area,
                    child: Stack(
                      children: [
                        for (final (i, blob) in widget.blobs.indexed)
                          _Blob(
                            blob: blob,
                            area: area,
                            animation: CurvedAnimation(
                              parent: _controllers[i],
                              curve: AppMotion.loop,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _Blob extends StatelessWidget {
  const _Blob({
    required this.blob,
    required this.area,
    required this.animation,
  });

  final GlowBlob blob;
  final Size area;
  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    final w = blob.rect.width * area.width;
    final h = blob.rect.height * area.height;
    // CSS `radial-gradient(circle, …)` sizes to the farthest corner.
    final radius = math.sqrt(w * w + h * h) / 2 / math.min(w, h);
    return Positioned(
      left: blob.rect.left * area.width,
      top: blob.rect.top * area.height,
      width: w,
      height: h,
      child: AnimatedBuilder(
        animation: animation,
        builder: (context, child) {
          final t = animation.value;
          final offset = Offset.lerp(blob.from.$1, blob.to.$1, t)!;
          final scale = lerpDouble(blob.from.$2, blob.to.$2, t)!;
          return Transform.translate(
            offset: Offset(offset.dx * w, offset.dy * h),
            child: Transform.scale(scale: scale, child: child),
          );
        },
        child: DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              radius: radius,
              colors: [blob.color, blob.color.withValues(alpha: 0)],
              stops: [0, blob.fadeStop],
            ),
          ),
        ),
      ),
    );
  }
}

/// A static soft blob, used behind the list and search headers.
class StaticGlow extends StatelessWidget {
  const StaticGlow({
    required this.color,
    required this.size,
    this.fadeStop = 0.68,
    super.key,
  });

  final Color color;
  final Size size;
  final double fadeStop;

  @override
  Widget build(BuildContext context) => IgnorePointer(
    child: ImageFiltered(
      imageFilter: ImageFilter.blur(
        sigmaX: 30,
        sigmaY: 30,
        tileMode: TileMode.decal,
      ),
      child: Container(
        width: size.width,
        height: size.height,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            radius: 0.71,
            colors: [color, color.withValues(alpha: 0)],
            stops: [0, fadeStop],
          ),
        ),
      ),
    ),
  );
}
