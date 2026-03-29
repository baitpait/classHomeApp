import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:hexacom_user/common/enums/footer_type_enum.dart';
import 'package:hexacom_user/common/models/config_model.dart';
import 'package:hexacom_user/common/models/response_model.dart';
import 'package:hexacom_user/common/models/userinfo_model.dart';
import 'package:hexacom_user/common/widgets/custom_button_widget.dart';
import 'package:hexacom_user/common/widgets/custom_image_widget.dart';
import 'package:hexacom_user/common/widgets/footer_web_widget.dart';
import 'package:hexacom_user/common/widgets/on_hover.dart';
import 'package:hexacom_user/features/auth/domain/enums/from_page_enum.dart';
import 'package:hexacom_user/features/auth/domain/enums/verification_type_enum.dart';
import 'package:hexacom_user/features/auth/providers/auth_provider.dart';
import 'package:hexacom_user/features/auth/providers/verification_provider.dart';
import 'package:hexacom_user/features/menu/widgets/menu_loyalty_points_card_widget.dart';
import 'package:hexacom_user/features/profile/providers/profile_provider.dart';
import 'package:hexacom_user/features/splash/providers/splash_provider.dart';
import 'package:hexacom_user/helper/auth_helper.dart';
import 'package:hexacom_user/helper/user_avatar_image_url.dart';
import 'package:hexacom_user/helper/custom_snackbar_helper.dart';
import 'package:hexacom_user/helper/phone_number_checker_helper.dart';
import 'package:hexacom_user/localization/language_constrants.dart';
import 'package:hexacom_user/main.dart';
import 'package:hexacom_user/utill/dimensions.dart';
import 'package:hexacom_user/utill/images.dart';
import 'package:hexacom_user/utill/routes.dart';
import 'package:hexacom_user/utill/styles.dart';
import 'package:hexacom_user/common/widgets/custom_text_field_widget.dart';

class ProfileWebWidget extends StatefulWidget {
  final FocusNode? firstNameFocus;
  final FocusNode? lastNameFocus;
  final FocusNode? phoneNumberFocus;
  final FocusNode? passwordFocus;
  final FocusNode? confirmPasswordFocus;
  final TextEditingController? firstNameController;
  final TextEditingController? lastNameController;
  final TextEditingController? phoneNumberController;
  final TextEditingController? passwordController;
  final TextEditingController? confirmPasswordController;
  final UserInfoModel? userInfo;

  final Function pickImage;
  final XFile? file;
  const ProfileWebWidget({
    super.key,
    required this.firstNameFocus,
    required this.lastNameFocus,
    required this.phoneNumberFocus,
    required this.passwordFocus,
    required this.confirmPasswordFocus,
    required this.firstNameController,
    required this.lastNameController,
    required this.phoneNumberController,
    required this.passwordController,
    required this.confirmPasswordController,
    //function
    required this.pickImage,
    //file
    required this.file, required this.userInfo


  });

  @override
  State<ProfileWebWidget> createState() => _ProfileWebWidgetState();
}

