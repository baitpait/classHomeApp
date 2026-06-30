import 'package:hexacom_user/common/enums/footer_type_enum.dart';
import 'package:hexacom_user/common/models/config_model.dart';
import 'package:hexacom_user/features/auth/domain/enums/from_page_enum.dart';
import 'package:hexacom_user/features/auth/domain/enums/verification_type_enum.dart';
import 'package:hexacom_user/features/auth/domain/models/user_log_data.dart';
import 'package:hexacom_user/features/auth/screens/only_social_login_widget.dart';
import 'package:hexacom_user/features/auth/screens/send_otp_screen.dart';
import 'package:hexacom_user/features/auth/widgets/social_login_widget.dart';
import 'package:hexacom_user/helper/auth_helper.dart';
import 'package:hexacom_user/utill/feature_flags.dart';
import 'package:hexacom_user/helper/phone_number_checker_helper.dart';
import 'package:hexacom_user/helper/responsive_helper.dart';
import 'package:hexacom_user/localization/language_constrants.dart';
import 'package:hexacom_user/features/auth/providers/auth_provider.dart';
import 'package:hexacom_user/features/splash/providers/splash_provider.dart';
import 'package:hexacom_user/utill/dimensions.dart';
import 'package:hexacom_user/utill/images.dart';
import 'package:hexacom_user/helper/login_route_helper.dart';
import 'package:hexacom_user/utill/routes.dart';
import 'package:hexacom_user/utill/styles.dart';
import 'package:hexacom_user/utill/color_resources.dart';
import 'package:hexacom_user/common/widgets/custom_button_widget.dart';
import 'package:hexacom_user/common/widgets/custom_image_widget.dart';
import 'package:hexacom_user/common/widgets/custom_shadow_widget.dart';
import 'package:hexacom_user/helper/custom_snackbar_helper.dart';
import 'package:hexacom_user/common/widgets/custom_text_field_widget.dart';
import 'package:hexacom_user/common/widgets/auth_background_widget.dart';
import 'package:hexacom_user/common/widgets/custom_pop_scope_widget.dart';
import 'package:hexacom_user/common/widgets/footer_web_widget.dart';
import 'package:hexacom_user/common/widgets/web_app_bar_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  final String fromPage;
  const LoginScreen({super.key, required this.fromPage});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  final FocusNode _phoneNumberFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  TextEditingController? _phoneController;
  TextEditingController? _passwordController;
  GlobalKey<FormState>? _formKeyLogin;
  String? _countryDialCode;
  bool _countryCodeFromConfig = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_){
      FocusScope.of(context).requestFocus(_phoneNumberFocus);
    });


    final AuthProvider authProvider = context.read<AuthProvider>();
    final SplashProvider splashProvider = context.read<SplashProvider>();

    authProvider.setCountSocialLoginOptions(isReload: true);
    int count = AuthHelper.countSocialLoginOptions(splashProvider.configModel);
    authProvider.setCountSocialLoginOptions(count: count, isReload: false);

    _formKeyLogin = GlobalKey<FormState>();
    _phoneController = TextEditingController();
    _passwordController = TextEditingController();

    UserLogData? userData = authProvider.getUserData();

    _phoneNumberFocus.addListener(() {
      setState(() {});
    });

    if(userData != null && userData.loginType == FromPage.login.name) {
      if(userData.phoneNumber != null){
        _phoneController!.text = PhoneNumberCheckerHelper.getPhoneNumber(userData.phoneNumber ?? '', userData.countryCode ?? '') ?? '';
        authProvider.toggleIsNumberLogin(value: true, isUpdate: false);
        _countryDialCode = '+972';
      }
      _passwordController?.text = userData.password ?? '';
    }else{
      _countryCodeFromConfig = true;
      // ConfigModel may still be null (especially on web/hot-restart). We'll derive the dial code in build().
      _countryDialCode = null;
    }
  }

  @override
  void dispose() {
    _phoneController!.dispose();
    _passwordController!.dispose();
    _phoneNumberFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.sizeOf(context);

    return Selector<SplashProvider, ConfigModel?>(
      selector: (ctx, splashProvider)=> splashProvider.configModel,
      builder: (context, configModel, _){

        if (configModel == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if(_countryCodeFromConfig) {
          _countryDialCode = '+972'; // مقدمة ثابتة لكل المتجر
        }


        if(!FeatureFlags.hideSocialLogin && !AuthHelper.isManualLoginEnable(configModel) && !AuthHelper.isOtpLoginEnable(configModel)){
          return OnlySocialLoginWidget(fromPage: widget.fromPage);
        }else if(!AuthHelper.isManualLoginEnable(configModel)){
          return SendOtpScreen(fromPage: widget.fromPage);
        }else{
          return CustomPopScopeWidget(
            child: Scaffold(
              backgroundColor: ColorResources.navBarNavy,
              appBar: ResponsiveHelper.isDesktop(context) ? const PreferredSize(preferredSize: Size.fromHeight(90), child: WebAppBarWidget()) : null,
              body: AuthBackgroundWidget(
                child: SafeArea(child: CustomScrollView(
                physics: ResponsiveHelper.isDesktop(context) ? null : const BouncingScrollPhysics(),
                slivers: [
                SliverToBoxAdapter(child: Center(
                  child: Consumer<SplashProvider>(builder: (context, splashProvider, _){
                    final bool isDesktop = ResponsiveHelper.isDesktop(context);
                    return SizedBox(
                      width: isDesktop ? 450 : (size.width - (Dimensions.paddingSizeDefault * 2)),
                      height: isDesktop ? null : size.height,
                      child: Column(
                        mainAxisSize: isDesktop ? MainAxisSize.min : MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [

                        if(isDesktop)...[
                          SizedBox(height: size.height * 0.04)
                        ],

                        Center(child: CustomShadowWidget(
                          boxShadow: isDesktop
                              ? BoxShadow(
                                  offset: const Offset(0,10),
                                  blurRadius: 30,
                                  spreadRadius: 0,
                                  color: Theme.of(context).textTheme.bodyMedium!.color!.withValues(alpha: 0.07),
                                )
                              : BoxShadow(
                                  offset: const Offset(0, 4),
                                  blurRadius: 16,
                                  spreadRadius: 0,
                                  color: Theme.of(context).shadowColor.withValues(alpha: 0.08),
                                ),
                          shadowColor: null,
                          padding: EdgeInsets.symmetric(
                            horizontal: isDesktop ? 50 : Dimensions.paddingSizeLarge,
                            vertical: isDesktop ? Dimensions.paddingSizeLarge : Dimensions.paddingSizeDefault,
                          ),
                          child: Consumer<AuthProvider>(
                            builder: (context, authProvider, child) {
                              final fontFamily = Theme.of(context).textTheme.bodyLarge?.fontFamily;
                              return Form(
                              key: _formKeyLogin,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // SizedBox(height: 30),
                                  !ResponsiveHelper.isDesktop(context)
                                      ? Center(
                                          child: Consumer<SplashProvider>(
                                            builder: (context, splashProvider, _) {
                                              final logoPath = splashProvider.configModel?.appLogo ?? '';
                                              final logoUrl = (splashProvider.baseUrls != null && logoPath.isNotEmpty)
                                                  ? '${splashProvider.baseUrls!.ecommerceImageUrl}/$logoPath'
                                                  : '';

                                              if (logoUrl.isEmpty) return const SizedBox.shrink();

                                              return CustomImageWidget(
                                                image: logoUrl,
                                                height: ResponsiveHelper.isDesktop(context) ? 100.0 : 64,
                                                fit: BoxFit.contain,
                                              );
                                            },
                                          ),
                                        )
                                      : const SizedBox.shrink(),
                                  SizedBox(height: ResponsiveHelper.isDesktop(context) ? size.height * 0.03 : Dimensions.paddingSizeSmall),
                                  Center(
                                    child: Column(
                                      children: [
                                        Text(
                                          getTranslated('login', context),
                                          style: rubikMedium.copyWith(
                                            fontSize: Dimensions.fontSizeOverLarge,
                                            fontFamily: fontFamily,
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
                                            fontFamily: fontFamily,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: ResponsiveHelper.isDesktop(context) ? size.height * 0.03 : Dimensions.paddingSizeDefault),

                                  RichText(
                                    text: TextSpan(
                                      style: rubikMedium.copyWith(
                                        color: Theme.of(context).textTheme.bodyLarge?.color,
                                        fontFamily: fontFamily,
                                      ),
                                      children: [
                                        TextSpan(
                                          text: getTranslated('whatsapp_mobile_number', context),
                                        ),
                                        TextSpan(
                                          text: ' *',
                                          style: TextStyle(
                                            color: Theme.of(context).colorScheme.error,
                                            fontFamily: fontFamily,
                                            fontWeight: FontWeight.w500,
                                            fontSize: Dimensions.fontSizeDefault,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(Dimensions.radiusSizeDefault),
                                      border: Border.all(
                                        color: _phoneNumberFocus.hasFocus
                                            ? Theme.of(context).primaryColor.withValues(alpha: 0.5)
                                            : Theme.of(context).hintColor.withValues(alpha: 0.2),
                                        width: 1,
                                      ),
                                    ),
                                    child: Row(children: [
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
                                        child: Text('+972', style: TextStyle(color: Theme.of(context).textTheme.displayLarge!.color)),
                                      ),
                                      Container(
                                        width: 1,
                                        height: Dimensions.paddingSizeExtraLarge,
                                        color: Theme.of(context).dividerColor,
                                      ),
                                      Expanded(
                                        child: CustomTextFieldWidget(
                                          borderColor: Colors.transparent,
                                          hintText: getTranslated('enter_whatsapp_mobile_number', context),
                                          isShowBorder: true,
                                          controller: _phoneController,
                                          focusNode: _phoneNumberFocus,
                                          nextFocus: _passwordFocus,
                                          inputType: TextInputType.phone,
                                        ),
                                      ),
                                    ]),
                                  ),
                                  const SizedBox(height: Dimensions.paddingSizeLarge),


                                  CustomTextFieldWidget(

                                    hintText: getTranslated('6+character', context),
                                    title: getTranslated('password', context),
                                    isShowBorder: true,
                                    isPassword: true,
                                    isRequired: true,
                                    isShowSuffixIcon: true,
                                    isShowPrefixIcon: true,
                                    prefixAssetUrl: Images.password,
                                    focusNode: _passwordFocus,
                                    controller: _passwordController,
                                    inputAction: TextInputAction.done,
                                    prefixAssetImageColor: Theme.of(context).hintColor,

                                  ),
                                  const SizedBox(height: Dimensions.paddingSizeLarge),

                                  // for remember me section
                                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [

                                    Consumer<AuthProvider>(
                                      builder: (context, authProvider, child) => InkWell(
                                        onTap: ()=> authProvider.toggleRememberMe(),
                                        child: Row(
                                          children: [
                                            Container(
                                              width: 18,
                                              height: 18,
                                              decoration: BoxDecoration(
                                                color: authProvider.isActiveRememberMe
                                                    ? ColorResources.primary
                                                    : Theme.of(context).cardColor,
                                                border: Border.all(
                                                  color: authProvider.isActiveRememberMe
                                                      ? Colors.transparent
                                                      : ColorResources.primary,
                                                ),
                                                borderRadius: BorderRadius.circular(3),
                                              ),
                                              child: authProvider.isActiveRememberMe
                                                  ? const Icon(Icons.done, color: Colors.white, size: 17)
                                                  : const SizedBox.shrink(),
                                            ),
                                            const SizedBox(width: Dimensions.paddingSizeSmall),

                                            Text(
                                              getTranslated('remember_me', context),
                                              style: rubikRegular.copyWith(fontSize: Dimensions.fontSizeSmall, fontFamily: fontFamily),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),

                                    InkWell(
                                        onTap: ()=> RouteHelper.getForgetPassRoute(context, action: RouteAction.push),
                                        child: Padding(padding: const EdgeInsets.all(8.0),
                                          child: Text('${getTranslated('forgot_password', context)} ?',
                                            style: rubikRegular.copyWith(
                                              fontSize: Dimensions.fontSizeSmall,
                                              color: Theme.of(context).colorScheme.error,
                                              fontFamily: fontFamily,
                                            ),
                                          ),
                                        )
                                    )

                                  ]),
                                  const SizedBox(height: Dimensions.paddingSizeLarge),

                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      authProvider.loginErrorMessage!.isNotEmpty
                                          ? const CircleAvatar(backgroundColor: Colors.red, radius: 5)
                                          : const SizedBox.shrink(),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          authProvider.loginErrorMessage ?? "",
                                          style: rubikMedium.copyWith(
                                            fontSize: Dimensions.fontSizeSmall,
                                            color: Theme.of(context).colorScheme.error,
                                            fontFamily: fontFamily,
                                          ),
                                        ),
                                      )
                                    ],
                                  ),

                                  if(authProvider.loginErrorMessage!.isNotEmpty)
                                    const SizedBox(height: Dimensions.paddingSizeSmall),

                                  // for login button
                                  CustomButtonWidget(
                                    isLoading: authProvider.isLoading,
                                    btnTxt: getTranslated('login', context),
                                    onTap: () async {
                                      final AuthProvider authProvider = Provider.of<AuthProvider>(context, listen: false);

                                      String userInput = _phoneController?.text.trim() ?? '';
                                      String password = _passwordController?.text.trim() ?? '';


                                      if (userInput.isEmpty) {
                                        showCustomSnackBar(getTranslated('enter_whatsapp_mobile_number', context), context);
                                      }else if (password.isEmpty) {
                                        showCustomSnackBar(getTranslated('enter_password', context), context);
                                      }else if (password.length < 6) {
                                        showCustomSnackBar(getTranslated('password_should_be', context), context);
                                      }else {

                                        final dialCode = (_countryDialCode ?? '').trim();
                                        if (dialCode.isEmpty) {
                                          showCustomSnackBar(getTranslated('select_your_country_code', context), context);
                                          return;
                                        }

                                        userInput = dialCode + userInput;
                                        String type = VerificationType.phone.name;

                                        await authProvider.login(context, userInput, password, type, fromPage: FromPage.login.name).then((status) async {

                                          if (status.isSuccess) {
                                            if (authProvider.isActiveRememberMe) {
                                              authProvider.saveUserData(UserLogData(
                                                countryCode:  _countryDialCode,
                                                phoneNumber: userInput,
                                                email: null,
                                                password: password,
                                                loginType: FromPage.login.name,
                                              ));
                                            }else {
                                              authProvider.clearUserData();
                                            }
                                            LoginRouteHelper.navigateToRoute(widget.fromPage);
                                          }

                                        });
                                      }
                                    },
                                  ),
                                  const SizedBox(height: Dimensions.paddingSizeLarge),

                                  if(AuthHelper.isOtpOrSocialLoginEnable(splashProvider.configModel))...[
                                    Center(child: Text(getTranslated('or', context),
                                      style: rubikRegular.copyWith(
                                        fontSize: Dimensions.fontSizeSmall,
                                        fontFamily: fontFamily,
                                      ),
                                    )),
                                    const SizedBox(height: Dimensions.paddingSizeDefault),

                                    if(AuthHelper.isOtpLoginEnable(splashProvider.configModel))...[
                                      Row(mainAxisAlignment: MainAxisAlignment.center, children: [

                                        Text(getTranslated('login_with', context),
                                          style: rubikRegular.copyWith(
                                            fontSize: Dimensions.fontSizeSmall,
                                            color: Theme.of(context).hintColor,
                                            fontFamily: fontFamily,
                                          ),
                                        ),
                                        const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                                        InkWell(
                                          onTap: () => RouteHelper.getSendOtpScreen(context, widget.fromPage, action: RouteAction.push),
                                          child: Text(getTranslated('otp', context),
                                            style: rubikRegular.copyWith(
                                              fontSize: Dimensions.fontSizeDefault,
                                              decoration: TextDecoration.underline,
                                              decorationColor: Theme.of(context).primaryColor,
                                              color: Theme.of(context).primaryColor,
                                              fontFamily: fontFamily,
                                            ),
                                          ),
                                        ),

                                      ]),
                                      const SizedBox(height: Dimensions.paddingSizeDefault),
                                    ],

                                    if(!FeatureFlags.hideSocialLogin && AuthHelper.isSocialMediaLoginEnable(splashProvider.configModel)
                                        && ((AuthHelper.isFacebookLoginEnable(splashProvider.configModel)
                                            || AuthHelper.isGoogleLoginEnable(splashProvider.configModel) || AuthHelper.isAppleLoginEnable(splashProvider.configModel))))...[

                                       Center(child: SocialLoginWidget(fromPage: widget.fromPage)),
                                      const SizedBox(height: Dimensions.paddingSizeLarge),
                                    ],
                                  ],

                                  // for create an account

                                  Center(child: InkWell(
                                    onTap: () => RouteHelper.getCreateAccountRoute(context, widget.fromPage, action: RouteAction.push),
                                    child: RichText(text: TextSpan(children: [
                                      TextSpan(text: getTranslated('do_not_have_an_account', context),  style: rubikRegular.copyWith(
                                        color: Theme.of(context).hintColor.withValues(alpha: 0.8),
                                        fontFamily: fontFamily,
                                      )),

                                      TextSpan(text: ' ${getTranslated('sign_up', context)}', style: rubikMedium.copyWith(
                                        color: Theme.of(context).primaryColor,
                                        decoration: TextDecoration.underline,
                                        fontFamily: fontFamily,
                                      )),

                                    ])),
                                  )),
                                  const SizedBox(height: Dimensions.paddingSizeSmall),

                                  if(!ResponsiveHelper.isDesktop(context))...[
                                    Center(child: InkWell(
                                      onTap: ()=> RouteHelper.getDashboardRoute(context, 'home', action: RouteAction.pushReplacement),
                                      child: RichText(text: TextSpan(children: [
                                        TextSpan(text: '${getTranslated('continue_as_a', context)} ',  style: rubikRegular.copyWith(
                                          color: Theme.of(context).hintColor.withValues(alpha: 0.8),
                                          fontFamily: fontFamily,
                                        )),

                                        TextSpan(text: getTranslated('guest', context), style: rubikMedium.copyWith(
                                          color: Theme.of(context).primaryColor,
                                          decoration: TextDecoration.underline,
                                          fontFamily: fontFamily,
                                        )),

                                      ])),
                                    )),
                                  ],

                                  if(ResponsiveHelper.isDesktop(context))...[
                                    SizedBox(height: size.height * 0.02),
                                  ],


                                ],
                              ),
                            );
                            },
                          ),
                        )),

                        if(ResponsiveHelper.isDesktop(context))...[
                          SizedBox(height: size.height * 0.02),
                        ],
                        if(!ResponsiveHelper.isDesktop(context))
                          SizedBox(height: MediaQuery.paddingOf(context).bottom + 24),

                        ],
                      ),
                    );
                  }),
                )),

                if(ResponsiveHelper.isDesktop(context)) const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [

                    SizedBox(height: Dimensions.paddingSizeLarge),
                    FooterWebWidget(footerType: FooterType.nonSliver),

                  ]),
                ),

              ],
              )),
              ),
            ),
          );
        }
      },
    );




  }
}
