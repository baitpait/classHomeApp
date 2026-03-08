import 'package:hexacom_user/common/models/place_order_model.dart';
import 'package:hexacom_user/common/models/cart_model.dart';
import 'package:hexacom_user/common/models/config_model.dart';
import 'package:hexacom_user/features/auth/providers/auth_provider.dart';
import 'package:hexacom_user/features/checkout/providers/checkout_provider.dart';
import 'package:hexacom_user/features/checkout/widgets/payment_method_bottom_sheet_widget.dart';
import 'package:hexacom_user/features/order/enums/delivery_charge_type.dart';
import 'package:hexacom_user/helper/checkout_helper.dart';
import 'package:hexacom_user/helper/responsive_helper.dart';
import 'package:hexacom_user/localization/language_constrants.dart';
import 'package:hexacom_user/main.dart';
import 'package:hexacom_user/features/cart/providers/cart_provider.dart';
import 'package:hexacom_user/features/coupon/providers/coupon_provider.dart';
import 'package:hexacom_user/features/address/providers/address_provider.dart';
import 'package:hexacom_user/features/order/providers/order_provider.dart';
import 'package:hexacom_user/features/profile/providers/profile_provider.dart';
import 'package:hexacom_user/features/splash/providers/splash_provider.dart';
import 'package:hexacom_user/utill/app_constants.dart';
import 'package:hexacom_user/utill/dimensions.dart';
import 'package:hexacom_user/utill/routes.dart';
import 'package:hexacom_user/common/widgets/custom_button_widget.dart';
import 'package:hexacom_user/helper/custom_snackbar_helper.dart';
import 'package:hexacom_user/helper/price_converter_helper.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:universal_html/html.dart' as html;
import 'dart:convert'as convert;


class PlaceOrderButtonView extends StatelessWidget {
  final double? amount;
  final double? deliveryCharge;
  final String? orderType;
  final bool kmWiseCharge;
  final List<CartModel?> cartList;
  final String? orderNote;
  final ScrollController? scrollController;
  final GlobalKey? dropdownKey;

  const PlaceOrderButtonView({
    super.key, required this.amount, required this.deliveryCharge,
    required this.orderType, required this.kmWiseCharge,
    required this.cartList, required this.orderNote, this.scrollController, this.dropdownKey
  });


