import 'package:hexacom_user/common/models/address_model.dart';
import 'package:hexacom_user/common/models/config_model.dart';
import 'package:hexacom_user/features/checkout/providers/checkout_provider.dart';
import 'package:hexacom_user/features/checkout/widgets/add_address_dialog_widget.dart';
import 'package:hexacom_user/features/order/enums/delivery_charge_type.dart';
import 'package:hexacom_user/helper/checkout_helper.dart';
import 'package:hexacom_user/helper/responsive_helper.dart';
import 'package:hexacom_user/localization/language_constrants.dart';
import 'package:hexacom_user/features/address/providers/address_provider.dart';
import 'package:hexacom_user/features/splash/providers/splash_provider.dart';
import 'package:hexacom_user/utill/dimensions.dart';
import 'package:hexacom_user/utill/styles.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

class DeliveryAddressWidget extends StatelessWidget {
  final bool selfPickup;

  const DeliveryAddressWidget({
    super.key, required this.selfPickup,
  });

  @override
  Widget build(BuildContext context) {
    final ConfigModel configModel = Provider.of<SplashProvider>(context, listen: false).configModel!;

    return !selfPickup ? Container(
      margin: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeExtraSmall),
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Theme.of(context).shadowColor.withValues(alpha: 0.10), blurRadius: 18, spreadRadius: 0, offset: const Offset(0, 4))],
      ),
      child: Consumer<AddressProvider>(
        builder: (context, locationProvider, _) => Consumer<CheckoutProvider>(
          builder: (context, checkoutProvider, _) {
            bool isAvailable = false;

            AddressModel? deliveryAddress = CheckOutHelper.getDeliveryAddress(
              addressList: locationProvider.addressList,
              selectedAddress: checkoutProvider.orderAddressIndex == -1 ? null : locationProvider.addressList?[checkoutProvider.orderAddressIndex],
              lastOrderAddress: null,
            );

            if(deliveryAddress != null &&
                (configModel.googleMapStatus ?? false) &&
                CheckOutHelper.getDeliveryChargeType(context) == DeliveryChargeType.distance.name
                && ((deliveryAddress.latitude != null && deliveryAddress.latitude!.isNotEmpty) && (deliveryAddress.longitude != null && deliveryAddress.longitude!.isNotEmpty))
            ) {
              isAvailable = CheckOutHelper.isBranchAvailable(
                branches: configModel.branches ?? [],
                selectedBranch: configModel.branches![checkoutProvider.branchIndex],
                selectedAddress: deliveryAddress,
              );

              if(!isAvailable) {
                deliveryAddress = null;
              }
            }

            final bool hasAddress = deliveryAddress != null && checkoutProvider.orderAddressIndex != -1;

            return locationProvider.addressList == null ? const DeliverySectionShimmer() : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

              // --- Title ---
              Row(children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3A4756).withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.location_on_outlined, color: Color(0xFF3A4756), size: 20),
                ),
                const SizedBox(width: Dimensions.paddingSizeSmall),
                Text(getTranslated('delivery_to', context), style: rubikSemiBold.copyWith(fontSize: Dimensions.fontSizeLarge)),
              ]),

              const SizedBox(height: Dimensions.paddingSizeDefault),

              if(!hasAddress) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeDefault, horizontal: Dimensions.paddingSizeSmall),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.error.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(Icons.info_outline_rounded, color: Theme.of(context).colorScheme.error, size: 18),
                    const SizedBox(width: Dimensions.paddingSizeSmall),
                    Text(getTranslated('no_contact_info_added', context), style: rubikRegular.copyWith(color: Theme.of(context).colorScheme.error, fontSize: Dimensions.fontSizeSmall)),
                  ]),
                ),
                const SizedBox(height: Dimensions.paddingSizeDefault),
              ],

              if(hasAddress) ...[
                // --- Address (most important, shown first) ---
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3A4756).withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Icon(Icons.place_rounded, color: Color(0xFF3A4756), size: 20),
                    const SizedBox(width: Dimensions.paddingSizeSmall),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      if (deliveryAddress.city != null && deliveryAddress.city!.isNotEmpty)
                        Text(deliveryAddress.city!, style: rubikMedium.copyWith(fontSize: Dimensions.fontSizeDefault)),
                      Text(
                        deliveryAddress.address ?? '',
                        maxLines: 2, overflow: TextOverflow.ellipsis,
                        style: rubikRegular.copyWith(
                          color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.7),
                          fontSize: Dimensions.fontSizeSmall,
                          height: 1.4,
                        ),
                      ),
                    ])),
                  ]),
                ),

                const SizedBox(height: Dimensions.paddingSizeDefault),

                // --- Contact details in a two-column grid ---
                ResponsiveHelper.isDesktop(context)
                    ? Row(children: [
                        Expanded(
                          child: _ContactRow(
                            icon: Icons.person_outline_rounded,
                            label: getTranslated('contact_person', context),
                            value: deliveryAddress.contactPersonName ?? '',
                          ),
                        ),
                        const SizedBox(width: Dimensions.paddingSizeDefault),
                        Expanded(
                          child: _ContactRow(
                            icon: Icons.phone_outlined,
                            label: getTranslated('phone', context),
                            value: deliveryAddress.contactPersonNumber ?? '',
                          ),
                        ),
                      ])
                    : Column(children: [
                        _ContactRow(
                          icon: Icons.person_outline_rounded,
                          label: getTranslated('contact_person', context),
                          value: deliveryAddress.contactPersonName ?? '',
                        ),
                        const SizedBox(height: Dimensions.paddingSizeSmall),
                        _ContactRow(
                          icon: Icons.phone_outlined,
                          label: getTranslated('phone', context),
                          value: deliveryAddress.contactPersonNumber ?? '',
                        ),
                      ]),

                const SizedBox(height: Dimensions.paddingSizeDefault),
              ],

              // --- Prominent change/add button ---
              InkWell(
                onTap: () => showDialog(context: context, builder: (_) => const AddAddressDialogWidget()),
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFF3A4756).withValues(alpha: 0.20), width: 1.5),
                  ),
                  child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(
                      hasAddress ? Icons.swap_horiz_rounded : Icons.add_location_alt_outlined,
                      color: const Color(0xFF3A4756), size: 20,
                    ),
                    const SizedBox(width: Dimensions.paddingSizeSmall),
                    Text(
                      getTranslated(hasAddress ? 'change' : 'add', context),
                      style: rubikMedium.copyWith(color: const Color(0xFF3A4756)),
                    ),
                  ]),
                ),
              ),

            ]);
          },
        ),
      ),
    ) : const SizedBox();
  }
}

