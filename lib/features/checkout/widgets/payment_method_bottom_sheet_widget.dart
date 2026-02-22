import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hexacom_user/common/models/config_model.dart';
import 'package:hexacom_user/common/widgets/custom_button_widget.dart';
import 'package:hexacom_user/features/checkout/providers/checkout_provider.dart';
import 'package:hexacom_user/features/checkout/widgets/bring_change_input_widget.dart';
import 'package:hexacom_user/features/checkout/widgets/payment_button_widget.dart';
import 'package:hexacom_user/features/checkout/widgets/payment_method_widget.dart';
import 'package:hexacom_user/features/splash/providers/splash_provider.dart';
import 'package:hexacom_user/helper/price_converter_helper.dart';
import 'package:hexacom_user/helper/responsive_helper.dart';
import 'package:hexacom_user/localization/language_constrants.dart';
import 'package:hexacom_user/utill/dimensions.dart';
import 'package:hexacom_user/utill/images.dart';
import 'package:hexacom_user/utill/feature_flags.dart';
import 'package:hexacom_user/utill/styles.dart';
import 'package:provider/provider.dart';



class PaymentMethodBottomSheetWidget extends StatefulWidget {
  final double totalAmount;
  final double? deliveryCharge;
  const PaymentMethodBottomSheetWidget({super.key, required this.totalAmount, this.deliveryCharge});

  @override
  State<PaymentMethodBottomSheetWidget> createState() => _PaymentMethodBottomSheetWidgetState();
}

class _PaymentMethodBottomSheetWidgetState extends State<PaymentMethodBottomSheetWidget> {
  bool notHideCod = true;
  bool notHideDigital = true;
  List<PaymentMethod> paymentList = [];
  final TextEditingController _bringAmountController = TextEditingController();

