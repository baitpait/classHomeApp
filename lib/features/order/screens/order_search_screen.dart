import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hexacom_user/common/enums/footer_type_enum.dart';
import 'package:hexacom_user/common/widgets/custom_button_widget.dart';
import 'package:hexacom_user/common/widgets/custom_loader_widget.dart';
import 'package:hexacom_user/common/widgets/custom_text_field_widget.dart';
import 'package:hexacom_user/common/widgets/custom_web_title_widget.dart';
import 'package:hexacom_user/common/widgets/footer_web_widget.dart';
import 'package:hexacom_user/common/widgets/web_app_bar_widget.dart';
import 'package:hexacom_user/common/widgets/phone_number_field_widget.dart';
import 'package:hexacom_user/features/order/providers/order_provider.dart';
import 'package:hexacom_user/features/order/widgets/track_order_web_widget.dart';
import 'package:hexacom_user/features/splash/providers/splash_provider.dart';
import 'package:hexacom_user/helper/custom_snackbar_helper.dart';
import 'package:hexacom_user/helper/responsive_helper.dart';
import 'package:hexacom_user/localization/language_constrants.dart';
import 'package:hexacom_user/utill/dimensions.dart';
import 'package:hexacom_user/utill/images.dart';
import 'package:hexacom_user/utill/routes.dart';
import 'package:hexacom_user/utill/styles.dart';
import 'package:provider/provider.dart';

class OrderSearchScreen extends StatefulWidget {
  const OrderSearchScreen({super.key});

  @override
  State<OrderSearchScreen> createState() => _OrderSearchScreenState();
}

class _OrderSearchScreenState extends State<OrderSearchScreen> {
  final TextEditingController orderIdTextController = TextEditingController();
  final TextEditingController phoneNumberTextController = TextEditingController();
  final FocusNode orderIdFocusNode = FocusNode();
  final FocusNode phoneFocusNode = FocusNode();
  String? countryCode;

