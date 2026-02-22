import 'package:hexacom_user/common/models/address_model.dart';
import 'package:hexacom_user/common/models/config_model.dart';
import 'package:hexacom_user/features/auth/providers/auth_provider.dart';
import 'package:hexacom_user/features/checkout/providers/checkout_provider.dart';
import 'package:hexacom_user/features/checkout/widgets/delivery_fee_dialog_widget.dart';
import 'package:hexacom_user/features/order/enums/delivery_charge_type.dart';
import 'package:hexacom_user/features/order/providers/order_provider.dart';
import 'package:hexacom_user/localization/language_constrants.dart';
import 'package:hexacom_user/main.dart';
import 'package:hexacom_user/features/address/providers/address_provider.dart';
import 'package:hexacom_user/features/splash/providers/splash_provider.dart';
import 'package:hexacom_user/common/widgets/custom_loader_widget.dart';
import 'package:hexacom_user/helper/custom_snackbar_helper.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

class CheckOutHelper {

  static AddressModel? getDeliveryAddress({
    required List<AddressModel?>? addressList,
    required AddressModel? selectedAddress,
    required AddressModel? lastOrderAddress,
  }){
    AddressModel? deliveryAddress;
    if(selectedAddress != null) {
      deliveryAddress = selectedAddress;
    }else if(lastOrderAddress != null){
      deliveryAddress = lastOrderAddress;
    }else if(addressList != null && addressList.isNotEmpty){
      deliveryAddress = addressList.first;
    }

    return deliveryAddress;
  }

  static bool isBranchAvailable({required List<Branches> branches, required Branches selectedBranch, required AddressModel selectedAddress}){
    bool isAvailable = branches.length == 1 && (branches[0].latitude == null || branches[0].latitude!.isEmpty);

    if(!isAvailable) {
      double distance = Geolocator.distanceBetween(
        double.parse(selectedBranch.latitude!), double.parse(selectedBranch.longitude!),
        double.parse(selectedAddress.latitude!), double.parse(selectedAddress.longitude!),
      ) / 1000;

      isAvailable = distance < selectedBranch.coverage!;
    }

    return isAvailable;
  }

  static bool isKmWiseCharge({required ConfigModel? configModel}) {
    final SplashProvider splashProvider = Provider.of<SplashProvider>(Get.context!, listen: false);
    final CheckoutProvider checkoutProvider = Provider.of<CheckoutProvider>(Get.context!, listen: false);
    return splashProvider.deliveryInfoModelList?[checkoutProvider.branchIndex].deliveryChargeSetup?.deliveryChargeType == DeliveryChargeType.distance.name;
  }