class _ContactRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _ContactRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Icon(icon, color: const Color(0xFF3A4756).withValues(alpha: 0.5), size: 18),
      const SizedBox(width: Dimensions.paddingSizeSmall),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: rubikRegular.copyWith(
          fontSize: Dimensions.fontSizeExtraSmall,
          color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.5),
        )),
        Text(value, style: rubikMedium.copyWith(fontSize: Dimensions.fontSizeDefault)),
      ])),
    ]);
  }
}


class DeliverySectionShimmer extends StatelessWidget {
  const DeliverySectionShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer(child: Column(children: [
      Container(
        margin: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall, horizontal: Dimensions.paddingSizeDefault),
        child: Column(children: [
          const SizedBox(height: Dimensions.paddingSizeSmall),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Container(height: 14, width: 200, decoration: BoxDecoration(color: Theme.of(context).shadowColor, borderRadius: BorderRadius.circular(2))),
            Container(height: 14, width: 50, decoration: BoxDecoration(color: Theme.of(context).shadowColor, borderRadius: BorderRadius.circular(2))),
          ]),
          const Divider(height: Dimensions.paddingSizeDefault),
          Column(children: [
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(height: Dimensions.paddingSizeLarge, width: Dimensions.paddingSizeLarge, decoration: BoxDecoration(color: Theme.of(context).shadowColor, borderRadius: BorderRadius.circular(2))),
              const SizedBox(width: Dimensions.paddingSizeLarge),
              Container(height: 14, width: 200, decoration: BoxDecoration(color: Theme.of(context).shadowColor, borderRadius: BorderRadius.circular(2))),
            ]),
            const SizedBox(height: Dimensions.paddingSizeSmall),
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(height: Dimensions.paddingSizeLarge, width: Dimensions.paddingSizeLarge, decoration: BoxDecoration(color: Theme.of(context).shadowColor, borderRadius: BorderRadius.circular(2))),
              const SizedBox(width: Dimensions.paddingSizeLarge),
              Container(height: 14, width: 250, decoration: BoxDecoration(color: Theme.of(context).shadowColor, borderRadius: BorderRadius.circular(2))),
            ]),
          ]),
          const SizedBox(height: Dimensions.paddingSizeDefault),
        ]),
      ),
    ]));
  }
}
