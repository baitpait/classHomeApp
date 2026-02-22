import 'package:hexacom_user/features/order/providers/order_provider.dart';
import 'package:hexacom_user/utill/dimensions.dart';
import 'package:hexacom_user/utill/styles.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PaymentButtonWidget extends StatelessWidget {
  final String icon;
  final String title;
  final bool isSelected;
  final Function onTap;

  const PaymentButtonWidget({
    super.key, required this.isSelected, required this.icon,
    required this.title, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<OrderProvider>(builder: (ctx, orderController, _) {
      return Padding(
        padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
        child: InkWell(
          onTap: onTap as void Function()?,
          child: Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Dimensions.radiusSizeSmall),
                border: Border.all(color: Theme.of(context).disabledColor.withValues(alpha: 0.1)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeLarge),
            child: Row(children: [
              Image.asset(icon, width: 20, height: 20),
              const SizedBox(width: Dimensions.paddingSizeSmall),

              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(title, style: rubikMedium.copyWith(fontSize: Dimensions.fontSizeSmall)),
              ])),

              Container(
                decoration: BoxDecoration(
                    shape: BoxShape.circle, color: Colors.transparent,
                    border: Border.all(color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).disabledColor, width: 2)
                ),
                padding: const EdgeInsets.all(2),
                child:  Icon(Icons.circle, color: isSelected ? Theme.of(context).primaryColor : Colors.transparent , size: 10) ,
              ),
              const SizedBox(width: Dimensions.paddingSizeSmall),
            ]),

          ),
        ),
      );
    });
  }
}