class _ProfileWebWidgetState extends State<ProfileWebWidget> {
  @override
  Widget build(BuildContext context) {
    final SplashProvider splashProvider = Provider.of<SplashProvider>(context, listen: false);
    final VerificationProvider verificationProvider = context.read<VerificationProvider>();
    final phoneToolTipKey = GlobalKey<State<Tooltip>>();

    return SingleChildScrollView(
      child: Column(
        children: [
          Consumer<ProfileProvider>(builder: (context, profileProvider, child) {
            return Center(
              child: SizedBox(
                width: Dimensions.webScreenWidth,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _ProfileWebHeader(
                      profileProvider: profileProvider,
                      splashProvider: splashProvider,
                      file: widget.file,
                      pickImage: widget.pickImage,
                    ),
                    const SizedBox(height: Dimensions.paddingSizeSection),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
                      child: Column(
                        children: [

                    Center(
                      child: SizedBox(
                        width: 860,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
                              decoration: BoxDecoration(
                                color: Theme.of(context).cardColor,
                                borderRadius: BorderRadius.circular(Dimensions.radiusSizeDefault),
                                border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.35)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    getTranslated('update_profile', context),
                                    style: rubikMedium.copyWith(
                                      fontSize: Dimensions.fontSizeLarge,
                                      color: Theme.of(context).textTheme.bodyLarge?.color,
                                    ),
                                  ),
                                  const SizedBox(height: Dimensions.paddingSizeLarge),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: CustomTextFieldWidget(
                                          title: getTranslated('first_name', context),
                                          hintText: getTranslated('enter_first_name', context),
                                          isShowBorder: true,
                                          controller: widget.firstNameController,
                                          focusNode: widget.firstNameFocus,
                                          nextFocus: widget.lastNameFocus,
                                          inputType: TextInputType.name,
                                          capitalization: TextCapitalization.words,
                                        ),
                                      ),
                                      const SizedBox(width: Dimensions.paddingSizeLarge),
                                      Expanded(
                                        child: CustomTextFieldWidget(
                                          title: getTranslated('last_name', context),
                                          hintText: getTranslated('enter_last_name', context),
                                          isShowBorder: true,
                                          controller: widget.lastNameController,
                                          focusNode: widget.lastNameFocus,
                                          nextFocus: widget.phoneNumberFocus,
                                          inputType: TextInputType.name,
                                          capitalization: TextCapitalization.words,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: Dimensions.paddingSizeLarge),
                                  Selector<AuthProvider, bool>(
                                    selector: (context, authProvider) => authProvider.isNumberLogin,
                                    builder: (context, isNumberLogin, child) {
                                      return Selector<VerificationProvider, bool>(
                                        selector: (context, verificationProvider) => verificationProvider.isLoading,
                                        builder: (context, isLoading, child) {
                                          return CustomTextFieldWidget(
                                            countryDialCode: isNumberLogin ? profileProvider.countryCode : null,
                                            onCountryChanged: (CountryCode value) => profileProvider.setCountryCode(value.dialCode!),
                                            onChanged: (String text) => AuthHelper.identifyEmailOrNumber(text, context),
                                            title: getTranslated('whatsapp_mobile_number', context),
                                            hintText: getTranslated('enter_phone_number_with_country_code', context),
                                            isShowBorder: true,
                                            isEnabled: profileProvider.userInfoModel?.isPhoneVerified == 0,
                                            controller: widget.phoneNumberController,
                                            isShowSuffixIcon: true,
                                            fillColor: profileProvider.userInfoModel?.isPhoneVerified == 0 ? null : Theme.of(context).hintColor.withValues(alpha: 0.08),
                                            isToolTipSuffix: AuthHelper.isPhoneVerificationEnable(splashProvider.configModel),
                                            focusNode: widget.phoneNumberFocus,
                                            nextFocus: widget.passwordFocus,
                                            inputType: TextInputType.phone,
                                            toolTipMessage: profileProvider.userInfoModel?.isPhoneVerified == 0
                                                ? getTranslated('phone_number_not_verified', context)
                                                : getTranslated('cant_update_phone_number', context),
                                            toolTipKey: phoneToolTipKey,
                                            suffixAssetUrl: AuthHelper.isPhoneVerificationEnable(splashProvider.configModel) &&
                                                    profileProvider.userInfoModel?.isPhoneVerified == 0
                                                ? Images.notVerifiedProfileIcon
                                                : Images.verifiedProfileIcon,
                                            onSuffixTap: () {
                                              final ConfigModel configModel = context.read<SplashProvider>().configModel!;
                                              String userInput = (profileProvider.countryCode ?? '') + (widget.phoneNumberController?.text.trim() ?? '');
                                              verificationProvider.sendVerificationCode(
                                                context,
                                                configModel,
                                                userInput,
                                                type: VerificationType.phone.name,
                                                fromPage: FromPage.profile.name,
                                              );
                                            },
                                          );
                                        },
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: Dimensions.paddingSizeLarge),
                            Container(
                              padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
                              decoration: BoxDecoration(
                                color: Theme.of(context).cardColor,
                                borderRadius: BorderRadius.circular(Dimensions.radiusSizeDefault),
                                border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.35)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    getTranslated('create_new_password', context),
                                    style: rubikMedium.copyWith(
                                      fontSize: Dimensions.fontSizeLarge,
                                      color: Theme.of(context).textTheme.bodyLarge?.color,
                                    ),
                                  ),
                                  const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                                  Text(
                                    getTranslated('will_add_later', context),
                                    style: rubikRegular.copyWith(
                                      fontSize: Dimensions.fontSizeSmall,
                                      color: Theme.of(context).hintColor,
                                    ),
                                  ),
                                  const SizedBox(height: Dimensions.paddingSizeLarge),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: CustomTextFieldWidget(
                                          title: getTranslated('password', context),
                                          hintText: getTranslated('password_hint', context),
                                          isShowBorder: true,
                                          controller: widget.passwordController,
                                          focusNode: widget.passwordFocus,
                                          nextFocus: widget.confirmPasswordFocus,
                                          isPassword: true,
                                          isShowSuffixIcon: true,
                                        ),
                                      ),
                                      const SizedBox(width: Dimensions.paddingSizeLarge),
                                      Expanded(
                                        child: CustomTextFieldWidget(
                                          title: getTranslated('confirm_password', context),
                                          hintText: getTranslated('password_hint', context),
                                          isShowBorder: true,
                                          controller: widget.confirmPasswordController,
                                          focusNode: widget.confirmPasswordFocus,
                                          isPassword: true,
                                          isShowSuffixIcon: true,
                                          inputAction: TextInputAction.done,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                          const SizedBox(height: 24),
                          Align(
                            alignment: Alignment.center,
                            child: SizedBox(
                              width: 430,
                              child: CustomButtonWidget(
                            isLoading: profileProvider.isLoading,
                            btnTxt: getTranslated('update_profile', context),
                            onTap: () async {
                              String firstName = widget.firstNameController?.text.trim() ?? '';
                              String lastName = widget.lastNameController?.text.trim() ?? '';
                              String phoneNumber = '';
                              if(!profileProvider.countryCode!.contains('+')){
                               phoneNumber = '+${profileProvider.countryCode}${widget.phoneNumberController?.text.trim() ?? ''}';
                              }else{
                                phoneNumber = '${profileProvider.countryCode}${widget.phoneNumberController?.text.trim() ?? ''}';
                              }

                              bool isPhoneValid = PhoneNumberCheckerHelper.isPhoneValidWithCountryCode(phoneNumber);
                              String password = widget.passwordController?.text.trim() ?? '';
                              String confirmPassword = widget.confirmPasswordController?.text.trim() ?? '';

                              if (profileProvider.userInfoModel?.fName == firstName &&
                                  profileProvider.userInfoModel?.lName == lastName &&
                                  profileProvider.userInfoModel?.phone == phoneNumber &&
                                  widget.file == null && password.isEmpty && confirmPassword.isEmpty
                              ) {
                                showCustomSnackBar(getTranslated('change_something_to_update', context), context);

                              }else if (firstName.isEmpty) {
                                showCustomSnackBar(getTranslated('enter_first_name', context), context);

                              }else if (lastName.isEmpty) {
                                showCustomSnackBar(getTranslated('enter_last_name', context), context);

                              }else if (phoneNumber.isEmpty) {
                                showCustomSnackBar(getTranslated('enter_phone_number', context), context);

                              }else if(!isPhoneValid){
                                showCustomSnackBar(getTranslated('invalid_phone_number', context), context);

                              } else if((password.isNotEmpty && password.length < 6) || (confirmPassword.isNotEmpty && confirmPassword.length < 6)) {
                                showCustomSnackBar(getTranslated('password_should_be', context), context);

                              } else if(password != confirmPassword) {
                                showCustomSnackBar(getTranslated('password_did_not_match', context), context);

                              } else {
                                UserInfoModel updateUserInfoModel = UserInfoModel();
                                updateUserInfoModel.fName = firstName;
                                updateUserInfoModel.lName = lastName;
                                updateUserInfoModel.email = profileProvider.userInfoModel?.email;
                                updateUserInfoModel.phone = phoneNumber;
                                updateUserInfoModel.loginMedium = widget.userInfo?.loginMedium;
                                updateUserInfoModel.image = widget.userInfo?.image;

                                String pass = password;

                                ResponseModel responseModel = await profileProvider.updateUserInfo(
                                  updateUserInfoModel, pass, widget.file,
                                  Provider.of<AuthProvider>(context, listen: false).getUserToken(),
                                );

                                if(responseModel.isSuccess) {
                                  await profileProvider.getUserInfo();
                                  widget.passwordController!.text = '';
                                  widget.confirmPasswordController!.text = '';
                                  showCustomSnackBar(getTranslated('updated_successfully', Get.context!), Get.context!, isError: false);
                                }else {
                                  showCustomSnackBar(responseModel.message, Get.context!);
                                }
                                setState(() {});

                              }},
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 55),
          const FooterWebWidget(footerType: FooterType.nonSliver),
        ],
      ),
    );
  }
}

class _ProfileWebHeader extends StatelessWidget {
  final ProfileProvider profileProvider;
  final SplashProvider splashProvider;
  final XFile? file;
  final Function pickImage;

  const _ProfileWebHeader({
    required this.profileProvider,
    required this.splashProvider,
    required this.file,
    required this.pickImage,
  });

  Widget _avatarBody(BuildContext context) {
    if (file != null) {
      return Image.network(file!.path, fit: BoxFit.cover, height: 100, width: 100);
    }
    final baseUrls = splashProvider.baseUrls;
    final user = profileProvider.userInfoModel;
    final resolved = UserAvatarImageUrl.resolve(
      isLoggedIn: user != null,
      userImage: user?.image,
      customerImageUrl: baseUrls?.customerImageUrl,
      appLogo: splashProvider.configModel?.appLogo,
      ecommerceImageUrl: baseUrls?.ecommerceImageUrl,
    );
    if (resolved != null && resolved.isNotEmpty) {
      return CustomImageWidget(
        image: resolved,
        placeholder: Images.placeholder(context),
        fit: BoxFit.cover,
        height: 100,
        width: 100,
      );
    }
    return Image.asset(
      Images.placeholder(context),
      fit: BoxFit.cover,
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    final user = profileProvider.userInfoModel;
    final showLoyalty = user != null && (splashProvider.configModel?.loyaltyPointsEnabled ?? false);
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
          Stack(
            clipBehavior: Clip.none,
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
                  child: _avatarBody(context),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: OnHover(
                  child: InkWell(
                    hoverColor: Colors.transparent,
                    onTap: pickImage as void Function()?,
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withValues(alpha: 0.9),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 20),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 28),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (user != null) ...[
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
                      onTap: () => RouteHelper.getMyPointsRoute(context, action: RouteAction.push),
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