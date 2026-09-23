import 'package:cinecatalog/core/theme/app_tokens.dart';
import 'package:cinecatalog/core/widgets/app_icon.dart';
import 'package:cinecatalog/core/widgets/glass.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/widgets.dart';

/// A row that slides left to reveal an action card stacked behind it: the
/// same soft white glass as the row, with the action in [actionColor].
///
/// Dragging past half the action's width (or flinging left) holds the row
/// open; the action only runs when its button is tapped, and the row then
/// closes. Tapping the open row, dragging it back or opening another row
/// sharing [openRow] also closes it.
class SwipeToReveal extends StatefulWidget {
  const SwipeToReveal({
    required this.id,
    required this.openRow,
    required this.actionLabel,
    required this.actionIcon,
    required this.onAction,
    required this.child,
    super.key,
    this.actionColor = AppColors.errorInk,
    this.radius = AppRadius.listRow,
  });

  /// Identifies this row in [openRow].
  final Object id;

  /// The row currently held open, shared by a list so only one is open.
  final ValueNotifier<Object?> openRow;

  final String actionLabel;
  final AppIconData actionIcon;
  final Color actionColor;
  final VoidCallback onAction;
  final Widget child;

  /// Corner radius of the card behind, matching [child].
  final double radius;

  @override
  State<SwipeToReveal> createState() => _SwipeToRevealState();
}

class _SwipeToRevealState extends State<SwipeToReveal>
    with SingleTickerProviderStateMixin {
  static const _actionWidth = 104.0;

  /// 0 closed, 1 fully open.
  late final _controller = AnimationController(
    vsync: this,
    duration: AppMotion.navPill,
  );

  bool get _isOpen => _controller.value > 0;

  @override
  void initState() {
    super.initState();
    widget.openRow.addListener(_onOtherRowOpened);
  }

  @override
  void didUpdateWidget(SwipeToReveal old) {
    super.didUpdateWidget(old);
    if (old.openRow != widget.openRow) {
      old.openRow.removeListener(_onOtherRowOpened);
      widget.openRow.addListener(_onOtherRowOpened);
    }
  }

  @override
  void dispose() {
    widget.openRow.removeListener(_onOtherRowOpened);
    if (widget.openRow.value == widget.id) widget.openRow.value = null;
    _controller.dispose();
    super.dispose();
  }

  void _onOtherRowOpened() {
    if (widget.openRow.value != widget.id && _isOpen) _settle(open: false);
  }

  void _settle({required bool open}) {
    _controller.animateTo(open ? 1 : 0, curve: AppMotion.ease);
    if (open) {
      widget.openRow.value = widget.id;
    } else if (widget.openRow.value == widget.id) {
      widget.openRow.value = null;
    }
  }

  void _onDragUpdate(DragUpdateDetails details) {
    _controller.value -= details.delta.dx / _actionWidth;
  }

  void _onDragEnd(DragEndDetails details) {
    final velocity = details.primaryVelocity ?? 0;
    if (velocity.abs() > 300) {
      _settle(open: velocity < 0);
    } else {
      _settle(open: _controller.value > 0.5);
    }
  }

  @override
  Widget build(BuildContext context) => Semantics(
    // Screen readers get the action without swiping.
    customSemanticsActions: {
      CustomSemanticsAction(label: widget.actionLabel): widget.onAction,
    },
    child: GestureDetector(
      onHorizontalDragUpdate: _onDragUpdate,
      onHorizontalDragEnd: _onDragEnd,
      child: Stack(
        children: [
          // The action card, stacked behind the row, full size so no gap
          // opens next to the row's rounded corner. The row is translucent
          // glass, so: the card's background only fades in once a swipe
          // starts (no doubled glass or shadow on closed rows), and its
          // label is clipped to the strip the row has uncovered (it never
          // shows through the row).
          Positioned.fill(
            child: ListenableBuilder(
              listenable: _controller,
              // Closed, the card is neither tappable nor announced; screen
              // readers use the row's custom action instead.
              builder: (context, _) {
                final t = _controller.value.clamp(0.0, 1.0);
                return IgnorePointer(
                  ignoring: !_isOpen,
                  child: ExcludeSemantics(
                    excluding: !_isOpen,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Opacity(
                          opacity: (t * 4).clamp(0.0, 1.0),
                          child: _ActionBackground(radius: widget.radius),
                        ),
                        ClipRect(
                          clipper: _RevealedClipper(_actionWidth * t),
                          child: _ActionButton(
                            label: widget.actionLabel,
                            icon: widget.actionIcon,
                            color: widget.actionColor,
                            width: _actionWidth,
                            onTap: () {
                              _settle(open: false);
                              widget.onAction();
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) => Transform.translate(
              offset: Offset(-_actionWidth * _controller.value, 0),
              child: child,
            ),
            child: Stack(
              children: [
                widget.child,
                // While open, a tap on the row closes it instead of opening
                // the title.
                ListenableBuilder(
                  listenable: _controller,
                  builder: (context, _) => _isOpen
                      ? Positioned.fill(
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () => _settle(open: false),
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

/// The right-hand strip of [revealed] px: what the row has uncovered.
class _RevealedClipper extends CustomClipper<Rect> {
  const _RevealedClipper(this.revealed);

  final double revealed;

  @override
  Rect getClip(Size size) => revealed <= 0
      ? Rect.zero
      : Rect.fromLTRB(size.width - revealed, 0, size.width, size.height);

  @override
  bool shouldReclip(_RevealedClipper old) => old.revealed != revealed;
}

/// Soft white glass matching the row, behind the whole row.
class _ActionBackground extends StatelessWidget {
  const _ActionBackground({required this.radius});

  final double radius;

  @override
  Widget build(BuildContext context) => Glass(
    radius: radius,
    blur: 0,
    color: AppColors.glassCard,
    borderColor: AppColors.glassBorderStrong,
    shadow: AppShadows.listRow,
    child: const SizedBox.expand(),
  );
}

/// Icon and label in [color], on the right edge of the card.
class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.width,
    required this.onTap,
  });

  final String label;
  final AppIconData icon;
  final Color color;
  final double width;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.centerRight,
    child: Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: SizedBox(
          width: width,
          height: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AppIcon(icon, color: color),
              const SizedBox(height: 6),
              Text(label, style: AppText.pill.copyWith(color: color)),
            ],
          ),
        ),
      ),
    ),
  );
}
