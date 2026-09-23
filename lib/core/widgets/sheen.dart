import 'package:cinecatalog/core/theme/app_tokens.dart';
import 'package:flutter/widgets.dart';

/// A light streak that sweeps across its parent now and then.
///
/// CSS: `sheen {0% translateX(-120%)} {55%,100% translateX(240%)}`, where the
/// percentages are of the streak's own width. The parent must clip.
class Sheen extends StatefulWidget {
  const Sheen({
    required this.period,
    super.key,
    this.widthFactor = 0.36,
    this.opacity = 0.4,
  });

  final Duration period;
  final double widthFactor;
  final double opacity;

  @override
  State<Sheen> createState() => _SheenState();
}

class _SheenState extends State<Sheen> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.period,
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final white = Color.fromRGBO(255, 255, 255, widget.opacity);
    return IgnorePointer(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final streak = constraints.maxWidth * widget.widthFactor;
          return AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final v = _controller.value;
              final p = v < 0.55 ? AppMotion.loop.transform(v / 0.55) : 1.0;
              final dx = streak * (-1.2 + 3.6 * p);
              return Transform.translate(offset: Offset(dx, 0), child: child);
            },
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                width: streak,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: const Alignment(-1, -0.18),
                    end: const Alignment(1, 0.18),
                    colors: [
                      white.withValues(alpha: 0),
                      white,
                      white.withValues(alpha: 0),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
