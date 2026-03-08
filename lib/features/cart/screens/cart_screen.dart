import 'package:flutter/material.dart';
import 'package:hexacom_user/common/enums/footer_type_enum.dart';
import 'package:hexacom_user/common/widgets/custom_web_title_widget.dart';
import 'package:hexacom_user/common/widgets/footer_web_widget.dart';
import 'package:hexacom_user/common/widgets/no_data_screen.dart';
import 'package:hexacom_user/common/widgets/web_app_bar_widget.dart';
import 'package:hexacom_user/features/cart/providers/cart_provider.dart';
import 'package:hexacom_user/features/cart/widgets/button_view_widget.dart';
import 'package:hexacom_user/features/cart/widgets/cart_details_widget.dart';
import 'package:hexacom_user/features/cart/widgets/cart_product_list_widget.dart';
import 'package:hexacom_user/features/checkout/providers/checkout_provider.dart';
import 'package:hexacom_user/features/coupon/providers/coupon_provider.dart';
import 'package:hexacom_user/helper/price_converter_helper.dart';
import 'package:hexacom_user/helper/responsive_helper.dart';
import 'package:hexacom_user/localization/language_constrants.dart';
import 'package:hexacom_user/utill/dimensions.dart';
import 'package:hexacom_user/utill/images.dart';
import 'package:hexacom_user/utill/styles.dart';
import 'package:provider/provider.dart';

class CartScreen extends StatefulWidget {
  final bool fromDetails;
  const CartScreen({super.key, this.fromDetails = false});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final TextEditingController couponController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Provider.of<CouponProvider>(context, listen: false).removeCouponData(false);
    Provider.of<CheckoutProvider>(context, listen: false).setOrderType('delivery', notify: false);
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height;
    final bool isDesktop = ResponsiveHelper.isDesktop(context);
    final double paddingBottom = MediaQuery.of(context).padding.bottom;
    final double bottomPaddingValue = !isDesktop ? Dimensions.bottomNavBarHeight + paddingBottom : 0.0;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: isDesktop
          ? const PreferredSize(
              preferredSize: Size.fromHeight(120),
              child: WebAppBarWidget(),
            )
          : null,
      body: Padding(
        padding: EdgeInsets.only(bottom: bottomPaddingValue),
        child: Consumer<CartProvider>(
        builder: (context, cart, child) {
          double? deliveryCharge = 0;
          double itemPrice = 0;
          double discount = 0;
          double tax = 0;
          for (var cartModel in cart.cartList) {
            itemPrice = itemPrice + (cartModel!.price! * cartModel.quantity!);
            discount = discount + (cartModel.discountAmount! * cartModel.quantity!);
            tax = tax + (cartModel.taxAmount! * cartModel.quantity!);
          }
          double subTotal = itemPrice - discount;
          double total = subTotal - Provider.of<CouponProvider>(context).discount! + deliveryCharge + tax;

          return cart.cartList.isNotEmpty ? Column(children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    Center(
                      child: Container(
                        padding: isDesktop
                            ? const EdgeInsets.all(Dimensions.paddingSizeSmall)
                            : const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
                        constraints: BoxConstraints(minHeight: !isDesktop && height < 600 ? height : height - 400),
                        width: isDesktop ? Dimensions.getWebContentWidth(MediaQuery.sizeOf(context).width) : MediaQuery.sizeOf(context).width,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomWebTitleWidget(title: getTranslated('', context)),

                            Container(
                              margin: const EdgeInsets.only(
                                left: Dimensions.paddingSizeSmall,
                                right: Dimensions.paddingSizeSmall,
                                bottom: Dimensions.paddingSizeLarge,
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: Dimensions.paddingSizeLarge,
                                vertical: Dimensions.paddingSizeDefault,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                color: const Color(0xFF3A4756),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.15),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.shopping_bag_outlined, color: Colors.white, size: 22),
                                  ),
                                  const SizedBox(width: Dimensions.paddingSizeDefault),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          Localizations.localeOf(context).languageCode == 'ar'
                                              ? 'السلة'
                                              : 'Cart',
                                          style: rubikSemiBold.copyWith(
                                            fontSize: Dimensions.fontSizeLarge,
                                            color: Colors.white,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          '${cart.cartList.length} ${getTranslated('items', context)}',
                                          style: rubikRegular.copyWith(
                                            fontSize: Dimensions.fontSizeSmall,
                                            color: Colors.white.withValues(alpha: 0.7),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        getTranslated('total_amount', context),
                                        style: rubikRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Colors.white.withValues(alpha: 0.7)),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        PriceConverterHelper.convertPrice(total),
                                        style: rubikBold.copyWith(
                                          color: Colors.white,
                                          fontSize: Dimensions.fontSizeExtraLarge,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            if(!isDesktop) const CartProductListWidget(),

                            if(!isDesktop) CartDetailsWidget(
                              itemPrice: itemPrice,
                              tax: tax,
                              discount: discount,
                              deliveryCharge: deliveryCharge,
                              total: total, couponController: couponController,
                              subTotal: subTotal,
                            ),

                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if(isDesktop) Expanded(
                                  flex: 7,
                                  child: Container(
                                    padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).cardColor,
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: const CartProductListWidget(),
                                  ),
                                ),
                                const SizedBox(width: Dimensions.paddingSizeLarge),

                                if(isDesktop) Expanded(
                                  flex: 4,
                                  child: CartDetailsWidget(
                                    itemPrice: itemPrice,
                                    tax: tax,
                                    discount: discount,
                                    deliveryCharge: deliveryCharge,
                                    total: total,
                                    couponController: couponController,
                                    subTotal: subTotal,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    const FooterWebWidget(footerType: FooterType.nonSliver),
                  ],
                ),
              ),
            ),

            if(!isDesktop) SafeArea(
              child: ButtonViewWidget(
                itemPrice: itemPrice, total: total,
                deliveryCharge: deliveryCharge, discount: discount,
              ),
            ),

          ]) : NoDataScreen(
            image: Images.wishListNoData,
            title: getTranslated('empty_cart', context),
            subTitle: getTranslated('look_like_have_not_added', context),
            showFooter: true,
          );
        },
      ),
      ),
    );
  }
}
