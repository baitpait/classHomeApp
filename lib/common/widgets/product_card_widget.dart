import 'package:hexacom_user/common/models/cart_model.dart';
import 'package:hexacom_user/common/models/product_model.dart';
import 'package:hexacom_user/helper/cart_helper.dart';
import 'package:hexacom_user/helper/price_converter_helper.dart';
import 'package:hexacom_user/helper/responsive_helper.dart';
import 'package:hexacom_user/localization/language_constrants.dart';
import 'package:hexacom_user/features/auth/providers/auth_provider.dart';
import 'package:hexacom_user/features/cart/providers/cart_provider.dart';
import 'package:hexacom_user/features/splash/providers/splash_provider.dart';
import 'package:hexacom_user/features/wishlist/providers/wishlist_provider.dart';
import 'package:hexacom_user/utill/color_resources.dart';
import 'package:hexacom_user/utill/dimensions.dart';
import 'package:hexacom_user/utill/images.dart';
import 'package:hexacom_user/utill/routes.dart';
import 'package:hexacom_user/utill/styles.dart';
import 'package:hexacom_user/common/widgets/custom_alert_dialog_widget.dart';
import 'package:hexacom_user/common/widgets/custom_directionality_widget.dart';
import 'package:hexacom_user/common/widgets/custom_image_widget.dart';
import 'package:hexacom_user/helper/custom_snackbar_helper.dart';
import 'package:hexacom_user/common/widgets/on_hover.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Returns product image URL or null if product has no image (avoids null/empty crash).
String? _productImageUrl(Product product, SplashProvider splashProvider) {
  if (product.image == null || product.image!.isEmpty) return null;
  return '${splashProvider.baseUrls!.productImageUrl}/${product.image!.first}';
}

Widget _buildProductImage(
  BuildContext context,
  Product product,
  SplashProvider splashProvider, {
  required double cacheWidth,
  required double cacheHeight,
}) {
  final url = _productImageUrl(product, splashProvider);
  if (url != null) {
    return CustomImageWidget(
      image: url,
      fit: BoxFit.cover,
      width: cacheWidth,
      height: cacheHeight,
    );
  }
  return Image.asset(Images.placeholder(context), fit: BoxFit.cover);
}

class ProductCardWidget extends StatelessWidget {
  final Product product;
  final Axis direction;
  const ProductCardWidget({super.key, required this.product, this.direction = Axis.vertical});

  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (context, cartProvider, _) {
        PriceRange priceRange = PriceConverterHelper.getPriceRange(product);
        double? discountedPrice = PriceConverterHelper.convertWithDiscount(product.price, product.discount, product.discountType);
        CartModel? cartModel = CartHelper.getCartModel(product);
        int? cartIndex = cartProvider.getCartProductIndex(cartModel);
        bool isExistInCart = cartIndex != null;

        // Skip OnHover for horizontal cards to avoid mouse_tracker assertion in horizontal scroll
        final content = InkWell(
          hoverColor: Colors.transparent,
          onTap: () => RouteHelper.getProductDetailsRoute(context, product.id),
          borderRadius: BorderRadius.circular(18),
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(18),
              boxShadow: direction == Axis.vertical
                  ? [
                      BoxShadow(
                        color: Theme.of(context).shadowColor.withValues(alpha: 0.1),
                        blurRadius: 24,
                        spreadRadius: 0,
                        offset: const Offset(0, 8),
                      ),
                      BoxShadow(
                        color: Theme.of(context).primaryColor.withValues(alpha: 0.05),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : [],
            ),
            clipBehavior: Clip.antiAlias,
            child: direction == Axis.vertical
                ? _VerticalCard(
                    product: product, isExistInCart: isExistInCart,
                    cartModel: cartModel, cartIndex: cartIndex,
                    discountedPrice: discountedPrice, priceRange: priceRange,
                  )
                : _HorizontalCard(
                    product: product, isExistInCart: isExistInCart,
                    cartModel: cartModel, cartIndex: cartIndex,
                    discountedPrice: discountedPrice, priceRange: priceRange,
                  ),
          ),
        );
        return direction == Axis.horizontal
            ? content
            : OnHover(isItem: true, child: content);
      },
    );
  }
}

