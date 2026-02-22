import 'package:hexacom_user/common/models/config_model.dart';
import 'package:hexacom_user/features/auth/providers/auth_provider.dart';
import 'package:hexacom_user/features/checkout/providers/checkout_provider.dart';
import 'package:hexacom_user/features/checkout/widgets/delivery_address_widget.dart';
import 'package:hexacom_user/features/checkout/widgets/zip_code_view_widget.dart';
import 'package:hexacom_user/features/order/enums/delivery_charge_type.dart';
import 'package:hexacom_user/features/order/providers/order_provider.dart';
import 'package:hexacom_user/features/splash/providers/splash_provider.dart';
import 'package:hexacom_user/helper/checkout_helper.dart';
import 'package:hexacom_user/helper/responsive_helper.dart';
import 'package:hexacom_user/localization/language_constrants.dart';
import 'package:hexacom_user/utill/dimensions.dart';
import 'package:hexacom_user/utill/styles.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MapViewWidget extends StatefulWidget {
  final bool isSelfPickUp;
  final GlobalKey? dropDownKey;
  final double? discount;
  final double? amount;
  const MapViewWidget({super.key, required this.isSelfPickUp, this.dropDownKey, this.discount, this.amount});

  @override
  State<MapViewWidget> createState() => _MapViewWidgetState();
}

class _MapViewWidgetState extends State<MapViewWidget> {

  List<Branches>? _branches = [];

  @override
  Widget build(BuildContext context) {

    final ConfigModel configModel = context.read<SplashProvider>().configModel!;
    final OrderProvider orderProvider = context.read<OrderProvider>();
    final bool isLoggedIn = context.read<AuthProvider>().isLoggedIn();
    double deliveryCharge = 0.0;

    return Consumer<SplashProvider>( builder: (context, splashProvider,_){
      _branches = splashProvider.configModel!.branches;
      return Consumer<CheckoutProvider>( builder: (context, checkoutProvider, _) {
        return Column(
          children: [
            //_branches!.length > 1 ?
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: Dimensions.paddingSizeDefault,
                ).copyWith(top: ResponsiveHelper.isDesktop(context) ? Dimensions.paddingSizeSmall : 0.0),
                child: Text(getTranslated('select_branch', context), style: rubikMedium.copyWith(fontSize: Dimensions.fontSizeLarge)),
              ),

              SizedBox(
                height: 50,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                  physics: const BouncingScrollPhysics(),
                  itemCount: _branches!.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(right: Dimensions.paddingSizeSmall),
                      child: InkWell(
                        onTap: () async {
                          checkoutProvider.setBranchIndex(index);
                          orderProvider.setAreaID(isReload: true);
                          orderProvider.setDeliveryCharge(null);
                          await CheckOutHelper.selectDeliveryAddressAuto(orderType: widget.isSelfPickUp ? 'self_pickup' : 'delivery', isLoggedIn: (isLoggedIn || CheckOutHelper.isGuestCheckout(context)));

                          deliveryCharge = CheckOutHelper.getDeliveryCharge(
                            context: context,
                            freeDeliveryType: checkoutProvider.getCheckOutData?.freeDeliveryType,
                            orderAmount: widget.amount ?? 0.0,
                            distance: checkoutProvider.distance,
                            discount: widget.discount ?? 0.0,
                            configModel: configModel,
                            isSelfPickUp: widget.isSelfPickUp,
                          );
                          orderProvider.setDeliveryCharge(deliveryCharge);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: Dimensions.paddingSizeExtraSmall,
                            horizontal: Dimensions.paddingSizeDefault,
                          ),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: index == checkoutProvider.branchIndex ? Theme.of(context).primaryColor : Theme.of(context).shadowColor,
                            borderRadius: BorderRadius.circular(32),
                          ),
                          child: Text(_branches![index].name!, maxLines: 1, overflow: TextOverflow.ellipsis, style: rubikMedium.copyWith(
                            color: index == checkoutProvider.branchIndex ? Colors.white : Theme.of(context).textTheme.bodyLarge!.color,
                          )),
                        ),
                      ),
                    );
                  },
                ),
              ),

              if(ResponsiveHelper.isDesktop(context) && CheckOutHelper.getDeliveryChargeType(context) == DeliveryChargeType.area.name && !widget.isSelfPickUp)...[
                ZipCodeViewWidget(
                  dropDownKey: widget.dropDownKey!,
                  discount: widget.discount ?? 0.0,
                  amount: widget.amount ?? 0.0,
                  isSelfPickUp: widget.isSelfPickUp,
                ),
              ],

              if(ResponsiveHelper.isDesktop(context) && !widget.isSelfPickUp)
                DeliveryAddressWidget(selfPickup: widget.isSelfPickUp),

            ])



          ],
        );
      });
    });
  }
}
