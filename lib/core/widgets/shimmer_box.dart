import 'package:cinecatalog/core/theme/app_tokens.dart';
import 'package:flutter/widgets.dart';
import 'package:shimmer/shimmer.dart';

/// Wraps skeleton shapes in the design's 1.3s blue-white shimmer.
class AppShimmer extends StatelessWidget {
  const AppShimmer({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) => Shimmer.fromColors(
    baseColor: AppColors.shimmerBase,
    highlightColor: AppColors.shimmerHighlight,
    period: AppMotion.shimmer,
    child: child,
  );
}

/// A skeleton block; must sit inside an [AppShimmer].
class ShimmerBox extends StatelessWidget {
  const ShimmerBox({
    super.key,
    this.width,
    this.height,
    this.radius = 8,
    this.circle = false,
  });

  final double? width;
  final double? height;
  final double radius;
  final bool circle;

  @override
  Widget build(BuildContext context) => Container(
    width: width,
    height: height,
    decoration: BoxDecoration(
      color: const Color(0xFFFFFFFF),
      shape: circle ? BoxShape.circle : BoxShape.rectangle,
      borderRadius: circle ? null : BorderRadius.circular(radius),
    ),
  );
}
