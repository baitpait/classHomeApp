import 'package:hexacom_user/common/models/config_model.dart';
import 'package:hexacom_user/common/widgets/custom_directionality_widget.dart';
import 'package:hexacom_user/features/auth/providers/auth_provider.dart';
import 'package:hexacom_user/features/cart/widgets/button_view_widget.dart';
import 'package:hexacom_user/features/cart/widgets/cart_coupon_dropdown_widget.dart';
import 'package:hexacom_user/features/cart/widgets/select_delivery_type_widget.dart';
import 'package:hexacom_user/features/coupon/providers/coupon_provider.dart';
import 'package:hexacom_user/features/splash/providers/splash_provider.dart';
import 'package:hexacom_user/helper/checkout_helper.dart';
import 'package:hexacom_user/helper/price_converter_helper.dart';
import 'package:hexacom_user/helper/responsive_helper.dart';
import 'package:hexacom_user/localization/language_constrants.dart';
import 'package:hexacom_user/utill/dimensions.dart';
import 'package:hexacom_user/utill/styles.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/cart_item_widget.dart';

class CartDetailsWidget extends StatelessWidget {
  final double itemPrice;
  final double discount;
  final double deliveryCharge;
  final double total;
  final double subTotal;
  final double loyaltyDiscount;
  final bool usePlaceOrderButton;

  const CartDetailsWidget({
    super.key,
    required this.itemPrice,
    required this.discount,
    required this.deliveryCharge,
    required this.total,
    required this.subTotal,
    this.loyaltyDiscount = 0,
    this.usePlaceOrderButton = false,
  });

