import 'package:hexacom_user/common/models/config_model.dart';
import 'package:hexacom_user/common/widgets/custom_alert_dialog_widget.dart';
import 'package:hexacom_user/common/widgets/custom_asset_image_widget.dart';
import 'package:hexacom_user/common/widgets/custom_image_widget.dart';
import 'package:hexacom_user/common/widgets/language_select_widget.dart';
import 'package:hexacom_user/common/widgets/theme_switch_button_widget.dart';
import 'package:hexacom_user/features/auth/domain/enums/from_page_enum.dart';
import 'package:hexacom_user/features/auth/providers/auth_provider.dart';
import 'package:hexacom_user/features/language/widgets/language_select_button_widget.dart';
import 'package:hexacom_user/features/profile/providers/profile_provider.dart';
import 'package:hexacom_user/features/splash/providers/splash_provider.dart';
import 'package:hexacom_user/helper/responsive_helper.dart';
import 'package:hexacom_user/localization/language_constrants.dart';
import 'package:hexacom_user/utill/dimensions.dart';
import 'package:hexacom_user/utill/images.dart';
import 'package:hexacom_user/utill/routes.dart';
import 'package:hexacom_user/utill/styles.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:url_launcher/url_launcher.dart';

/// Redesigned mobile menu content: header card, grouped sections, and actions.
class MenuMobileContent extends StatelessWidget {
  const MenuMobileContent({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final splashProvider = Provider.of<SplashProvider>(context, listen: false);
    final configModel = splashProvider.configModel;
    final policyModel = splashProvider.policyModel;
    final isLoggedIn = authProvider.isLoggedIn();

    return Consumer<ProfileProvider>(
      builder: (ctx, userController, _) {
        return Column(
          children: [
            _MenuHeader(
              configModel: configModel,
              userController: userController,
              isLoggedIn: isLoggedIn,
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async => userController.getUserInfo(),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.only(
                    top: Dimensions.paddingSizeLarge,
                    left: Dimensions.paddingSizeDefault,
                    right: Dimensions.paddingSizeDefault,
                    bottom: Dimensions.bottomNavBarHeight +
                        MediaQuery.of(context).padding.bottom +
                        Dimensions.paddingSizeLarge,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _SocialLinksSection(),
                      const SizedBox(height: Dimensions.paddingSizeLarge),
                      const _MenuLoyaltyPointsSection(),
                      const SizedBox(height: Dimensions.paddingSizeLarge),
                      _SectionLabel(title: getTranslated('general', context)),
                      _MenuCard(
                        children: [
                          _MenuTile(
                            icon: Images.profileMenuIcon,
                            iconData: Icons.person_rounded,
                            title: getTranslated('profile', context),
                            onTap: () => RouteHelper.getProfileRoute(context),
                          ),
                          _MenuTile(
                            icon: Images.trackOrder,
                            iconData: Icons.delivery_dining_rounded,
                            title: getTranslated('track_order', context),
                            onTap: () =>
                                RouteHelper.getOrderSearchScreen(context),
                          ),
                          _MenuTile(
                            icon: Images.order,
                            iconData: Icons.receipt_long_rounded,
                            title: getTranslated('my_orders', context),
                            onTap: () =>
                                RouteHelper.getOrderListScreen(context),
                          ),
                          _MenuTile(
                            icon: Images.address,
                            iconData: Icons.location_on_rounded,
                            title: getTranslated('my_address', context),
                            onTap: () => RouteHelper.getAddressRoute(context),
                          ),
                          _MenuTile(
                            icon: Images.notificationWeb,
                            iconData: Icons.notifications_rounded,
                            title: getTranslated('notification', context),
                            onTap: () => RouteHelper.getNotificationRoute(context),
                          ),
                          if (isLoggedIn && (configModel?.loyaltyPointsEnabled ?? false))
                            _MenuTile(
                              icon: Images.ratingIcon,
                              iconData: Icons.stars_rounded,
                              title: getTranslated('my_points', context),
                              onTap: () => RouteHelper.getMyPointsRoute(context),
                            ),
                          _MenuTile(
                            icon: Images.language,
                            iconData: Icons.language_rounded,
                            title: getTranslated('language', context),
                            onTap: () => _showLanguageSheet(context),
                            showDivider: false,
                          ),
                        ],
                      ),
                      const SizedBox(height: Dimensions.paddingSizeLarge),
                      _SectionLabel(title: getTranslated('about_us', context)),
                      _MenuCard(
                        children: [
                          _MenuTile(
                            icon: Images.aboutUs,
                            iconData: Icons.contact_support_rounded,
                            title: getTranslated('contact_us', context),
                            onTap: () =>
                                RouteHelper.getContactUsRoute(context),
                          ),
                          _MenuTile(
                            icon: Images.aboutUs,
                            iconData: Icons.info_outline_rounded,
                            title: getTranslated('about_us', context),
                            onTap: () =>
                                RouteHelper.getAboutUsRoute(context),
                          ),
                          _MenuTile(
                            icon: Images.termsAndCondition,
                            iconData: Icons.description_rounded,
                            title: getTranslated('terms_and_condition', context),
                            onTap: () => RouteHelper.getTermsRoute(context),
                          ),
                          _MenuTile(
                            icon: Images.privacyPolicy,
                            iconData: Icons.privacy_tip_rounded,
                            title: getTranslated('privacy_policy', context),
                            onTap: () => RouteHelper.getPolicyRoute(context),
                            showDivider: false,
                          ),
                          if (policyModel?.refundPage?.status ?? false)
                            _MenuTile(
                              icon: Images.refundPolicy,
                              iconData: Icons.money_off_rounded,
                              title: getTranslated('refund_policy', context),
                              onTap: () =>
                                  RouteHelper.getRefundPolicyRoute(context),
                            ),
                          if (policyModel?.returnPage?.status ?? false)
                            _MenuTile(
                              icon: Images.refundPolicy,
                              iconData: Icons.assignment_return_rounded,
                              title: getTranslated('return_policy', context),
                              onTap: () =>
                                  RouteHelper.getReturnPolicyRoute(context),
                            ),
                          if (policyModel?.cancellationPage?.status ?? false)
                            _MenuTile(
                              icon: Images.cancellationPolicy,
                              iconData: Icons.cancel_rounded,
                              title: getTranslated(
                                  'cancellation_policy', context),
                              onTap: () =>
                                  RouteHelper.getCancellationPolicyRoute(
                                      context),
                              showDivider: false,
                            ),
                        ],
                      ),
                      if (isLoggedIn) ...[
                        const SizedBox(height: Dimensions.paddingSizeLarge),
                        _MenuCard(
                          children: [
                            _MenuTile(
                              icon: Images.userDeleteIcon,
                              iconData: Icons.delete_outline_rounded,
                              title: getTranslated('delete_account', context),
                              onTap: () => _showDeleteAccountDialog(context),
                              showDivider: false,
                              destructive: true,
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: Dimensions.paddingSizeLarge),
                      _LogoutButton(isLoggedIn: isLoggedIn),
                      const SizedBox(height: Dimensions.paddingSizeLarge),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showLanguageSheet(BuildContext context) {
    showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: context,
      builder: (ctx) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.7,
        ),
        padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
        decoration: BoxDecoration(
          color: Theme.of(context).canvasColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 4,
              width: 40,
              decoration: BoxDecoration(
                color: Theme.of(context).dividerColor,
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            const SizedBox(height: Dimensions.paddingSizeDefault),
            Text(
              getTranslated('select_language', context),
              style: rubikMedium,
            ),
            const SizedBox(height: Dimensions.paddingSizeExtraSmall),
            Text(
              getTranslated('choose_the_language', context),
              style: rubikRegular.copyWith(
                  fontSize: Dimensions.fontSizeSmall),
            ),
            const SizedBox(height: Dimensions.paddingSizeExtraLarge),
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.sizeOf(context).height * 0.35,
              ),
              child: const SingleChildScrollView(
                child: LanguageSelectWidget(fromMenu: true),
              ),
            ),
            const SizedBox(height: Dimensions.paddingSizeDefault),
            const LanguageSelectButtonWidget(fromMenu: true),
          ],
        ),
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    ResponsiveHelper.showDialogOrBottomSheet(
      context,
      Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          return CustomAlertDialogWidget(
            title: getTranslated('are_you_sure_to_delete_account', context),
            subTitle:
                getTranslated('it_will_remove_your_all_information', context),
            icon: Icons.contact_support_outlined,
            isLoading: authProvider.isLoading,
            onPressRight: () => authProvider.deleteUser(),
          );
        },
      ),
    );
  }
}

class _MenuHeader extends StatelessWidget {
  final ConfigModel? configModel;
  final ProfileProvider userController;
  final bool isLoggedIn;

  const _MenuHeader({
    required this.configModel,
    required this.userController,
    required this.isLoggedIn,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;
    final onPrimary = Theme.of(context).cardColor;

    return SafeArea(
      bottom: false,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.only(
          left: Dimensions.paddingSizeDefault,
          right: Dimensions.paddingSizeDefault,
          top: Dimensions.paddingSizeDefault,
          bottom: Dimensions.paddingSizeLarge,
        ),
        decoration: BoxDecoration(
          color: primary,
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: primary.withValues(alpha: 0.25),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: onPrimary.withValues(alpha: 0.5), width: 2),
              ),
              child: ClipOval(
                child: CustomImageWidget(
                  placeholder: Images.profile,
                  placeholderColor: onPrimary.withValues(alpha: 0.3),
                  image:
                      '${configModel?.baseUrls?.customerImageUrl}'
                      '/${(userController.userInfoModel != null && isLoggedIn) ? userController.userInfoModel!.image : ''}',
                  height: 56,
                  width: 56,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: Dimensions.paddingSizeDefault),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isLoggedIn && userController.userInfoModel == null)
                    Shimmer(
                      duration: const Duration(seconds: 2),
                      enabled: true,
                      child: Container(
                        height: 18,
                        width: 150,
                        decoration: BoxDecoration(
                          color: onPrimary.withValues(alpha: 0.35),
                          borderRadius:
                              BorderRadius.circular(Dimensions.radiusSizeSmall),
                        ),
                      ),
                    )
                  else
                    Text(
                      isLoggedIn
                          ? '${userController.userInfoModel?.fName ?? ''} ${userController.userInfoModel?.lName ?? ''}'
                          : getTranslated('guest_user', context),
                      style: rubikSemiBold.copyWith(
                        fontSize: Dimensions.fontSizeExtraLarge,
                        color: onPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  if (isLoggedIn && userController.userInfoModel != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      userController.userInfoModel?.email ?? '',
                      style: rubikRegular.copyWith(
                        fontSize: Dimensions.fontSizeSmall,
                        color: onPrimary.withValues(alpha: 0.85),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            const ThemeSwitchButtonWidget(fromWebBar: false),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String title;

  const _SectionLabel({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: Dimensions.paddingSizeExtraSmall,
        bottom: Dimensions.paddingSizeExtraSmall,
      ),
      child: Text(
        title,
        style: rubikSemiBold.copyWith(
          fontSize: Dimensions.fontSizeSmall,
          color: Theme.of(context).textTheme.titleMedium?.color?.withValues(alpha: 0.75),
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  final List<Widget> children;

  const _MenuCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusSizeLarge),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(children: children),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final String icon;
  final String title;
  final VoidCallback onTap;
  final bool showDivider;
  final bool destructive;
  final IconData? iconData;

  const _MenuTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.showDivider = true,
    this.destructive = false,
    this.iconData,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = destructive
        ? Theme.of(context).colorScheme.error
        : Theme.of(context).textTheme.titleMedium?.color;
    final iconBgColor = destructive
        ? Theme.of(context).colorScheme.error.withValues(alpha: 0.12)
        : Theme.of(context).primaryColor.withValues(alpha: 0.1);
    final iconColor = destructive
        ? Theme.of(context).colorScheme.error
        : Theme.of(context).primaryColor;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: Dimensions.paddingSizeDefault,
                vertical: Dimensions.paddingSizeSmall + 2,
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: iconBgColor,
                      borderRadius: BorderRadius.circular(Dimensions.radiusSizeSmall),
                    ),
                    alignment: Alignment.center,
                    child: iconData != null
                        ? Icon(iconData!, size: 22, color: iconColor)
                        : CustomAssetImageWidget(
                            icon,
                            height: 20,
                            width: 20,
                            color: iconColor,
                          ),
                  ),
                  const SizedBox(width: Dimensions.paddingSizeDefault),
                  Expanded(
                    child: Text(
                      title,
                      style: rubikMedium.copyWith(
                        fontSize: Dimensions.fontSizeDefault,
                        color: textColor,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 22,
                    color: Theme.of(context).hintColor.withValues(alpha: 0.7),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            indent: Dimensions.paddingSizeDefault + 40 + Dimensions.paddingSizeDefault,
            endIndent: Dimensions.paddingSizeDefault,
            color: Theme.of(context).dividerColor.withValues(alpha: 0.5),
          ),
      ],
    );
  }
}

class _LogoutButton extends StatelessWidget {
  final bool isLoggedIn;

  const _LogoutButton({required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          if (isLoggedIn) {
            ResponsiveHelper.showDialogOrBottomSheet(
              context,
              CustomAlertDialogWidget(
                title: getTranslated('want_to_sign_out', context),
                icon: Icons.contact_support_outlined,
                onPressRight: () async {
                  await Provider.of<AuthProvider>(context, listen: false)
                      .clearSharedData();
                  if (context.mounted) Navigator.pop(context);
                  RouteHelper.getDashboardRoute(context, 'home',
                      action: RouteAction.pushNamedAndRemoveUntil);
                },
              ),
            );
          } else {
            RouteHelper.getLoginRoute(context, FromPage.menu.name,
                action: RouteAction.push);
          }
        },
        borderRadius: BorderRadius.circular(Dimensions.radiusSizeLarge),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isLoggedIn
                ? Theme.of(context).cardColor
                : Theme.of(context).primaryColor,
            borderRadius: BorderRadius.circular(Dimensions.radiusSizeLarge),
            border: isLoggedIn
                ? Border.all(
                    color: Theme.of(context).primaryColor.withValues(alpha: 0.35),
                    width: 1.5,
                  )
                : null,
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).shadowColor.withValues(alpha: 0.06),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isLoggedIn ? Icons.power_settings_new_rounded : Icons.login_rounded,
                size: 22,
                color: isLoggedIn
                    ? Theme.of(context).primaryColor
                    : Theme.of(context).cardColor,
              ),
              const SizedBox(width: Dimensions.paddingSizeSmall),
              Text(
                isLoggedIn
                    ? getTranslated('logout', context)
                    : getTranslated('sign_in', context),
                style: rubikSemiBold.copyWith(
                  fontSize: Dimensions.fontSizeDefault,
                  color: isLoggedIn
                      ? Theme.of(context).primaryColor
                      : Theme.of(context).cardColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SocialLinksSection extends StatelessWidget {
  const _SocialLinksSection();

  @override
  Widget build(BuildContext context) {
    return Consumer<SplashProvider>(
      builder: (context, splash, _) {
        final links = splash.configModel?.socialMediaLink;
        if (links == null || links.isEmpty) return const SizedBox.shrink();

        final title = getTranslated('social_follow_us_title', context);
        final subtitle = getTranslated('social_follow_us_subtitle', context);
        final hintColor = Theme.of(context).hintColor;
        final primary = Theme.of(context).primaryColor;
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final titleColor = Theme.of(context).textTheme.titleMedium?.color;

        // Light mode: primary accents; dark mode: light icon tints and softer border
        final sectionBorderColor = isDark
            ? Theme.of(context).dividerColor.withValues(alpha: 0.4)
            : primary.withValues(alpha: 0.25);
        final lightIconColor = Theme.of(context).colorScheme.onSurface;
        final shareIconColor = isDark ? lightIconColor : primary;
        final iconBgColor = isDark
            ? lightIconColor.withValues(alpha: 0.12)
            : primary.withValues(alpha: 0.12);
        final iconTintColor = isDark ? lightIconColor : null;

        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: Dimensions.paddingSizeLarge,
            vertical: Dimensions.paddingSizeLarge,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(Dimensions.radiusSizeLarge),
            border: Border.all(
              color: sectionBorderColor,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).shadowColor.withValues(alpha: isDark ? 0.15 : 0.06),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.share_rounded,
                    size: 22,
                    color: shareIconColor,
                  ),
                  const SizedBox(width: Dimensions.paddingSizeSmall),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: rubikSemiBold.copyWith(
                      fontSize: Dimensions.fontSizeLarge,
                      color: titleColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: rubikRegular.copyWith(
                  fontSize: Dimensions.fontSizeSmall,
                  color: hintColor,
                ),
              ),
              const SizedBox(height: Dimensions.paddingSizeDefault),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 12,
                runSpacing: 12,
                children: links.map((link) {
                  if (link.link == null || link.link!.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  final linkIconColor = iconTintColor ?? primary;
                  return InkWell(
                    onTap: () => _launchUrl(link.link!),
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: iconBgColor,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      padding: const EdgeInsets.all(12),
                      child: isDark
                          ? ColorFiltered(
                              colorFilter: ColorFilter.mode(
                                linkIconColor,
                                BlendMode.srcIn,
                              ),
                              child: Image.asset(
                                Images.getSocialImage(link.name ?? ''),
                                fit: BoxFit.contain,
                                errorBuilder: (_, __, ___) => Icon(
                                  Icons.link_rounded,
                                  size: 24,
                                  color: linkIconColor,
                                ),
                              ),
                            )
                          : Image.asset(
                              Images.getSocialImage(link.name ?? ''),
                              fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) => Icon(
                                Icons.link_rounded,
                                size: 24,
                                color: primary,
                              ),
                            ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }

  static Future<void> _launchUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

class _MenuLoyaltyPointsSection extends StatelessWidget {
  const _MenuLoyaltyPointsSection();

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final splashProvider = Provider.of<SplashProvider>(context, listen: false);
    final isLoggedIn = authProvider.isLoggedIn();
    final loyaltyEnabled = splashProvider.configModel?.loyaltyPointsEnabled ?? false;
    if (!isLoggedIn || !loyaltyEnabled) return const SizedBox.shrink();

    return Consumer<ProfileProvider>(
      builder: (context, profileProvider, _) {
        final points = profileProvider.userInfoModel?.loyaltyPoints ?? 0;
        return Padding(
          padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeLarge),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => RouteHelper.getMyPointsRoute(context),
              borderRadius: BorderRadius.circular(Dimensions.radiusSizeLarge),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: Dimensions.paddingSizeDefault,
                  vertical: Dimensions.paddingSizeLarge,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Theme.of(context).primaryColor.withValues(alpha: 0.12),
                      Theme.of(context).primaryColor.withValues(alpha: 0.06),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(Dimensions.radiusSizeLarge),
                  border: Border.all(
                    color: Theme.of(context).primaryColor.withValues(alpha: 0.2),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).shadowColor.withValues(alpha: 0.06),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(Dimensions.radiusSizeDefault),
                      ),
                      child: Icon(
                        Icons.stars_rounded,
                        size: 28,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    const SizedBox(width: Dimensions.paddingSizeDefault),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            getTranslated('loyalty_points', context),
                            style: rubikRegular.copyWith(
                              fontSize: Dimensions.fontSizeSmall,
                              color: Theme.of(context).hintColor,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '$points ${getTranslated('points', context)}',
                            style: rubikSemiBold.copyWith(
                              fontSize: Dimensions.fontSizeLarge,
                              color: Theme.of(context).textTheme.titleMedium?.color,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 24,
                      color: Theme.of(context).hintColor.withValues(alpha: 0.7),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
