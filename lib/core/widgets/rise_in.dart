import 'dart:async';

import 'package:cinecatalog/core/theme/app_tokens.dart';
import 'package:flutter/widgets.dart';

/// Fades in while rising 24px, once, when first built (CSS `riseIn`).
class RiseIn extends StatefulWidget {
  const RiseIn({
    required this.child,
    super.key,
    this.duration = AppMotion.rowIn,
    this.delay = Duration.zero,
    this.distance = 24,
    this.enabled = true,
  });

  final Widget child;
  final Duration duration;
  final Duration delay;
  final double distance;

  /// False renders the child as-is, e.g. for rows already seen once.
  final bool enabled;

  @override
  State<RiseIn> createState() => _RiseInState();
}

class _RiseInState extends State<RiseIn> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.duration,
    value: widget.enabled ? 0 : 1,
  );
  late final Animation<double> _curve = CurvedAnimation(
    parent: _controller,
    curve: AppMotion.ease,
  );

  Timer? _delay;

  @override
  void initState() {
    super.initState();
    if (!widget.enabled) return;
    if (widget.delay == Duration.zero) {
      _controller.forward();
    } else {
      _delay = Timer(widget.delay, _controller.forward);
    }
  }

  @override
  void dispose() {
    _delay?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _curve,
    builder: (context, child) => Opacity(
      opacity: _curve.value,
      child: Transform.translate(
        offset: Offset(0, widget.distance * (1 - _curve.value)),
        child: child,
      ),
    ),
    child: widget.child,
  );
}
