import 'package:hexacom_user/features/home/providers/banner_provider.dart';
import 'package:hexacom_user/features/home/widgets/main_slider_widget.dart';
import 'package:hexacom_user/helper/responsive_helper.dart';
import 'package:hexacom_user/utill/dimensions.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

/// Skeleton for the main slider/banner. Matches [MainSliderWidget] / [BannerWidget]:
/// desktop 420px height with rounded corners; mobile 210px height, zero radius.
class MainSliderShimmerWidget extends StatelessWidget {
  const MainSliderShimmerWidget({super.key});

  static const double _desktopHeight = 420.0;
  static const double _mobileHeight = 210.0;

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveHelper.isDesktop(context);
    return SizedBox(
      height: isDesktop ? _desktopHeight : _mobileHeight,
      width: isDesktop ? double.infinity : MediaQuery.sizeOf(context).width,
      child: Padding(
        padding: EdgeInsets.all(isDesktop ? Dimensions.paddingSizeSmall : 0),
        child: Shimmer(
          duration: const Duration(seconds: 2),
          enabled: Provider.of<BannerProvider>(context).bannerList == null,
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).shadowColor.withValues(alpha: 0.25),
              borderRadius: isDesktop
                  ? BorderRadius.circular(MainSliderWidget.webBannerRadius)
                  : BorderRadius.zero,
              boxShadow: isDesktop
                  ? [
                      BoxShadow(
                        color: Theme.of(context).shadowColor.withValues(alpha: 0.08),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
          ),
        ),
      ),
    );
  }
}