  @override
  void initState() {
    countryCode = CountryCode.fromCountryCode(Provider.of<SplashProvider>(context, listen: false).configModel!.countryCode!).code;
    Provider.of<OrderProvider>(context, listen: false).clearPrevData();
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    final bool isDesktop = ResponsiveHelper.isDesktop(context);
    return Scaffold(
      appBar: isDesktop
          ? const PreferredSize(
              preferredSize: Size.fromHeight(120),
              child: WebAppBarWidget(),
            )
          : null,
      body: CustomScrollView(slivers: [
        SliverToBoxAdapter(
          child: Center(
            child: Container(
              width: isDesktop ? Dimensions.getWebContentWidth(MediaQuery.sizeOf(context).width) : null,
              padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!isDesktop)
                    SizedBox(
                      height: MediaQuery.paddingOf(context).top + Dimensions.paddingSizeSmall,
                    ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(Dimensions.paddingSizeSmall, 8, Dimensions.paddingSizeSmall, 0),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => context.pop(),
                          icon: Icon(Icons.arrow_back_ios_new, size: 20, color: Theme.of(context).textTheme.bodyLarge?.color),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                        ),
                        if (!isDesktop) ...[
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              getTranslated('track_order', context),
                              style: rubikSemiBold.copyWith(fontSize: Dimensions.fontSizeLarge),
                            ),
                          ),
                        ],
                        if (isDesktop)
                          _TrackRefreshButtonView(
                            orderIdTextController: orderIdTextController,
                            phoneNumberTextController: phoneNumberTextController,
                          ),
                      ],
                    ),
                  ),
                  CustomWebTitleWidget(title: getTranslated('track_order', context)),
                  Container(
                    margin: const EdgeInsets.only(
                      left: Dimensions.paddingSizeSmall,
                      right: Dimensions.paddingSizeSmall,
                      bottom: Dimensions.paddingSizeLarge,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: Dimensions.paddingSizeLarge,
                      vertical: Dimensions.paddingSizeDefault,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: const Color(0xFF3A4756),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.location_on_rounded, color: Colors.white, size: 22),
                        ),
                        const SizedBox(width: Dimensions.paddingSizeDefault),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                getTranslated('track_your_order', context),
                                style: rubikSemiBold.copyWith(fontSize: Dimensions.fontSizeLarge, color: Colors.white),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                getTranslated('enter_your_order_id', context),
                                style: rubikRegular.copyWith(
                                  fontSize: Dimensions.fontSizeSmall,
                                  color: Colors.white.withValues(alpha: 0.7),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                    padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context).shadowColor.withValues(alpha: 0.10),
                          blurRadius: 18,
                          spreadRadius: 0,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _InputView(
                          orderIdTextController: orderIdTextController,
                          orderIdFocusNode: orderIdFocusNode,
                          phoneFocusNode: phoneFocusNode,
                          phoneNumberTextController: phoneNumberTextController,
                          onValueChange: (String code) {
                            setState(() {
                              countryCode = code;
                            });
                          },
                          countryCode: countryCode,
                        ),
                        if (!isDesktop)
                          _TrackRefreshButtonView(
                            orderIdTextController: orderIdTextController,
                            phoneNumberTextController: phoneNumberTextController,
                          ),
                        Consumer<OrderProvider>(
                          builder: (context, orderProvider, _) {
                            return orderProvider.trackModel == null || orderProvider.trackModel?.id == null
                                ? Column(
                                    children: [
                                      const SizedBox(height: Dimensions.paddingSizeLarge),
                                      Image.asset(Images.outForDelivery, color: Theme.of(context).disabledColor.withValues(alpha: 0.5), width: 70),
                                      const SizedBox(height: Dimensions.paddingSizeDefault),
                                      Text(
                                        getTranslated('enter_your_order_id', context),
                                        style: rubikRegular.copyWith(color: Theme.of(context).disabledColor),
                                        maxLines: 2,
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 60),
                                    ],
                                  )
                                : isDesktop
                                    ? TrackOrderWebWidget(
                                        phoneNumber: '${CountryCode.fromCountryCode(countryCode!).dialCode}${phoneNumberTextController.text.trim()}',
                                      )
                                    : const SizedBox();
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const FooterWebWidget(footerType: FooterType.sliver),
      ]),
    );
  }
}


class _TrackRefreshButtonView extends StatelessWidget {
  const _TrackRefreshButtonView({
    required this.orderIdTextController,
    required this.phoneNumberTextController,
  });

  final TextEditingController orderIdTextController;
  final TextEditingController phoneNumberTextController;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      elevation: 0,
      hoverElevation: 0,
      hoverColor:  const Color(0xFF3A4756).withValues(alpha: 0.08),
      backgroundColor:  Theme.of(context).cardColor,
      onPressed: () {
        orderIdTextController.clear();
        phoneNumberTextController.clear();
        Provider.of<OrderProvider>(context, listen: false).clearPrevData(isUpdate: true);
      },
      label: Text(getTranslated('refresh', context), style: rubikMedium.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color)),
      icon: Icon(Icons.refresh, color: const Color(0xFF3A4756)),
    );
  }
}


class _InputView extends StatelessWidget {
  const _InputView({
    required this.orderIdTextController,
    required this.orderIdFocusNode,
    required this.phoneFocusNode,
    required this.phoneNumberTextController,
    required this.countryCode,
    required this.onValueChange,
  });

  final TextEditingController orderIdTextController;
  final FocusNode orderIdFocusNode;
  final FocusNode phoneFocusNode;
  final TextEditingController phoneNumberTextController;
  final String? countryCode;
  final Function(String value) onValueChange;

