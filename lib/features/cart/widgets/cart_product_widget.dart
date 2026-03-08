import 'package:hexacom_user/features/cart/widgets/cart_bottom_sheet_widget.dart';
import 'package:hexacom_user/helper/responsive_helper.dart';
import 'package:hexacom_user/features/coupon/providers/coupon_provider.dart';
import 'package:hexacom_user/common/widgets/custom_directionality_widget.dart';
import 'package:hexacom_user/common/widgets/custom_image_widget.dart';
import 'package:hexacom_user/helper/custom_snackbar_helper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hexacom_user/common/models/cart_model.dart';
import 'package:hexacom_user/helper/price_converter_helper.dart';
import 'package:hexacom_user/localization/language_constrants.dart';
import 'package:hexacom_user/features/cart/providers/cart_provider.dart';
import 'package:hexacom_user/features/splash/providers/splash_provider.dart';
import 'package:hexacom_user/utill/dimensions.dart';
import 'package:hexacom_user/utill/styles.dart';
import 'package:provider/provider.dart';

class CartProductWidget extends StatelessWidget {
  final CartModel? cart;
  final int cartIndex;
  const CartProductWidget({super.key, required this.cart, required this.cartIndex});

  @override
  Widget build(BuildContext context) {
    String? variationText = getVariationText();

    final SplashProvider splashProvider = Provider.of<SplashProvider>(context, listen: false);
    final bool isDesktop = ResponsiveHelper.isDesktop(context);


    return InkWell(
      hoverColor: Colors.transparent,
      onTap: () {
      ResponsiveHelper.isMobile(context) ? showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (con) => CartBottomSheetWidget(
          product: cart!.product,
          cart: cart,
          cartIndex: cartIndex,
          callback: (CartModel cartModel) {
            showCustomSnackBar(getTranslated('added_to_cart', context), context, isError: false);
          },
        ),
      ): showDialog(context: context, builder: (con) => Dialog(
        child: SizedBox(
          width: 500,
          child: CartBottomSheetWidget(
            cart: cart,
            product: cart!.product,
            cartIndex: cartIndex,
            callback: (CartModel cartModel) {
              showCustomSnackBar(getTranslated('added_to_cart', context), context, isError: false);
            },
          ),
        ),
      )) ;
    },

      child: Container(
        margin: const EdgeInsets.only(
          bottom: Dimensions.paddingSizeDefault,
        ).copyWith(
          left: Dimensions.paddingSizeSmall,
          right: Dimensions.paddingSizeSmall,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFF3A4756).withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Stack(children: [
          Positioned(
            top: 0, bottom: 0, right: 0, left: 0,
            child: Icon(
              Icons.delete_outline_rounded,
              color: const Color(0xFF3A4756),
              size: 42,
            ),
          ),
          Dismissible(
            key: UniqueKey(),
            direction: DismissDirection.endToStart,
            onDismissed: (DismissDirection direction) => Provider.of<CartProvider>(context, listen: false).removeFromCart(cart!),
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge),
              decoration: BoxDecoration(
                color: const Color(0xFF3A4756).withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.delete_outline_rounded,
                color: Color(0xFF3A4756),
                size: 28,
              ),
            ),
            child: Container(
              padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [BoxShadow(
                  color: Theme.of(context).shadowColor.withValues(alpha: 0.10),
                  blurRadius: 18,
                  spreadRadius: 0,
                  offset: const Offset(0, 4),
                )],
              ),
              child: Column(
                children: [

                  Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: CustomImageWidget(
                        image: '${splashProvider.baseUrls?.productImageUrl}/${cart?.product?.image?[0]}',
                        height: 96, width: 96, fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: Dimensions.paddingSizeSmall),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // 1. Total price (big text)
                          CustomDirectionalityWidget(
                            child: Text(
                              PriceConverterHelper.convertPrice((cart?.discountedPrice ?? 0) * (cart?.quantity ?? 1)),
                              style: rubikBold.copyWith(
                                fontSize: Dimensions.fontSizeExtraLarge + 2,
                                color: Theme.of(context).primaryColor,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(height: 6),
                          // 2. Name
                          Text(
                            cart!.product!.name!,
                            style: rubikSemiBold.copyWith(fontSize: Dimensions.fontSizeDefault),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          // 3. Unit price with discount
                          _UnitPriceWithDiscount(
                            unitPrice: cart!.discountedPrice!,
                            originalUnitPrice: cart!.discountAmount! > 0 ? (cart!.discountedPrice! + cart!.discountAmount!) : null,
                            context: context,
                          ),
                          if (cart?.product?.variations != null && cart!.product!.variations!.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Text('${getTranslated('variation', context)}: ', style: rubikRegular.copyWith(fontSize: Dimensions.fontSizeSmall)),
                                Expanded(
                                  child: Text(
                                    variationText ?? '',
                                    overflow: TextOverflow.ellipsis,
                                    style: rubikRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),


                    IntrinsicWidth(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: isDesktop
                            ? Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  InkWell(
                                    onTap: () {
                                      if (cart!.quantity! > 1) {
                                        Provider.of<CartProvider>(context, listen: false).setQuantity(false, cart, cart!.stock, context, false, null);
                                        Provider.of<CouponProvider>(context, listen: false).removeCouponData(true);
                                      } else if (cart!.quantity == 1) {
                                        Provider.of<CartProvider>(context, listen: false).removeFromCart(cart!);
                                        Provider.of<CouponProvider>(context, listen: false).removeCouponData(true);
                                      }
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeExtraSmall),
                                      child: Icon(
                                        cart!.quantity == 1 ? CupertinoIcons.delete : Icons.remove,
                                        size: 20,
                                        color: Theme.of(context).primaryColor.withValues(alpha: 0.9),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeExtraSmall),
                                    child: Text(cart!.quantity.toString(), style: rubikMedium.copyWith(fontSize: Dimensions.fontSizeExtraLarge)),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      Provider.of<CouponProvider>(context, listen: false).removeCouponData(true);
                                      Provider.of<CartProvider>(context, listen: false).setQuantity(true, cart, cart!.stock, context, false, null);
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeExtraSmall),
                                      child: Icon(Icons.add, size: 20, color: Theme.of(context).primaryColor.withValues(alpha: 0.9)),
                                    ),
                                  ),
                                ],
                              )
                            : Padding(
                                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraSmall, vertical: Dimensions.paddingSizeExtraSmall),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        Provider.of<CouponProvider>(context, listen: false).removeCouponData(true);
                                        Provider.of<CartProvider>(context, listen: false).setQuantity(true, cart, cart!.stock, context, false, null);
                                      },
                                      child: Icon(Icons.add, size: 20, color: Theme.of(context).primaryColor.withValues(alpha: 0.9)),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(cart!.quantity.toString(), style: rubikMedium.copyWith(fontSize: Dimensions.fontSizeExtraLarge)),
                                    const SizedBox(height: 4),
                                    InkWell(
                                      onTap: () {
                                        if (cart!.quantity! > 1) {
                                          Provider.of<CartProvider>(context, listen: false).setQuantity(false, cart, cart!.stock, context, false, null);
                                          Provider.of<CouponProvider>(context, listen: false).removeCouponData(true);
                                        } else if (cart!.quantity == 1) {
                                          Provider.of<CartProvider>(context, listen: false).removeFromCart(cart!);
                                          Provider.of<CouponProvider>(context, listen: false).removeCouponData(true);
                                        }
                                      },
                                      child: Icon(
                                        cart!.quantity == 1 ? CupertinoIcons.delete : Icons.remove,
                                        size: 20,
                                        color: Theme.of(context).primaryColor.withValues(alpha: 0.9),
                                      ),
                                    ),
                                  ],
                                ),
                              )),
                    ),

                  ]),

                ],
              ),
            ),
          ),
        ]),
      ),
    );
  }

  static Widget _UnitPriceWithDiscount({
    required double unitPrice,
    required double? originalUnitPrice,
    required BuildContext context,
  }) {
    final bool isDesktop = ResponsiveHelper.isDesktop(context);
    final strikeColor = Theme.of(context).hintColor;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isDesktop)
          Text(
            '${getTranslated('unit_price', context)}: ',
            style: rubikRegular.copyWith(
              fontSize: Dimensions.fontSizeSmall,
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ),
        if (originalUnitPrice != null && originalUnitPrice > unitPrice) ...[
          CustomDirectionalityWidget(
            child: Text(
              PriceConverterHelper.convertPrice(originalUnitPrice),
              style: rubikRegular.copyWith(
                fontSize: Dimensions.fontSizeSmall,
                color: strikeColor,
                decoration: TextDecoration.lineThrough,
              ),
              maxLines: 1,
            ),
          ),
          const SizedBox(width: 6),
        ],
        Flexible(
          child: CustomDirectionalityWidget(
            child: Text(
              PriceConverterHelper.convertPrice(unitPrice),
              style: rubikSemiBold.copyWith(fontSize: Dimensions.fontSizeSmall),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ],
    );
  }

  String? getVariationText() {
    String? variationText = '';
    if(cart?.variation != null && cart!.variation!.isNotEmpty && cart!.variation!.first.type != null) {
      List<String> variationTypes =  cart!.variation!.first.type!.split('-');
      if(variationTypes.length == cart!.product!.choiceOptions!.length) {
        int index = 0;
        for (var choice in cart!.product!.choiceOptions!) {
          variationText = '${variationText!}${(index == 0) ? '' : ',  '}${choice.title} - ${variationTypes[index]}';
          index = index + 1;
        }
      }else {
        variationText = cart!.product!.variations![0].type;
      }
    }
    return variationText;
  }
}
