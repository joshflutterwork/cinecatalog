import 'dart:math' as math;

import 'package:cinecatalog/core/theme/app_tokens.dart';
import 'package:flutter/widgets.dart';

/// 24px ring with a blue top arc, spinning every 0.75s.
class Spinner extends StatefulWidget {
  const Spinner({super.key, this.size = 24});

  final double size;

  @override
  State<Spinner> createState() => _SpinnerState();
}

class _SpinnerState extends State<Spinner> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 750),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Semantics(
    label: 'Loading',
    child: RotationTransition(
      turns: _controller,
      child: CustomPaint(
        size: Size.square(widget.size),
        painter: const _RingPainter(),
      ),
    ),
  );
}

class _RingPainter extends CustomPainter {
  const _RingPainter();

  static const _stroke = 2.5;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = (Offset.zero & size).deflate(_stroke / 2);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = _stroke;
    canvas
      ..drawOval(rect, paint..color = AppColors.spinnerTrack)
      ..drawArc(
        rect,
        -math.pi * 3 / 4,
        math.pi / 2,
        false,
        paint..color = AppColors.accent,
      );
  }

  @override
  bool shouldRepaint(_RingPainter oldDelegate) => false;
}
