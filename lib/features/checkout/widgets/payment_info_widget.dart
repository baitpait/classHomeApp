import 'package:hexacom_user/common/models/config_model.dart';
import 'package:hexacom_user/features/checkout/providers/checkout_provider.dart';
import 'package:hexacom_user/features/checkout/widgets/selected_payment_widget.dart';
import 'package:hexacom_user/features/order/providers/order_provider.dart';
import 'package:hexacom_user/features/splash/providers/splash_provider.dart';
import 'package:hexacom_user/helper/checkout_helper.dart';
import 'package:hexacom_user/helper/custom_snackbar_helper.dart';
import 'package:hexacom_user/helper/responsive_helper.dart';
import 'package:hexacom_user/localization/language_constrants.dart';
import 'package:hexacom_user/utill/dimensions.dart';
import 'package:hexacom_user/utill/feature_flags.dart';
import 'package:hexacom_user/utill/styles.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'payment_method_bottom_sheet_widget.dart';

class PaymentInfoWidget extends StatefulWidget {
  final double totalAmount;
  const PaymentInfoWidget({super.key, required this.totalAmount});

  @override
  State<PaymentInfoWidget> createState() => _PaymentInfoWidgetState();
}

class _PaymentInfoWidgetState extends State<PaymentInfoWidget> {
  bool _didAutoSelectSinglePayment = false;

  void _openDialog(BuildContext context) {
    final CheckoutProvider checkoutProvider = Provider.of<CheckoutProvider>(context, listen: false);
    final double? deliveryCharge = Provider.of<OrderProvider>(context, listen: false).deliveryCharge;

    if (!CheckOutHelper.isSelfPickup(orderType: checkoutProvider.orderType) && checkoutProvider.orderAddressIndex == -1) {
      showCustomSnackBar(getTranslated('select_delivery_address', context), context, isError: true);
    } else {
      if (!ResponsiveHelper.isMobile(context)) {
        showDialog(
          context: context,
          builder: (con) => PaymentMethodBottomSheetWidget(totalAmount: widget.totalAmount, deliveryCharge: deliveryCharge),
        );
      } else {
        showModalBottomSheet(
          context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
          builder: (con) => PaymentMethodBottomSheetWidget(totalAmount: widget.totalAmount, deliveryCharge: deliveryCharge),
        );
      }
    }
  }

  static bool _hasSinglePaymentMethod(ConfigModel? config) {
    if (config == null) return false;
    final bool cod = config.cashOnDelivery == true;
    final List<PaymentMethod> digital = FeatureFlags.cashOnly ? [] : (config.activePaymentMethodList ?? []);
    final int total = (cod ? 1 : 0) + digital.length;
    return total == 1;
  }

  static void _autoSelectSinglePaymentMethod(BuildContext context, ConfigModel config, CheckoutProvider checkoutProvider) {
    if (checkoutProvider.selectedPaymentMethod != null) return;
    final bool cod = config.cashOnDelivery == true;
    final List<PaymentMethod> digital = FeatureFlags.cashOnly ? [] : (config.activePaymentMethodList ?? []);
    if (cod && digital.isEmpty) {
      checkoutProvider.savePaymentMethod(index: 0);
    } else if (digital.length == 1) {
      checkoutProvider.changePaymentMethod(digitalMethod: digital.first);
      checkoutProvider.savePaymentMethod(method: digital.first);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<SplashProvider, CheckoutProvider>(builder: (context, splashProvider, checkoutProvider, _) {
      final ConfigModel? config = splashProvider.configModel;
      final bool hasSingleMethod = _hasSinglePaymentMethod(config);
      final bool showPayment = checkoutProvider.selectedPaymentMethod != null;

      if (hasSingleMethod && !_didAutoSelectSinglePayment && config != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          _autoSelectSinglePaymentMethod(context, config, checkoutProvider);
          _didAutoSelectSinglePayment = true;
        });
      }

      return Container(
        margin: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeExtraSmall),
        padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: Theme.of(context).shadowColor.withValues(alpha: 0.10), blurRadius: 18, spreadRadius: 0, offset: const Offset(0, 4))],
        ),
        child: Column(children: [
          Row(children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF3A4756).withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.payment_outlined, color: Color(0xFF3A4756), size: 20),
            ),
            const SizedBox(width: Dimensions.paddingSizeSmall),
            Expanded(child: Text(getTranslated('payment_method', context), style: rubikSemiBold.copyWith(fontSize: Dimensions.fontSizeLarge))),

            if(showPayment && !hasSingleMethod) InkWell(
              onTap: () => _openDialog(context),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF3A4756).withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  getTranslated('change', context),
                  style: rubikMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: const Color(0xFF3A4756)),
                ),
              ),
            ),
          ]),

          const SizedBox(height: Dimensions.paddingSizeSmall),

          if(!showPayment && !hasSingleMethod) InkWell(
            onTap: () => _openDialog(context),
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeDefault, horizontal: Dimensions.paddingSizeSmall),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFF3A4756).withValues(alpha: 0.15), width: 1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Icon(Icons.add_circle_outline, color: Color(0xFF3A4756), size: 20),
                const SizedBox(width: Dimensions.paddingSizeSmall),
                Text(
                  getTranslated('add_payment_method', context),
                  style: rubikMedium.copyWith(color: const Color(0xFF3A4756)),
                ),
              ]),
            ),
          ),

          if(ResponsiveHelper.isDesktop(context) && showPayment) const SizedBox(height: Dimensions.paddingSizeDefault),

          if(showPayment) SelectedPaymentWidget(total: (checkoutProvider.getCheckOutData?.amount ?? 0)),
        ]),
      );
    });
  }
}
