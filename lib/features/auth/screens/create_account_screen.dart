import 'package:country_code_picker/country_code_picker.dart';
import 'package:hexacom_user/common/enums/footer_type_enum.dart';
import 'package:hexacom_user/common/models/signup_model.dart';
import 'package:hexacom_user/features/auth/domain/enums/from_page_enum.dart';
import 'package:hexacom_user/features/auth/providers/registration_provider.dart';
import 'package:hexacom_user/helper/login_route_helper.dart';
import 'package:hexacom_user/helper/responsive_helper.dart';
import 'package:hexacom_user/localization/language_constrants.dart';
import 'package:hexacom_user/features/auth/providers/auth_provider.dart';
import 'package:hexacom_user/features/splash/providers/splash_provider.dart';
import 'package:hexacom_user/utill/dimensions.dart';
import 'package:hexacom_user/utill/images.dart';
import 'package:hexacom_user/utill/routes.dart';
import 'package:hexacom_user/utill/styles.dart';
import 'package:hexacom_user/utill/color_resources.dart';
import 'package:hexacom_user/common/widgets/custom_image_widget.dart';
import 'package:hexacom_user/common/widgets/custom_button_widget.dart';
import 'package:hexacom_user/helper/custom_snackbar_helper.dart';
import 'package:hexacom_user/common/widgets/auth_background_widget.dart';
import 'package:hexacom_user/common/widgets/custom_text_field_widget.dart';
import 'package:hexacom_user/common/widgets/footer_web_widget.dart';
import 'package:hexacom_user/features/auth/widgets/code_picker_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hexacom_user/common/widgets/web_app_bar_widget.dart';

