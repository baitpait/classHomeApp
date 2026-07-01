import 'package:hexacom_user/common/models/address_model.dart';
import 'package:hexacom_user/features/address/widgets/address_widget.dart';
import 'package:hexacom_user/features/checkout/providers/checkout_provider.dart';
import 'package:hexacom_user/features/order/enums/delivery_charge_type.dart';
import 'package:hexacom_user/helper/checkout_helper.dart';
import 'package:hexacom_user/localization/language_constrants.dart';
import 'package:hexacom_user/features/address/providers/address_provider.dart';
import 'package:hexacom_user/utill/dimensions.dart';
import 'package:hexacom_user/utill/images.dart';
import 'package:hexacom_user/utill/routes.dart';
import 'package:hexacom_user/utill/styles.dart';
import 'package:hexacom_user/common/widgets/custom_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AddAddressDialogWidget extends StatelessWidget {
  const AddAddressDialogWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final CheckoutProvider checkoutProvider = Provider.of<CheckoutProvider>(context, listen: false);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Consumer<AddressProvider>(
        builder: (context, locationProvider, _) {
          bool isNotEmptyAddress = (locationProvider.addressList != null && locationProvider.addressList!.isNotEmpty);

          return Container(
            constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.8),
            width: (Dimensions.webScreenWidth / 2),
            padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Row(children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1F4C5C).withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.location_on_outlined, color: Color(0xFF1F4C5C), size: 20),
                ),
                const SizedBox(width: Dimensions.paddingSizeSmall),
                Expanded(
                  child: Text(
                    getTranslated(isNotEmptyAddress ? 'select_form_saved_address' : 'you_have_to_save_address', context),
                    style: rubikSemiBold.copyWith(fontSize: Dimensions.fontSizeLarge),
                  ),
                ),
                InkWell(
                  onTap: () => Navigator.pop(context),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).disabledColor.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.close, color: Theme.of(context).disabledColor, size: 18),
                  ),
                ),
              ]),

              const SizedBox(height: Dimensions.paddingSizeDefault),

              if(!isNotEmptyAddress) ...[
                Image.asset(Images.locationBannerImage, height: 120, width: 120),
                const SizedBox(height: Dimensions.paddingSizeSmall),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.fontSizeExtraSmall),
                  child: Text(
                    getTranslated('you_dont_have_any_saved_address_yet', context),
                    style: rubikRegular.copyWith(color: Theme.of(context).disabledColor),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
              const SizedBox(height: Dimensions.paddingSizeSmall),

              Flexible(child: SingleChildScrollView(
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  locationProvider.addressList != null ? locationProvider.addressList!.isNotEmpty ? ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.zero,
                    itemCount: locationProvider.addressList?.length,
                    itemBuilder: (context, index) {
                      bool isDistanceWiseDelivery = CheckOutHelper.getDeliveryChargeType(context) == DeliveryChargeType.distance.name;
                      AddressModel? addressModel = locationProvider.addressList?[index];

                      bool isAddressAvailableForDelivery = true;
                      if(isDistanceWiseDelivery && (addressModel?.latitude == null && addressModel?.longitude == null)) {
                        isAddressAvailableForDelivery = false;
                      }

                      return Center(child: SizedBox(width: 700, child: AddressWidget(
                        fromSelectAddress: true,
                        addressModel: locationProvider.addressList![index],
                        index: index,
                        isAvailableForDelivery: isAddressAvailableForDelivery,
                      )));
                    },
                  ) : const SizedBox() : const Center(child: CircularProgressIndicator()),
                ]),
              )),

              const SizedBox(height: Dimensions.paddingSizeSmall),

              InkWell(
                onTap: () async {
                  Navigator.pop(context);
                  RouteHelper.getAddAddressRoute(context, 'checkout', 'add', AddressModel(), routeAction: RouteAction.push);
                  await locationProvider.initAddressList();
                  CheckOutHelper.selectDeliveryAddressAuto(
                    isLoggedIn: true,
                    orderType: checkoutProvider.getCheckOutData?.orderType,
                    lastAddress: null,
                  );
                },
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: Dimensions.paddingSizeDefault),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFF1F4C5C).withValues(alpha: 0.15), width: 1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(mainAxisAlignment: MainAxisAlignment.center, mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.add_circle_outline, color: Color(0xFF1F4C5C), size: 20),
                    const SizedBox(width: Dimensions.paddingSizeSmall),
                    Text(getTranslated('add_new_address', context), style: rubikMedium.copyWith(color: const Color(0xFF1F4C5C))),
                  ]),
                ),
              ),

              if(isNotEmptyAddress) Padding(
                padding: const EdgeInsets.only(top: Dimensions.paddingSizeDefault),
                child: CustomButtonWidget(
                  btnTxt: getTranslated('select', context),
                  onTap: () => Navigator.pop(context),
                ),
              ),

              if(!isNotEmptyAddress) const SizedBox(height: Dimensions.paddingSizeDefault),
            ]),
          );
        },
      ),
    );
  }
}

class CurrentLocationButton extends StatelessWidget {
  final bool isBorder;
  const CurrentLocationButton({
    super.key, required this.isBorder,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: () {
        Navigator.pop(context);
        RouteHelper.getAddAddressRoute(context, 'checkout', 'add', AddressModel(), routeAction: RouteAction.push);
      },
      style: TextButton.styleFrom(
        padding: EdgeInsets.zero,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(Dimensions.radiusSizeDefault))),
        fixedSize: const Size(200, 40),
        backgroundColor: isBorder ? const Color(0xFF1F4C5C) : Theme.of(context).cardColor,
      ),
      icon: Icon(
        Icons.my_location,
        color: isBorder ? Theme.of(context).cardColor : const Color(0xFF1F4C5C),
      ),
      label: Text(getTranslated('use_my_current_location', context), style: rubikRegular.copyWith(
        fontSize: Dimensions.fontSizeExtraSmall,
        color: isBorder ? Theme.of(context).cardColor : const Color(0xFF1F4C5C),
      )),
    );
  }
}
