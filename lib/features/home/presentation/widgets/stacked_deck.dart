import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' show lerpDouble;

import 'package:cinecatalog/core/common/media.dart';
import 'package:cinecatalog/core/config/tmdb_image.dart';
import 'package:cinecatalog/core/theme/app_tokens.dart';
import 'package:cinecatalog/core/widgets/glass.dart';
import 'package:cinecatalog/core/widgets/poster_image.dart';
import 'package:cinecatalog/core/widgets/rating_badge.dart';
import 'package:flutter/widgets.dart';

/// Dating-app style card stack.
///
/// Drag the front card sideways: past [AppMotion.deckSwipeThreshold] it flies
/// out, left for the next title and right for the previous one. A tap opens
/// the front card. Three cards are visible; the ones behind sit higher and
/// smaller, anchored at their top centre.
class StackedDeck extends StatefulWidget {
  const StackedDeck({
    required this.items,
    required this.onTap,
    super.key,
    this.height = 490,
  });

  final List<Media> items;
  final ValueChanged<Media> onTap;
  final double height;

  @override
  State<StackedDeck> createState() => _StackedDeckState();
}

class _StackedDeckState extends State<StackedDeck> {
  static const _visible = 3;

  int _index = 0;
  double _dx = 0;
  bool _dragging = false;
  bool _flying = false;
  Timer? _flyTimer;

  /// Card that enters from the right after a "previous" swipe.
  int? _enteringKey;

  int get _count => widget.items.length;

  int _wrap(int i) => ((i % _count) + _count) % _count;

  /// How far a card travels off screen: 1.5 deck widths.
  static double _flyDistance(double width) => width * 1.5;

  @override
  void dispose() {
    _flyTimer?.cancel();
    super.dispose();
  }

  void _onDragStart(DragStartDetails _) {
    if (_flying) return;
    setState(() {
      _dragging = true;
      _enteringKey = null;
    });
  }

  void _onDragUpdate(DragUpdateDetails details) {
    if (!_dragging) return;
    setState(() => _dx += details.delta.dx);
  }

  void _onDragEnd(DragEndDetails details) {
    if (!_dragging) return;
    final dx = _dx;
    if (dx.abs() <= AppMotion.deckSwipeThreshold || _count < 2) {
      setState(() {
        _dragging = false;
        _dx = 0;
      });
      return;
    }

    if (dx < 0) {
      // Next: the front card flies off to the left, then drops to the back.
      setState(() {
        _dragging = false;
        _flying = true;
        // A gesture callback, so the deck's size is known here.
        _dx = -_flyDistance(context.size?.width ?? 400);
      });
      _flyTimer = Timer(AppMotion.deck, () {
        if (!mounted) return;
        setState(() {
          _index = _wrap(_index + 1);
          _dx = 0;
          _flying = false;
        });
      });
    } else {
      // Previous: the card before slides in from the right over the stack,
      // while the current one settles into second place.
      setState(() {
        _dragging = false;
        _index = _wrap(_index - 1);
        _enteringKey = _index;
        _dx = 0;
      });
    }
  }

  void _onTap() {
    if (_flying || _count == 0) return;
    widget.onTap(widget.items[_wrap(_index)]);
  }

