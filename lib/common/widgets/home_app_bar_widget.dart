import 'package:hexacom_user/common/widgets/cart_count_widget.dart';
import 'package:hexacom_user/common/widgets/custom_asset_image_widget.dart';
import 'package:hexacom_user/features/cart/providers/cart_provider.dart';
import 'package:hexacom_user/helper/cart_helper.dart';
import 'package:hexacom_user/helper/responsive_helper.dart';
import 'package:hexacom_user/localization/language_constrants.dart';
import 'package:hexacom_user/utill/color_resources.dart';
import 'package:hexacom_user/utill/dimensions.dart';
import 'package:hexacom_user/utill/images.dart';
import 'package:hexacom_user/utill/routes.dart';
import 'package:hexacom_user/utill/styles.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeAppBarWidget extends StatelessWidget {
  const HomeAppBarWidget({
    super.key,
    required this.drawerGlobalKey,
    this.headerScrolled,
  });

  final GlobalKey<ScaffoldState> drawerGlobalKey;
  final ValueListenable<bool>? headerScrolled;

  static const double _mobileLogoSize = 40.0;

  @override
  Widget build(BuildContext context) {
    final isTab = ResponsiveHelper.isTab(context);

    if (isTab) {
      return _buildTabletAppBar(context);
    }
    return _buildMobileAppBar(context);
  }

  Widget _buildTabletAppBar(BuildContext context) {
    // Use the same modern header style for tablets as for mobile.
    return _buildMobileAppBar(context);
  }

  static const double _mobileHeaderRowHeight = 48.0;
  static const double _mobileItemSize = 44.0;
  static const double _mobileGap = 12.0;
  static const double _mobileEdgePadding = 16.0;

  static const Duration _headerColorDuration = Duration(milliseconds: 200);

  Widget _buildMobileAppBar(BuildContext context) {
    final listenable = headerScrolled ?? ValueNotifier(false);
    return ValueListenableBuilder<bool>(
      valueListenable: listenable,
      builder: (context, scrolled, _) => SliverAppBar(
        floating: true,
        toolbarHeight: 70,
        elevation: scrolled ? 3 : 0,
        shadowColor: Colors.black26,
        centerTitle: false,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        pinned: false,
        titleSpacing: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        flexibleSpace: AnimatedContainer(
          duration: _headerColorDuration,
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            color: scrolled ? ColorResources.primary : ColorResources.navBarNavy,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(18),
              bottomRight: Radius.circular(18),
            ),
          ),
        ),
        title: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: _mobileEdgePadding,
            vertical: 10,
          ),
          child: SizedBox(
            height: _mobileHeaderRowHeight,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: _mobileItemSize,
                  height: _mobileItemSize,
                  child: Center(
                    child: InkWell(
                      onTap: () => RouteHelper.getDashboardRoute(context, 'home', action: RouteAction.pushNamedAndRemoveUntil),
                      borderRadius: BorderRadius.circular(12),
                      child: CustomAssetImageWidget(
                        Images.logo,
                        width: _mobileLogoSize,
                        height: _mobileLogoSize,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: _mobileGap),
                Expanded(
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => RouteHelper.getSearchRoute(context, action: RouteAction.push),
                      borderRadius: BorderRadius.circular(24),
                      child: Container(
                        height: _mobileItemSize,
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: Colors.black.withValues(alpha: 0.06),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.06),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.search_rounded,
                              size: 22,
                              color: Theme.of(context).hintColor.withValues(alpha: 0.8),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                getTranslated('search_for_products', context),
                                style: rubikRegular.copyWith(
                                  fontSize: 14,
                                  color: Theme.of(context).hintColor.withValues(alpha: 0.8),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: _mobileGap),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => RouteHelper.getCouponRoute(context, action: RouteAction.push),
                    borderRadius: BorderRadius.circular(22),
                    child: Container(
                      width: _mobileItemSize,
                      height: _mobileItemSize,
                      decoration: const BoxDecoration(
                        color: ColorResources.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Image.asset(
                          Images.coupon,
                          height: 20,
                          width: 20,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
