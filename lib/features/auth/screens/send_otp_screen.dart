import 'package:flutter/material.dart';
import 'package:hexacom_user/common/models/config_model.dart';
import 'package:hexacom_user/common/widgets/auth_background_widget.dart';
import 'package:hexacom_user/common/widgets/custom_button_widget.dart';
import 'package:hexacom_user/common/widgets/custom_pop_scope_widget.dart';
import 'package:hexacom_user/common/widgets/custom_text_field_widget.dart';
import 'package:hexacom_user/common/widgets/web_app_bar_widget.dart';
import 'package:hexacom_user/features/auth/domain/enums/verification_type_enum.dart';
import 'package:hexacom_user/features/auth/domain/enums/from_page_enum.dart';
import 'package:hexacom_user/features/auth/domain/models/user_log_data.dart';
import 'package:hexacom_user/features/auth/providers/auth_provider.dart';
import 'package:hexacom_user/features/auth/providers/verification_provider.dart';
import 'package:hexacom_user/features/splash/providers/splash_provider.dart';
import 'package:hexacom_user/helper/auth_helper.dart';
import 'package:hexacom_user/helper/custom_snackbar_helper.dart';
import 'package:hexacom_user/helper/phone_number_checker_helper.dart';
import 'package:hexacom_user/helper/responsive_helper.dart';
import 'package:hexacom_user/localization/language_constrants.dart';
import 'package:hexacom_user/utill/dimensions.dart';
import 'package:hexacom_user/utill/images.dart';
import 'package:hexacom_user/utill/routes.dart';
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

    final AuthProvider authProvider = Provider.of<AuthProvider>(context, listen: false);
    UserLogData? userData = authProvider.getUserData();
    if (userData != null && userData.loginType == FromPage.otp.name && userData.phoneNumber != null) {
      _phoneNumberController!.text = PhoneNumberCheckerHelper.getPhoneNumber(userData.phoneNumber ?? '', userData.countryCode ?? '') ?? '';
    }
    countryCode = '+972'; // مقدمة ثابتة لكل المتجر
  }

  Future<void> _onGetOtp(BuildContext context, ConfigModel configModel) async {
    final VerificationProvider verificationProvider = context.read<VerificationProvider>();
    if (_phoneNumberController!.text.trim().isEmpty) {
      showCustomSnackBar(getTranslated('enter_phone_number', context), context);
      return;
    }
    final String phoneWithCountryCode = countryCode! + _phoneNumberController!.text.trim().replaceFirst(RegExp(r'^0+'), '');
    if (!PhoneNumberCheckerHelper.isPhoneValidWithCountryCode(phoneWithCountryCode)) {
      showCustomSnackBar(getTranslated('invalid_phone_number', context), context);
      return;
    }
    if (AuthHelper.isPhoneVerificationEnable(configModel)) {
      await verificationProvider.sendVerificationCode(
        context, configModel, phoneWithCountryCode,
        type: VerificationType.phone.name, fromPage: FromPage.otp.name, navigatePage: widget.fromPage,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final ConfigModel configModel = Provider.of<SplashProvider>(context, listen: false).configModel!;
    final bool isDesktop = ResponsiveHelper.isDesktop(context);

    return CustomPopScopeWidget(
      child: Scaffold(
        backgroundColor: ColorResources.navBarNavy,
        appBar: isDesktop ? const PreferredSize(preferredSize: Size.fromHeight(120), child: WebAppBarWidget()) : null,
        body: AuthBackgroundWidget(
          child: SafeArea(
            child: isDesktop ? _desktopLayout(context, configModel) : _mobileLayout(context, configModel),
          ),
        ),
      ),
    );
  }

  /// Full-screen layout for mobile — content spread across the whole screen on the brand background.
  Widget _mobileLayout(BuildContext context, ConfigModel configModel) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: IconButton(
              onPressed: () => Navigator.canPop(context) ? Navigator.pop(context) : null,
              icon: const Icon(Icons.arrow_back, color: Colors.white),
            ),
          ),
          const Spacer(flex: 2),

          Image.asset(Images.logo, height: 96, fit: BoxFit.scaleDown),
          const SizedBox(height: Dimensions.paddingSizeLarge),
          Text(
            getTranslated('login', context),
            textAlign: TextAlign.center,
            style: rubikBold.copyWith(fontSize: 26, color: Colors.white),
          ),
          const SizedBox(height: Dimensions.paddingSizeSmall),
          Text(
            getTranslated('enter_phone_number', context),
            textAlign: TextAlign.center,
            style: rubikRegular.copyWith(fontSize: Dimensions.fontSizeDefault, color: Colors.white.withValues(alpha: 0.75)),
          ),

          const Spacer(flex: 2),

          CustomTextFieldWidget(
            hintText: getTranslated('mobile_number', context),
            isShowBorder: true,
            fillColor: Colors.white,
            controller: _phoneNumberController,
            inputType: TextInputType.phone,
          ),
          const SizedBox(height: Dimensions.paddingSizeDefault),
          _rememberMe(context),
          const SizedBox(height: Dimensions.paddingSizeLarge),

          Selector<VerificationProvider, bool>(
            selector: (context, vp) => vp.isLoading,
            builder: (context, isLoading, child) => CustomButtonWidget(
              isLoading: isLoading,
              backgroundColor: Colors.white,
              loadingColor: ColorResources.navBarNavy,
              btnTxt: getTranslated('send_verification_code', context),
              style: rubikBold.copyWith(fontSize: Dimensions.fontSizeLarge, color: ColorResources.navBarNavy),
              onTap: () => _onGetOtp(context, configModel),
            ),
          ),
          const SizedBox(height: Dimensions.paddingSizeDefault),
          _registerLink(context, onDark: true),

          const Spacer(flex: 3),
          _guestLink(context, onDark: true),
          const SizedBox(height: Dimensions.paddingSizeSmall),
        ],
      ),
    );
  }

  /// Centered card for desktop / large screens.
  Widget _desktopLayout(BuildContext context, ConfigModel configModel) {
    return Center(
      child: SingleChildScrollView(
        child: Container(
          width: 450,
          margin: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeLarge),
          padding: const EdgeInsets.all(Dimensions.paddingSizeExtraLarge),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Image.asset(Images.logo, height: 90, fit: BoxFit.scaleDown),
            const SizedBox(height: Dimensions.paddingSizeLarge),
            Text(getTranslated('login', context), style: rubikBold.copyWith(fontSize: Dimensions.fontSizeExtraLarge, color: ColorResources.getTextColor(context))),
            const SizedBox(height: Dimensions.paddingSizeSmall),
            Text(getTranslated('enter_phone_number', context), textAlign: TextAlign.center,
              style: rubikRegular.copyWith(fontSize: Dimensions.fontSizeDefault, color: ColorResources.getTextColor(context).withValues(alpha: 0.75))),
            const SizedBox(height: Dimensions.paddingSizeExtraLarge),
            CustomTextFieldWidget(
              hintText: getTranslated('mobile_number', context),
              isShowBorder: true,
              controller: _phoneNumberController,
              inputType: TextInputType.phone,
              title: getTranslated('mobile_number', context),
            ),
            const SizedBox(height: Dimensions.paddingSizeDefault),
            _rememberMe(context),
            const SizedBox(height: Dimensions.paddingSizeLarge),
            Selector<VerificationProvider, bool>(
              selector: (context, vp) => vp.isLoading,
              builder: (context, isLoading, child) => CustomButtonWidget(
                isLoading: isLoading,
                btnTxt: getTranslated('send_verification_code', context),
                onTap: () => _onGetOtp(context, configModel),
              ),
            ),
            const SizedBox(height: Dimensions.paddingSizeLarge),
            _registerLink(context, onDark: false),
            const SizedBox(height: Dimensions.paddingSizeSmall),
            _guestLink(context, onDark: false),
          ]),
        ),
      ),
    );
  }

  Widget _rememberMe(BuildContext context) {
    return Consumer<AuthProvider>(builder: (context, authProvider, child) {
      final Color labelColor = ResponsiveHelper.isDesktop(context) ? (Theme.of(context).textTheme.bodyMedium?.color ?? Colors.black) : Colors.white;
      return InkWell(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        onTap: () => authProvider.toggleRememberMe(),
        child: Row(children: [
          Container(
            width: 18, height: 18,
            decoration: BoxDecoration(
              color: authProvider.isActiveRememberMe ? ColorResources.primary : Colors.transparent,
              border: Border.all(color: authProvider.isActiveRememberMe ? Colors.transparent : labelColor),
              borderRadius: BorderRadius.circular(3),
            ),
            child: authProvider.isActiveRememberMe ? const Icon(Icons.done, color: Colors.white, size: 15) : null,
          ),
          const SizedBox(width: Dimensions.paddingSizeSmall),
          Text(getTranslated('remember_me', context), style: rubikRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: labelColor)),
        ]),
      );
    });
  }

  Widget _registerLink(BuildContext context, {required bool onDark}) {
    final Color base = onDark ? Colors.white.withValues(alpha: 0.85) : Theme.of(context).hintColor;
    return Center(
      child: InkWell(
        onTap: () => RouteHelper.getCreateAccountRoute(context, widget.fromPage, action: RouteAction.push),
        child: RichText(text: TextSpan(children: [
          TextSpan(text: '${getTranslated('do_not_have_an_account', context)} ', style: rubikRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: base)),
          TextSpan(text: getTranslated('sign_up', context), style: rubikMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: ColorResources.primary)),
        ])),
      ),
    );
  }

  Widget _guestLink(BuildContext context, {required bool onDark}) {
    final Color color = onDark ? Colors.white : Theme.of(context).hintColor;
    return Center(
      child: TextButton(
        onPressed: () => RouteHelper.getMainRoute(context, action: RouteAction.pushNamedAndRemoveUntil),
        child: RichText(text: TextSpan(children: [
          TextSpan(text: '${getTranslated('login_as_a', context)} ', style: rubikRegular.copyWith(color: color.withValues(alpha: 0.8), fontSize: Dimensions.fontSizeSmall)),
          TextSpan(text: getTranslated('guest', context), style: rubikMedium.copyWith(color: color, fontSize: Dimensions.fontSizeSmall, decoration: TextDecoration.underline)),
        ])),
      ),
    );
  }
}
