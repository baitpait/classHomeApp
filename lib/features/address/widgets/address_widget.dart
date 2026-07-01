import 'package:hexacom_user/common/models/address_model.dart';
import 'package:hexacom_user/common/models/config_model.dart';
import 'package:hexacom_user/common/widgets/custom_loader_widget.dart';
import 'package:hexacom_user/features/checkout/providers/checkout_provider.dart';
import 'package:hexacom_user/features/order/enums/delivery_charge_type.dart';
import 'package:hexacom_user/helper/checkout_helper.dart';
import 'package:hexacom_user/helper/responsive_helper.dart';
import 'package:hexacom_user/localization/language_constrants.dart';
import 'package:hexacom_user/features/address/providers/address_provider.dart';
import 'package:hexacom_user/features/splash/providers/splash_provider.dart';
import 'package:hexacom_user/utill/dimensions.dart';
import 'package:hexacom_user/utill/images.dart';
import 'package:hexacom_user/utill/routes.dart';
import 'package:hexacom_user/utill/styles.dart';
import 'package:hexacom_user/common/widgets/custom_alert_dialog_widget.dart';
import 'package:hexacom_user/helper/custom_snackbar_helper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


class AddressWidget extends StatelessWidget {

  final AddressModel addressModel;
  final int index;
  final bool fromSelectAddress;
  final bool? isAvailableForDelivery;

  static const _slate = Color(0xFF1F4C5C);

  const AddressWidget({
    super.key,
    required this.addressModel,
    required this.index,
    this.fromSelectAddress = false,
    this.isAvailableForDelivery
  });

  @override
  Widget build(BuildContext context) {
    final AddressProvider addressProvider = Provider.of<AddressProvider>(context, listen: false);
    final CheckoutProvider checkoutProvider = Provider.of<CheckoutProvider>(context, listen: false);
    final ConfigModel configModel = Provider.of<SplashProvider>(context, listen: false).configModel!;

    return Padding(
      padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () async {
          if(fromSelectAddress){
            if((configModel.googleMapStatus ?? false) && CheckOutHelper.getDeliveryChargeType(context) == DeliveryChargeType.distance.name){
              bool isAvailable = CheckOutHelper.isBranchAvailable(
                branches: configModel.branches ?? [],
                selectedBranch: configModel.branches![checkoutProvider.branchIndex],
                selectedAddress: addressProvider.addressList![index],
              );

              CheckOutHelper.selectDeliveryAddress(context,
                isAvailable: isAvailable, index: index, configModel: configModel,
                fromAddressList: true,
              );

            }else{
              CheckOutHelper.selectDeliveryAddress(context,
                isAvailable: true, index: index, configModel: configModel,
                fromAddressList: true,
              );
            }
          }

        },
        child: Stack(children: [

          Container(padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              border: fromSelectAddress && index == addressProvider.selectAddressIndex
                  ? Border.all(width: 1.5, color: _slate)
                  : null,
              borderRadius: BorderRadius.circular(14),
              color: Theme.of(context).cardColor,
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).shadowColor.withValues(alpha: 0.10),
                  blurRadius: 18, spreadRadius: 0,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [

              Expanded(flex: 2, child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [

                fromSelectAddress ? Radio(
                  activeColor: _slate,
                  value: index,
                  groupValue: addressProvider.selectAddressIndex,
                  onChanged: (_){},
                ) : Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _slate.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.location_on_rounded, color: _slate, size: 20),
                ),
                const SizedBox(width: Dimensions.paddingSizeDefault),

                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [

                  Text(
                    addressModel.city != null && addressModel.city!.isNotEmpty
                        ? addressModel.city!
                        : getTranslated('address', context),
                    style: rubikMedium.copyWith(fontSize: Dimensions.fontSizeLarge),
                  ),
                  const SizedBox(height: 4),

                  Text(addressModel.address ?? '', maxLines: fromSelectAddress ? 1 : 3, style: rubikRegular.copyWith(
                    color: Theme.of(context).textTheme.bodyLarge?.color?.withValues(alpha: 0.6), fontSize: Dimensions.fontSizeDefault,
                  )),
                ]))

              ])),

