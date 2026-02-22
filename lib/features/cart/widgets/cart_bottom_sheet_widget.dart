import 'package:hexacom_user/common/models/cart_model.dart';
import 'package:hexacom_user/common/models/product_model.dart';
import 'package:hexacom_user/common/widgets/custom_image_widget.dart';
import 'package:hexacom_user/features/product/widgets/quantity_widget.dart';
import 'package:hexacom_user/features/rate_review/providers/rate_review_provider.dart';
import 'package:hexacom_user/helper/cart_helper.dart';
import 'package:hexacom_user/helper/custom_snackbar_helper.dart';
import 'package:hexacom_user/helper/price_converter_helper.dart';
import 'package:hexacom_user/localization/language_constrants.dart';
import 'package:hexacom_user/features/cart/providers/cart_provider.dart';
import 'package:hexacom_user/features/product/providers/product_provider.dart';
import 'package:hexacom_user/features/splash/providers/splash_provider.dart';
import 'package:hexacom_user/utill/color_resources.dart';
import 'package:hexacom_user/utill/dimensions.dart';
import 'package:hexacom_user/utill/images.dart';
import 'package:hexacom_user/utill/styles.dart';
import 'package:hexacom_user/common/widgets/custom_button_widget.dart';
import 'package:hexacom_user/common/widgets/custom_directionality_widget.dart';
import 'package:hexacom_user/common/widgets/rating_bar_widget.dart';
import 'package:hexacom_user/common/widgets/wish_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CartBottomSheetWidget extends StatefulWidget {
  final Product? product;
  final bool fromOfferProduct;
  final Function? callback;
  final CartModel? cart;
  final int? cartIndex;
  const CartBottomSheetWidget({super.key, required this.product, this.fromOfferProduct = false, this.callback, this.cart, this.cartIndex});

  @override
  State<CartBottomSheetWidget> createState() => _CartBottomSheetWidgetState();
}

class _CartBottomSheetWidgetState extends State<CartBottomSheetWidget> {