  @override
  Widget build(BuildContext context) {
    if (_count == 0) return SizedBox(height: widget.height);
    final visible = math.min(_visible, _count);
    final front = widget.items[_wrap(_index)];

    return Semantics(
      button: true,
      label: '${front.title}. Swipe for another title, tap for details.',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _onTap,
        onHorizontalDragStart: _onDragStart,
        onHorizontalDragUpdate: _onDragUpdate,
        onHorizontalDragEnd: _onDragEnd,
        onHorizontalDragCancel: () => _onDragEnd(DragEndDetails()),
        child: SizedBox(
          height: widget.height,
          // The entering card starts off screen, so build needs the width;
          // `context.size` is not allowed during build.
          child: LayoutBuilder(
            builder: (context, constraints) => Stack(
              clipBehavior: Clip.none,
              children: [
                for (var depth = visible - 1; depth >= 0; depth--)
                  _buildCard(depth, constraints.maxWidth),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCard(int depth, double width) {
    final key = _wrap(_index + depth);
    final isFront = depth == 0;
    final target = _Pose(depth.toDouble(), isFront ? _dx : 0);
    final entering = key == _enteringKey;

    return TweenAnimationBuilder<_Pose>(
      key: ValueKey(key),
      tween: _PoseTween(
        begin: entering ? _Pose(0, _flyDistance(width)) : null,
        end: target,
      ),
      duration: isFront && _dragging ? Duration.zero : AppMotion.deck,
      curve: AppMotion.ease,
      builder: (context, pose, child) => Positioned.fill(
        child: Opacity(
          opacity: pose.opacity,
          child: Transform(
            alignment: Alignment.topCenter,
            transform: pose.matrix,
            child: child,
          ),
        ),
      ),
      child: _DeckCard(media: widget.items[key]),
    );
  }
}

/// Where a card sits: its depth in the stack (0 = front, fractional while
/// animating) and its horizontal drag offset.
@immutable
class _Pose {
  const _Pose(this.depth, this.dx);

  final double depth;
  final double dx;

  static const _translateY = [0.0, -30.0, -56.0];
  static const _scale = [1.0, 0.93, 0.86];
  static const _opacity = [1.0, 0.9, 0.7];

  static double _at(List<double> stops, double depth) {
    final d = depth.clamp(0.0, stops.length - 1.0);
    final i = d.floor().clamp(0, stops.length - 2);
    return lerpDouble(stops[i], stops[i + 1], d - i)!;
  }

  double get opacity => _at(_opacity, depth).clamp(0.0, 1.0);

  Matrix4 get matrix {
    final scale = _at(_scale, depth);
    return Matrix4.identity()
      ..translateByDouble(dx, _at(_translateY, depth), 0, 1)
      ..rotateZ(dx / 26 * math.pi / 180)
      ..scaleByDouble(scale, scale, 1, 1);
  }
}

class _PoseTween extends Tween<_Pose> {
  _PoseTween({super.begin, super.end});

  @override
  _Pose lerp(double t) => _Pose(
    lerpDouble(begin!.depth, end!.depth, t)!,
    lerpDouble(begin!.dx, end!.dx, t)!,
  );
}

class _DeckCard extends StatelessWidget {
  const _DeckCard({required this.media});

  final Media media;

  @override
  Widget build(BuildContext context) => OuterShadow(
    radius: AppRadius.deck,
    shadow: AppShadows.deck,
    child: ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.deck),
      child: Stack(
        fit: StackFit.expand,
        children: [
          PosterImage(
            path: media.posterPath,
            seed: media.id,
            size: TmdbImageSize.w780,
          ),
          // radial-gradient(90% 60% at 30% 12%, white .28, transparent 60%)
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(-0.4, -0.76),
                radius: 0.9,
                colors: [
                  Color.fromRGBO(255, 255, 255, 0.28),
                  Color.fromRGBO(255, 255, 255, 0),
                ],
                stops: [0, 0.6],
              ),
            ),
          ),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color.fromRGBO(255, 255, 255, 0),
                  Color.fromRGBO(255, 255, 255, 0.42),
                ],
                stops: [0.46, 0.96],
              ),
            ),
          ),
          Positioned(
            top: 14,
            right: 14,
            child: RatingBadge(vote: media.voteAverage),
          ),
          Positioned(
            left: 14,
            right: 14,
            bottom: 14,
            child: Glass(
              radius: AppRadius.deckPanel,
              blur: 3,
              color: AppColors.glassSoft.withValues(alpha: 0.2),
              borderColor: const Color.fromRGBO(255, 255, 255, 0.85),
              shadow: AppShadows.deckPanel,
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 19),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    media.title,
                    style: AppText.deckTitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (media.overview.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      media.overview,
                      style: AppText.body.copyWith(color: AppColors.ink),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ),

          DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.deck),
              border: Border.all(
                color: const Color.fromRGBO(255, 255, 255, 0.16),
                width: 0.5,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
