import 'package:hexacom_user/common/models/config_model.dart';
import 'package:hexacom_user/features/checkout/providers/checkout_provider.dart';
import 'package:hexacom_user/features/splash/providers/splash_provider.dart';
import 'package:hexacom_user/localization/language_constrants.dart';
import 'package:hexacom_user/utill/dimensions.dart';
import 'package:hexacom_user/utill/styles.dart';
import 'package:hexacom_user/common/widgets/custom_image_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PaymentMethodWidget extends StatelessWidget {
  final Function(int index) onTap;

  final List<PaymentMethod> paymentList;
  const PaymentMethodWidget({
    super.key, required this.onTap, required this.paymentList,
  });

  @override
  Widget build(BuildContext context) {
    final CheckoutProvider checkoutProvider = Provider.of<CheckoutProvider>(context, listen: false);
    final SplashProvider splashProvider = Provider.of<SplashProvider>(context, listen: false);



    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).hintColor.withValues(alpha: 0.2)),
        borderRadius: BorderRadius.circular(Dimensions.radiusSizeSmall)
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [

        Padding(
          padding: const EdgeInsets.only(left: Dimensions.paddingSizeDefault, right: Dimensions.paddingSizeDefault, top: Dimensions.paddingSizeSmall),
          child: Row(children: [
            Text(getTranslated('pay_via_online', context), style: rubikMedium.copyWith(fontSize: Dimensions.fontSizeSmall)),
            const SizedBox(width: Dimensions.paddingSizeExtraSmall),

            Text('(${getTranslated('faster_and_secure_way_to_pay_bill', context)})', style: rubikMedium.copyWith(fontSize: 8)),
          ]),
        ),

        Flexible(child: ListView.builder(
            itemCount: paymentList.length,
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemBuilder: (context, index){
              bool isSelected = paymentList[index] == checkoutProvider.paymentMethod;

              return InkWell(
                onTap: ()=> onTap(index),
                child: Container(
                  decoration: BoxDecoration(
                      color: isSelected ? Colors.blue.withValues(alpha: 0.05) : Colors.transparent,
                      borderRadius: BorderRadius.circular(Dimensions.radiusSizeDefault)
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeLarge),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Row(children: [
                        CustomImageWidget(
                          height: Dimensions.paddingSizeLarge, fit: BoxFit.contain,
                          image: '${splashProvider.configModel?.baseUrls?.getWayImageUrl}/${paymentList[index].getWayImage}',
                        ),
                        const SizedBox(width: Dimensions.paddingSizeSmall),

                        Text(
                          paymentList[index].getWayTitle ?? '',
                          style: rubikMedium.copyWith(fontSize: Dimensions.fontSizeDefault),
                        ),
                      ]),

                      Container(
                        height: Dimensions.paddingSizeLarge, width: Dimensions.paddingSizeLarge,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle, color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).cardColor,
                            border: Border.all(color: Theme.of(context).disabledColor)
                        ),
                        child: Icon(Icons.check, color: Theme.of(context).cardColor, size: 16),
                      ),
                    ]),


                  ]),
                ),
              );
            },
          )),
      ]),
    );
  }
}