  @override
  void initState() {
    Provider.of<ProductProvider>(context, listen: false).getProductDetails(widget.product!, widget.cart);
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    Provider.of<ProductProvider>(context, listen: false).initDataLoad(widget.product, widget.cart, isUpdate: false);
    Provider.of<RateReviewProvider>(context, listen: false).setProductReviewList = [];

    return Consumer<CartProvider>(builder: (context, cartProvider, _) {
      return Container(
        padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: const BorderRadius.only(topRight: Radius.circular(20), topLeft: Radius.circular(20)),
        ),
        child: Consumer<ProductProvider>(builder: (context, productProvider, child) {
          PriceRange priceRange = PriceConverterHelper.getPriceRange(widget.product!);
          double? priceWithQuantity;
          double? priceWithDiscount;
          bool isExistInCart = false;
          CartModel? cartModel;

          if(productProvider.product != null){

            cartModel = CartHelper.getCartModel(productProvider.product!, variationIndexList: productProvider.variationIndex, quantity: productProvider.quantity);
            priceWithDiscount = PriceConverterHelper.convertWithDiscount((cartModel?.price ?? 0), productProvider.product!.discount, productProvider.product!.discountType);

            isExistInCart = cartProvider.isExistInCart(cartModel, false, null);

            if(isExistInCart) {
              priceWithQuantity = priceWithDiscount! * cartProvider.updatedCartList[cartProvider.getCartProductIndex(cartModel)!]!.quantity!;

            }else {
              priceWithQuantity = priceWithDiscount! * productProvider.quantity!;

            }
          }

          return SingleChildScrollView(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            //Product
            Row(children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: CustomImageWidget(
                  placeholder: Images.placeholder(context),
                  image: '${Provider.of<SplashProvider>(context, listen: false).baseUrls!.productImageUrl}/${widget.product!.image![0]}',
                  width: 100, height: 100, fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: Dimensions.paddingSizeSmall),

              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(
                  widget.product?.name ?? '', maxLines: 2, overflow: TextOverflow.ellipsis,
                  style: rubikMedium.copyWith(fontSize: Dimensions.fontSizeLarge),
                ),

                if(widget.product!.rating != null) RatingBarWidget(rating: widget.product!.rating!.isNotEmpty ? double.parse(widget.product!.rating![0].average!) : 0.0, size: 15),
                const SizedBox(height: Dimensions.paddingSizeSmall),

                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  CustomDirectionalityWidget(child: Text(
                    '${PriceConverterHelper.convertPrice(priceRange.startPrice, discount: widget.product!.discount, discountType: widget.product!.discountType)}'
                        '${priceRange.endPrice != null ? ' - ${PriceConverterHelper.convertPrice(priceRange.endPrice, discount: widget.product!.discount,
                        discountType: widget.product!.discountType)}' : ''}',
                    style: rubikMedium.copyWith(fontSize: Dimensions.fontSizeLarge),
                  )),

                  widget.product?.price == priceWithDiscount ? WishButtonWidget(product: widget.product) : const SizedBox(),
                ]),

                (widget.product?.price ?? 0) > (priceWithDiscount ?? 0) ?
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  CustomDirectionalityWidget(child: Text(
                    '${PriceConverterHelper.convertPrice(priceRange.startPrice)}'
                        '${priceRange.endPrice!= null ? ' - ${PriceConverterHelper.convertPrice(priceRange.endPrice)}' : ''}',
                    style: rubikMedium.copyWith(color: ColorResources.colorGrey, decoration: TextDecoration.lineThrough),
                  )),

                  WishButtonWidget(product: widget.product),
                ]) : const SizedBox(),
              ])),
            ]),
            const SizedBox(height: Dimensions.paddingSizeLarge),

            // Quantity
            Row(children: [
              Text(getTranslated('quantity', context), style: rubikMedium.copyWith(fontSize: Dimensions.fontSizeLarge)),
              const Expanded(child: SizedBox()),

              QuantityWidget(cartModel: cartModel, isExistInCart: isExistInCart, stock: cartModel?.stock ?? 0),
            ]),
            const SizedBox(height: Dimensions.paddingSizeLarge),

            // Variation
            ListView.builder(
              shrinkWrap: true,
              itemCount: widget.product?.choiceOptions?.length,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(widget.product!.choiceOptions![index].title!, style: rubikMedium.copyWith(fontSize: Dimensions.fontSizeLarge)),
                  const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                  GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 20,
                      mainAxisSpacing: 10,
                      childAspectRatio: (1 / 0.25),
                    ),
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: widget.product!.choiceOptions![index].options!.length,
                    itemBuilder: (context, i) {
                      return InkWell(
                        onTap: () {
                          productProvider.setCartVariationIndex(index, i);
                        },
                        child: Container(
                          alignment: Alignment.center,
                          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraSmall),
                          decoration: BoxDecoration(
                            color: productProvider.variationIndex![index] != i ? Theme.of(context).dividerColor.withValues(alpha: 0.3) : Theme.of(context).primaryColor,
                            borderRadius: BorderRadius.circular(5),
                            border: productProvider.variationIndex![index] != i ? Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.5), width: 1) : null,
                          ),
                          child: Text(
                            widget.product!.choiceOptions![index].options![i].trim(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: rubikRegular.copyWith(
                              color: productProvider.variationIndex![index] != i ? Colors.black : Colors.white,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  SizedBox(height: index != widget.product!.choiceOptions!.length-1 ? Dimensions.paddingSizeLarge : 0),
                ]);
              },
            ),
            widget.product!.choiceOptions!.isNotEmpty ? const SizedBox(height: Dimensions.paddingSizeLarge) : const SizedBox(),

            widget.fromOfferProduct ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(getTranslated('description', context), style: rubikMedium.copyWith(fontSize: Dimensions.fontSizeLarge)),
              const SizedBox(height: Dimensions.paddingSizeExtraSmall),

              Text(widget.product!.description ?? '', style: rubikRegular),
              const SizedBox(height: Dimensions.paddingSizeLarge),
            ]) : const SizedBox(),

            Row(children: [
              Text('${getTranslated('total_amount', context)}:', style: rubikMedium.copyWith(fontSize: Dimensions.fontSizeLarge)),
              const SizedBox(width: Dimensions.paddingSizeExtraSmall),

              CustomDirectionalityWidget(
                child: Text(PriceConverterHelper.convertPrice(priceWithQuantity), style: rubikBold.copyWith(
                  color: Theme.of(context).primaryColor, fontSize: Dimensions.fontSizeLarge,
                )),
              ),
            ]),
            const SizedBox(height: Dimensions.paddingSizeLarge),

            CustomButtonWidget(
              btnTxt: _getCartButtonText(cartModel, context, isExistInCart),
              backgroundColor: Theme.of(context).primaryColor,
              onTap: _onSubmitCartButton(cartProvider, cartModel, isExistInCart, context),
            ),

          ]));
        }),
      );
    });
  }

  VoidCallback? _onSubmitCartButton(CartProvider cartProvider, CartModel? cartModel, bool isExistInCart, BuildContext context) {
    return (cartModel?.stock ?? 0) > 0 ? () {
      Navigator.pop(context);

      if(cartProvider.pendingCartList.isNotEmpty) {
        cartProvider.updateCart();
        showCustomSnackBar(getTranslated('cart_updated', context), context, isError: false);

      }else {
        if (!isExistInCart && (cartModel?.stock ?? 0) > 0) {
          cartProvider.addToCart(cartModel!, null);
          showCustomSnackBar(getTranslated('added_to_cart', context), context, isError: false);


        } else {
          showCustomSnackBar(getTranslated('already_added', context), context);
        }
      }
    } : null;
  }

  String _getCartButtonText(CartModel? cartModel, BuildContext context, bool isExistInCart) {
    if (isExistInCart) {
      return getTranslated('update_cart', context);
    }

    if ((cartModel?.stock ?? 0) <= 0) {
      return getTranslated('out_of_stock', context);
    }

    return getTranslated('add_to_cart', context);
  }
}


