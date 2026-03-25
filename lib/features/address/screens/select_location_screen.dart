import 'package:hexacom_user/features/address/providers/location_provider.dart';
import 'package:hexacom_user/features/order/providers/order_provider.dart';
import 'package:hexacom_user/features/splash/providers/splash_provider.dart';
import 'package:hexacom_user/helper/responsive_helper.dart';
import 'package:hexacom_user/main.dart';
import 'package:hexacom_user/localization/language_constrants.dart';
import 'package:hexacom_user/provider/localization_provider.dart';
import 'package:hexacom_user/utill/dimensions.dart';
import 'package:hexacom_user/utill/feature_flags.dart';
import 'package:hexacom_user/utill/styles.dart';
import 'package:flutter/material.dart';
import 'package:hexacom_user/common/widgets/custom_button_widget.dart';
import 'package:hexacom_user/common/widgets/custom_text_field_widget.dart';
import 'package:hexacom_user/common/widgets/web_app_bar_widget.dart';
import 'package:provider/provider.dart';

class SelectLocationScreen extends StatefulWidget {
  const SelectLocationScreen({super.key});

  @override
  State<SelectLocationScreen> createState() => _SelectLocationScreenState();
}

class _SelectLocationScreenState extends State<SelectLocationScreen> {
  final TextEditingController _locationController = TextEditingController();
  int? _selectedAreaId;

  @override
  void initState() {
    super.initState();

    final LocationProvider locationProvider = Provider.of<LocationProvider>(context, listen: false);
    locationProvider.setPickData();
    if ((locationProvider.address ?? '').isNotEmpty) {
      _locationController.text = locationProvider.address ?? '';
    }
  }

  @override
  void dispose() {
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ResponsiveHelper.isDesktop(context)
          ? const PreferredSize(preferredSize: Size.fromHeight(90), child: WebAppBarWidget())
          : AppBar(
              backgroundColor: const Color(0xFF3A4756),
              elevation: 0,
              leading: const SizedBox.shrink(),
              centerTitle: true,
              title: Text(getTranslated('select_delivery_address', context), style: rubikMedium.copyWith(color: Colors.white)),
            ),
      body: _buildTextAndAreaBody(context),
    );
  }

  /// When map is disabled: address text field + area dropdown only.
  Widget _buildTextAndAreaBody(BuildContext context) {
    final locationProvider = Provider.of<LocationProvider>(context, listen: false);
    final splashProvider = Provider.of<SplashProvider>(context, listen: false);
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);
    final configModel = splashProvider.configModel;
    final locale = Provider.of<LocalizationProvider>(context, listen: false).locale.languageCode;

    if (_locationController.text.isEmpty && (locationProvider.address ?? '').isNotEmpty) {
      _locationController.text = locationProvider.address ?? '';
    }

    List<({int id, String name})> areaOptions = [];
    final byArea = splashProvider.deliveryInfoModelList?.isNotEmpty == true
        ? splashProvider.deliveryInfoModelList![0].deliveryChargeByArea
        : null;
    if (byArea != null && byArea.isNotEmpty) {
      for (final a in byArea) {
        final name = (locale == 'ar' && (a.nameAr ?? '').isNotEmpty) ? (a.nameAr ?? a.areaName ?? '') : (a.nameEn ?? a.areaName ?? '');
        areaOptions.add((id: a.id!, name: name));
      }
    } else if (configModel?.areas != null && configModel!.areas!.isNotEmpty) {
      for (final a in configModel.areas!) {
        final name = (locale == 'ar' && (a.nameAr != null && a.nameAr!.isNotEmpty)) ? a.nameAr! : (a.nameEn ?? '');
        areaOptions.add((id: a.id!, name: name));
      }
    }

    return Center(
      child: SizedBox(
        width: Dimensions.webScreenWidth,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                getTranslated('delivery_address', context),
                style: rubikMedium.copyWith(fontSize: Dimensions.fontSizeDefault),
              ),
              const SizedBox(height: Dimensions.paddingSizeSmall),
              CustomTextFieldWidget(
                controller: _locationController,
                hintText: getTranslated('address', context),
                maxLines: 2,
                inputType: TextInputType.streetAddress,
              ),
              const SizedBox(height: Dimensions.paddingSizeLarge),
              if (areaOptions.isNotEmpty) ...[
                Text(
                  getTranslated('zip_area', context),
                  style: rubikMedium.copyWith(fontSize: Dimensions.fontSizeDefault),
                ),
                const SizedBox(height: Dimensions.paddingSizeSmall),
                DropdownButtonFormField<int>(
                  value: _selectedAreaId,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(Dimensions.radiusSizeDefault)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeSmall),
                  ),
                  hint: Text(getTranslated('search_or_select_zip_code_area', context)),
                  items: areaOptions
                      .map((e) => DropdownMenuItem<int>(value: e.id, child: Text(e.name)))
                      .toList(),
                  onChanged: (int? value) {
                    setState(() => _selectedAreaId = value);
                  },
                ),
                const SizedBox(height: Dimensions.paddingSizeLarge),
              ],
              CustomButtonWidget(
                btnTxt: getTranslated('select_location', context),
                backgroundColor: const Color(0xFF3A4756),
                onTap: () {
                  final address = _locationController.text.trim();
                  if (address.isEmpty) {
                    return;
                  }
                  locationProvider.setAddress = address;
                  locationProvider.setLocationData(true);
                  locationProvider.setPickedAddressLatLon('0', '0');
                  if (_selectedAreaId != null) {
                    orderProvider.setAreaID(areaID: _selectedAreaId);
                  }
                  Navigator.of(context).pop(false);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

}
