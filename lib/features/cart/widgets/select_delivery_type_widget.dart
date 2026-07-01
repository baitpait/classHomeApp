import 'package:hexacom_user/features/checkout/providers/checkout_provider.dart';
import 'package:flutter/material.dart';
import 'package:hexacom_user/utill/dimensions.dart';
import 'package:hexacom_user/utill/styles.dart';
import 'package:provider/provider.dart';

class SelectDeliveryTypeWidget extends StatelessWidget {
  final String value;
  final String? title;
  const SelectDeliveryTypeWidget({super.key, required this.value, required this.title});

  @override
  Widget build(BuildContext context) {
    return Consumer<CheckoutProvider>(
      builder: (context, checkoutProvider, child) {
        final bool isSelected = checkoutProvider.orderType == value;
        return InkWell(
          onTap: () => checkoutProvider.setOrderType(value),
          borderRadius: BorderRadius.circular(10),
          child: Container(
            margin: const EdgeInsets.only(top: Dimensions.paddingSizeExtraSmall),
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF1F4C5C).withValues(alpha: 0.08) : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Radio(
                  value: value,
                  groupValue: checkoutProvider.orderType,
                  activeColor: const Color(0xFF1F4C5C),
                  onChanged: (String? value) => checkoutProvider.setOrderType(value),
                ),
                const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                Expanded(
                  child: Text(
                    title!,
                    style: isSelected
                        ? rubikMedium.copyWith(color: const Color(0xFF1F4C5C))
                        : rubikRegular,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
