import 'package:flutter/material.dart';
import 'package:hexacom_user/common/enums/footer_type_enum.dart';
import 'package:hexacom_user/common/models/config_model.dart';
import 'package:hexacom_user/common/widgets/auth_background_widget.dart';
import 'package:hexacom_user/common/widgets/custom_app_bar_widget.dart';
import 'package:hexacom_user/common/widgets/custom_button_widget.dart';
import 'package:hexacom_user/common/widgets/custom_pop_scope_widget.dart';
import 'package:hexacom_user/common/widgets/custom_text_field_widget.dart';
import 'package:hexacom_user/common/widgets/footer_web_widget.dart';
import 'package:hexacom_user/common/widgets/web_app_bar_widget.dart';
import 'package:hexacom_user/features/auth/domain/enums/verification_type_enum.dart';
import 'package:hexacom_user/features/auth/domain/enums/from_page_enum.dart';
import 'package:hexacom_user/features/auth/domain/models/user_log_data.dart';
import 'package:hexacom_user/features/auth/providers/auth_provider.dart';
import 'package:hexacom_user/features/auth/providers/verification_provider.dart';
import 'package:hexacom_user/features/auth/widgets/social_login_widget.dart';
import 'package:hexacom_user/utill/feature_flags.dart';
import 'package:hexacom_user/features/splash/providers/splash_provider.dart';
import 'package:hexacom_user/helper/auth_helper.dart';
import 'package:hexacom_user/helper/custom_snackbar_helper.dart';
import 'package:hexacom_user/helper/phone_number_checker_helper.dart';
import 'package:hexacom_user/helper/responsive_helper.dart';
import 'package:hexacom_user/localization/language_constrants.dart';
import 'package:hexacom_user/utill/dimensions.dart';
import 'package:hexacom_user/utill/images.dart';
import 'package:hexacom_user/utill/styles.dart';
import 'package:hexacom_user/utill/color_resources.dart';
import 'package:provider/provider.dart';

class SendOtpScreen extends StatefulWidget {
  final String fromPage;
  const SendOtpScreen({super.key, required this.fromPage});


  @override
  State<SendOtpScreen> createState() => _SendOtpScreenState();
}

class _SendOtpScreenState extends State<SendOtpScreen> {

  String? countryCode;
  TextEditingController? _phoneNumberController;

  @override
  void initState() {
    super.initState();
    _phoneNumberController = TextEditingController();

    final AuthProvider authProvider =  Provider.of<AuthProvider>(context, listen: false);

    UserLogData? userData = authProvider.getUserData();
    if(userData != null && userData.loginType == FromPage.otp.name) {
      if(userData.phoneNumber != null){
        _phoneNumberController!.text = PhoneNumberCheckerHelper.getPhoneNumber(userData.phoneNumber ?? '', userData.countryCode ?? '') ?? '';
      }
    }
    countryCode = '+972'; // مقدمة ثابتة لكل المتجر

  }

