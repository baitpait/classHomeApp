import 'package:hexacom_user/common/widgets/custom_image_widget.dart';
import 'package:hexacom_user/common/widgets/custom_pop_scope_widget.dart';
import 'package:flutter/material.dart';
import 'package:hexacom_user/features/auth/domain/enums/from_page_enum.dart';
import 'package:hexacom_user/helper/responsive_helper.dart';
import 'package:hexacom_user/localization/language_constrants.dart';
import 'package:hexacom_user/features/splash/providers/splash_provider.dart';
import 'package:hexacom_user/utill/dimensions.dart';
import 'package:hexacom_user/utill/images.dart';
import 'package:hexacom_user/utill/routes.dart';
import 'package:hexacom_user/utill/styles.dart';
import 'package:hexacom_user/common/widgets/custom_button_widget.dart';
import 'package:hexacom_user/common/widgets/main_app_bar_widget.dart';
import 'package:hexacom_user/utill/color_resources.dart';
import 'package:provider/provider.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPopScopeWidget(
      child: Scaffold(
        appBar: ResponsiveHelper.isDesktop(context) ? const PreferredSize(preferredSize: Size.fromHeight(80), child: MainAppBarWidget()) : null,
        backgroundColor: ColorResources.getFlashSaleSectionBackground(context),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Center(
            child: SizedBox(
              width: Dimensions.webScreenWidth,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: Dimensions.paddingSizeDefault,
                  vertical: Dimensions.paddingSizeLarge,
                ),
                child: Container(
                  padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: ColorResources.primary.withValues(alpha: 0.08),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                    border: Border.all(
                      color: ColorResources.lightGray.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 30),
                      Container(
                        alignment: Alignment.bottomCenter,
                        padding: const EdgeInsets.all(30),
                        child: ResponsiveHelper.isWeb() ? Consumer<SplashProvider>(
                          builder:(context, splash, child) => CustomImageWidget(
                            image: splash.baseUrls != null ? '${splash.baseUrls!.ecommerceImageUrl}/${splash.configModel!.appLogo}' : '',
                            height: 200,
                          ),
                        ) : Image.asset(Images.logo, height: 200),
                      ),
                      const SizedBox(height: 30),
                      Text(
                        getTranslated('welcome', context),
                        textAlign: TextAlign.center,
                        style: rubikBold.copyWith(
                          color: ColorResources.getTextColor(context),
                          fontSize: Dimensions.fontSizeThirty,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                        child: Text(
                          '${getTranslated('welcome_to', context)} ${Provider.of<SplashProvider>(context).configModel?.ecommerceName}${getTranslated('please_login_or_signup', context)}',
                          textAlign: TextAlign.center,
                          style: rubikRegular.copyWith(
                            color: ColorResources.getGreyColor(context),
                            fontSize: Dimensions.fontSizeDefault,
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                      Padding(
                        padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                        child: CustomButtonWidget(
                          btnTxt: getTranslated('login', context),
                          onTap: () {
                            RouteHelper.getLoginRoute(context, FromPage.mainRoute.name, action: RouteAction.pushReplacement);
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            left: Dimensions.paddingSizeDefault,
                            right: Dimensions.paddingSizeDefault,
                            bottom: Dimensions.paddingSizeDefault,
                            top: 12),
                        child: CustomButtonWidget(
                          btnTxt: getTranslated('signup', context),
                          onTap: () {
                            RouteHelper.getCreateAccountRoute(context, FromPage.mainRoute.name, action: RouteAction.push);
                          },
                          backgroundColor: ColorResources.secondary,
                        ),
                      ),
                      TextButton(
                        style: TextButton.styleFrom(
                          minimumSize: const Size(1, 40),
                        ),
                        onPressed: () {
                          RouteHelper.getMainRoute(context, action: RouteAction.pushReplacement);
                        },
                        child: RichText(text: TextSpan(children: [
                          TextSpan(
                            text: '${getTranslated('login_as_a', context)} ',
                            style: rubikRegular.copyWith(
                              color: ColorResources.getGreyColor(context),
                            ),
                          ),
                          TextSpan(
                            text: getTranslated('guest', context),
                            style: rubikMedium.copyWith(
                              color: ColorResources.primary,
                            ),
                          ),
                        ])),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