class _VerticalCard extends StatelessWidget {
  final Product product;
  final bool isExistInCart;
  final CartModel? cartModel;
  final int? cartIndex;
  final double? discountedPrice;
  final PriceRange priceRange;

  const _VerticalCard({
    required this.product, required this.isExistInCart,
    required this.cartModel, required this.cartIndex,
    required this.discountedPrice, required this.priceRange,
  });

  @override
  Widget build(BuildContext context) {
    final splashProvider = Provider.of<SplashProvider>(context, listen: false);
    final hasNoVariations = product.variations == null || (product.variations?.isEmpty ?? false);

    return LayoutBuilder(
      builder: (context, constraints) {
        final hasBoundedHeight = constraints.maxHeight.isFinite;

        final topContent = Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (product.rating != null && product.rating!.isNotEmpty && (product.rating!.first.average?.length ?? 0) > 0)
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Row(children: [
                  Icon(Icons.star_rounded, color: ColorResources.getRatingColor(context), size: 14),
                  const SizedBox(width: 2),
                  Text(
                    double.parse(product.rating!.first.average ?? '0').toStringAsFixed(1),
                    style: rubikMedium.copyWith(fontSize: 11),
                  ),
                ]),
              ),
            Text(
              product.name ?? '',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: rubikMedium.copyWith(fontSize: 13, height: 1.2),
            ),
          ],
        );

        final priceCartRow = Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (product.price! > discountedPrice!)
                    CustomDirectionalityWidget(
                      child: Text(
                        PriceConverterHelper.convertPrice(priceRange.startPrice ?? 0),
                        style: rubikRegular.copyWith(
                          color: Theme.of(context).hintColor.withValues(alpha: 0.65),
                          decoration: TextDecoration.lineThrough,
                          fontSize: 12,
                          height: 1.2,
                        ),
                      ),
                    ),
                  CustomDirectionalityWidget(
                    child: Text(
                      PriceConverterHelper.convertPrice(
                        priceRange.startPrice ?? 0,
                        discount: product.discount,
                        discountType: product.discountType,
                      ),
                      style: rubikBold.copyWith(
                        fontSize: 16,
                        color: Theme.of(context).primaryColor,
                        height: 1,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            _AddToCartButton(
              product: product,
              isExistInCart: isExistInCart,
              cartModel: cartModel,
              cartIndex: cartIndex,
              hasNoVariations: hasNoVariations,
            ),
          ],
        );

        return Column(
          mainAxisSize: hasBoundedHeight ? MainAxisSize.max : MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
      AspectRatio(
        aspectRatio: 1.1,
        child: Stack(children: [
          Positioned.fill(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return _buildProductImage(
                  context,
                  product,
                  splashProvider,
                  cacheWidth: constraints.maxWidth,
                  cacheHeight: constraints.maxHeight,
                );
              },
            ),
          ),

          // Limited stock badge (current stock at or below minimum_stock_alert)
          if (product.totalStock != null && product.totalStock! > 0 &&
              product.minimumStockAlert != null && product.totalStock! <= product.minimumStockAlert!)
            Positioned(
              top: 8,
              left: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange.shade700,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  getTranslated('limited_stock', context),
                  style: rubikMedium.copyWith(fontSize: 11, color: Colors.white),
                ),
              ),
            ),

          // Discount Badge & Wishlist
          Positioned(top: 10, left: 10, right: 10, child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (product.discount != 0) 
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: CustomDirectionalityWidget(child: Text(
                    product.discountType == 'percent'
                        ? '-${product.discount}%'
                        : '-${PriceConverterHelper.convertPrice(product.discount)}',
                    style: rubikBold.copyWith(fontSize: 12, color: Colors.white),
                  )),
                )
              else 
                SizedBox(
                  width: 50,
                  height: 32,
                ),

              ProductWishListButton(product: product),
            ],
          )),

          // Out of Stock Overlay — 50% black + "نفذ المخزون" (on top so always visible)
          if ((product.totalStock ?? 0) < 1)
            Positioned.fill(
              child: IgnorePointer(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.zero,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    getTranslated('stock_run_out', context),
                    style: rubikSemiBold.copyWith(
                      fontSize: 15,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
        ]),
      ),

      hasBoundedHeight
          ? Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [topContent, priceCartRow],
                ),
              ),
            )
          : Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
                topContent,
                const SizedBox(height: 8),
                priceCartRow,
              ]),
            ),
    ]);
      },
    );
  }
}

