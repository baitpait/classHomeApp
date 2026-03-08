import 'package:hexacom_user/features/category/providers/category_provider.dart';
import 'package:hexacom_user/helper/responsive_helper.dart';
import 'package:hexacom_user/utill/color_resources.dart';
import 'package:hexacom_user/utill/dimensions.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

/// Skeleton for the category horizontal list. Matches [CategoryWidget] _CategoryChip:
/// image (76 mobile / 104 desktop) with same shadow + radius, then label pill (32h, 80w mobile).
class CategoryShimmerWidget extends StatelessWidget {
  const CategoryShimmerWidget({super.key});

  static const double _mobileImageSize = 76.0;
  static const double _mobileCardHeight = 124.0;
  static const double _mobileLabelHeight = 32.0;
  static const double _mobileLabelWidth = 80.0;
  static const double _desktopImageSize = 104.0;
  static const double _desktopCardHeight = 172.0;
  static const double _desktopLabelHeight = 28.0;
  static const double _desktopLabelWidth = 116.0;

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveHelper.isDesktop(context);
    final imageSize = isDesktop ? _desktopImageSize : _mobileImageSize;
    final cardHeight = isDesktop ? _desktopCardHeight : _mobileCardHeight;
    final labelHeight = isDesktop ? _desktopLabelHeight : _mobileLabelHeight;
    final labelWidth = isDesktop ? _desktopLabelWidth : _mobileLabelWidth;
    final shadowColor = Theme.of(context).shadowColor;
    final accent = ColorResources.accentNavy;

    return SizedBox(
      height: cardHeight,
      child: ListView.builder(
        itemCount: isDesktop ? 13 : 10,
        padding: const EdgeInsets.only(left: Dimensions.paddingSizeSmall),
        physics: const BouncingScrollPhysics(),
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.only(
                right: isDesktop ? 10 : Dimensions.paddingSizeDefault),
            child: Shimmer(
              duration: const Duration(seconds: 2),
              enabled:
                  Provider.of<CategoryProvider>(context).categoryList == null,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    height: imageSize,
                    width: imageSize,
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      shape: isDesktop ? BoxShape.rectangle : BoxShape.circle,
                      borderRadius: isDesktop ? BorderRadius.circular(16) : null,
                      boxShadow: [
                        BoxShadow(
                          color: shadowColor.withValues(alpha: 0.08),
                          blurRadius: 12,
                          spreadRadius: 0,
                          offset: const Offset(0, 4),
                        ),
                        BoxShadow(
                          color: accent.withValues(alpha: 0.04),
                          blurRadius: 8,
                          spreadRadius: -2,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: isDesktop
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: Container(
                              color: shadowColor.withValues(alpha: 0.25),
                            ),
                          )
                        : ClipOval(
                            child: Container(
                              color: shadowColor.withValues(alpha: 0.25),
                            ),
                          ),
                  ),
                  const SizedBox(height: 8),
                  isDesktop
                      ? Container(
                          height: labelHeight,
                          width: labelWidth,
                          decoration: BoxDecoration(
                            color: shadowColor.withValues(alpha: 0.25),
                            borderRadius: BorderRadius.circular(20),
                          ),
                        )
                      : Container(
                          height: 12,
                          width: labelWidth * 0.7,
                          decoration: BoxDecoration(
                            color: shadowColor.withValues(alpha: 0.25),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