  @override
  void initState() {
    super.initState();

    final CheckoutProvider checkoutProvider =  Provider.of<CheckoutProvider>(context, listen: false);
    final SplashProvider splashProvider =  Provider.of<SplashProvider>(context, listen: false);

    final ConfigModel configModel = splashProvider.configModel!;

    _bringAmountController.text = checkoutProvider.bringChangeAmount ?? '';

    if(notHideDigital && !FeatureFlags.cashOnly) {
      paymentList.addAll(configModel.activePaymentMethodList ?? []);
    }

    // When only COD is available, pre-select COD so user just confirms
    final bool onlyCod = configModel.cashOnDelivery! && paymentList.isEmpty;
    if (onlyCod) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final CheckoutProvider cp = Provider.of<CheckoutProvider>(context, listen: false);
        cp.setPaymentIndex(0);
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    final ConfigModel configModel = Provider.of<SplashProvider>(context, listen: false).configModel!;

    final bool isCODActive = configModel.cashOnDelivery!;

    final bool isDisableAllPayment = !isCODActive &&  paymentList.isEmpty;

    return SizedBox(width: 550, child: Column(mainAxisSize: MainAxisSize.min, children: [
      if(ResponsiveHelper.isDesktop(context))
        SizedBox(height: MediaQuery.sizeOf(context).height * 0.1),

      Container(
        constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.8),
        width: 550,
        margin: const EdgeInsets.only(top: kIsWeb ? 0 : 30),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: ResponsiveHelper.isMobile(context) ?
          const BorderRadius.vertical(top: Radius.circular(Dimensions.radiusSizeDefault)) :
          const BorderRadius.all(Radius.circular(Dimensions.radiusSizeDefault)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge, vertical: Dimensions.paddingSizeLarge),
        child: isDisableAllPayment ?
        Text(getTranslated('no_payment_methods_are_available', context)) :
        Consumer<CheckoutProvider>(builder: (ctx, checkoutProvider, _) {

          bool isSelectBottomActive = _isActiveSelectBtn(checkoutProvider, widget.totalAmount, context);

          return Column(mainAxisSize: MainAxisSize.min, children: [
            if(ResponsiveHelper.isDesktop(context)) Align(
              alignment: Alignment.topRight,
              child: InkWell(
                onTap: () => Navigator.pop(context),
                child: Container(
                  height: 30, width: 30,
                  margin: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraSmall),
                  decoration: BoxDecoration(color: Theme.of(context).hintColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(50)),
                  child: const Icon(Icons.clear),
                ),
              ),
            ),

            !ResponsiveHelper.isDesktop(context) ?
            Align(
              alignment: Alignment.center,
              child: Container(
                height: 4, width: 35,
                margin: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraSmall),
                decoration: BoxDecoration(color: Theme.of(context).disabledColor, borderRadius: BorderRadius.circular(10)),
              ),
            ) :
            const SizedBox(),
            const SizedBox(height: Dimensions.paddingSizeDefault),

            Text(
              _isOnlyCodUsable(context, configModel, isCODActive, paymentList, widget.totalAmount)
                  ? getTranslated('cash_on_delivery', context)
                  : getTranslated('choose_payment_method', context),
              style: rubikSemiBold.copyWith(fontSize: Dimensions.fontSizeDefault),
            ),
            const SizedBox(height: Dimensions.paddingSizeExtraSmall),

            if (widget.deliveryCharge != null && widget.deliveryCharge! > 0) ...[
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text(getTranslated('subtotal', context), style: rubikRegular.copyWith(fontSize: Dimensions.fontSizeSmall)),
                Text(PriceConverterHelper.convertPrice(widget.totalAmount - widget.deliveryCharge!), style: rubikRegular.copyWith(fontSize: Dimensions.fontSizeSmall), textDirection: TextDirection.ltr),
              ]),
              const SizedBox(height: 4),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text(getTranslated('delivery_fee', context), style: rubikRegular.copyWith(fontSize: Dimensions.fontSizeSmall)),
                Text(PriceConverterHelper.convertPrice(widget.deliveryCharge!), style: rubikRegular.copyWith(fontSize: Dimensions.fontSizeSmall), textDirection: TextDirection.ltr),
              ]),
              const SizedBox(height: 4),
            ],
            Text(getTranslated('total_bill', context), style: rubikRegular.copyWith(
                fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.7)
            )),

            Text(PriceConverterHelper.convertPrice(widget.totalAmount), style: rubikBold.copyWith(fontSize: Dimensions.fontSizeLarge)),
            const SizedBox(height:  Dimensions.paddingSizeDefault),

            Flexible(child: SingleChildScrollView(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                if(isCODActive) PaymentButtonWidget(
                  icon: Images.cashOnDelivery,
                  title: getTranslated('cash_on_delivery', context),
                  isSelected: checkoutProvider.paymentMethodIndex == 0,
                  onTap: () {
                    checkoutProvider.setPaymentIndex(0);
                  },
                ),

                BringChangeInputWidget(amountController: _bringAmountController),

                if(paymentList.isNotEmpty)
                  Flexible(child: PaymentMethodWidget(
                    paymentList: paymentList,
                    onTap: (index)=> checkoutProvider.changePaymentMethod(digitalMethod: paymentList[index]),
                  )),
                const SizedBox(height: Dimensions.paddingSizeSmall),
              ]),
            )),

            SafeArea(child: CustomButtonWidget(
              btnTxt: getTranslated('select', context),
              onTap: (checkoutProvider.paymentMethodIndex == null && checkoutProvider.paymentMethod == null) ||
                  isSelectBottomActive ? null : () {

                if(checkoutProvider.paymentMethodIndex == 0){
                  checkoutProvider.setBringChangeAmount(amountController: _bringAmountController);
                }
                Navigator.pop(context);
                checkoutProvider.savePaymentMethod(index: checkoutProvider.paymentMethodIndex, method: checkoutProvider.paymentMethod);

              },
            )),

          ]);
        }),
      ),
    ]));
  }
}

bool _isOnlyCodUsable(BuildContext context, ConfigModel configModel, bool isCODActive, List<PaymentMethod> paymentList, double totalAmount) {
  return isCODActive && paymentList.isEmpty;
}

bool _isActiveSelectBtn(CheckoutProvider checkoutProvider, double totalAmount, BuildContext context){
  return false;
}
