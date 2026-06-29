import 'package:country_code_picker/country_code_picker.dart';
import 'package:hexacom_user/common/models/address_model.dart';
import 'package:hexacom_user/common/models/config_model.dart';
import 'package:hexacom_user/features/address/providers/address_provider.dart';
import 'package:hexacom_user/features/address/widgets/address_button_widget.dart';
import 'package:hexacom_user/features/address/providers/location_provider.dart';
import 'package:hexacom_user/localization/language_constrants.dart';
import 'package:hexacom_user/provider/localization_provider.dart';
import 'package:hexacom_user/utill/cities_list.dart';
import 'package:hexacom_user/utill/dimensions.dart';
import 'package:hexacom_user/features/splash/providers/splash_provider.dart';
import 'package:hexacom_user/utill/styles.dart';
import 'package:hexacom_user/common/widgets/custom_text_field_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AddressDetailsWebWidget extends StatelessWidget {
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

  const AddressDetailsWebWidget({
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

  static String _cityName(CityModel c, String langCode) {
    return (langCode == 'ar' && (c.nameAr ?? '').isNotEmpty) ? (c.nameAr ?? c.nameEn ?? '') : (c.nameEn ?? c.nameAr ?? '');
  }

  static String _areaName(AreaModel a, String langCode) {
    return (langCode == 'ar' && (a.nameAr ?? '').isNotEmpty) ? (a.nameAr ?? a.nameEn ?? '') : (a.nameEn ?? a.nameAr ?? '');
  }

  @override
  Widget build(BuildContext context) {
    final LocationProvider locationProvider = context.read<LocationProvider>();
    final config = context.read<SplashProvider>().configModel;
    final locale = context.read<LocalizationProvider>().locale.languageCode;
    final hasAreasAndCities = (config?.areas != null && config!.areas!.isNotEmpty &&
        config.citiesStructured != null && config.citiesStructured!.isNotEmpty);
    final List<String> citiesFallback = config?.cities ?? citiesList;
    final List<CityModel> citiesStructured = config?.citiesStructured ?? [];
    final List<CityModel> allCities = citiesStructured;
    int? selectedCityId;
    if (hasAreasAndCities && selectedCity != null && selectedCity!.isNotEmpty && selectedAreaId != null) {
      for (final c in allCities) {
        if (_cityName(c, locale) == selectedCity && c.areaId == selectedAreaId) {
          selectedCityId = c.id;
          break;
        }
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge, vertical: Dimensions.paddingSizeLarge),
      child: Consumer<AddressProvider>(
        builder: (context, addressProvider, _) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomTextFieldWidget(
                title: getTranslated("name", context),
                isRequired: true,
                hintText: getTranslated('enter_contact_person_name', context),
                isShowBorder: true,
                inputType: TextInputType.name,
                controller: contactPersonNameController,
                focusNode: nameNode,
                nextFocus: numberNode,
                inputAction: TextInputAction.next,
                capitalization: TextCapitalization.words,
                isDense: false,
              ),
              const SizedBox(height: Dimensions.paddingSizeDefault),
              CustomTextFieldWidget(
                countryDialCode: addressProvider.countryCode,
                onCountryChanged: (CountryCode value) => addressProvider.setCountryCode(value.dialCode ?? '', isUpdate: true),
                isRequired: true,
                title: getTranslated('phone_number', context),
                hintText: getTranslated('enter_contact_person_number', context),
                isShowBorder: true,
                inputType: TextInputType.phone,
                inputAction: TextInputAction.next,
                focusNode: numberNode,
                nextFocus: addressNode,
                controller: contactPersonNumberController,
                isDense: false,
              ),
              const SizedBox(height: Dimensions.paddingSizeDefault),

              if (hasAreasAndCities) ...[
                Text(
                  getTranslated('region', context),
                  style: rubikRegular.copyWith(
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                    fontSize: Dimensions.fontSizeDefault,
                  ),
                ),
                const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
                  decoration: BoxDecoration(
                    border: Border.all(color: Theme.of(context).dividerColor),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int?>(
                      value: selectedAreaId,
                      hint: Text('${getTranslated('select', context)} ${getTranslated('region', context)}'),
                      isExpanded: true,
                      items: (config.areas ?? []).map((AreaModel a) {
                        return DropdownMenuItem<int?>(
                          value: a.id,
                          child: Text(_areaName(a, locale)),
                        );
                      }).toList(),
                      onChanged: (int? id) {
                        if (id == null || id == selectedAreaId) return;
                        onAreaChanged?.call(id);
                        onCityChanged(null);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: Dimensions.paddingSizeDefault),
              ],

              Text(
                getTranslated('city', context),
                style: rubikRegular.copyWith(
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                  fontSize: Dimensions.fontSizeDefault,
                ),
              ),
              const SizedBox(height: Dimensions.paddingSizeExtraSmall),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
                decoration: BoxDecoration(
                  border: Border.all(color: Theme.of(context).dividerColor),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: DropdownButtonHideUnderline(
                  child: hasAreasAndCities
                      ? DropdownButton<int?>(
                          value: selectedCityId,
                          hint: Text(selectedAreaId == null
                              ? getTranslated('select_region_first', context)
                              : '${getTranslated('select', context)} ${getTranslated('city', context)}'),
                          isExpanded: true,
                          items: allCities.where((c) => c.areaId == selectedAreaId).map((CityModel c) {
                            return DropdownMenuItem<int?>(
                              value: c.id,
                              child: Text(_cityName(c, locale)),
                            );
                          }).toList(),
                          onChanged: selectedAreaId == null ? null : (int? id) {
                            if (id == null) return;
                            final c = allCities.firstWhere((c) => c.id == id);
                            onCityChanged(_cityName(c, locale));
                          },
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
              const SizedBox(height: Dimensions.paddingSizeDefault),

              CustomTextFieldWidget(
                title: getTranslated('address', context),
                isRequired: true,
                onChanged: (String? value) => locationProvider.setAddress = value,
                hintText: getTranslated('address', context),
                isShowBorder: true,
                maxLines: 5,
                inputType: TextInputType.multiline,
                inputAction: TextInputAction.newline,
                capitalization: TextCapitalization.sentences,
                focusNode: addressNode,
                controller: addressTextController,
                isDense: false,
              ),
              const SizedBox(height: Dimensions.paddingSizeLarge),
              AddressButtonWidget(
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
            ],
          );
        },
      ),
    );
  }
}