  void _openDropdown() {
    final dropdownContext = dropdownKey?.currentContext;

    if (dropdownContext != null) {
      GestureDetector? detector;
      void searchGestureDetector(BuildContext context) {
        context.visitChildElements((element) {
          if (element.widget is GestureDetector) {
            detector = element.widget as GestureDetector?;
          } else {
            searchGestureDetector(element);
          }
        });
      }
      searchGestureDetector(dropdownContext);

      detector?.onTap?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    final AddressProvider locationProvider = Provider.of<AddressProvider>(context, listen: false);
    final ProfileProvider profileProvider = Provider.of<ProfileProvider>(context, listen: false);
    final AuthProvider authProvider = Provider.of<AuthProvider>(Get.context!, listen: false);
    bool selfPickup = orderType == 'self_pickup';
    final List<Branches> branches = Provider.of<SplashProvider>(context, listen: false).configModel!.branches ?? [];
    final Size size = MediaQuery.sizeOf(context);


    return Consumer<CheckoutProvider>(
        builder: (context, checkoutProvider, _) {
          return SafeArea(child: Container(
            width: Dimensions.webScreenWidth,
            alignment: Alignment.center,
            padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
            child: Consumer<OrderProvider>(
                builder: (context, orderProvider, _) {
                  return CustomButtonWidget(isLoading: orderProvider.isLoading, btnTxt: getTranslated('confirm_order', context), onTap: () async {
                    if(amount! < Provider.of<SplashProvider>(context, listen: false).configModel!.minimumOrderValue!) {
                      final splash = Provider.of<SplashProvider>(context, listen: false);
                      final minOrder = splash.configModel!.minimumOrderValue;
                      showCustomSnackBar(
                        '${getTranslated('minimum_order_amount_is', context)} ${PriceConverterHelper.convertPrice(minOrder)}, ${getTranslated('in_your_cart_please_add_more', context)} ${PriceConverterHelper.convertPrice(amount)}',
                        context,
                      );
                    }else if(!selfPickup && checkoutProvider.selectedPaymentMethod == null){
                      if(!ResponsiveHelper.isMobile(context)){
                        showDialog(
                          context: context,
                          builder: (con) => PaymentMethodBottomSheetWidget(
                            totalAmount: (amount ?? 0) + (deliveryCharge ?? 0),
                            deliveryCharge: deliveryCharge,
                          ),
                        );
                      }else{
                        showModalBottomSheet(
                          context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
                          builder: (con) => PaymentMethodBottomSheetWidget(
                            totalAmount: (amount ?? 0) + (deliveryCharge ?? 0),
                            deliveryCharge: deliveryCharge,
                          ),
                        );
                      }

                    } else if(!selfPickup && (locationProvider.addressList == null || locationProvider.addressList!.isEmpty || checkoutProvider.orderAddressIndex < 0)) {
                      showCustomSnackBar(getTranslated('select_an_address', context), context);
                    }
                    // else if (!selfPickup && kmWiseCharge && checkoutProvider.distance == -1) {
                    //   showCustomSnackBar(getTranslated('delivery_fee_not_set_yet', context), context);
                    // }
                    else if((CheckOutHelper.getDeliveryChargeType(context) == DeliveryChargeType.area.name) && (orderProvider.selectedAreaID == null) && !selfPickup){
                      await scrollController?.animateTo(ResponsiveHelper.isDesktop(context) ? size.height * 0.08 : 0, duration: const Duration(milliseconds: 100), curve: Curves.ease);
                      _openDropdown();
                    }else {

                      String? hostname = html.window.location.hostname;
                      String protocol = html.window.location.protocol;
                      String port = html.window.location.port;

                      List<Cart> carts = [];
                      for (int index = 0; index < cartList.length; index++) {
                        CartModel cart = cartList[index]!;
                        carts.add(Cart(
                          cart.product!.id.toString(), cart.discountedPrice.toString(), '', cart.variation,
                          cart.discountAmount, cart.quantity, cart.taxAmount,
                        ));
                      }

                      final paymentMethod = selfPickup
                          ? 'cash_on_delivery'
                          : checkoutProvider.selectedPaymentMethod!.getWay!;

                      PlaceOrderModel placeOrderBody = PlaceOrderModel(
                        cart: carts, couponDiscountAmount: Provider.of<CouponProvider>(context, listen: false).discount, couponDiscountTitle: '',
                        deliveryAddressId: !selfPickup ? locationProvider.addressList![checkoutProvider.orderAddressIndex].id : 0,
                        orderAmount: amount!+ (deliveryCharge ?? 0),
                        orderNote: selfPickup ? '' : (orderNote ?? ''), orderType: orderType,
                        paymentMethod: paymentMethod,
                        couponCode: Provider.of<CouponProvider>(context, listen: false).coupon?.code,
                        branchId: branches[checkoutProvider.branchIndex].id,
                        distance: selfPickup ? 0 : checkoutProvider.distance,
                        selectedDeliveryArea: orderProvider.selectedAreaID,
                        bringChangeAmount: checkoutProvider.bringChangeAmount,
                        isGuest: authProvider.isLoggedIn() ? "0" : "1",
                        customerId: profileProvider.getUserId(),
                        paymentPlatform: kIsWeb ? 'web' : 'app',
                        callBack: ResponsiveHelper.isWeb() ?
                        '$protocol//$hostname${kDebugMode ? ':$port' : ''}${RouteHelper.orderWebPayment}' :
                        '${AppConstants.baseUrl}${RouteHelper.orderSuccessScreen}'
                      );
                      if(placeOrderBody.paymentMethod == 'cash_on_delivery'){

                        debugPrint('------------(PLACE ORDER MODEL)-------------${placeOrderBody.toJson().toString()}');

                        orderProvider.placeOrder(context, placeOrderBody, _callback);
                      }else{

                        final String placeOrder =  convert.base64Url.encode(convert.utf8.encode(convert.jsonEncode(placeOrderBody.toJson())));
                        orderProvider.placeDigitalOrder(context, placeOrderBody).then((selectedUrl){
                          if(selectedUrl.isNotEmpty){
                            orderProvider.clearPlaceOrderData().then((_) => orderProvider.setPlaceOrderData(placeOrder).then((value) {
                              if(ResponsiveHelper.isWeb()){

                                html.window.open(selectedUrl,"_self");

                              }else{
                                RouteHelper.getPaymentRoute(context, url: selectedUrl, action: RouteAction.push);
                              }

                            }));
                          }
                        });

                      }
                    }
                  });
                }
            ),
          ));
        }
    );

  }

  void _callback(BuildContext context, bool isSuccess, String message, String orderID) async {

    final CheckoutProvider checkoutProvider = Provider.of<CheckoutProvider>(Get.context!, listen: false);

    if(isSuccess) {
      Provider.of<CartProvider>(Get.context!, listen: false).clearCartList();

      if(checkoutProvider.selectedPaymentMethod?.getWay == 'cash_on_delivery') {
        // if(ResponsiveHelper.isWeb()) {
        //   Navigator.pop(Get.context!);
        // }
        RouteHelper.getOrderSuccessScreen(context, orderID, "success", action: RouteAction.push);
      }

    }else {
      showCustomSnackBar(message, Get.context!, isError: true);

    }
  }

}