class CreateAccountScreen extends StatefulWidget {
  final String fromPage;
  const CreateAccountScreen({super.key, required this.fromPage});

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  final FocusNode _firstNameFocus = FocusNode();
  final FocusNode _lastNameFocus = FocusNode();
  final FocusNode _numberFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  final FocusNode _confirmPasswordFocus = FocusNode();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _numberController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  String? _countryDialCode;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_){
      FocusScope.of(context).requestFocus(_firstNameFocus);
    });

    final AuthProvider authProvider = Provider.of<AuthProvider>(context, listen: false);
    final RegistrationProvider registrationProvider = Provider.of<RegistrationProvider>(context, listen: false);

    _numberFocus.addListener(() {
      setState(() {
      });
    });
    _passwordFocus.addListener(() {
      setState(() {
      });
    });

    authProvider.updateIsUpdateTernsStatus(value: false, isUpdate: false);
    registrationProvider.setErrorMessage = '';

    _countryDialCode = CountryCode.fromCountryCode(Provider.of<SplashProvider>(context, listen: false).configModel!.countryCode!).dialCode;
  }

  @override
  void dispose() {
    super.dispose();

    _numberFocus.dispose();
    _passwordFocus.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final config = Provider.of<SplashProvider>(context, listen: false).configModel!;
    final Size size = MediaQuery.sizeOf(context);
    final fontFamily = Theme.of(context).textTheme.bodyLarge?.fontFamily;

    return Scaffold(
      backgroundColor: ColorResources.navBarNavy,
      appBar: ResponsiveHelper.isDesktop(context) ? const PreferredSize(preferredSize: Size.fromHeight(90), child: WebAppBarWidget()) : null,
      body: AuthBackgroundWidget(
        child: Consumer<AuthProvider>(
          builder: (context, authProvider, child) => SafeArea(
            child: NestedScrollView(
            controller: _scrollController,
            headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
              // On mobile we don't show an extra app bar/header; the card already contains logo + title.
              if (!ResponsiveHelper.isDesktop(context)) {
                return <Widget>[];
              }

              return <Widget>[
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: size.height * 0.02,
                  ),
                ),
              ];
            },
            body: CustomScrollView(slivers: [

              if(ResponsiveHelper.isDesktop(context))...[
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: size.height * 0.05,
                  ),
                )
              ],


              SliverToBoxAdapter(child: Center(child: Container(
                width: size.width > 700 ? 500 : (size.width - (Dimensions.paddingSizeDefault * 2)),
                margin: EdgeInsets.only(
                  top: Dimensions.paddingSizeLarge,
                  left: size.width > 700 ? 0 : Dimensions.paddingSizeDefault,
                  right: size.width > 700 ? 0 : Dimensions.paddingSizeDefault,
                  bottom: size.width > 700 ? 0 : Dimensions.paddingSizeLarge,
                ),
                padding: size.width > 700
                    ? const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: Dimensions.paddingSizeExtraLarge,
                      )
                    : const EdgeInsets.symmetric(
                        horizontal: Dimensions.paddingSizeLarge,
                        vertical: Dimensions.paddingSizeDefault,
                      ),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      offset: const Offset(0, 4),
                      blurRadius: size.width > 700 ? 20 : 16,
                      spreadRadius: 0,
                      color: Theme.of(context).shadowColor.withValues(alpha: size.width > 700 ? 0.14 : 0.08),
                    ),
                  ],
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                    Center(
                      child: Column(
                        children: [
                          Builder(
                            builder: (context) {
                              final logoUrl = (Provider.of<SplashProvider>(context, listen: false).baseUrls != null &&
                                      (Provider.of<SplashProvider>(context, listen: false).configModel?.appLogo ?? '').isNotEmpty)
                                  ? '${Provider.of<SplashProvider>(context, listen: false).baseUrls!.ecommerceImageUrl}/${Provider.of<SplashProvider>(context, listen: false).configModel!.appLogo}'
                                  : '';
                              if (logoUrl.isNotEmpty) {
                                return Column(
                                  children: [
                                    CustomImageWidget(
                                      image: logoUrl,
                                      placeholder: Images.placeholder(context),
                                      height: 64,
                                      fit: BoxFit.scaleDown,
                                    ),
                                    const SizedBox(height: Dimensions.paddingSizeSmall),
                                  ],
                                );
                              }
                              return const SizedBox.shrink();
                            },
                          ),
                          Text(
                            getTranslated('signup', context),
                            style: rubikMedium.copyWith(
                              fontSize: Dimensions.fontSizeOverLarge,
                              color: ColorResources.getTextColor(context),
                              fontFamily: fontFamily,
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
                          const SizedBox(height: Dimensions.paddingSizeLarge),
                        ],
                      ),
                    ),

                    CustomTextFieldWidget(
                      prefixAssetUrl: Images.profile,
                      isShowPrefixIcon: true,
                      hintText: getTranslated('first_name', context),
                      title: getTranslated('first_name', context),
                      isShowBorder: true,
                      isRequired: true,
                      controller: _firstNameController,
                      focusNode: _firstNameFocus,
                      nextFocus: _lastNameFocus,
                      inputType: TextInputType.name,
                      capitalization: TextCapitalization.words,
                    ),
                    const SizedBox(height: Dimensions.paddingSizeDefault),

                    // for last name section

                    CustomTextFieldWidget(
                      hintText: getTranslated('last_name', context),
                      title: getTranslated('last_name', context),
                      prefixAssetUrl: Images.profile,
                      isShowBorder: true,
                      isShowPrefixIcon: true,
                      isRequired: true,
                      controller: _lastNameController,
                      focusNode: _lastNameFocus,
                      nextFocus: _numberFocus,
                      inputType: TextInputType.name,
                      capitalization: TextCapitalization.words,
                    ),
                    const SizedBox(height: Dimensions.paddingSizeDefault),

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
                        border: Border.all(color: _numberFocus.hasFocus
                            ? Theme.of(context).primaryColor.withValues(alpha: 0.5)
                            : Theme.of(context).hintColor.withValues(alpha: 0.2), width: 1,
                        ),
                      ),
                      child: Row(children: [
                        CodePickerWidget(
                          onChanged: (countryCode) {
                            _countryDialCode = countryCode.dialCode;
                          },
                          initialSelection: _countryDialCode ?? '+970',
                          favorite: const ['+970', '+972'],
                          showDropDownButton: true,
                          padding: EdgeInsets.zero,
                          showFlagMain: true,
                          textStyle: TextStyle(color: Theme.of(context).textTheme.displayLarge!.color),

                        ),
                        Container(width: 1, height: Dimensions.paddingSizeExtraLarge, color: Theme.of(context).dividerColor),

                        Expanded(child: CustomTextFieldWidget(
                          borderColor: Colors.transparent,
                          hintText: getTranslated('enter_whatsapp_mobile_number', context),
                          isShowBorder: true,
                          controller: _numberController,
                          focusNode: _numberFocus,
                          nextFocus: _passwordFocus,
                          inputType: TextInputType.phone,

                        )),
                      ]),
                    ),

                    const SizedBox(height: Dimensions.paddingSizeDefault),

                    // for password section,
                    CustomTextFieldWidget(
                      prefixIconUrl: Icons.lock,
                      hintText: getTranslated('password', context),
                      title: getTranslated('password', context),
                      prefixAssetImageColor: Theme.of(context).primaryColor,
                      isShowBorder: true,
                      isPassword: true,
                      isRequired: true,
                      controller: _passwordController,
                      focusNode: _passwordFocus,
                      nextFocus: _confirmPasswordFocus,
                      isShowSuffixIcon: true,
                      isShowPrefixIcon: true,
                    ),
                    const SizedBox(height: Dimensions.paddingSizeDefault),

                    // for confirm password section
                    CustomTextFieldWidget(
                      hintText: getTranslated('confirm_password', context),
                      title: getTranslated('confirm_password', context),
                      isShowBorder: true,
                      isPassword: true,
                      isRequired: true,
                      prefixIconUrl: Icons.lock,
                      prefixAssetImageColor: Theme.of(context).primaryColor,
                      isShowPrefixIcon: true,
                      controller: _confirmPasswordController,
                      focusNode: _confirmPasswordFocus,
                      isShowSuffixIcon: true,
                      inputAction: TextInputAction.done,
                    ),
                    const SizedBox(height: Dimensions.paddingSizeDefault),

                    Consumer<RegistrationProvider>(
                      builder: (context, registrationProvider, _) {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            registrationProvider.errorMessage!.isNotEmpty
                                ? CircleAvatar(backgroundColor: Theme.of(context).colorScheme.error, radius: 5)
                                : const SizedBox.shrink(),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                registrationProvider.errorMessage ?? "",
                                style: rubikMedium.copyWith(
                                  fontSize: Dimensions.fontSizeSmall,
                                  color: Theme.of(context).colorScheme.error,
                                ),
                              ),
                            )
                          ],
                        );
                      }
                    ),
                    const SizedBox(height: Dimensions.paddingSizeSmall),

                    Row(children: [
                      InkWell(
                        onTap: ()=> authProvider.updateIsUpdateTernsStatus(),
                        child: Container(
                          width: Dimensions.paddingSizeLarge,
                          height: Dimensions.paddingSizeLarge,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(color: Theme.of(context).primaryColor.withValues(alpha: 0.3), width: 1),
                            color: Theme.of(context).primaryColor.withValues(alpha: authProvider.isAgreeTerms ? 0.2 : 0.02),
                          ),
                          child: authProvider.isAgreeTerms ?  Icon(
                            Icons.check, color: Theme.of(context).primaryColor,
                            size: Dimensions.paddingSizeDefault,
                          ) : const SizedBox(),
                        ),
                      ),
                      const SizedBox(width: Dimensions.paddingSizeSmall),

                      Text(getTranslated('i_agree_with_the', context)),
                      const SizedBox(width: Dimensions.paddingSizeExtraSmall),


                      InkWell(
                        onTap: ()=> RouteHelper.getTermsRoute(context, action: RouteAction.push),
                        child: Text(getTranslated('terms_and_condition', context), style: rubikRegular.copyWith(
                          color: Theme.of(context).primaryColor, decoration: TextDecoration.underline,
                        )),
                      ),



                    ]),
                    const SizedBox(height: Dimensions.paddingSizeLarge),




                    // for signup button

                      Consumer<RegistrationProvider>(
                        builder: (context, registrationProvider, _) {
                          return CustomButtonWidget(
                            isLoading: registrationProvider.isLoading,
                            btnTxt: getTranslated('signup', context),
                            onTap: !authProvider.isAgreeTerms ? null :  () {

                              String firstName = _firstNameController.text.trim();
                              String lastName = _lastNameController.text.trim();
                              String number = _countryDialCode!+_numberController.text.trim();
                              String password = _passwordController.text.trim();
                              String confirmPassword = _confirmPasswordController.text.trim();


                              if (firstName.isEmpty) {
                                showCustomSnackBar(getTranslated('enter_first_name', context), context);
                              }else if (lastName.isEmpty) {
                                showCustomSnackBar(getTranslated('enter_last_name', context), context);
                              }else if (_numberController.text.isEmpty) {
                                showCustomSnackBar(getTranslated('enter_whatsapp_mobile_number', context), context);
                              }else if (password.isEmpty) {
                                showCustomSnackBar(getTranslated('enter_password', context), context);
                              }else if (password.length < 6) {
                                showCustomSnackBar(getTranslated('password_should_be', context), context);
                              }else if (confirmPassword.isEmpty) {
                                showCustomSnackBar(getTranslated('enter_confirm_password', context), context);
                              }else if(password != confirmPassword) {
                                showCustomSnackBar(getTranslated('password_did_not_match', context), context);
                              }else {
                                SignUpModel signUpModel = SignUpModel(
                                  fName: firstName,
                                  lName: lastName,
                                  email: '',
                                  password: password,
                                  phone: number,
                                );

                                registrationProvider.registration(context, signUpModel, config).then((status) async {
                                  if (status.isSuccess) {
                                    LoginRouteHelper.navigateToRoute(FromPage.mainRoute.name);
                                  }
                                });
                              }

                            },
                          );
                        }
                      ),

                    // for already an account
                    const SizedBox(height: Dimensions.paddingSizeLarge),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(getTranslated('already_have_account', context), style: rubikRegular.copyWith(fontFamily: fontFamily)),
                        const SizedBox(width: Dimensions.paddingSizeSmall),

                        InkWell(
                          onTap: ()=> RouteHelper.getLoginRoute(context, FromPage.mainRoute.name, action: RouteAction.pushReplacement),
                          child: Text(getTranslated('login', context), style: rubikMedium.copyWith(
                            color: Theme.of(context).primaryColor, decoration: TextDecoration.underline, fontFamily: fontFamily,
                          )),
                        ),
                      ],
                    ),
                    const SizedBox(height: Dimensions.paddingSizeSmall),

                    Center(child: Text(
                      getTranslated('or', context),
                      style: rubikRegular.copyWith(fontSize: Dimensions.fontSizeSmall, fontFamily: fontFamily),
                    )),
                    const SizedBox(height: Dimensions.paddingSizeSmall),


                    Center(child: InkWell(
                      onTap: ()=> RouteHelper.getDashboardRoute(context, 'home'),
                      child: RichText(text: TextSpan(children: [
                        TextSpan(text: '${getTranslated('continue_as_a', context)}  ',  style: rubikRegular.copyWith(
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                          fontFamily: fontFamily,
                        )),

                        TextSpan(text: getTranslated('guest', context), style: rubikMedium.copyWith(
                          color: Theme.of(context).primaryColor, decoration: TextDecoration.underline, fontFamily: fontFamily,
                        )),

                      ])),
                    )),


                  ],
                ),
                ))),

              if(ResponsiveHelper.isDesktop(context))...[
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: size.height * 0.05,
                  ),
                )
              ],

              const FooterWebWidget(footerType: FooterType.sliver),

            ]),
          ),
        ),
      ),
      ),
    );
  }
}

