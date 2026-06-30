import 'package:flutter/material.dart';
import 'package:hexacom_user/common/enums/footer_type_enum.dart';
import 'package:hexacom_user/common/models/check_out_model.dart';
import 'package:hexacom_user/common/models/config_model.dart';
import 'package:hexacom_user/common/widgets/custom_text_field_widget.dart';
import 'package:hexacom_user/common/widgets/custom_web_title_widget.dart';
import 'package:hexacom_user/common/widgets/footer_web_widget.dart';
import 'package:hexacom_user/common/widgets/no_data_screen.dart';
import 'package:hexacom_user/common/widgets/web_app_bar_widget.dart';
import 'package:hexacom_user/features/address/providers/address_provider.dart';
import 'package:hexacom_user/features/auth/providers/auth_provider.dart';
import 'package:hexacom_user/features/cart/providers/cart_provider.dart';
import 'package:hexacom_user/features/cart/widgets/cart_delivery_address_section_widget.dart';
import 'package:hexacom_user/features/cart/widgets/cart_details_widget.dart';
import 'package:hexacom_user/features/cart/widgets/cart_product_list_widget.dart';
import 'package:hexacom_user/features/checkout/providers/checkout_provider.dart';
import 'package:hexacom_user/features/checkout/widgets/place_order_button_view.dart';
import 'package:hexacom_user/features/checkout/widgets/payment_info_widget.dart';
import 'package:hexacom_user/features/order/enums/delivery_charge_type.dart';
import 'package:hexacom_user/features/coupon/providers/coupon_provider.dart';
import 'package:hexacom_user/features/order/providers/order_provider.dart';
import 'package:hexacom_user/features/profile/providers/profile_provider.dart';
import 'package:hexacom_user/features/splash/providers/splash_provider.dart';
import 'package:hexacom_user/helper/checkout_helper.dart';
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
  final TextEditingController orderNoteController = TextEditingController();
  final GlobalKey areaDropDownKey = GlobalKey();
  bool _checkoutDataInitialized = false;

  @override
  void initState() {
    super.initState();
    Provider.of<CouponProvider>(context, listen: false).removeCouponData(false);
    final CheckoutProvider checkoutProvider = Provider.of<CheckoutProvider>(context, listen: false);
    final OrderProvider orderProvider = Provider.of<OrderProvider>(context, listen: false);
    checkoutProvider.setOrderType('delivery', notify: false);
    checkoutProvider.clearPrevData();
    orderProvider.setDeliveryCharge(0, notify: false);
    orderProvider.setAreaID(isReload: true, isUpdate: false);
    WidgetsBinding.instance.addPostFrameCallback((_) => _initCheckoutDataIfNeeded());
  }

  void _initCheckoutDataIfNeeded() {
    if (_checkoutDataInitialized) return;
    final CartProvider cartProvider = Provider.of<CartProvider>(context, listen: false);
    if (cartProvider.cartList.isEmpty) return;
    _checkoutDataInitialized = true;
    double itemPrice = 0;
    double discount = 0;
    for (var cartModel in cartProvider.cartList) {
      if (cartModel == null) continue;
      itemPrice += (cartModel.price! * cartModel.quantity!);
      discount += (cartModel.discountAmount! * cartModel.quantity!);
    }
    final double subTotal = itemPrice - discount;
    final CouponProvider couponProvider = Provider.of<CouponProvider>(context, listen: false);
    final double orderAmount = subTotal - (couponProvider.discount ?? 0);
    final CheckoutProvider checkoutProvider = Provider.of<CheckoutProvider>(context, listen: false);
    checkoutProvider.setCheckOutData = CheckOutModel(
      orderType: checkoutProvider.orderType,
      deliveryCharge: 0,
      freeDeliveryType: '',
      amount: orderAmount,
      placeOrderDiscount: 0,
      couponCode: couponProvider.coupon?.code,
      orderNote: null,
      widgetDiscount: discount,
    );
    final AuthProvider authProvider = Provider.of<AuthProvider>(context, listen: false);
    final bool isLoggedIn = authProvider.isLoggedIn();
    if (isLoggedIn || authProvider.getGuestId() != null) {
      Provider.of<AddressProvider>(context, listen: false).initAddressList().then((_) {
        if (!mounted) return;
        CheckOutHelper.selectDeliveryAddressAuto(
          orderType: checkoutProvider.orderType,
          isLoggedIn: isLoggedIn,
          lastAddress: null,
        );
      });
    }
  }

  @override
  void dispose() {
    orderNoteController.dispose();
    super.dispose();
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
        child: Consumer3<CartProvider, OrderProvider, CheckoutProvider>(
        builder: (context, cart, orderProvider, checkoutProvider, child) {
          double itemPrice = 0;
          double discount = 0;
          for (var cartModel in cart.cartList) {
            itemPrice = itemPrice + (cartModel!.price! * cartModel.quantity!);
            discount = discount + (cartModel.discountAmount! * cartModel.quantity!);
          }
          double subTotal = itemPrice - discount;
          final double couponDiscount = Provider.of<CouponProvider>(context).discount ?? 0;
          final double orderAmount = subTotal - couponDiscount;
          final ConfigModel? configModel = Provider.of<SplashProvider>(context, listen: false).configModel;
          if (configModel != null) {
            checkoutProvider.setCheckOutData = CheckOutModel(
              orderType: checkoutProvider.orderType,
              deliveryCharge: checkoutProvider.getCheckOutData?.deliveryCharge ?? 0,
              freeDeliveryType: checkoutProvider.getCheckOutData?.freeDeliveryType,
              amount: orderAmount,
              placeOrderDiscount: 0,
              couponCode: Provider.of<CouponProvider>(context, listen: false).coupon?.code,
              orderNote: null,
              widgetDiscount: discount,
            );
            final bool isSelfPickup = checkoutProvider.orderType == 'self_pickup';
            final double deliveryCharge = CheckOutHelper.getDeliveryCharge(
              context: context,
              orderAmount: orderAmount,
              distance: checkoutProvider.distance,
              discount: couponDiscount,
              freeDeliveryType: checkoutProvider.getCheckOutData?.freeDeliveryType,
              configModel: configModel,
              isSelfPickUp: isSelfPickup,
            );
            if (orderProvider.deliveryCharge != deliveryCharge) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                orderProvider.setDeliveryCharge(deliveryCharge, notify: true);
              });
            }
          }
          final double deliveryChargeValue = orderProvider.deliveryCharge ?? 0;
          final int loyaltyPoints = Provider.of<ProfileProvider>(context, listen: false).userInfoModel?.loyaltyPoints ?? 0;
          final double redemptionValue = configModel?.loyaltyPointRedemptionValue ?? 0.5;
          final bool useLoyalty = checkoutProvider.useLoyaltyPoints && loyaltyPoints > 0;
          final double loyaltyDiscount = useLoyalty ? (loyaltyPoints * redemptionValue).clamp(0.0, orderAmount + deliveryChargeValue) : 0.0;
          double total = orderAmount + deliveryChargeValue - loyaltyDiscount;
          final bool selfPickup = checkoutProvider.orderType == 'self_pickup';

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

                            // Products first: the customer sees their items right under the header.
                            if(!isDesktop) const CartProductListWidget(),

                            if(!isDesktop && !selfPickup) ...[
                              const SizedBox(height: Dimensions.paddingSizeDefault),
                              CartDeliveryAddressSectionWidget(
                                orderAmount: orderAmount,
                                couponDiscount: couponDiscount,
                                isSelfPickUp: selfPickup,
                              ),
                              const SizedBox(height: Dimensions.paddingSizeDefault),
                              _CartOrderNoteSection(controller: orderNoteController),
                              const SizedBox(height: Dimensions.paddingSizeSmall),
                              PaymentInfoWidget(totalAmount: orderAmount + deliveryChargeValue),
                              const SizedBox(height: Dimensions.paddingSizeSmall),
                              _CartLoyaltySwitchSection(),
                              const SizedBox(height: Dimensions.paddingSizeDefault),
                            ],

                            if(!isDesktop) ...[
                              CartDetailsWidget(
                                itemPrice: itemPrice,
                                discount: discount,
                                deliveryCharge: deliveryChargeValue,
                                total: total,
                                subTotal: subTotal,
                                loyaltyDiscount: loyaltyDiscount,
                              ),
                              const SizedBox(height: Dimensions.paddingSizeDefault),
                            ],

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
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      if(!selfPickup) ...[
                                        CartDeliveryAddressSectionWidget(
                                          orderAmount: orderAmount,
                                          couponDiscount: couponDiscount,
                                          isSelfPickUp: selfPickup,
                                        ),
                                        const SizedBox(height: Dimensions.paddingSizeDefault),
                                        _CartOrderNoteSection(controller: orderNoteController),
                                        const SizedBox(height: Dimensions.paddingSizeSmall),
                                        PaymentInfoWidget(totalAmount: orderAmount + deliveryChargeValue),
                                        const SizedBox(height: Dimensions.paddingSizeSmall),
                                        _CartLoyaltySwitchSection(),
                                        const SizedBox(height: Dimensions.paddingSizeDefault),
                                      ],
                                      CartDetailsWidget(
                                        itemPrice: itemPrice,
                                        discount: discount,
                                        deliveryCharge: deliveryChargeValue,
                                        total: total,
                                        subTotal: subTotal,
                                        loyaltyDiscount: loyaltyDiscount,
                                        usePlaceOrderButton: true,
                                      ),
                                      const SizedBox(height: Dimensions.paddingSizeDefault),
                                      PlaceOrderButtonView(
                                        amount: orderAmount,
                                        deliveryCharge: deliveryChargeValue,
                                        orderType: checkoutProvider.orderType,
                                        kmWiseCharge: CheckOutHelper.getDeliveryChargeType(context) == DeliveryChargeType.distance.name,
                                        cartList: cart.cartList,
                                        orderNote: orderNoteController.text,
                                        dropdownKey: areaDropDownKey,
                                      ),
                                    ],
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
              child: PlaceOrderButtonView(
                amount: orderAmount,
                deliveryCharge: deliveryChargeValue,
                orderType: checkoutProvider.orderType,
                kmWiseCharge: CheckOutHelper.getDeliveryChargeType(context) == DeliveryChargeType.distance.name,
                cartList: cart.cartList,
                orderNote: orderNoteController.text,
                dropdownKey: areaDropDownKey,
              ),
            ),

          ]) : NoDataScreen(
            image: Images.emptyCart,
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

class _CartOrderNoteSection extends StatelessWidget {
  final TextEditingController controller;

  const _CartOrderNoteSection({required this.controller});

  static const _slate = Color(0xFF3A4756);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withValues(alpha: 0.10),
            blurRadius: 18,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _slate.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.note_alt_outlined, color: _slate, size: 20),
              ),
              const SizedBox(width: Dimensions.paddingSizeSmall),
              Text(
                getTranslated('add_delivery_note', context),
                style: rubikSemiBold.copyWith(fontSize: Dimensions.fontSizeLarge),
              ),
            ],
          ),
          const SizedBox(height: Dimensions.paddingSizeSmall),
          CustomTextFieldWidget(
            fillColor: Theme.of(context).canvasColor,
            isShowBorder: true,
            controller: controller,
            hintText: getTranslated('type', context),
            maxLines: 3,
            inputType: TextInputType.multiline,
            inputAction: TextInputAction.newline,
            capitalization: TextCapitalization.sentences,
          ),
        ],
      ),
    );
  }
}

class _CartLoyaltySwitchSection extends StatelessWidget {
  const _CartLoyaltySwitchSection();

  @override
  Widget build(BuildContext context) {
    final isLoggedIn = Provider.of<AuthProvider>(context, listen: false).isLoggedIn();
    final loyaltyPoints = Provider.of<ProfileProvider>(context).userInfoModel?.loyaltyPoints ?? 0;
    if (!isLoggedIn) return const SizedBox.shrink();

    return Consumer<CheckoutProvider>(
      builder: (context, checkoutProvider, _) {
        return Container(
          padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).shadowColor.withValues(alpha: 0.10),
                blurRadius: 18,
                spreadRadius: 0,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      getTranslated('loyalty_points', context),
                      style: rubikSemiBold.copyWith(fontSize: Dimensions.fontSizeDefault),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${getTranslated('available', context)}: $loyaltyPoints ${getTranslated('points', context)}',
                      style: rubikRegular.copyWith(
                        fontSize: Dimensions.fontSizeSmall,
                        color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.85),
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: checkoutProvider.useLoyaltyPoints,
                onChanged: loyaltyPoints > 0 ? (value) => checkoutProvider.setUseLoyaltyPoints(value) : null,
              ),
            ],
          ),
        );
      },
    );
  }
}
