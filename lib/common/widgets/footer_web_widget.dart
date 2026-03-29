import 'package:hexacom_user/common/enums/footer_type_enum.dart';
import 'package:hexacom_user/common/models/config_model.dart';
import 'package:hexacom_user/helper/app_name_helper.dart';
import 'package:hexacom_user/helper/responsive_helper.dart';
import 'package:hexacom_user/utill/color_resources.dart';
import 'package:hexacom_user/utill/routes.dart';
import 'package:hexacom_user/utill/styles.dart';
import 'package:hexacom_user/common/widgets/developer_credit_bar_widget.dart';
import 'package:hexacom_user/common/widgets/custom_image_widget.dart';
import 'package:hexacom_user/common/widgets/on_hover.dart';
import 'package:hexacom_user/common/widgets/text_hover_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../localization/language_constrants.dart';
import '../../features/splash/providers/splash_provider.dart';
import '../../utill/dimensions.dart';

class FooterWebWidget extends StatelessWidget {
  final FooterType footerType;
  const FooterWebWidget({super.key, required this.footerType});

  /// `app_logo` from config API is the square (1:1) web app asset; not `ecommerce_logo` (3:1 admin banner).
  static const double _footerLogoSize = 96;

  static const Color _footerBackground = ColorResources.footerWebBackground;
  static const Color _footerTextWhite = Colors.white;
  static Color get _footerTextMuted => Colors.white.withValues(alpha: 0.85);

