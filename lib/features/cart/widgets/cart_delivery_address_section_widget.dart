import 'package:hexacom_user/common/models/address_model.dart';
import 'package:hexacom_user/common/models/config_model.dart';
import 'package:hexacom_user/features/address/providers/address_provider.dart';
import 'package:hexacom_user/features/address/widgets/address_widget.dart';
import 'package:hexacom_user/features/address/widgets/inline_address_form_widget.dart';
import 'package:hexacom_user/features/checkout/providers/checkout_provider.dart';
import 'package:hexacom_user/features/order/enums/delivery_charge_type.dart';
import 'package:hexacom_user/features/splash/providers/splash_provider.dart';
import 'package:hexacom_user/helper/checkout_helper.dart';
import 'package:hexacom_user/localization/language_constrants.dart';
import 'package:hexacom_user/utill/dimensions.dart';
import 'package:hexacom_user/utill/styles.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Delivery address section for cart: saved addresses list + expandable "Add new address" form.
/// Area is set automatically from the selected address (city/areaId) when delivery charge is area-based.
/// Used when order type is delivery (not self_pickup).
class CartDeliveryAddressSectionWidget extends StatefulWidget {
  final double orderAmount;
  final double couponDiscount;
  final bool isSelfPickUp;
  final AddressFormController? formController;

  const CartDeliveryAddressSectionWidget({
    super.key,
    required this.orderAmount,
    required this.couponDiscount,
    this.isSelfPickUp = false,
    this.formController,
  });

  @override
  State<CartDeliveryAddressSectionWidget> createState() => _CartDeliveryAddressSectionWidgetState();
}

class _CartDeliveryAddressSectionWidgetState extends State<CartDeliveryAddressSectionWidget> {
  final int _formVersion = 0;

  static const _slate = Color(0xFF1F4C5C);

  @override
  Widget build(BuildContext context) {
    final CheckoutProvider checkoutProvider = context.read<CheckoutProvider>();
    final SplashProvider splashProvider = context.read<SplashProvider>();
    final ConfigModel? configModel = splashProvider.configModel;

    return Consumer<AddressProvider>(
      builder: (context, addressProvider, _) {
        final bool hasAddresses =
            addressProvider.addressList != null && addressProvider.addressList!.isNotEmpty;

        // Shared: after a new address is saved, refresh the list and select it (so delivery/area update).
        Future<void> onFormSaved() async {
          await addressProvider.initAddressList();
          if (!context.mounted) return;
          final list = addressProvider.addressList;
          if (list != null && list.isNotEmpty && configModel != null) {
            final int newIndex = list.length - 1;
            final bool isDistanceWise =
                CheckOutHelper.getDeliveryChargeType(context) == DeliveryChargeType.distance.name;
            final AddressModel? newAddr = list[newIndex];
            bool isAvailable = true;
            if (isDistanceWise &&
                configModel.googleMapStatus == true &&
                newAddr != null &&
                (newAddr.latitude?.isNotEmpty ?? false) &&
                (newAddr.longitude?.isNotEmpty ?? false) &&
                (configModel.branches?.isNotEmpty ?? false) &&
                checkoutProvider.branchIndex < (configModel.branches!.length)) {
              isAvailable = CheckOutHelper.isBranchAvailable(
                branches: configModel.branches!,
                selectedBranch: configModel.branches![checkoutProvider.branchIndex],
                selectedAddress: newAddr,
              );
            } else if (isDistanceWise &&
                (newAddr?.latitude == null || newAddr?.longitude == null)) {
              isAvailable = false;
            }
            await CheckOutHelper.selectDeliveryAddress(
              context,
              isAvailable: isAvailable,
              index: newIndex,
              configModel: configModel,
              fromAddressList: true,
            );
          }
        }

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
                    child: const Icon(Icons.location_on_outlined, color: _slate, size: 20),
                  ),
                  const SizedBox(width: Dimensions.paddingSizeSmall),
                  Text(
                    getTranslated(hasAddresses ? 'select_form_saved_address' : 'delivery_address', context),
                    style: rubikSemiBold.copyWith(fontSize: Dimensions.fontSizeLarge),
                  ),
                ],
              ),
              const SizedBox(height: Dimensions.paddingSizeDefault),
              if (!hasAddresses)
                Padding(
                  padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
                  child: Text(
                    getTranslated('you_dont_have_any_saved_address_yet', context),
                    style: rubikRegular.copyWith(color: Theme.of(context).disabledColor),
                  ),
                ),
              if (addressProvider.addressList != null && addressProvider.addressList!.isNotEmpty)
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.zero,
                  itemCount: addressProvider.addressList!.length,
                  itemBuilder: (context, index) {
                    final bool isDistanceWiseDelivery =
                        configModel != null &&
                        CheckOutHelper.getDeliveryChargeType(context) == DeliveryChargeType.distance.name;
                    final AddressModel? addressModel = addressProvider.addressList?[index];
                    final bool isAddressAvailableForDelivery =
                        !isDistanceWiseDelivery ||
                        (addressModel?.latitude != null && addressModel?.longitude != null);

                    return Padding(
                      padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
                      child: AddressWidget(
                        fromSelectAddress: true,
                        addressModel: addressProvider.addressList![index],
                        index: index,
                        isAvailableForDelivery: isAddressAvailableForDelivery,
                      ),
                    );
                  },
                ),
              // With saved addresses: form is collapsed behind "add new address" (no auto-save → no duplicates).
              // Without saved addresses: form is shown directly and saved automatically on order placement.
              if (hasAddresses)
                Theme(
                  data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    tilePadding: EdgeInsets.zero,
                    childrenPadding: const EdgeInsets.only(bottom: Dimensions.paddingSizeDefault),
                    title: Row(
                      children: [
                        const Icon(Icons.add_circle_outline, color: _slate, size: 18),
                        const SizedBox(width: Dimensions.paddingSizeSmall),
                        Text(
                          getTranslated('add_new_address', context),
                          style: rubikMedium.copyWith(color: _slate),
                        ),
                      ],
                    ),
                    children: [
                      InlineAddressFormWidget(
                        key: ValueKey('inline-address-form-saved-$_formVersion'),
                        showSaveButton: true,
                        onSaved: onFormSaved,
                      ),
                    ],
                  ),
                )
              else
                InlineAddressFormWidget(
                  key: ValueKey('inline-address-form-$_formVersion'),
                  controller: widget.formController,
                  showSaveButton: false,
                  onSaved: onFormSaved,
                ),
            ],
          ),
        );
      },
    );
  }
}
