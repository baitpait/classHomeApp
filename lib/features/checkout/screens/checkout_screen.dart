import 'dart:ui';
import 'package:hexacom_user/common/enums/footer_type_enum.dart';
import 'package:hexacom_user/common/models/cart_model.dart';
import 'package:hexacom_user/common/models/check_out_model.dart';
import 'package:hexacom_user/common/models/config_model.dart';
import 'package:hexacom_user/common/widgets/custom_app_bar_widget.dart';
import 'package:hexacom_user/common/widgets/custom_web_title_widget.dart';
import 'package:hexacom_user/common/widgets/footer_web_widget.dart';
import 'package:hexacom_user/common/widgets/not_logged_in_screen.dart';
import 'package:hexacom_user/common/widgets/web_app_bar_widget.dart';
import 'package:hexacom_user/features/address/providers/address_provider.dart';
import 'package:hexacom_user/features/auth/domain/enums/from_page_enum.dart';
import 'package:hexacom_user/features/auth/providers/auth_provider.dart';
import 'package:hexacom_user/features/cart/providers/cart_provider.dart';
import 'package:hexacom_user/features/checkout/providers/checkout_provider.dart';
import 'package:hexacom_user/features/checkout/widgets/delivery_address_widget.dart';
import 'package:hexacom_user/features/checkout/widgets/details_view_widget.dart';
import 'package:hexacom_user/features/checkout/widgets/map_view_widget.dart';
import 'package:hexacom_user/features/checkout/widgets/place_order_button_view.dart';
import 'package:hexacom_user/features/checkout/widgets/zip_code_view_widget.dart';
import 'package:hexacom_user/features/order/enums/delivery_charge_type.dart';
import 'package:hexacom_user/features/order/providers/order_provider.dart';
import 'package:hexacom_user/features/profile/providers/profile_provider.dart';
import 'package:hexacom_user/features/splash/providers/splash_provider.dart';
import 'package:hexacom_user/helper/checkout_helper.dart';
import 'package:hexacom_user/helper/price_converter_helper.dart';
import 'package:hexacom_user/helper/responsive_helper.dart';
import 'package:hexacom_user/localization/language_constrants.dart';
import 'package:hexacom_user/utill/dimensions.dart';
import 'package:hexacom_user/utill/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class CheckoutScreen extends StatefulWidget {
  final List<CartModel>? cartList;
  final double? amount;
  final double? discount;
  final String? couponCode;
  final double deliveryCharge;
  final String? orderType;
  final bool fromCart;

  const CheckoutScreen({
    super.key,
    required this.amount,
    required this.orderType,
    required this.fromCart,
    required this.discount,
    required this.couponCode,
    required this.deliveryCharge, this.cartList,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final GlobalKey<ScaffoldMessengerState> _scaffoldKey = GlobalKey<ScaffoldMessengerState>();
  final TextEditingController _noteController = TextEditingController();
  final TextEditingController searchController = TextEditingController();
  final GlobalKey dropDownKey = GlobalKey();
  final ScrollController scrollController = ScrollController();

  late bool _isLoggedIn;
  late List<CartModel?> _cartList;
  List<Branches>? _branches = [];
  bool _guestAddressLoadScheduled = false;
  /// True while guest ID is being created (avoids flashing NotLoggedInScreen).
  bool _isAwaitingGuestId = false;

  @override
  void initState() {
    super.initState();

    final CheckoutProvider checkoutProvider = Provider.of<CheckoutProvider>(context, listen: false);
    final OrderProvider orderProvider = context.read<OrderProvider>();
    final AuthProvider authProvider = context.read<AuthProvider>();

    _isLoggedIn = Provider.of<AuthProvider>(context, listen: false).isLoggedIn();
    _branches = Provider.of<SplashProvider>(context, listen: false).configModel?.branches;
    orderProvider.setAreaID(isReload: true, isUpdate: false);
    // Avoid notifying listeners during build; initial value only.
    orderProvider.setDeliveryCharge(0, notify: false);

    if (!_isLoggedIn && authProvider.getGuestId() == null) {
      _isAwaitingGuestId = true;
      authProvider.addOrUpdateGuest().then((_) {
        if (mounted) setState(() => _isAwaitingGuestId = false);
      });
    }

    Provider.of<CheckoutProvider>(context, listen: false).clearPrevData();
    _cartList = [];
    if (widget.fromCart) {
      _cartList.addAll(Provider.of<CartProvider>(context, listen: false).cartList);
    } else {
      _cartList.addAll(widget.cartList ?? []);
    }

    if (_isLoggedIn || authProvider.getGuestId() != null) {
      Provider.of<AddressProvider>(context, listen: false).initAddressList().then((value) {
        CheckOutHelper.selectDeliveryAddressAuto(orderType: widget.orderType, isLoggedIn: _isLoggedIn, lastAddress: null);
      });
      if (Provider.of<ProfileProvider>(context, listen: false).userInfoModel == null && authProvider.isLoggedIn()) {
        Provider.of<ProfileProvider>(context, listen: false).getUserInfo();
      }
    }

    checkoutProvider.setCheckOutData = CheckOutModel(
      orderType: widget.orderType,
      deliveryCharge: 0,
      freeDeliveryType: '',
      amount: widget.amount,
      placeOrderDiscount: 0,
      couponCode: widget.couponCode, orderNote: null,
      widgetDiscount: widget.discount,
    );
  }

  @override
  Widget build(BuildContext context) {
    final ConfigModel configModel = Provider.of<SplashProvider>(context, listen: false).configModel!;
    final OrderProvider orderProvider = context.read<OrderProvider>();
    final CheckoutProvider checkoutProvider = context.read<CheckoutProvider>();
    final SplashProvider splashProvider = context.read<SplashProvider>();
    bool kmWiseCharge = splashProvider.deliveryInfoModelList?[checkoutProvider.branchIndex].deliveryChargeSetup?.deliveryChargeType == 'distance';
    bool selfPickup = widget.orderType == 'self_pickup';
    final bool isDesktop = ResponsiveHelper.isDesktop(context);

    return Scaffold(
      key: _scaffoldKey,
      appBar: isDesktop
          ? const PreferredSize(
              preferredSize: Size.fromHeight(120),
              child: WebAppBarWidget(),
            )
          : null,
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          final bool canCheckout = _isLoggedIn || authProvider.getGuestId() != null;

          if (!canCheckout) {
            if (_isAwaitingGuestId) {
              return const Center(child: CircularProgressIndicator());
            }
            return NotLoggedInScreen(fromPage: FromPage.checkOut.name);
          }

          if (!_isLoggedIn && !_guestAddressLoadScheduled) {
            _guestAddressLoadScheduled = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Provider.of<AddressProvider>(context, listen: false).initAddressList().then((value) {
                CheckOutHelper.selectDeliveryAddressAuto(orderType: widget.orderType, isLoggedIn: _isLoggedIn, lastAddress: null);
              });
            });
          }

          return Consumer<CheckoutProvider>(
            builder: (context, checkoutProvider, child) {
              double deliveryCharge = CheckOutHelper.getDeliveryCharge(
                orderAmount: widget.amount ?? 0.0,
                distance: checkoutProvider.distance,
                discount: widget.discount ?? 0.0,
                freeDeliveryType: checkoutProvider.getCheckOutData?.freeDeliveryType,
                configModel: configModel,
                context: context,
                isSelfPickUp: widget.orderType == 'self_pickup',
              );
              orderProvider.setDeliveryCharge(deliveryCharge, notify: true);

              return Consumer<AddressProvider>(builder: (context, address, child) {
                final double total = (widget.amount ?? 0) + (orderProvider.deliveryCharge ?? 0);

                return Column(children: [
                  Expanded(child: CustomScrollView(controller: scrollController, slivers: [
                    SliverToBoxAdapter(child: Center(child: SizedBox(width: isDesktop ? Dimensions.getWebContentWidth(MediaQuery.sizeOf(context).width) : MediaQuery.sizeOf(context).width,
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        if(!isDesktop) SizedBox(height: MediaQuery.paddingOf(context).top + Dimensions.paddingSizeSmall),
                        CustomWebTitleWidget(title: getTranslated('', context)),

                        // --- Checkout header banner (same as cart; back button next to icon) ---
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
                              IconButton(
                                onPressed: () => context.pop(),
                                icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: Colors.white),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                              ),
                              const SizedBox(width: 4),
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.15),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.shopping_cart_checkout_rounded, color: Colors.white, size: 22),
                              ),
                              const SizedBox(width: Dimensions.paddingSizeDefault),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      getTranslated('checkout', context),
                                      style: rubikSemiBold.copyWith(fontSize: Dimensions.fontSizeLarge, color: Colors.white),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${_cartList.length} ${getTranslated('items', context)}',
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

                        if(!isDesktop)
                          MapViewWidget(isSelfPickUp: selfPickup),
                        const SizedBox(height: Dimensions.paddingSizeSmall),

                        if(!isDesktop && !selfPickup)
                          _stepHeader(context, 1, getTranslated('delivery_to', context)),

                        // Region picker shown only as a fallback when the selected address has no region yet
                        // (avoids duplicating the region selection that now lives in the structured address form).
                        if(!isDesktop && CheckOutHelper.getDeliveryChargeType(context) == DeliveryChargeType.area.name && !selfPickup)
                          Selector<OrderProvider, int?>(
                            selector: (_, op) => op.selectedAreaID,
                            builder: (context, areaId, child) => areaId != null
                                ? const SizedBox.shrink()
                                : ZipCodeViewWidget(
                                    dropDownKey: dropDownKey,
                                    discount: widget.discount ?? 0.0,
                                    amount: widget.amount ?? 0.0,
                                    isSelfPickUp: selfPickup,
                                  ),
                          ),

                        if(!isDesktop)...[
                          DeliveryAddressWidget(selfPickup: selfPickup),
                        ],

                        if(!isDesktop)
                          _stepHeader(context, selfPickup ? 1 : 2, getTranslated('order_summary', context)),

                        if(!isDesktop) Selector<OrderProvider, double?>(
                          selector: (context, orderProvider) => orderProvider.deliveryCharge,
                          builder: (context, deliveryCharge, child) {
                            return DetailsViewWidget(
                              amount: widget.amount ?? 0,
                              kmWiseCharge: kmWiseCharge,
                              selfPickup: selfPickup,
                              deliveryCharge: orderProvider.deliveryCharge ?? 0.0,
                              orderNoteController: _noteController,
                              orderType: widget.orderType,
                              cartList: _cartList,
                            );
                          },
                        ),

                        if(isDesktop) Padding(
                          padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
                          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Expanded(flex: 7, child: Container(
                              padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                              decoration: BoxDecoration(
                                color: Theme.of(context).cardColor,
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: [
                                  BoxShadow(color: Theme.of(context).shadowColor.withValues(alpha: 0.10), blurRadius: 18, spreadRadius: 0, offset: const Offset(0, 4)),
                                ],
                              ),
                              child: MapViewWidget(
                                isSelfPickUp: selfPickup,
                                dropDownKey: dropDownKey,
                                discount: widget.discount ?? 0.0,
                                amount: widget.amount ?? 0.0,
                              ),
                            )),
                            const SizedBox(width: Dimensions.paddingSizeLarge),

                            Expanded(flex: 4, child: Container(
                              padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                              decoration: BoxDecoration(
                                color: Theme.of(context).cardColor,
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: [
                                  BoxShadow(color: Theme.of(context).shadowColor.withValues(alpha: 0.10), blurRadius: 18, spreadRadius: 0, offset: const Offset(0, 4)),
                                ],
                              ),
                              child: DetailsViewWidget(
                                amount: widget.amount ?? 0,
                                kmWiseCharge: kmWiseCharge,
                                selfPickup: selfPickup,
                                deliveryCharge: orderProvider.deliveryCharge ?? 0.0,
                                orderNoteController: _noteController,
                                orderType: widget.orderType ?? '',
                                cartList: _cartList,
                                scrollController: scrollController,
                                dropdownKey: dropDownKey,
                              ),
                            )),
                          ]),
                        ),
                      ]),
                    ))),
                    const FooterWebWidget(footerType: FooterType.sliver),
                  ])),

                  if(!isDesktop) PlaceOrderButtonView(
                    deliveryCharge: orderProvider.deliveryCharge,
                    amount: widget.amount,
                    cartList: _cartList,
                    kmWiseCharge: kmWiseCharge,
                    orderNote: _noteController.text,
                    orderType: widget.orderType,
                    scrollController: scrollController,
                    dropdownKey: dropDownKey,
                  ),
                ]);
              });
            },
          );
        },
      ),
    );
  }

  Widget _stepHeader(BuildContext context, int number, String title) {
    final Color primary = Theme.of(context).primaryColor;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        Dimensions.paddingSizeDefault, Dimensions.paddingSizeDefault, Dimensions.paddingSizeDefault, Dimensions.paddingSizeExtraSmall,
      ),
      child: Row(children: [
        Container(
          width: 24, height: 24,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: primary.withValues(alpha: 0.12), shape: BoxShape.circle),
          child: Text('$number', style: rubikSemiBold.copyWith(fontSize: Dimensions.fontSizeSmall, color: primary)),
        ),
        const SizedBox(width: Dimensions.paddingSizeSmall),
        Text(title, style: rubikSemiBold.copyWith(fontSize: Dimensions.fontSizeLarge)),
      ]),
    );
  }

  Future<Uint8List> convertAssetToUnit8List(String imagePath, {int width = 50}) async {
    ByteData data = await rootBundle.load(imagePath);
    Codec codec = await instantiateImageCodec(data.buffer.asUint8List(), targetWidth: width);
    FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ImageByteFormat.png))!.buffer.asUint8List();
  }
}
