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
import 'package:provider/provider.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPopScopeWidget(
      child: Scaffold(
        appBar: ResponsiveHelper.isDesktop(context) ? const PreferredSize(preferredSize: Size.fromHeight(80), child: MainAppBarWidget()) : null,
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Center(
            child: SizedBox(
              width: Dimensions.webScreenWidth,
              child: Column(
                children: [
                  const SizedBox(height: 50),
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
                    style: rubikMedium.copyWith(color: Theme.of(context).textTheme.bodyMedium!.color, fontSize: 32),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                    child: Text(
                      '${getTranslated('welcome_to', context)} ${Provider.of<SplashProvider>(context).configModel?.ecommerceName}${getTranslated('please_login_or_signup', context)}',
                      textAlign: TextAlign.center,
                      style: rubikRegular.copyWith(color: Theme.of(context).textTheme.bodyMedium!.color!.withValues(alpha: 0.8)),
                    ),
                  ),
                  const SizedBox(height: 50),
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
                      backgroundColor: Colors.black,
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
                      TextSpan(text: '${getTranslated('login_as_a', context)} ', style: rubikRegular.copyWith(color: Theme.of(context).textTheme.bodyMedium!.color!.withValues(alpha: 0.8))),

                      TextSpan(text: getTranslated('guest', context), style: rubikMedium.copyWith(color: Theme.of(context).textTheme.bodyLarge!.color)),
                    ])),
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
