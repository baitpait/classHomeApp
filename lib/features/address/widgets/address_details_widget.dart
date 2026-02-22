import 'package:country_code_picker/country_code_picker.dart';
import 'package:hexacom_user/common/models/address_model.dart';
import 'package:hexacom_user/common/models/config_model.dart';
import 'package:hexacom_user/features/address/providers/address_provider.dart';
import 'package:hexacom_user/features/address/providers/location_provider.dart';
import 'package:hexacom_user/features/address/widgets/address_button_widget.dart';
import 'package:hexacom_user/helper/auth_helper.dart';
import 'package:hexacom_user/helper/responsive_helper.dart';
import 'package:hexacom_user/localization/language_constrants.dart';
import 'package:hexacom_user/provider/localization_provider.dart';
import 'package:hexacom_user/utill/cities_list.dart';
import 'package:hexacom_user/utill/dimensions.dart';
import 'package:hexacom_user/features/splash/providers/splash_provider.dart';
import 'package:hexacom_user/utill/styles.dart';
import 'package:hexacom_user/common/widgets/custom_text_field_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AddressDetailsWidget extends StatelessWidget {
  final TextEditingController contactPersonNameController;
  final TextEditingController contactPersonNumberController;
  final TextEditingController addressTextController;
  final FocusNode addressNode;
  final FocusNode nameNode;
  final FocusNode numberNode;
  final bool isUpdateEnable;
  final bool fromCheckout;
  final AddressModel? address;
  final String? selectedCity;
  final ValueChanged<String?> onCityChanged;
  final int? selectedAreaId;
  final ValueChanged<int?>? onAreaChanged;

  const AddressDetailsWidget({
    super.key,
    required this.contactPersonNameController,
    required this.contactPersonNumberController,
    required this.addressTextController,
    required this.addressNode,
    required this.nameNode,
    required this.numberNode,
    required this.isUpdateEnable,
    required this.fromCheckout,
    required this.address,
    required this.selectedCity,
    required this.onCityChanged,
    this.selectedAreaId,
    this.onAreaChanged,
  });

  static String _areaName(AreaModel a, String langCode) {
    return (langCode == 'ar' && (a.nameAr ?? '').isNotEmpty) ? (a.nameAr ?? a.nameEn ?? '') : (a.nameEn ?? a.nameAr ?? '');
  }

  static String _cityName(CityModel c, String langCode) {
    return (langCode == 'ar' && (c.nameAr ?? '').isNotEmpty) ? (c.nameAr ?? c.nameEn ?? '') : (c.nameEn ?? c.nameAr ?? '');
  }

  @override
  Widget build(BuildContext context) {
    final LocationProvider locationProvider = context.read<LocationProvider>();
    final AddressProvider addressProvider = context.read<AddressProvider>();
    final config = context.read<SplashProvider>().configModel;
    final locale = context.read<LocalizationProvider>().locale.languageCode;
    final hasAreasAndCities = (config?.areas != null && config!.areas!.isNotEmpty &&
        config.citiesStructured != null && config.citiesStructured!.isNotEmpty);
    final List<String> citiesFallback = config?.cities ?? citiesList;
    final List<AreaModel> areas = config?.areas ?? [];
    final List<CityModel> citiesStructured = config?.citiesStructured ?? [];
    final citiesInArea = hasAreasAndCities && selectedAreaId != null
        ? citiesStructured.where((c) => c.areaId == selectedAreaId).toList()
        : <CityModel>[];

    return Padding(
      padding: ResponsiveHelper.isDesktop(context)
          ? const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge, vertical: Dimensions.paddingSizeLarge)
          : EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Name
          Text(
            getTranslated('contact_person_name', context),
            style: rubikMedium.copyWith(color: Theme.of(context).hintColor),
          ),
          const SizedBox(height: Dimensions.paddingSizeSmall),
          CustomTextFieldWidget(
            hintText: getTranslated('enter_contact_person_name', context),
            isShowBorder: true,
            inputType: TextInputType.name,
            controller: contactPersonNameController,
            focusNode: nameNode,
            nextFocus: numberNode,
            inputAction: TextInputAction.next,
            capitalization: TextCapitalization.words,
          ),
          const SizedBox(height: Dimensions.paddingSizeLarge),

          // Phone number
          Text(
            getTranslated('contact_person_number', context),
            style: rubikMedium.copyWith(color: Theme.of(context).hintColor),
          ),
          const SizedBox(height: Dimensions.paddingSizeSmall),
          CustomTextFieldWidget(
            hintText: getTranslated('enter_contact_person_number', context),
            isShowBorder: true,
            inputType: TextInputType.phone,
            inputAction: TextInputAction.next,
            focusNode: numberNode,
            nextFocus: addressNode,
            controller: contactPersonNumberController,
            countryDialCode: addressProvider.countryCode,
            onCountryChanged: (CountryCode value) {
              addressProvider.setCountryCode(value.dialCode ?? '', isUpdate: true);
            },
            onChanged: (String text) => AuthHelper.identifyEmailOrNumber(text, context),
          ),
          const SizedBox(height: Dimensions.paddingSizeLarge),

          if (hasAreasAndCities) ...[
            Text(
              getTranslated('area', context),
              style: rubikMedium.copyWith(color: Theme.of(context).hintColor),
            ),
            const SizedBox(height: Dimensions.paddingSizeSmall),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
              decoration: BoxDecoration(
                border: Border.all(color: Theme.of(context).dividerColor),
                borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  value: selectedAreaId != null && areas.any((a) => a.id == selectedAreaId) ? selectedAreaId : null,
                  hint: Text('${getTranslated('select', context)} ${getTranslated('area', context)}'),
                  isExpanded: true,
                  items: areas.map((AreaModel area) {
                    return DropdownMenuItem<int>(value: area.id, child: Text(_areaName(area, locale)));
                  }).toList(),
                  onChanged: (int? id) {
                    onAreaChanged?.call(id);
                    onCityChanged(null);
                  },
                ),
              ),
            ),
            const SizedBox(height: Dimensions.paddingSizeLarge),
          ],
          Text(
            getTranslated('city', context),
            style: rubikMedium.copyWith(color: Theme.of(context).hintColor),
          ),
          const SizedBox(height: Dimensions.paddingSizeSmall),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
            decoration: BoxDecoration(
              border: Border.all(color: Theme.of(context).dividerColor),
              borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall),
            ),
            child: DropdownButtonHideUnderline(
              child: hasAreasAndCities
                  ? DropdownButton<String>(
                      value: selectedCity != null && selectedCity!.isNotEmpty &&
                          citiesInArea.any((c) => _cityName(c, locale) == selectedCity)
                          ? selectedCity
                          : null,
                      hint: Text('${getTranslated('select', context)} ${getTranslated('city', context)}'),
                      isExpanded: true,
                      items: citiesInArea.map((CityModel c) {
                        final name = _cityName(c, locale);
                        return DropdownMenuItem<String>(value: name, child: Text(name));
                      }).toList(),
                      onChanged: onCityChanged,
                    )
                  : DropdownButton<String>(
                      value: selectedCity != null && selectedCity!.isNotEmpty && citiesFallback.contains(selectedCity)
                          ? selectedCity
                          : null,
                      hint: Text('${getTranslated('select', context)} ${getTranslated('city', context)}'),
                      isExpanded: true,
                      items: citiesFallback.map((String city) {
                        return DropdownMenuItem<String>(value: city, child: Text(city));
                      }).toList(),
                      onChanged: onCityChanged,
                    ),
            ),
          ),
          const SizedBox(height: Dimensions.paddingSizeLarge),

          // Address
          Text(
            getTranslated('address', context),
            style: rubikMedium.copyWith(color: Theme.of(context).hintColor),
          ),
          const SizedBox(height: Dimensions.paddingSizeSmall),
          CustomTextFieldWidget(
            onChanged: (String? value) {
              locationProvider.setAddress = value;
            },
            hintText: getTranslated('address', context),
            isShowBorder: true,
            inputType: TextInputType.streetAddress,
            inputAction: TextInputAction.done,
            focusNode: addressNode,
            controller: addressTextController,
          ),
          const SizedBox(height: Dimensions.paddingSizeLarge),

          if (ResponsiveHelper.isDesktop(context))
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge),
              child: AddressButtonWidget(
                isUpdateEnable: isUpdateEnable,
                fromCheckout: fromCheckout,
                contactPersonNumberController: contactPersonNumberController,
                contactPersonNameController: contactPersonNameController,
                addressTextController: addressTextController,
                address: address,
                selectedCity: selectedCity ?? '',
                selectedAreaId: selectedAreaId,
                countryCode: addressProvider.countryCode ?? '',
              ),
            ),
        ],
      ),
    );
  }
}