              if (fromSelectAddress)
                InkWell(
                  onTap: () {
                    ResponsiveHelper.showDialogOrBottomSheet(
                      context,
                      CustomAlertDialogWidget(
                        title: getTranslated('remove_this_address', context),
                        subTitle: getTranslated('address_will_be_remove_from_list', context),
                        image: Images.locationDeleteIcon,
                        onPressRight: () {
                          Navigator.pop(context);

                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (context) => const Center(
                              child: CustomLoaderWidget(color: _slate),
                            ),
                          );

                          addressProvider.deleteUserAddressByID(addressModel.id, index, (bool isSuccessful, String message) {
                            Navigator.pop(context);

                            // Keep selected index stable if the list shrinks.
                            final currentSelected = addressProvider.selectAddressIndex;
                            if (index == currentSelected) {
                              addressProvider.updateAddressIndex(0, true);
                            } else if (index < currentSelected) {
                              addressProvider.updateAddressIndex(currentSelected - 1, true);
                            }

                            showCustomSnackBar(
                              isSuccessful ? getTranslated('address_deleted_successfully', context) : message,
                              context,
                              isError: !isSuccessful,
                            );
                          });
                        },
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _slate.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.delete_outline_rounded,
                      color: _slate,
                      size: 20,
                    ),
                  ),
                )
              else
                PopupMenuButton<String>(
                padding: const EdgeInsets.all(0),
                icon: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: _slate.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.more_vert_rounded, color: _slate, size: 18),
                ),
                onSelected: (String result) {
                  if (result == 'delete') {
                    ResponsiveHelper.showDialogOrBottomSheet(context, CustomAlertDialogWidget(
                      title: getTranslated('remove_this_address', context),
                      subTitle: getTranslated('address_will_be_remove_from_list', context),
                      image: Images.locationDeleteIcon,
                      onPressRight: (){
                        Navigator.pop(context);

                        showDialog(context: context, barrierDismissible: false, builder: (context) => Center(
                          child: CustomLoaderWidget(color: _slate),
                        ));

                        addressProvider.deleteUserAddressByID(addressModel.id, index, (bool isSuccessful, String message) {
                          Navigator.pop(context);
                          showCustomSnackBar(
                            isSuccessful ? getTranslated('address_deleted_successfully', context) : message,
                            context,
                            isError: !isSuccessful,
                          );
                        });
                      },

                    ));

                  } else {
                    addressProvider.setAddressStatusMessage = '';
                    RouteHelper.getAddAddressRoute(context, 'address', 'update', addressModel);
                  }
                },
                itemBuilder: (BuildContext c) => <PopupMenuEntry<String>>[
                  PopupMenuItem<String>(
                    value: 'edit',
                    child: Row(children: [
                      const Icon(Icons.edit_outlined, size: 18, color: _slate),
                      const SizedBox(width: 8),
                      Text(getTranslated('edit', context), style: rubikMedium),
                    ]),
                  ),
                  PopupMenuItem<String>(
                    value: 'delete',
                    child: Row(children: [
                      Icon(Icons.delete_outline_rounded, size: 18, color: Colors.red.shade400),
                      const SizedBox(width: 8),
                      Text(getTranslated('delete', context), style: rubikMedium.copyWith(color: Colors.red.shade400)),
                    ]),
                  ),
                ],
              ),

            ]),
          ),

          if(fromSelectAddress && !(isAvailableForDelivery ?? false))...[
            Positioned.fill(
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6),
                ),
                child: Text(
                  getTranslated('out_of_coverage_for_this_branch', context),
                  textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis,
                  style: rubikRegular.copyWith(color: Colors.white, fontSize: 10),
                ),
              ),

            ),
          ],

        ]),
      ),
    );
  }
}
