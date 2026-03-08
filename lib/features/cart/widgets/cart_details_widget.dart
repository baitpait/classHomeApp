import 'package:hexacom_user/common/models/config_model.dart';
import 'package:hexacom_user/features/auth/providers/auth_provider.dart';
import 'package:hexacom_user/features/cart/widgets/button_view_widget.dart';
import 'package:hexacom_user/features/cart/widgets/cart_coupon_widget.dart';
import 'package:hexacom_user/features/cart/widgets/select_delivery_type_widget.dart';
import 'package:hexacom_user/features/coupon/providers/coupon_provider.dart';
import 'package:hexacom_user/features/splash/providers/splash_provider.dart';
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
  final double tax;
  final double discount;
  final double deliveryCharge;
  final double total;
  final double subTotal;
  final TextEditingController couponController;

  const CartDetailsWidget({super.key,
    required this.itemPrice,
    required this.tax, required this.discount,
    required this.deliveryCharge,
    required this.total, required this.couponController,
    required this.subTotal
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
               if(isLoggedIn) CartCouponWidget(couponTextController: couponController, totalAmount: subTotal),

               const SizedBox(height: Dimensions.paddingSizeDefault),

               // Total
               CartItemWidget(
                 title: getTranslated('items_price', context),
                 subTitle: PriceConverterHelper.convertPrice(itemPrice),
               ),
               const SizedBox(height: 10),

               CartItemWidget(
                 title: getTranslated('tax', context),
                 subTitle: PriceConverterHelper.convertPrice(tax),
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

              const Divider(height: 20),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: Dimensions.paddingSizeSmall,
                  vertical: Dimensions.paddingSizeSmall,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF3A4756).withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: CartItemWidget(
                  title: getTranslated('total_amount', context),
                  subTitle: PriceConverterHelper.convertPrice(total),
                  style: rubikSemiBold.copyWith(
                    fontSize: Dimensions.fontSizeExtraLarge,
                    color: const Color(0xFF3A4756),
                  ),
                ),
               ),

               SizedBox(height: ResponsiveHelper.isDesktop(context) ? 10 : 0),
               if(ResponsiveHelper.isDesktop(context)) ButtonViewWidget(
                 itemPrice: itemPrice,total: total,
                 deliveryCharge: deliveryCharge, discount: discount,
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
