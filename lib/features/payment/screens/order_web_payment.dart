import 'dart:convert';
import 'package:hexacom_user/common/models/place_order_model.dart';
import 'package:hexacom_user/helper/responsive_helper.dart';
import 'package:hexacom_user/features/cart/providers/cart_provider.dart';
import 'package:hexacom_user/features/auth/providers/auth_provider.dart';
import 'package:hexacom_user/features/order/providers/order_provider.dart';
import 'package:hexacom_user/features/splash/providers/splash_provider.dart';
import 'package:hexacom_user/utill/routes.dart';
import 'package:hexacom_user/common/widgets/custom_loader_widget.dart';
import 'package:hexacom_user/helper/custom_snackbar_helper.dart';
import 'package:hexacom_user/common/widgets/web_app_bar_widget.dart';
import 'package:universal_html/html.dart' as html;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class OrderWebPayment extends StatefulWidget {
  final String? token;
  const OrderWebPayment({super.key, this.token});

  @override
  State<OrderWebPayment> createState() => _OrderWebPaymentState();
}

class _OrderWebPaymentState extends State<OrderWebPayment> {

  getValue() async {
    if(html.window.location.href.contains('success')){
      try{
        final orderProvider =  Provider.of<OrderProvider>(context, listen: false);
        String placeOrderString =  utf8.decode(base64Url.decode(orderProvider.getPlaceOrderData()!.replaceAll(' ', '+')));
        String tokenString = utf8.decode(base64Url.decode(widget.token!.replaceAll(' ', '+')));
        String paymentMethod = tokenString.substring(0, tokenString.indexOf('&&'));
        String transactionReference = tokenString.substring(tokenString.indexOf('&&') + '&&'.length, tokenString.length);

        PlaceOrderModel placeOrderBody =  PlaceOrderModel.fromJson(jsonDecode(placeOrderString)).copyWith(
          paymentMethod: paymentMethod.replaceAll('payment_method=', ''),
          transactionReference:  transactionReference.replaceRange(0, transactionReference.indexOf('transaction_reference='), '').replaceAll('transaction_reference=', ''),
        );
        final configModel = Provider.of<SplashProvider>(context, listen: false).configModel;
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        if (authProvider.isLoggedIn() && (configModel?.loyaltyPointsEnabled ?? false)) {
          final amountForOne = configModel!.loyaltyAmountForOnePoint ?? 10;
          final pointsPer = configModel.loyaltyPointsPerAmount ?? 1;
          final orderAmt = placeOrderBody.orderAmount ?? 0;
          if (amountForOne > 0 && orderAmt > 0) {
            orderProvider.setLastExpectedPointsForSuccess(((orderAmt / amountForOne).floor() * pointsPer).round());
          } else {
            orderProvider.setLastExpectedPointsForSuccess(null);
          }
        } else {
          orderProvider.setLastExpectedPointsForSuccess(null);
        }
        orderProvider.placeOrder(context, placeOrderBody, _callback);
      }catch(e){

        RouteHelper.getMainRoute(context, action: RouteAction.pushNamedAndRemoveUntil);
      }

    }else{
      RouteHelper.getOrderSuccessScreen(context, '0', 'field');
    }
  }

  void _callback(BuildContext context, bool isSuccess, String message, String orderID) async {
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);
    final expectedPoints = orderProvider.lastExpectedPointsForSuccess;
    Provider.of<CartProvider>(context, listen: false).clearCartList();
    orderProvider.clearPlaceOrderData();
    if(isSuccess) {
      RouteHelper.getOrderSuccessScreen(context, orderID, 'success', expectedPoints: expectedPoints);

    }else {
      showCustomSnackBar(message, context);
    }
  }

  @override
  void initState() {
    super.initState();
    getValue();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ResponsiveHelper.isDesktop(context) ? const PreferredSize(preferredSize: Size.fromHeight(90), child: WebAppBarWidget()): null,
      body: Center(
          child: CustomLoaderWidget(color: Theme.of(context).primaryColor)),
    );
  }
}
