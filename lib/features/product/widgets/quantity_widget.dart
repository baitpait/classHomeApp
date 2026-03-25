import 'package:flutter/material.dart';
import 'package:hexacom_user/common/models/cart_model.dart';
import 'package:hexacom_user/features/cart/providers/cart_provider.dart';
import 'package:hexacom_user/features/product/providers/product_provider.dart';
import 'package:hexacom_user/helper/custom_snackbar_helper.dart';
import 'package:hexacom_user/helper/responsive_helper.dart';
import 'package:hexacom_user/localization/language_constrants.dart';
import 'package:hexacom_user/utill/dimensions.dart';
import 'package:hexacom_user/utill/styles.dart';
import 'package:provider/provider.dart';


class QuantityWidget extends StatelessWidget {
  final CartModel? cartModel;
  final bool isExistInCart;
  final int stock;
  const QuantityWidget({super.key, required this.cartModel, required this.isExistInCart, required this.stock});


  @override
  Widget build(BuildContext context) {
    final CartProvider cartProvider = Provider.of<CartProvider>(context, listen: false);
    final isDesktop = ResponsiveHelper.isDesktop(context);
    final pillRadius = BorderRadius.circular(isDesktop ? 40 : 25);
    final pillBg = Theme.of(context).primaryColor.withValues(alpha: 0.08);

    return Consumer<ProductProvider>(
        builder: (context, productProvider, _) {
          return Container(
            decoration: BoxDecoration(
              color: pillBg,
              borderRadius: pillRadius,
            ),
            child: Row(children: [
              _QuantityButtonWidget(
                isIncrement: false,
                quantity: isExistInCart
                    ? cartProvider.updatedCartList[cartProvider.getCartProductIndex(cartModel)!]!.quantity
                    : productProvider.quantity,
                stock: stock,
                isExistInCart : isExistInCart,
                cart: cartModel,
              ),
              if(isDesktop) const SizedBox(width: 26),

              Text(
                isExistInCart ? cartProvider.updatedCartList[cartProvider.getCartProductIndex(cartModel)!]!.quantity.toString() : productProvider.quantity.toString(),
                style: rubikBold.copyWith(fontSize: Dimensions.fontSizeExtraLarge, color: Theme.of(context).primaryColor),
              ),
              if(isDesktop) const SizedBox(width: 26),


              _QuantityButtonWidget(
                isIncrement: true, quantity: isExistInCart
                  ? cartProvider.updatedCartList[cartProvider.getCartProductIndex(cartModel)!]!.quantity
                  : productProvider.quantity,
                stock: stock, cart: cartModel,
                isExistInCart: isExistInCart,
              ),
            ]),
          );
        }
    );
  }

}


class _QuantityButtonWidget extends StatelessWidget {
  final bool isIncrement;
  final int? quantity;
  final int? stock;
  final bool isExistInCart;
  final CartModel? cart;
  const _QuantityButtonWidget({
    required this.isIncrement,
    required this.quantity,
    required this.stock,
    required this.isExistInCart,
    required this.cart,
  });

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveHelper.isDesktop(context);
    final radius = BorderRadius.circular(isDesktop ? 40 : 25);
    final canDecrement = (quantity ?? 0) > 1;
    final canIncrement = (quantity ?? 0) < (stock ?? 0);
    final isEnabled = isIncrement ? canIncrement : canDecrement;
    final bg = Theme.of(context).primaryColor.withValues(alpha: isEnabled ? 0.12 : 0.06);
    final fg = isEnabled ? Theme.of(context).primaryColor : Theme.of(context).disabledColor;

    return InkWell(
      radius: isDesktop ? 40 : 25,
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      onTap:  () {
        if(isExistInCart) {
          if (!isIncrement) {
            if(quantity! > 1){
              Provider.of<CartProvider>(context, listen: false).initialUpdateCartQuantity(false, Provider.of<CartProvider>(context, listen: false).getCartProductIndex(cart));
            }else{

             // Provider.of<CartProvider>(context, listen: false).removeFromCart(Provider.of<CartProvider>(context, listen: false).cartList[Provider.of<CartProvider>(context, listen: false).getCartProductIndex(cart)!]!);
            }
          } else if (isIncrement) {
            if(quantity! < stock!) {
              Provider.of<CartProvider>(context, listen: false).initialUpdateCartQuantity(true, Provider.of<CartProvider>(context, listen: false).getCartProductIndex(cart));
            }else {
              showCustomSnackBar(getTranslated('out_of_stock', context), context);
            }
          }
        } else {
          if (!isIncrement && quantity! > 1) {
            Provider.of<ProductProvider>(context, listen: false).setProductQuantity(false, stock, context);
          } else if (isIncrement) {
            if(quantity! < stock!) {
              Provider.of<ProductProvider>(context, listen: false).setProductQuantity(true, stock, context);
            }else {
              showCustomSnackBar(getTranslated('out_of_stock', context), context);
            }
          }

        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        height: 40,
        width: 40,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: radius,
        ),
        child: Center(
          child: Icon(
            isIncrement ? Icons.add : Icons.remove,
            color: fg,
            size: 20,
          ),
        ),
      ),
    );
  }
}