/// Image strip width inside horizontal card (content area uses remainder). Parent must provide width/height via [Dimensions.horizontalProductCardWidth] / [Dimensions.horizontalProductCardHeight].
const double _kHorizontalCardImageWidth = 150.0;
const double _kHorizontalCardImageMargin = 6.0;

class _HorizontalCard extends StatelessWidget {
  final Product product;
  final bool isExistInCart;
  final CartModel? cartModel;
  final int? cartIndex;
  final double? discountedPrice;
  final PriceRange priceRange;

  const _HorizontalCard({
    required this.product, required this.isExistInCart,
    required this.cartModel, required this.cartIndex,
    required this.discountedPrice, required this.priceRange,
  });

  @override
  Widget build(BuildContext context) {
    final splashProvider = Provider.of<SplashProvider>(context, listen: false);
    final hasNoVariations = product.variations == null || (product.variations?.isEmpty ?? false);
    final theme = Theme.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth.isFinite && constraints.maxWidth > 0
            ? constraints.maxWidth
            : Dimensions.horizontalProductCardWidth;
        final height = constraints.maxHeight.isFinite && constraints.maxHeight > 0
            ? constraints.maxHeight
            : Dimensions.horizontalProductCardHeight;
        return SizedBox(
          width: width,
          height: height,
          child: Container(
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(14),
            ),
            clipBehavior: Clip.antiAlias,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Fixed-width image block with margin and wishlist overlay (name gets full row in content)
                SizedBox(
                  width: _kHorizontalCardImageWidth,
                  child: Padding(
                    padding: const EdgeInsets.all(_kHorizontalCardImageMargin),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Positioned.fill(
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                return _buildProductImage(
                                  context,
                                  product,
                                  splashProvider,
                                  cacheWidth: constraints.maxWidth,
                                  cacheHeight: constraints.maxHeight,
                                );
                              },
                            ),
                          ),
                          if ((product.totalStock ?? 0) < 1)
                            Positioned.fill(
                              child: IgnorePointer(
                                child: Container(
                                  color: Colors.black.withValues(alpha: 0.5),
                                  alignment: Alignment.center,
                                  child: Text(
                                    getTranslated('stock_run_out', context),
                                    style: rubikSemiBold.copyWith(fontSize: 12, color: Colors.white),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ),
                          if (product.totalStock != null && product.totalStock! > 0 &&
                              product.minimumStockAlert != null && product.totalStock! <= product.minimumStockAlert!)
                            Positioned(
                              bottom: 4,
                              left: 4,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                decoration: BoxDecoration(
                                  color: Colors.orange.shade700,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  getTranslated('limited_stock', context),
                                  style: rubikMedium.copyWith(fontSize: 10, color: Colors.white),
                                ),
                              ),
                            ),
                          if (product.discount != 0)
                            Positioned(
                              top: 4,
                              left: 4,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                decoration: BoxDecoration(
                                  color: theme.primaryColor,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: CustomDirectionalityWidget(
                                  child: Text(
                                    product.discountType == 'percent'
                                        ? '-${product.discount}%'
                                        : '-${PriceConverterHelper.convertPrice(product.discount)}',
                                    style: rubikMedium.copyWith(fontSize: 10, color: Colors.white),
                                  ),
                                ),
                              ),
                            ),
                          Positioned(top: 4, right: 4, child: ProductWishListButton(product: product)),
                        ],
                      ),
                    ),
                  ),
                ),
                // Content: name on its own row, then rating, prices, add button
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          product.name ?? '',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: rubikSemiBold.copyWith(fontSize: 13, height: 1.25),
                        ),
                        if (product.rating != null &&
                            product.rating!.isNotEmpty &&
                            (product.rating!.first.average?.length ?? 0) > 0) ...[
                          const SizedBox(height: 4),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.star_rounded, color: ColorResources.getRatingColor(context), size: 12),
                              const SizedBox(width: 2),
                              Text(
                                double.parse(product.rating!.first.average ?? '0').toStringAsFixed(1),
                                style: rubikMedium.copyWith(fontSize: 11),
                              ),
                            ],
                          ),
                        ],
                        const Spacer(),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (product.price! > discountedPrice!)
                                    CustomDirectionalityWidget(
                                      child: Text(
                                        PriceConverterHelper.convertPrice(priceRange.startPrice ?? 0),
                                        style: rubikRegular.copyWith(
                                          color: theme.hintColor.withValues(alpha: 0.8),
                                          decoration: TextDecoration.lineThrough,
                                          fontSize: 11,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  CustomDirectionalityWidget(
                                    child: Text(
                                      PriceConverterHelper.convertPrice(
                                        priceRange.startPrice ?? 0,
                                        discount: product.discount,
                                        discountType: product.discountType,
                                      ),
                                      style: rubikBold.copyWith(fontSize: 14, color: theme.primaryColor),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            _AddToCartButton(
                              product: product,
                              isExistInCart: isExistInCart,
                              cartModel: cartModel,
                              cartIndex: cartIndex,
                              hasNoVariations: hasNoVariations,
                              hasShadow: false,
                            ),
                          ],
                        ),
                      ],
                    ),
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

class _AddToCartButton extends StatelessWidget {
  final Product product;
  final bool isExistInCart;
  final CartModel? cartModel;
  final int? cartIndex;
  final bool hasNoVariations;
  final bool isWideCard;
  final bool hasShadow;

  const _AddToCartButton({
    required this.product, required this.isExistInCart,
    required this.cartModel, required this.cartIndex,
    required this.hasNoVariations,
    this.isWideCard = false,
    this.hasShadow = true,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(builder: (context, cartProvider, _) {
      if (isExistInCart && hasNoVariations) {
        return Container(
          width: isWideCard ? double.infinity : null,
          constraints: isWideCard ? const BoxConstraints(minHeight: 44) : null,
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            borderRadius: BorderRadius.circular(isWideCard ? 10 : 8),
            boxShadow: hasShadow
                ? [
                    BoxShadow(
                      color: Theme.of(context).primaryColor.withValues(alpha: 0.25),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [],
          ),
          child: Row(
            mainAxisSize: isWideCard ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              InkWell(
                onTap: () {
                  if (cartProvider.cartList[cartIndex!]!.quantity! > 1) {
                    cartProvider.setQuantity(
                      false, cartModel, cartModel!.stock,
                      context, true, cartProvider.getCartProductIndex(cartModel),
                    );
                  } else {
                    cartProvider.removeFromCart(cartProvider.cartList[cartIndex!]!);
                    showCustomSnackBar(getTranslated('remove_from_cart', context), context, isError: false);
                  }
                },
                child: Padding(
                  padding: EdgeInsets.all(isWideCard ? 10 : 6),
                  child: const Icon(Icons.remove, color: Colors.white, size: 18),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  '${cartProvider.cartList[cartIndex!]?.quantity}',
                  style: rubikBold.copyWith(color: Colors.white, fontSize: isWideCard ? 15 : 14),
                ),
              ),
              InkWell(
                onTap: () => cartProvider.setQuantity(
                  true, cartModel, cartModel?.stock, context,
                  true, cartProvider.getCartProductIndex(cartModel),
                ),
                child: Padding(
                  padding: EdgeInsets.all(isWideCard ? 10 : 6),
                  child: const Icon(Icons.add, color: Colors.white, size: 18),
                ),
              ),
            ],
          ),
        );
      }

      final isOutOfStock = hasNoVariations && (cartModel?.stock ?? 0) < 1;
      final borderRadius = isWideCard ? 10.0 : 8.0;
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isOutOfStock
              ? null
              : () {
                  if (product.variations == null || product.variations!.isEmpty) {
                    if (isExistInCart) {
                      showCustomSnackBar(getTranslated('already_added', context), context);
                    } else {
                      cartProvider.addToCart(cartModel!, null);
                      showCustomSnackBar(getTranslated('added_to_cart', context), context, isError: false);
                    }
                  } else {
                    RouteHelper.getProductDetailsRoute(context, product.id);
                  }
                },
          borderRadius: BorderRadius.circular(borderRadius),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: isWideCard ? double.infinity : null,
            constraints: isWideCard ? const BoxConstraints(minHeight: 44) : null,
            padding: EdgeInsets.symmetric(
              horizontal: isWideCard ? 14 : 10,
              vertical: isWideCard ? 10 : 8,
            ),
            decoration: BoxDecoration(
              color: isOutOfStock
                  ? Theme.of(context).hintColor.withValues(alpha: 0.12)
                  : (isWideCard 
                      ? Theme.of(context).primaryColor 
                      : Theme.of(context).primaryColor.withValues(alpha: 0.12)),
              borderRadius: BorderRadius.circular(borderRadius),
              boxShadow: (!hasShadow || isOutOfStock)
                  ? []
                  : [
                      BoxShadow(
                        color: Theme.of(context).primaryColor.withValues(
                          alpha: isWideCard ? 0.25 : 0.1,
                        ),
                        blurRadius: isWideCard ? 12 : 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
            ),
            alignment: isWideCard ? Alignment.center : null,
            child: isWideCard && !isOutOfStock
                ? FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.shopping_cart_rounded, size: 22, color: Colors.white),
                        const SizedBox(width: 8),
                        Text(
                          getTranslated('add_to_cart', context),
                          style: rubikSemiBold.copyWith(color: Colors.white, fontSize: 22),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  )
                : isWideCard && isOutOfStock
                    ? Text(
                        getTranslated('out_of_stock', context),
                        style: rubikMedium.copyWith(
                          color: Theme.of(context).hintColor,
                          fontSize: 13,
                        ),
                      )
                    : Icon(
                        Icons.add_shopping_cart_rounded,
                        size: 20,
                        color: isOutOfStock 
                            ? Theme.of(context).hintColor 
                            : Theme.of(context).primaryColor,
                      ),
          ),
        ),
      );
    });
  }
}