  @override
  Widget build(BuildContext context) {

    final Size size = MediaQuery.sizeOf(context);
    final ConfigModel configModel = Provider.of<SplashProvider>(context, listen: false).configModel!;

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
          child: SafeArea(
            child: Center(
              child: CustomScrollView(slivers: [

              SliverToBoxAdapter(child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [

                if(ResponsiveHelper.isDesktop(context))
                  SizedBox(height: size.width * 0.02),

                Center(child: Container(
                  width: size.width > 700 ? 450 : (size.width - (Dimensions.paddingSizeDefault * 2)),
                  margin: EdgeInsets.only(
                    top: size.width > 700 ? Dimensions.paddingSizeLarge : 24,
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
                  child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [

                    SizedBox(height: ResponsiveHelper.isDesktop(context) ? size.height * 0.02 : 20),

                    if(!ResponsiveHelper.isDesktop(context))...[
                      Directionality(
                        textDirection: TextDirection.ltr,
                        child: Image.asset(
                          Images.logo,
                          height: ResponsiveHelper.isDesktop(context)
                              ? MediaQuery.sizeOf(context).height * 0.15
                              : 64,
                          fit: BoxFit.scaleDown,
                        ),
                      ),
                    ],
                    const SizedBox(height: Dimensions.paddingSizeDefault),

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
                          getTranslated('enter_phone_number', context),
                          textAlign: TextAlign.center,
                          style: rubikRegular.copyWith(
                            fontSize: Dimensions.fontSizeDefault,
                            color: ColorResources.getTextColor(context).withValues(alpha: 0.75),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: size.height * 0.04),



                    Row(children: [

                      Expanded(child: Container()),

                      Expanded(flex: 7, child: Column(children: [

                        CustomTextFieldWidget(
                          fixedCountryCode: '+972',
                          hintText: getTranslated('enter_phone_number_with_country_code', context),
                          isShowBorder: true,
                          controller: _phoneNumberController,
                          inputType: TextInputType.phone,
                          title: getTranslated('mobile_number', context),
                        ),
                        SizedBox(height: size.height * 0.03),

                        Consumer<AuthProvider>(builder: (context, authProvider, child) {
                          return InkWell(
                            splashColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            onTap: ()=> authProvider.toggleRememberMe(),
                            child: Row(children: [

                              Container(
                                width: 18,
                                height: 18,
                                decoration: BoxDecoration(
                                  color: authProvider.isActiveRememberMe ? ColorResources.primary : Theme.of(context).cardColor,
                                  border: Border.all(
                                    color: authProvider.isActiveRememberMe ? Colors.transparent : ColorResources.primary,
                                  ),
                                  borderRadius: BorderRadius.circular(3),
                                ),
                                child: authProvider.isActiveRememberMe
                                    ? const Icon(Icons.done, color: Colors.white, size: 17)
                                    : const SizedBox.shrink(),
                              ),
                              const SizedBox(width: Dimensions.paddingSizeSmall),

                              Text(getTranslated('remember_me', context),
                                style: Theme.of(context).textTheme.displayMedium!.copyWith(
                                  fontSize: Dimensions.fontSizeExtraSmall,
                                  color: Theme.of(context).textTheme.bodyMedium?.color,
                                ),
                              ),

                            ]),
                          );
                        }),
                        SizedBox(height: size.height * 0.03),

                        Selector<VerificationProvider, bool>(
                          selector: (context, verificationProvider) => verificationProvider.isLoading,
                          builder: (context, isLoading, child) {
                            return CustomButtonWidget(
                              isLoading: isLoading,
                              btnTxt: getTranslated('get_otp', context),
                              onTap: () async {

                                final VerificationProvider verificationProvider= context.read<VerificationProvider>();

                                if (_phoneNumberController!.text.isEmpty) {
                                  showCustomSnackBar(getTranslated('enter_phone_number', context), context);
                                }else {
                                  String phoneWithCountryCode = countryCode! + _phoneNumberController!.text.trim();
                                  if(PhoneNumberCheckerHelper.isPhoneValidWithCountryCode(phoneWithCountryCode)){
                                    if(AuthHelper.isPhoneVerificationEnable(configModel)){
                                      await verificationProvider.sendVerificationCode(context,
                                          configModel, phoneWithCountryCode, type: VerificationType.phone.name,
                                          fromPage: FromPage.otp.name, navigatePage : widget.fromPage
                                      );
                                    }
                                  }else{
                                    showCustomSnackBar(getTranslated('invalid_phone_number', context), context);
                                  }

                                }
                              },
                            );
                        },),
                        const SizedBox(height: Dimensions.paddingSizeExtraLarge),

                        if(AuthHelper.isSocialMediaLoginEnable(configModel) && !AuthHelper.isManualLoginEnable(configModel))...[
                          Center(child: Text(
                            getTranslated('or', context),
                            style: rubikRegular.copyWith(
                              fontSize: Dimensions.fontSizeDefault,
                              color: Theme.of(context).hintColor,
                            ),
                          )),
                          const SizedBox(height: Dimensions.paddingSizeDefault),

                          if(!FeatureFlags.hideSocialLogin)
                            SocialLoginWidget(fromPage: widget.fromPage),
                          if(!FeatureFlags.hideSocialLogin)
                            const SizedBox(height: Dimensions.paddingSizeLarge),
                        ],

                      ])),

                      Expanded(child: Container()),

                    ]),

                    // if(configModel.isGuestCheckout == true && !Navigator.canPop(context))...[
                    //   Center(child: InkWell(
                    //     onTap: () => Navigator.pushNamedAndRemoveUntil(context, RouteHelper.getMainRoute(), (route) => false),
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
                    //           color: Theme.of(context).colorScheme.onSurface,
                    //         ),
                    //       ),
                    //
                    //     ])),
                    //   )),
                    // ],

                  ])),
                )),

                if(ResponsiveHelper.isDesktop(context))
                  SizedBox(height: size.width * 0.02),

              ]))),

              if(ResponsiveHelper.isDesktop(context)) const SliverFillRemaining(
                hasScrollBody: false,
                child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [

                  SizedBox(height: Dimensions.paddingSizeLarge),
                  FooterWebWidget(footerType: FooterType.nonSliver),

                ]),
              ),

            ]),
          ),
        ),
      ),
      ),
    );
  }
}
