import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:hexacom_user/common/enums/footer_type_enum.dart';
import 'package:hexacom_user/common/widgets/custom_alert_dialog_widget.dart';
import 'package:hexacom_user/common/widgets/custom_image_widget.dart';
import 'package:hexacom_user/common/widgets/footer_web_widget.dart';
import 'package:hexacom_user/features/auth/domain/enums/from_page_enum.dart';
import 'package:hexacom_user/features/menu/domain/models/menu_model.dart';
import 'package:hexacom_user/features/menu/widgets/menu_item_web_widget.dart';
import 'package:hexacom_user/features/menu/widgets/menu_loyalty_points_card_widget.dart';
import 'package:hexacom_user/features/profile/providers/profile_provider.dart';
import 'package:hexacom_user/features/splash/providers/splash_provider.dart';
import 'package:hexacom_user/helper/responsive_helper.dart';
import 'package:hexacom_user/localization/language_constrants.dart';
import 'package:hexacom_user/utill/dimensions.dart';
import 'package:hexacom_user/utill/images.dart';
import 'package:hexacom_user/utill/routes.dart';
import 'package:hexacom_user/utill/styles.dart';
import 'package:hexacom_user/features/auth/providers/auth_provider.dart';

class MenuWebWidget extends StatelessWidget {
  final bool? isLoggedIn;
  const MenuWebWidget({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    final splashProvider =  Provider.of<SplashProvider>(context, listen: false);

    final List<MenuModel> menuList = [
      MenuModel(icon: Images.couponMenuIcon, iconData: Icons.receipt_long_rounded, title: getTranslated('my_order', context), route: ()=>  RouteHelper.getOrderListScreen(context)),
      MenuModel(icon: Images.trackOrder, iconData: Icons.delivery_dining_rounded, title: getTranslated('track_order', context), route: ()=>  RouteHelper.getOrderSearchScreen(context)),
      MenuModel(icon: Images.profileMenuIcon, iconData: Icons.person_rounded, title: getTranslated('profile', context), route: ()=>  RouteHelper.getProfileRoute(context)),
      MenuModel(icon: Images.address, iconData: Icons.location_on_rounded, title: getTranslated('address', context), route: ()=>  RouteHelper.getAddressRoute(context)),
      if(isLoggedIn! && (splashProvider.configModel?.loyaltyPointsEnabled ?? false))
        MenuModel(icon: Images.ratingIcon, iconData: Icons.stars_rounded, title: getTranslated('my_points', context), route: ()=>  RouteHelper.getMyPointsRoute(context)),
      MenuModel(icon: Images.notification, iconData: Icons.notifications_rounded, title: getTranslated('notification', context), route: ()=>  RouteHelper.getNotificationRoute(context)),
      MenuModel(icon: Images.privacyPolicy, iconData: Icons.privacy_tip_rounded, title: getTranslated('privacy_policy', context), route: ()=>  RouteHelper.getPolicyRoute(context)),
      MenuModel(icon: Images.termsAndCondition, iconData: Icons.description_rounded, title: getTranslated('terms_and_condition', context), route: ()=> RouteHelper.getTermsRoute(context)),

      if(splashProvider.policyModel?.refundPage?.status ?? false)
        MenuModel(icon: Images.refundPolicy, iconData: Icons.money_off_rounded, title: getTranslated('refund_policy', context), route: ()=>  RouteHelper.getRefundPolicyRoute(context)),

      if(splashProvider.policyModel?.returnPage?.status ?? false)
        MenuModel(icon: Images.refundPolicy, iconData: Icons.assignment_return_rounded, title: getTranslated('return_policy', context), route: ()=>  RouteHelper.getReturnPolicyRoute(context)),

      if(splashProvider.policyModel?.cancellationPage?.status ?? false)
        MenuModel(icon: Images.cancellationPolicy, iconData: Icons.cancel_rounded, title: getTranslated('cancellation_policy', context), route: ()=>  RouteHelper.getCancellationPolicyRoute(context)),

      MenuModel(icon: Images.aboutUs, iconData: Icons.contact_support_rounded, title: getTranslated('contact_us', context), route: ()=>  RouteHelper.getContactUsRoute(context)),
      MenuModel(icon: Images.aboutUs, iconData: Icons.info_outline_rounded, title: getTranslated('about_us', context), route: ()=>  RouteHelper.getAboutUsRoute(context)),

      if (isLoggedIn!)
        MenuModel(
          icon: Images.userDeleteIcon,
          iconData: Icons.delete_forever_rounded,
          title: getTranslated('delete_account', context),
          destructive: true,
          route: () {
            ResponsiveHelper.showDialogOrBottomSheet(
              context,
              Consumer<AuthProvider>(
                builder: (context, authProvider, _) {
                  return CustomAlertDialogWidget(
                    isLoading: authProvider.isLoading,
                    title: getTranslated('are_you_sure_to_delete_account', context),
                    subTitle: getTranslated('it_will_remove_your_all_information', context),
                    icon: Icons.contact_support_outlined,
                    onPressRight: () => authProvider.deleteUser(),
                  );
                },
              ),
            );
          },
        ),

      MenuModel(icon: Images.login, iconData: isLoggedIn! ? Icons.logout_rounded : Icons.login_rounded, title: getTranslated(isLoggedIn! ? 'logout' : 'login', context), route: (isLoggedIn ?? false) ? (){

        ResponsiveHelper.showDialogOrBottomSheet(context, Selector<AuthProvider, bool>(
          selector: (context, authProvider) => authProvider.isLoading,
          builder: (context, isLoading, child) {
            return CustomAlertDialogWidget(
              isLoading: isLoading,
              title: getTranslated('want_to_sign_out', context),
              icon: Icons.contact_support_outlined,
              onPressRight: () async{
                Provider.of<AuthProvider>(context, listen: false).clearSharedData();
                if(ResponsiveHelper.isDesktop(context)) {
                  GoRouter.of(context).pop();
                  RouteHelper.getMainRoute(context, action: RouteAction.push);
                }else {
                  Navigator.pop(context);
                  RouteHelper.getDashboardRoute(context, 'home', action: RouteAction.pushNamedAndRemoveUntil);
                }
              },
            );
          }
        ));
      } : () => RouteHelper.getLoginRoute(context, FromPage.menu.name)),

    ];

    return SingleChildScrollView(
      child: Column(
        children: [
          Center(
            child: Consumer<ProfileProvider>(
              builder: (context, profileProvider, child) {
                return SizedBox(
                  width: Dimensions.webScreenWidth,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _MenuWebHeader(
                        isLoggedIn: isLoggedIn!,
                        profileProvider: profileProvider,
                        splashProvider: splashProvider,
                      ),
                      const SizedBox(height: Dimensions.paddingSizeSection),
                      GridView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 6,
                          crossAxisSpacing: Dimensions.paddingSizeExtraLarge,
                          mainAxisSpacing: Dimensions.paddingSizeExtraLarge,
                        ),
                        itemCount: menuList.length,
                        itemBuilder: (context, index) {
                          return MenuItemWebWidget(menu: menuList[index]);
                        },
                      ),
                      const SizedBox(height: 50),
                    ],
                  ),
                );
              },
            ),
          ),
          const FooterWebWidget(footerType: FooterType.nonSliver),
        ],
      ),
    );
  }
}