  @override
  Widget build(BuildContext context) {
   final bool isLoggedIn = Provider.of<AuthProvider>(context, listen: false).isLoggedIn();

   return Selector <SplashProvider, ConfigModel?>(
     selector: (ctx, splashProvider)=> splashProvider.configModel,
     builder: (context, configModel, _){
       return Column( children: [

         configModel?.selfPickup == 1 ? Container(
           padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
           decoration: BoxDecoration(
             color: Theme.of(context).cardColor,
             borderRadius: BorderRadius.circular(14),
             boxShadow: [BoxShadow(color: Theme.of(context).shadowColor.withValues(alpha: 0.10), blurRadius: 18, spreadRadius: 0, offset: const Offset(0, 4))],
           ),
           child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
             Text(
               getTranslated('delivery_option', context),
               style: rubikSemiBold.copyWith(
                 fontSize: Dimensions.fontSizeLarge,
                 color: Theme.of(context).textTheme.bodyLarge?.color,
               ),
             ),
             const SizedBox(height: Dimensions.paddingSizeExtraSmall),
             SelectDeliveryTypeWidget(value: 'delivery', title: getTranslated('delivery', context)),
             SelectDeliveryTypeWidget(value: 'self_pickup', title: getTranslated('self_pickup', context)),
           ]),
         ) : const SizedBox(),

         SizedBox(height:  configModel?.selfPickup == 1 ? Dimensions.paddingSizeDefault : 0),

         Container(
           padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
           decoration: BoxDecoration(
             color: Theme.of(context).cardColor,
             borderRadius: BorderRadius.circular(14),
             boxShadow: [BoxShadow(color: Theme.of(context).shadowColor.withValues(alpha: 0.10), blurRadius: 18, spreadRadius: 0, offset: const Offset(0, 4))],
           ),
           child: Column(
             crossAxisAlignment: CrossAxisAlignment.start,
             children: [
               Text(
                 getTranslated('total_amount', context),
                 style: rubikSemiBold.copyWith(fontSize: Dimensions.fontSizeLarge),
               ),
               const SizedBox(height: Dimensions.paddingSizeSmall),
               if(isLoggedIn) CartCouponDropdownWidget(totalAmount: subTotal),

               const SizedBox(height: Dimensions.paddingSizeDefault),

               // Total
               CartItemWidget(
                 title: getTranslated('items_price', context),
                 subTitle: PriceConverterHelper.convertPrice(itemPrice),
               ),
               const SizedBox(height: 10),

               CartItemWidget(
                 title: getTranslated('discount', context),
                 subTitle: '- ${PriceConverterHelper.convertPrice(discount)}',
               ),
               const SizedBox(height: 10),

               if(isLoggedIn) ...[
                 CartItemWidget(
                   title: getTranslated('coupon_discount', context),
                   subTitle: '- ${PriceConverterHelper.convertPrice(Provider.of<CouponProvider>(context).discount)}',
                 ),
                 const SizedBox(height: 10),
               ],

               if(deliveryCharge > 0) ...[
                 Builder(builder: (context) {
                   final config = Provider.of<SplashProvider>(context, listen: false).configModel;
                   final double base = CheckOutHelper.getAreaBaseDeliveryCharge(context);
                   final int rolls = CheckOutHelper.getDeliveryRollCount(context);
                   final int threshold = config?.deliveryRollFreeThreshold ?? 7;
                   final double rate = config?.deliveryRollSurchargeRate ?? 0.10;
                   final int extraRolls = (rolls - threshold) > 0 ? (rolls - threshold) : 0;
                   // Split only when we have a real area base and an actual surcharge.
                   final bool split = base > 0 && extraRolls > 0 && deliveryCharge > base;
                   final double surcharge = split ? (deliveryCharge - base) : 0.0;
                   final double perRoll = base * rate;

                   return Column(
                     crossAxisAlignment: CrossAxisAlignment.start,
                     children: [
                       Row(
                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                         children: [
                           Text(
                             getTranslated('delivery_fee', context),
                             style: rubikRegular.copyWith(
                               fontSize: Dimensions.fontSizeDefault,
                               color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.85),
                             ),
                           ),
                           CustomDirectionalityWidget(
                             child: Text(
                               '(+) ${PriceConverterHelper.convertPrice(split ? base : deliveryCharge)}',
                               style: rubikSemiBold.copyWith(fontSize: Dimensions.fontSizeLarge),
                             ),
                           ),
                         ],
                       ),
                       if (split) ...[
                         const SizedBox(height: 8),
                         Row(
                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
                           crossAxisAlignment: CrossAxisAlignment.start,
                           children: [
                             Expanded(
                               child: Column(
                                 crossAxisAlignment: CrossAxisAlignment.start,
                                 children: [
                                   Text(
                                     getTranslated('roll_surcharge', context),
                                     style: rubikRegular.copyWith(
                                       fontSize: Dimensions.fontSizeDefault,
                                       color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.85),
                                     ),
                                   ),
                                   Text(
                                     '$extraRolls ${getTranslated('roll', context)} × ${PriceConverterHelper.convertPrice(perRoll)}',
                                     style: rubikRegular.copyWith(
                                       fontSize: Dimensions.fontSizeSmall,
                                       color: Theme.of(context).hintColor,
                                     ),
                                   ),
                                 ],
                               ),
                             ),
                             CustomDirectionalityWidget(
                               child: Text(
                                 '(+) ${PriceConverterHelper.convertPrice(surcharge)}',
                                 style: rubikSemiBold.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).primaryColor),
                               ),
                             ),
                           ],
                         ),
                       ],
                     ],
                   );
                 }),
                 const SizedBox(height: 10),
               ],

               if(loyaltyDiscount > 0) ...[
                 Row(
                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                   children: [
                     Text(
                       getTranslated('loyalty_discount', context),
                       style: rubikRegular.copyWith(
                         fontSize: Dimensions.fontSizeDefault,
                         color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.85),
                       ),
                     ),
                     CustomDirectionalityWidget(
                       child: Text(
                         '(-) ${PriceConverterHelper.convertPrice(loyaltyDiscount)}',
                         style: rubikSemiBold.copyWith(
                           fontSize: Dimensions.fontSizeLarge,
                           color: Theme.of(context).primaryColor,
                         ),
                       ),
                     ),
                   ],
                 ),
                 const SizedBox(height: 10),
               ],

              const Divider(height: 20),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: Dimensions.paddingSizeSmall,
                  vertical: Dimensions.paddingSizeSmall,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF1F4C5C).withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: CartItemWidget(
                  title: getTranslated('total_amount', context),
                  subTitle: PriceConverterHelper.convertPrice(total),
                  style: rubikSemiBold.copyWith(
                    fontSize: Dimensions.fontSizeExtraLarge,
                    color: const Color(0xFF1F4C5C),
                  ),
                ),
               ),

               SizedBox(height: ResponsiveHelper.isDesktop(context) ? 10 : 0),
               if(ResponsiveHelper.isDesktop(context) && !usePlaceOrderButton) ButtonViewWidget(
                 itemPrice: itemPrice,
                 total: total,
                 deliveryCharge: deliveryCharge,
                 discount: discount,
               ),

             ],
           ),
         ),

         const SizedBox( height: Dimensions.paddingSizeDefault),
       ]);
     }
   );
  }
}