class ProductWishListButton extends StatelessWidget {
  final Product product;
  const ProductWishListButton({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Consumer<WishListProvider>(
      builder: (context, wishListProvider, _) {
        final isFav = wishListProvider.wishIdList.contains(product.id);
        return InkWell(
          onTap: () {
            if (Provider.of<AuthProvider>(context, listen: false).isLoggedIn()) {
              if (isFav) {
                ResponsiveHelper.showDialogOrBottomSheet(context, CustomAlertDialogWidget(
                  title: getTranslated('remove_from_wish_list', context),
                  subTitle: getTranslated('remove_this_item_from_your_favorite_list', context),
                  icon: Icons.contact_support_outlined,
                  leftButtonText: getTranslated('cancel', context),
                  rightButtonText: getTranslated('remove', context),
                  buttonColor: Theme.of(context).colorScheme.error.withValues(alpha: 0.9),
                  onPressRight: () {
                    Navigator.pop(context);
                    wishListProvider.removeFromWishList(product, context);
                  },
                ));
              } else {
                wishListProvider.addToWishList(product);
              }
            } else {
              showCustomSnackBar(getTranslated('now_you_are_in_guest_mode', context), context);
            }
          },
          borderRadius: BorderRadius.circular(50),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 36,
            width: 36,
            decoration: BoxDecoration(
              color: isFav 
                  ? Theme.of(context).primaryColor.withValues(alpha: 0.15)
                  : Theme.of(context).cardColor.withValues(alpha: 0.95),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Icon(
              isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              color: isFav 
                  ? Theme.of(context).primaryColor 
                  : Theme.of(context).textTheme.bodyLarge?.color,
              size: 20,
            ),
          ),
        );
      },
    );
  }
}

class ProductImageView extends StatelessWidget {
  const ProductImageView({super.key,
    required this.product,
    required this.isExistInCart,
    required this.cartModel,
    required this.cartIndex,
    required this.direction,
  });

  final Product product;
  final bool isExistInCart;
  final CartModel? cartModel;
  final int? cartIndex;
  final Axis? direction;

  @override
  Widget build(BuildContext context) {
    return const SizedBox();
  }
}