  static Future<void> selectDeliveryAddress(BuildContext context,{
    required bool isAvailable,
    required int index,
    required ConfigModel configModel,
    required bool fromAddressList,
  }) async {

    final CheckoutProvider checkoutProvider = context.read<CheckoutProvider>();
    final AddressProvider addressProvider = context.read<AddressProvider>();
    final OrderProvider orderProvider = context.read<OrderProvider>();
    final SplashProvider splashProvider = context.read<SplashProvider>();

    if(isAvailable) {

      addressProvider.updateAddressIndex(index, fromAddressList);
      checkoutProvider.setOrderAddressIndex(index, notify: false);

      // When delivery charge is by area, set or clear area from selected saved address so delivery updates
      final bool isAreaWiseDelivery = CheckOutHelper.getDeliveryChargeType(context) == DeliveryChargeType.area.name ||
          (splashProvider.deliveryInfoModelList != null &&
              checkoutProvider.branchIndex < (splashProvider.deliveryInfoModelList!.length) &&
              (splashProvider.deliveryInfoModelList![checkoutProvider.branchIndex].deliveryChargeByArea?.isNotEmpty ?? false));
      if(isAreaWiseDelivery) {
        final AddressModel? addr = addressProvider.addressList != null && index >= 0 && index < addressProvider.addressList!.length
            ? addressProvider.addressList![index] : null;
        if(addr?.areaId != null) {
          orderProvider.setAreaID(areaID: addr!.areaId!, isUpdate: true);
        } else {
          orderProvider.setAreaID(isReload: true, isUpdate: true);
        }
      }

      if(CheckOutHelper.isKmWiseCharge(configModel: configModel)) {
        if(fromAddressList) {
          if(checkoutProvider.selectedPaymentMethod != null){
            showCustomSnackBar(getTranslated('your_payment_method_has_been', Get.context!), Get.context!, isError: false);
          }
          checkoutProvider.savePaymentMethod(index: null, method: null);

        }
        showDialog(context: Get.context!, builder: (context) => Center(child: Container(
          height: 100, width: 100, alignment: Alignment.center,
          decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(10)),
          child: CustomLoaderWidget(color: Theme.of(context).primaryColor),
        )), barrierDismissible: false);

        bool isSuccess = await checkoutProvider.getDistanceInMeter(
          LatLng(
            double.parse(configModel.branches![checkoutProvider.branchIndex].latitude!),
            double.parse(configModel.branches![checkoutProvider.branchIndex].longitude!),
          ),
          LatLng(
            double.parse(addressProvider.addressList![index].latitude!),
            double.parse(addressProvider.addressList![index].longitude!),
          ),
        );


        Navigator.pop(Get.context!);

        if(fromAddressList) {
          Navigator.pop(context);
          await showDialog(context: Get.context!, builder: (context) => DeliveryFeeDialogWidget(
            freeDelivery: checkoutProvider.getCheckOutData?.freeDeliveryType == 'free_delivery',
            amount: checkoutProvider.getCheckOutData?.amount ?? 0,
            distance: checkoutProvider.distance,
            callBack: (deliveryCharge){
              checkoutProvider.getCheckOutData?.copyWith(deliveryCharge: deliveryCharge);
              orderProvider.setDeliveryCharge(checkoutProvider.getCheckOutData?.deliveryCharge);
            },
          ));
        }else{
          checkoutProvider.getCheckOutData?.copyWith(deliveryCharge: CheckOutHelper.getDeliveryCharge(
            context: Get.context!,
            isSelfPickUp: checkoutProvider.getCheckOutData?.orderType == 'self_pickup',
            freeDeliveryType: checkoutProvider.getCheckOutData?.freeDeliveryType,
            orderAmount: checkoutProvider.getCheckOutData?.amount ?? 0,
            distance: checkoutProvider.distance,
            discount: checkoutProvider.getCheckOutData?.placeOrderDiscount ?? 0,
            configModel: configModel,
          ));
          orderProvider.setDeliveryCharge(checkoutProvider.getCheckOutData?.deliveryCharge);
        }

        if(!isSuccess){
          showCustomSnackBar(getTranslated('failed_to_fetch_distance', Get.context!), Get.context!);
        }
      }else{
        checkoutProvider.getCheckOutData?.copyWith(deliveryCharge: CheckOutHelper.getDeliveryCharge(
          context: Get.context!,
          isSelfPickUp: checkoutProvider.getCheckOutData?.orderType == 'self_pickup',
          freeDeliveryType: checkoutProvider.getCheckOutData?.freeDeliveryType,
          orderAmount: checkoutProvider.getCheckOutData?.amount ?? 0,
          distance: checkoutProvider.distance,
          discount: checkoutProvider.getCheckOutData?.placeOrderDiscount ?? 0,
          configModel: configModel,
        ));
        orderProvider.setDeliveryCharge(checkoutProvider.getCheckOutData?.deliveryCharge);
      }

    }else{
      showCustomSnackBar(getTranslated('out_of_coverage_for_this_branch', Get.context!), Get.context!);
    }
  }


  static double getDeliveryCharge({
    required double orderAmount,
    bool? isSelfPickUp,
    required double distance,
    required double discount,
    required String? freeDeliveryType,
    required ConfigModel configModel,
    required BuildContext context,
  }) {
    final SplashProvider splashProvider = context.read<SplashProvider>();
    final CheckoutProvider checkoutProvider = context.read<CheckoutProvider>();

    double deliveryCharge = 0;

    if(freeDeliveryType == 'free_delivery' || (isSelfPickUp ?? false)){
      deliveryCharge = 0;
    }else{
      final String chargeType = getDeliveryChargeType(context);
      final hasAreaList = (splashProvider.deliveryInfoModelList?[checkoutProvider.branchIndex].deliveryChargeByArea?.isNotEmpty ?? false);
      // Prefer area-based logic when branch is area type or has areas configured (avoid using fixed default e.g. 100)
      if(chargeType == DeliveryChargeType.area.name || (hasAreaList && chargeType != DeliveryChargeType.distance.name)){
        deliveryCharge = getAreaWiseDeliveryCharge(context);
      }else if(chargeType == DeliveryChargeType.fixed.name){
        deliveryCharge = splashProvider.deliveryInfoModelList?[checkoutProvider.branchIndex].deliveryChargeSetup?.fixedDeliveryCharge?.toDouble() ?? 0.0;
      }else if(chargeType == DeliveryChargeType.distance.name && distance != -1 && distance > getMinimumDistanceForFreeDelivery(context)){
        deliveryCharge = distance * getDeliveryChargePerKm(context);
      }
    }

    return deliveryCharge;
  }

  static selectDeliveryAddressAuto({AddressModel? lastAddress, required bool isLoggedIn, required String? orderType}) async {
    final AddressProvider locationProvider = Provider.of<AddressProvider>(Get.context!, listen: false);
    final CheckoutProvider checkoutProvider = Provider.of<CheckoutProvider>(Get.context!, listen: false);
    final SplashProvider splashProvider = Provider.of<SplashProvider>(Get.context!, listen: false);


    AddressModel? deliveryAddress = CheckOutHelper.getDeliveryAddress(
      addressList: locationProvider.addressList,
      selectedAddress: checkoutProvider.orderAddressIndex == -1 ? null : locationProvider.addressList?[checkoutProvider.orderAddressIndex],
      lastOrderAddress: lastAddress,
    );


    if(isLoggedIn && orderType == 'delivery' && deliveryAddress != null && locationProvider.getAddressIndex(deliveryAddress) != null){

      if(isSelectDeliveryAddress(deliveryAddress)){

        await CheckOutHelper.selectDeliveryAddress(Get.context!,
          isAvailable: true,
          index: locationProvider.getAddressIndex(deliveryAddress)!,
          configModel: splashProvider.configModel!,
          fromAddressList: false,
        );
      }

    }

  }

  static bool isSelfPickup({required String? orderType}) => orderType == 'self_pickup';

  static bool isGuestCheckout(BuildContext context){
    final SplashProvider splashProvider = context.read<SplashProvider>();
    final AuthProvider authProvider = context.read<AuthProvider>();
    return (splashProvider.configModel!.isGuestCheckout!) && authProvider.getGuestId() != null;

  }

  static String getDeliveryChargeType(BuildContext context){
    final CheckoutProvider checkoutProvider = Provider.of<CheckoutProvider>(context, listen: false);
    final SplashProvider splashProvider = Provider.of<SplashProvider>(context, listen: false);

    return splashProvider.deliveryInfoModelList?[checkoutProvider.branchIndex].deliveryChargeSetup?.deliveryChargeType ?? '';
  }

  static double getMinimumDistanceForFreeDelivery(BuildContext context){
    final CheckoutProvider checkoutProvider = context.read<CheckoutProvider>();
    final SplashProvider splashProvider = context.read<SplashProvider>();
    return splashProvider.deliveryInfoModelList?[checkoutProvider.branchIndex].deliveryChargeSetup?.minimumDistanceForFreeDelivery?.toDouble() ?? 0.0;
  }

  static double getDeliveryChargePerKm(BuildContext context){
    final CheckoutProvider checkoutProvider = context.read<CheckoutProvider>();
    final SplashProvider splashProvider = context.read<SplashProvider>();

    return splashProvider.deliveryInfoModelList?[checkoutProvider.branchIndex].deliveryChargeSetup?.deliveryChargePerKilometer?.toDouble() ?? 0.0;
  }

  static double getAreaWiseDeliveryCharge(BuildContext context){
    final CheckoutProvider checkoutProvider = context.read<CheckoutProvider>();
    final SplashProvider splashProvider = context.read<SplashProvider>();
    final OrderProvider orderProvider = context.read<OrderProvider>();

    final int? areaId = orderProvider.selectedAreaID;
    if(areaId == null){
      return 0.0;
    }
    int? toInt(dynamic v) {
      if (v == null) return null;
      if (v is int) return v;
      if (v is num) return v.toInt();
      if (v is String) return int.tryParse(v);
      return null;
    }
    bool matchId(dynamic id) => toInt(id) == areaId;

    final configModel = splashProvider.configModel;
    if(configModel?.areas != null) {
      final list = configModel!.areas!.where((a) => matchId(a.id)).toList();
      if(list.isNotEmpty && list.first.deliveryCharge != null) return list.first.deliveryCharge!;
    }
    final areas = splashProvider.deliveryInfoModelList?[checkoutProvider.branchIndex].deliveryChargeByArea;
    if(areas != null && areas.isNotEmpty) {
      try {
        final area = areas.firstWhere((area) => matchId(area.id));
        return area.deliveryCharge?.toDouble() ?? 0.0;
      } catch (_) {}
    }
    return 0.0;
  }

  static bool isSelectDeliveryAddress(AddressModel deliveryAddress){

    bool isSelectDeliveryAddress = false;
    bool hasLatLon = (deliveryAddress.latitude?.isNotEmpty ?? false) && (deliveryAddress.longitude?.isNotEmpty ?? false);
    if(hasLatLon){
      //isSelectDeliveryAddress = getDeliveryChargeType(Get.context!) == DeliveryChargeType.distance.name;
      isSelectDeliveryAddress = true;
    }else{
      isSelectDeliveryAddress = !(getDeliveryChargeType(Get.context!) == DeliveryChargeType.distance.name);
    }

    return isSelectDeliveryAddress;
  }

}