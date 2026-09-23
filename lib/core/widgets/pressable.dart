import 'package:cinecatalog/core/theme/app_tokens.dart';
import 'package:flutter/widgets.dart';

/// Scales its child down while pressed, the design's `:active` feedback.
/// There is no ink ripple anywhere in the app.
class Pressable extends StatefulWidget {
  const Pressable({
    required this.child,
    required this.onTap,
    super.key,
    this.scale = 0.95,
  });

  final Widget child;
  final VoidCallback? onTap;
  final double scale;

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> {
  bool _down = false;

  void _set(bool down) {
    if (_down != down) setState(() => _down = down);
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onTap != null;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: enabled ? (_) => _set(true) : null,
      onTapUp: enabled ? (_) => _set(false) : null,
      onTapCancel: enabled ? () => _set(false) : null,
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _down ? widget.scale : 1,
        duration: const Duration(milliseconds: 140),
        curve: AppMotion.ease,
        child: widget.child,
      ),
    );
  }
}