class _MenuWebHeader extends StatelessWidget {
  final bool isLoggedIn;
  final ProfileProvider profileProvider;
  final SplashProvider splashProvider;

  const _MenuWebHeader({
    required this.isLoggedIn,
    required this.profileProvider,
    required this.splashProvider,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    final baseUrls = splashProvider.baseUrls;
    final user = profileProvider.userInfoModel;
    final showLoyalty = isLoggedIn && (splashProvider.configModel?.loyaltyPointsEnabled ?? false) && user != null;
    final points = user?.loyaltyPoints ?? 0;

    return Container(
      decoration: BoxDecoration(
        color: primaryColor,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(Dimensions.radiusExtraLarge),
          bottomRight: Radius.circular(Dimensions.radiusExtraLarge),
        ),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withValues(alpha: 0.35),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(32, 24, 32, 32),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            height: 100,
            width: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.2),
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipOval(
              child: isLoggedIn && user != null && (user.image ?? '').isNotEmpty && baseUrls != null
                  ? CustomImageWidget(
                      image: '${baseUrls.customerImageUrl}/${user.image}',
                      fit: BoxFit.cover,
                    )
                  : Image.asset(
                      Images.placeholder(context),
                      fit: BoxFit.cover,
                    ),
            ),
          ),
          const SizedBox(width: 28),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isLoggedIn && user != null) ...[
                  Text(
                    '${user.fName ?? ''} ${user.lName ?? ''}'.trim().isEmpty ? getTranslated('guest', context) : '${user.fName ?? ''} ${user.lName ?? ''}'.trim(),
                    style: rubikMedium.copyWith(
                      fontSize: Dimensions.fontSizeOverLarge,
                      color: Colors.white,
                    ),
                  ),
                  if (showLoyalty) ...[
                    const SizedBox(height: 12),
                    MenuLoyaltyPointsCardWidget(
                      points: points,
                      onTap: () => RouteHelper.getMyPointsRoute(context),
                    ),
                  ],
                ] else ...[
                  Text(
                    getTranslated('guest', context),
                    style: rubikMedium.copyWith(
                      fontSize: Dimensions.fontSizeOverLarge,
                      color: Colors.white,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}