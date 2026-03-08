import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:hexacom_user/common/enums/footer_type_enum.dart';
import 'package:hexacom_user/common/models/config_model.dart';
import 'package:hexacom_user/common/models/userinfo_model.dart';
import 'package:hexacom_user/common/widgets/auth_background_widget.dart';
import 'package:hexacom_user/common/widgets/custom_alert_dialog_widget.dart';
import 'package:hexacom_user/common/widgets/custom_app_bar_widget.dart';
import 'package:hexacom_user/common/widgets/custom_pop_scope_widget.dart';
import 'package:hexacom_user/common/widgets/footer_web_widget.dart';
import 'package:hexacom_user/common/widgets/web_app_bar_widget.dart';
import 'package:hexacom_user/features/auth/domain/models/social_login_model.dart';
import 'package:hexacom_user/features/auth/domain/enums/social_login_options_enum.dart';
import 'package:hexacom_user/features/auth/providers/auth_provider.dart';
import 'package:hexacom_user/features/auth/widgets/existing_account_bottom_sheet.dart';
import 'package:hexacom_user/features/auth/widgets/social_login_widget.dart';
import 'package:hexacom_user/features/splash/providers/splash_provider.dart';
import 'package:hexacom_user/helper/auth_helper.dart';
import 'package:hexacom_user/helper/login_route_helper.dart';
import 'package:hexacom_user/helper/responsive_helper.dart';
import 'package:hexacom_user/localization/language_constrants.dart';
import 'package:hexacom_user/utill/app_constants.dart';
import 'package:hexacom_user/utill/dimensions.dart';
import 'package:hexacom_user/utill/images.dart';
import 'package:hexacom_user/utill/routes.dart';
import 'package:hexacom_user/utill/styles.dart';
import 'package:hexacom_user/utill/color_resources.dart';
import 'package:provider/provider.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class OnlySocialLoginWidget extends StatefulWidget {
  final String fromPage;
  const OnlySocialLoginWidget({super.key, required this.fromPage});



  @override
  State<OnlySocialLoginWidget> createState() => _OnlySocialLoginWidgetState();
}

class _OnlySocialLoginWidgetState extends State<OnlySocialLoginWidget> {