  @override
  Widget build(BuildContext context) {

    return !ResponsiveHelper.isDesktop(context) ? Column(children: [
      FormField(builder: (builder)=> Column(children: [
        _OrderIdTextField(
          orderIdTextController: orderIdTextController,
          orderIdFocusNode: orderIdFocusNode,
          phoneFocusNode: phoneFocusNode,
        ),
        const SizedBox(height: Dimensions.paddingSizeLarge),

        PhoneNumberFieldWidget(
          onValueChange: onValueChange,
          countryCode: countryCode,
          phoneNumberTextController: phoneNumberTextController,
          phoneFocusNode: phoneFocusNode,
        ),
        const SizedBox(height: Dimensions.paddingSizeLarge),

      ])),
      const SizedBox(height: Dimensions.paddingSizeDefault),

      TrackOrderButtonView(
        orderIdTextController: orderIdTextController,
        countryCode: countryCode,
        phoneNumberTextController: phoneNumberTextController,
      ),
    ]) : Center(child: SizedBox(
      width: Dimensions.webScreenWidth,
      child: FormField(builder: (builder)=> Row(children: [
        Expanded(child: _OrderIdTextField(
          orderIdTextController: orderIdTextController,
          orderIdFocusNode: orderIdFocusNode,
          phoneFocusNode: phoneFocusNode,
        )),
        const SizedBox(width: Dimensions.paddingSizeLarge),

        Expanded(child: PhoneNumberFieldWidget(
          onValueChange: onValueChange, countryCode: countryCode,
          phoneNumberTextController: phoneNumberTextController,
          phoneFocusNode: phoneFocusNode,
        )),
        const SizedBox(width: Dimensions.paddingSizeLarge),


        SizedBox(
          width: 200,
          child: TrackOrderButtonView(
            orderIdTextController: orderIdTextController,
            countryCode: countryCode,
            phoneNumberTextController: phoneNumberTextController,
          ),
        ),
      ])),
    ));
  }
}

class TrackOrderButtonView extends StatelessWidget {
  const TrackOrderButtonView({
    super.key,
    required this.orderIdTextController,
    required this.countryCode,
    required this.phoneNumberTextController,
  });

  final TextEditingController orderIdTextController;
  final String? countryCode;
  final TextEditingController phoneNumberTextController;

  @override
  Widget build(BuildContext context) {
    return Consumer<OrderProvider>(
      builder: (context, orderProvider, _) {
        return orderProvider.isLoading ? CustomLoaderWidget(color: Theme.of(context).primaryColor) : CustomButtonWidget(
          radius: ResponsiveHelper.isDesktop(context) ? Dimensions.radiusSizeDefault : Dimensions.radiusSizeFifty,
          btnTxt: getTranslated('search_order', context),
          onTap: (){
            final String orderId = orderIdTextController.text.trim();
            final dialCode = CountryCode.fromCountryCode(countryCode!).dialCode;

            final String phoneNumber = '$dialCode${phoneNumberTextController.text.trim()}';

            if(orderId.isEmpty){
              showCustomSnackBar(getTranslated('enter_order_id', context), context);
            }else if(phoneNumberTextController.text.trim().isEmpty){
              showCustomSnackBar(getTranslated('enter_phone_number', context), context);
            }else{
              if(ResponsiveHelper.isDesktop(context)){
                orderProvider.trackOrder(orderId, null, context, true, phoneNumber: phoneNumber);
              }else{
                context.go(RouteHelper.getOrderTrackingRoute(context, int.parse(orderId), phoneNumber));
              }
            }

          },
        );
      }
    );
  }
}



class _OrderIdTextField extends StatelessWidget {
  const _OrderIdTextField({
    required this.orderIdTextController,
    required this.orderIdFocusNode,
    required this.phoneFocusNode,
  });

  final TextEditingController orderIdTextController;
  final FocusNode orderIdFocusNode;
  final FocusNode phoneFocusNode;

  @override
  Widget build(BuildContext context) {
    return CustomTextFieldWidget(
      controller: orderIdTextController,
      focusNode: orderIdFocusNode,
      nextFocus: phoneFocusNode,
      isShowBorder: true,
      hintText: getTranslated('order_id', context),
      prefixAssetUrl: Images.order,
      isShowPrefixIcon: true,
      suffixAssetUrl: Images.order,
      inputType: TextInputType.phone,
      imageSize: Dimensions.paddingSizeExtraLarge,
      contentPadding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeDefault, horizontal: 20),

    );
  }
}