  @override
  Widget build(BuildContext context) {
    final ConfigModel configModel =
        Provider.of<SplashProvider>(context, listen: false).configModel!;

    final List<QuickLinkModel> accountQuickLink = [
      QuickLinkModel(
          title: getTranslated('profile', context),
          route: () => RouteHelper.getProfileRoute(context)),
      QuickLinkModel(
          title: getTranslated('address', context),
          route: () => RouteHelper.getAddressRoute(context)),
      QuickLinkModel(
          title: getTranslated('order', context),
          route: () => RouteHelper.getOrderListScreen(context)),
    ];
    final List<QuickLinkModel> otherQuickLink = [
      QuickLinkModel(
          title: getTranslated('privacy_policy', context),
          route: () => RouteHelper.getPolicyRoute(context)),
      QuickLinkModel(
          title: getTranslated('terms_and_condition', context),
          route: () => RouteHelper.getTermsRoute(context)),
      QuickLinkModel(
          title: getTranslated('about_us', context),
          route: () => RouteHelper.getAboutUsRoute(context)),
      QuickLinkModel(
          title: getTranslated('contact_us', context),
          route: () => RouteHelper.getContactUsRoute(context)),
    ];

    return _FooterFormatter(
      footerType: footerType,
      child: Container(
        width: double.maxFinite,
        decoration: BoxDecoration(
          color: _footerBackground,
          border: Border(
            top: BorderSide(
              color: ColorResources.brandTeal.withValues(alpha: 0.35),
              width: 1,
            ),
          ),
        ),
        child: Center(
          child: SizedBox(
            width: Dimensions.webScreenWidth,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: Dimensions.paddingSizeExtraLarge,
                vertical: Dimensions.paddingSizeExtraLarge * 1.5,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Main content row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Brand block
                      Expanded(
                        flex: 4,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Consumer<SplashProvider>(
                              builder: (context, splash, child) {
                                final appLogo = splash.configModel?.appLogo ?? '';
                                final ecommerceImageBase = splash.baseUrls?.ecommerceImageUrl ?? '';
                                final logoUrl = appLogo.isNotEmpty && ecommerceImageBase.isNotEmpty
                                    ? '$ecommerceImageBase/$appLogo'
                                    : '';

                                return Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  if (logoUrl.isNotEmpty) ...[
                                    SizedBox(
                                      width: _footerLogoSize,
                                      height: _footerLogoSize,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(Dimensions.radiusSizeDefault),
                                        child: CustomImageWidget(
                                          image: logoUrl,
                                          width: _footerLogoSize,
                                          height: _footerLogoSize,
                                          fit: BoxFit.contain,
                                          useShimmerPlaceholder: true,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: Dimensions.paddingSizeDefault),
                                  ],
                                  Flexible(
                                    child: Text(
                                      splash.configModel?.ecommerceName ??
                                          getAppName(context),
                                      style: rubikBold.copyWith(
                                        fontSize: 22,
                                        color: _footerTextWhite,
                                        letterSpacing: -0.5,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              );
                              },
                            ),
                            const SizedBox(height: Dimensions.paddingSizeLarge),
                            if (configModel.ecommerceAddress != null &&
                                configModel.ecommerceAddress!.isNotEmpty)
                              _FooterText(
                                text: configModel.ecommerceAddress!,
                                color: _footerTextMuted,
                                maxLines: 2,
                              ),
                            if (configModel.ecommercePhone != null &&
                                configModel.ecommercePhone!.isNotEmpty) ...[
                              const SizedBox(
                                  height: Dimensions.paddingSizeSmall),
                              _FooterText(
                                text: configModel.ecommercePhone!,
                                color: _footerTextMuted,
                              ),
                            ],
                            if (configModel.ecommerceEmail != null &&
                                configModel.ecommerceEmail!.isNotEmpty) ...[
                              const SizedBox(
                                  height: Dimensions.paddingSizeExtraSmall),
                              _FooterText(
                                text: configModel.ecommerceEmail!,
                                color: _footerTextMuted,
                              ),
                            ],
                          ],
                        ),
                      ),
                      // My Account
                      Expanded(
                        flex: 2,
                        child: _FooterColumn(
                          title: getTranslated('my_account', context),
                          links: accountQuickLink,
                          textColor: _footerTextWhite,
                          mutedColor: _footerTextMuted,
                        ),
                      ),
                      // Quick Links
                      Expanded(
                        flex: 2,
                        child: _FooterColumn(
                          title: getTranslated('quick_links', context),
                          links: otherQuickLink,
                          textColor: _footerTextWhite,
                          mutedColor: _footerTextMuted,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: Dimensions.paddingSizeExtraLarge),
                  // Divider
                  Divider(
                    height: 1,
                    thickness: 1,
                    color: Colors.white.withValues(alpha: 0.15),
                  ),
                  const SizedBox(height: Dimensions.paddingSizeLarge),
                  // Bottom row: developer credit (shared strip with web menu)
                  const Row(
                    children: [
                      Expanded(child: DeveloperCreditBarWidget()),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FooterText extends StatelessWidget {
  final String text;
  final Color color;
  final int maxLines;

  const _FooterText(
      {required this.text, required this.color, this.maxLines = 1});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: rubikRegular.copyWith(
        fontSize: Dimensions.fontSizeSmall,
        color: color,
      ),
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
    );
  }
}

class _FooterColumn extends StatelessWidget {
  final String title;
  final List<QuickLinkModel> links;
  final Color textColor;
  final Color mutedColor;

  const _FooterColumn({
    required this.title,
    required this.links,
    required this.textColor,
    required this.mutedColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: rubikSemiBold.copyWith(
            fontSize: Dimensions.fontSizeDefault,
            color: textColor,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: Dimensions.paddingSizeDefault),
        ...links.map(
          (link) => OnHover(
            child: TextHoverWidget(
              builder: (hovered) => Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: Dimensions.paddingSizeExtraSmall),
                child: InkWell(
                  onTap: () => link.route(),
                  borderRadius:
                      BorderRadius.circular(Dimensions.radiusSizeSmall),
                  child: Text(
                    link.title,
                    style: rubikRegular.copyWith(
                      fontSize: Dimensions.fontSizeSmall,
                      color: hovered ? Colors.white : mutedColor,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class QuickLinkModel {
  final String title;
  final Function route;

  QuickLinkModel({required this.title, required this.route});
}

class _FooterFormatter extends StatelessWidget {
  final Widget child;
  final FooterType footerType;
  const _FooterFormatter(
      {required this.child, required this.footerType});

  @override
  Widget build(BuildContext context) {
    return ResponsiveHelper.isDesktop(context)
        ? footerType == FooterType.nonSliver
            ? child
            : SliverFillRemaining(
                hasScrollBody: false,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const SizedBox(height: Dimensions.paddingSizeLarge),
                    child,
                  ],
                ),
              )
        : footerType == FooterType.sliver
            ? const SliverToBoxAdapter()
            : const SizedBox();
  }
}