  void route(bool isRoute, String? token, String? errorMessage, String? tempToken, UserInfoModel? userInfoModel, String? socialLoginMedium, String? email, String? name) async {
    if (isRoute) {
      if(token != null){
        LoginRouteHelper.navigateToRoute(widget.fromPage);
      }else if(tempToken != null){
        RouteHelper.getOtpRegistrationScreen(context, tempToken, email ?? '', userName: name ?? '', action: RouteAction.push);

      } else if(userInfoModel != null){
        ResponsiveHelper.showDialogOrBottomSheet(
          context,
          CustomAlertDialogWidget(
            child: ExistingAccountBottomSheet(userInfoModel: userInfoModel, socialLoginMedium: socialLoginMedium!, socialUserName: name ?? '',),
          ),
        );
      }else{
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMessage ?? ''), backgroundColor: Theme.of(context).colorScheme.error));
      }
    }else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMessage ?? ''), backgroundColor: Theme.of(context).colorScheme.error));
    }
  }

  @override
  Widget build(BuildContext context) {

    final Size size = MediaQuery.sizeOf(context);
    final ConfigModel? configModel = Provider.of<SplashProvider>(context, listen: false).configModel;


    return CustomPopScopeWidget(
      child: Scaffold(
        backgroundColor: ColorResources.navBarNavy,
        appBar: ResponsiveHelper.isDesktop(context)? const PreferredSize(preferredSize: Size.fromHeight(120), child: WebAppBarWidget()) : PreferredSize(
          preferredSize: const Size.fromHeight(40),
          child: CustomAppBarWidget(
            isBackButtonExist: true,
            title: '',
            onBackPressed: (){
              if(Navigator.canPop(context)){
                Navigator.pop(context);
              }
            },
          ),
        ),
        body: AuthBackgroundWidget(
          child: SafeArea(child: Center(child: CustomScrollView(slivers: [

          if(ResponsiveHelper.isDesktop(context))...[
            SliverToBoxAdapter(child: SizedBox(height: size.height * 0.05)),
          ],

          SliverToBoxAdapter(child: Column(children: [


            Center(child: Container(
              width: size.width > 700 ? 400 : (size.width - (Dimensions.paddingSizeDefault * 2)),
              margin: EdgeInsets.only(
                top: Dimensions.paddingSizeLarge,
                left: size.width > 700 ? 0 : Dimensions.paddingSizeDefault,
                right: size.width > 700 ? 0 : Dimensions.paddingSizeDefault,
                bottom: size.width > 700 ? 0 : Dimensions.paddingSizeLarge,
              ),
              padding: size.width > 700
                  ? const EdgeInsets.all(Dimensions.paddingSizeDefault)
                  : const EdgeInsets.symmetric(
                      horizontal: Dimensions.paddingSizeLarge,
                      vertical: Dimensions.paddingSizeDefault,
                    ),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).shadowColor.withValues(alpha: size.width > 700 ? 0.07 : 0.08),
                    blurRadius: size.width > 700 ? 30 : 16,
                    spreadRadius: 0,
                    offset: Offset(0, size.width > 700 ? 10 : 4),
                  ),
                ],
              ),
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [

                SizedBox(
                  height: ResponsiveHelper.isDesktop(context) ? size.height * 0.04 : 20,
                ),

                if (!ResponsiveHelper.isDesktop(context))
                  Center(
                    child: Image.asset(
                      Images.logo,
                      height: ResponsiveHelper.isDesktop(context) ? 100.0 : 64,
                      fit: BoxFit.scaleDown,
                      matchTextDirection: true,
                    ),
                  )
                else
                  const SizedBox.shrink(),
                const SizedBox(height: Dimensions.paddingSizeLarge),

                Column(
                  children: [
                    Text(
                      getTranslated('login', context),
                      style: rubikBold.copyWith(
                        fontSize: Dimensions.fontSizeExtraLarge,
                        color: ColorResources.getTextColor(context),
                      ),
                    ),
                    const SizedBox(height: Dimensions.paddingSizeSmall),
                    Text(
                      getTranslated('please_login_or_signup', context),
                      textAlign: TextAlign.center,
                      style: rubikRegular.copyWith(
                        fontSize: Dimensions.fontSizeDefault,
                        color: ColorResources.getTextColor(context).withValues(alpha: 0.75),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: Dimensions.paddingSizeExtraLarge),

                const SizedBox(height: Dimensions.paddingSizeExtraLarge),

                if(AuthHelper.isGoogleLoginEnable(configModel))...[
                  Row(children: [

                    Expanded(child: Container()),

                    Expanded(flex: 4,
                      child: Consumer<AuthProvider>(builder: (context, authProvider, child) {
                        return InkWell(
                          onTap: ()async{
                            try{

                              if(authProvider.googleAccount != null){
                                await authProvider.googleSignOut();
                              }

                              SocialLoginModel socialLoginModel;

                              if(kIsWeb){
                                socialLoginModel = await authProvider.googleWebSignIn();
                              }else{
                                socialLoginModel = await authProvider.googleLogin();
                              }

                              authProvider.socialLogin(
                                socialLoginModel,
                                route,
                              );


                            }catch(er){
                              debugPrint('access token error is : $er');
                            }
                          },
                          child: SocialButtonView(
                            image: Images.google,
                            text: getTranslated('continue_with_google', context),
                          ),
                        );
                      }),
                    ),

                    Expanded(child: Container()),

                  ]),
                  const SizedBox(height: Dimensions.paddingSizeLarge),
                ],

                if(AuthHelper.isFacebookLoginEnable(configModel))...[
                  Row(children: [

                    Expanded(child: Container()),

                    Expanded(flex: 4,
                      child: Consumer<AuthProvider>(builder: (context, authProvider, child) {
                        return InkWell(
                          onTap: () async{
                            LoginResult result = await FacebookAuth.instance.login();

                            if (result.status == LoginStatus.success) {
                              Map userData = await FacebookAuth.instance.getUserData(fields: 'name, email');

                              authProvider.socialLogin(
                                SocialLoginModel(
                                  email: userData['email'],
                                  token: result.accessToken!.tokenString,
                                  uniqueId: userData['id'],
                                  medium: SocialLoginOptionsEnum.facebook.name,
                                  name: userData['name'],
                                ), route,
                              );
                            }
                          },
                          child: SocialButtonView(
                            text: getTranslated('continue_with_facebook', context),
                            image: Images.facebookSocial,
                          ),
                        );
                      }),
                    ),

                    Expanded(child: Container()),

                  ]),
                  const SizedBox(height: Dimensions.paddingSizeLarge),
                ],

                if(AuthHelper.isAppleLoginEnable(configModel))...[
                  Row(children: [

                    Expanded(child: Container()),

                    Expanded(flex: 4,
                      child: Consumer<AuthProvider>(builder: (context, authProvider, child) {
                        return InkWell(
                          onTap: () async {
                            final credential = await SignInWithApple.getAppleIDCredential(scopes: [
                              AppleIDAuthorizationScopes.email,
                              AppleIDAuthorizationScopes.fullName,
                            ],
                              webAuthenticationOptions: WebAuthenticationOptions(
                                clientId: '${configModel?.appleLogin?.clientId}',
                                redirectUri: Uri.parse(AppConstants.baseUrl),
                              ),
                            );
                            authProvider.socialLogin(SocialLoginModel(
                                email: credential.email, token: credential.authorizationCode, uniqueId: credential.authorizationCode, medium: SocialLoginOptionsEnum.apple.name,
                                name: credential.givenName ?? credential.familyName
                            ), route);
                          },
                          child: SocialButtonView(
                            text: getTranslated('continue_with_apple', context),
                            image: Images.appleLogo,
                            color: Theme.of(context).textTheme.bodyMedium?.color,
                          ),
                        );
                      }),
                    ),

                    Expanded(child: Container()),

                  ]),
                  const SizedBox(height: Dimensions.paddingSizeLarge),
                ],

                // if(configModel?.isGuestCheckout == true && !Navigator.canPop(context))...[
                //   Center(child: Text(
                //     getTranslated('or', context),
                //     style: poppinsRegular.copyWith(
                //       fontSize: Dimensions.fontSizeDefault,
                //       color: Theme.of(context).hintColor,
                //     ),
                //   )),
                //   const SizedBox(height: Dimensions.paddingSizeSmall),
                //
                //   Center(child: InkWell(
                //     //onTap: ()=> RouterHelper.getDashboardRoute('home', ),
                //     child: RichText(text: TextSpan(children: [
                //
                //       TextSpan(text: '${getTranslated('continue_as_a', context)} ',
                //         style: poppinsRegular.copyWith(
                //           fontSize: Dimensions.fontSizeSmall,
                //           color: Theme.of(context).hintColor,
                //         ),
                //       ),
                //
                //       TextSpan(text: getTranslated('guest', context),
                //         style: poppinsRegular.copyWith(
                //           color: Theme.of(context).primaryColor,
                //         ),
                //       ),
                //
                //     ])),
                //   )),
                //   SizedBox(height: size.height * 0.03),
                // ],

                if(ResponsiveHelper.isDesktop(context))...[
                  SizedBox(height: size.height * 0.05),
                ],


              ]),
            )),

            // if(ResponsiveHelper.isDesktop(context)) const SizedBox(height: 50),

          ])),

          if(ResponsiveHelper.isDesktop(context))...[
            SliverToBoxAdapter(child: SizedBox(height: size.height * 0.05)),
          ],

          if(ResponsiveHelper.isDesktop(context)) const SliverFillRemaining(
            hasScrollBody: false,
            child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [

              SizedBox(height: Dimensions.paddingSizeLarge),

              FooterWebWidget(footerType: FooterType.nonSliver),

            ]),
          ),

        ]))),
      ),
      ),
    );
  }
}

