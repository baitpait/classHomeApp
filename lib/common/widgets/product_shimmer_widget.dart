import 'package:flutter/material.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

/// Skeleton for [ProductCardWidget]. Matches both vertical and horizontal card layout.
class ProductShimmerWidget extends StatelessWidget {
  final bool isEnabled;
  final bool isWeb;
  /// When [direction] is [Axis.horizontal], layout matches [ProductCardWidget] horizontal:
  /// 150px image left, then title + price row (e.g. new arrival, flash sale).
  final Axis direction;

  const ProductShimmerWidget({
    super.key,
    required this.isEnabled,
    this.isWeb = false,
    this.direction = Axis.vertical,
  });

  static const double _verticalImageAspectRatio = 1.1;
  static const double _horizontalImageWidth = 150.0;
  static const double _borderRadius = 14.0;
  static const List<BoxShadow> _cardShadow = [
    BoxShadow(
      color: Color(0x1A000000),
      blurRadius: 18,
      spreadRadius: 0,
      offset: Offset(0, 4),
    ),
  ];

  /// Returns a list of [ProductShimmerWidget] items suitable for building
  /// grid and list skeletons across home, store, and search screens.
  static List<Widget> buildGridShimmers({
    required int itemCount,
    bool isWeb = false,
    Axis direction = Axis.vertical,
  }) {
    if (itemCount <= 0) {
      return const <Widget>[];
    }
    return List<Widget>.generate(
      itemCount,
      (_) => ProductShimmerWidget(
        isEnabled: true,
        isWeb: isWeb,
        direction: direction,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final shadowColor = Theme.of(context).shadowColor.withValues(alpha: 0.10);
    final shimmerColor = Theme.of(context).shadowColor.withValues(alpha: 0.25);

    if (direction == Axis.horizontal) {
      return _buildHorizontal(context, shadowColor, shimmerColor);
    }
    return _buildVertical(context, shadowColor, shimmerColor);
  }

  Widget _buildHorizontal(
    BuildContext context,
    Color shadowColor,
    Color shimmerColor,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(_borderRadius),
        boxShadow: _cardShadow.map((s) => s.copyWith(color: shadowColor)).toList(),
      ),
      clipBehavior: Clip.antiAlias,
      child: Shimmer(
        duration: const Duration(seconds: 2),
        enabled: isEnabled,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              width: _horizontalImageWidth,
              child: ClipRRect(
                borderRadius: const BorderRadius.horizontal(left: Radius.circular(13)),
                child: Container(
                  width: double.infinity,
                  color: shimmerColor,
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    height: 12,
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color: shimmerColor,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Container(
                                    height: 12,
                                    width: 80,
                                    decoration: BoxDecoration(
                                      color: shimmerColor,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              height: 32,
                              width: 32,
                              decoration: BoxDecoration(
                                color: shimmerColor,
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Container(
                          height: 12,
                          width: 48,
                          decoration: BoxDecoration(
                            color: shimmerColor,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Container(
                            height: 14,
                            decoration: BoxDecoration(
                              color: shimmerColor,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          height: 32,
                          width: 32,
                          decoration: BoxDecoration(
                            color: shimmerColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVertical(
    BuildContext context,
    Color shadowColor,
    Color shimmerColor,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final hasBoundedHeight = constraints.maxHeight.isFinite && constraints.maxHeight > 0;
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(_borderRadius),
            boxShadow: _cardShadow.map((s) => s.copyWith(color: shadowColor)).toList(),
          ),
          clipBehavior: Clip.antiAlias,
          child: Shimmer(
            duration: const Duration(seconds: 2),
            enabled: isEnabled,
            child: Column(
              mainAxisSize: hasBoundedHeight ? MainAxisSize.max : MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (hasBoundedHeight)
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      color: shimmerColor,
                    ),
                  )
                else
                  AspectRatio(
                    aspectRatio: _verticalImageAspectRatio,
                    child: Container(
                      width: double.infinity,
                      color: shimmerColor,
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        height: 12,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: shimmerColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        height: 12,
                        width: 100,
                        decoration: BoxDecoration(
                          color: shimmerColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 14,
                              decoration: BoxDecoration(
                                color: shimmerColor,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            height: 32,
                            width: 32,
                            decoration: BoxDecoration(
                              color: shimmerColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
