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

  static const _slate = Color(0xFF3A4756);

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
    final List<CityModel> citiesStructured = config?.citiesStructured ?? [];
    /// All cities from all areas (area is derived from selected city for API).
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
      padding: ResponsiveHelper.isDesktop(context)
          ? const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge, vertical: Dimensions.paddingSizeLarge)
          : EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          _buildSectionCard(
            context,
            icon: Icons.person_outline_rounded,
            title: getTranslated('contact_information', context),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  getTranslated('contact_person_name', context),
                  style: rubikMedium.copyWith(color: Theme.of(context).hintColor, fontSize: Dimensions.fontSizeSmall),
                ),
                const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                CustomTextFieldWidget(
                  hintText: getTranslated('enter_contact_person_name', context),
                  isShowBorder: true,
                  isDense: false,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  inputType: TextInputType.name,
                  controller: contactPersonNameController,
                  focusNode: nameNode,
                  nextFocus: numberNode,
                  inputAction: TextInputAction.next,
                  capitalization: TextCapitalization.words,
                ),
                const SizedBox(height: Dimensions.paddingSizeDefault),

                Text(
                  getTranslated('contact_person_number', context),
                  style: rubikMedium.copyWith(color: Theme.of(context).hintColor, fontSize: Dimensions.fontSizeSmall),
                ),
                const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                CustomTextFieldWidget(
                  hintText: getTranslated('enter_contact_person_number', context),
                  isShowBorder: true,
                  isDense: false,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
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
              ],
            ),
          ),

          const SizedBox(height: Dimensions.paddingSizeDefault),

          _buildSectionCard(
            context,
            icon: Icons.location_on_outlined,
            title: getTranslated('location_details', context),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  getTranslated('city', context),
                  style: rubikMedium.copyWith(color: Theme.of(context).hintColor, fontSize: Dimensions.fontSizeSmall),
                ),
                const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                _buildDropdownContainer(
                  context,
                  child: DropdownButtonHideUnderline(
                    child: hasAreasAndCities
                        ? DropdownButton<int?>(
                            value: selectedCityId,
                            hint: Text('${getTranslated('select', context)} ${getTranslated('city', context)}'),
                            isExpanded: true,
                            items: allCities.map((CityModel c) {
                              return DropdownMenuItem<int?>(
                                value: c.id,
                                child: Text(_cityName(c, locale)),
                              );
                            }).toList(),
                            onChanged: (int? id) {
                              if (id == null) return;
                              final c = allCities.firstWhere((c) => c.id == id);
                              onCityChanged(_cityName(c, locale));
                              onAreaChanged?.call(c.areaId);
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

                Text(
                  getTranslated('address', context),
                  style: rubikMedium.copyWith(color: Theme.of(context).hintColor, fontSize: Dimensions.fontSizeSmall),
                ),
                const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                CustomTextFieldWidget(
                  onChanged: (String? value) {
                    locationProvider.setAddress = value;
                  },
                  hintText: getTranslated('address', context),
                  isShowBorder: true,
                  isDense: false,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  maxLines: 5,
                  inputType: TextInputType.multiline,
                  inputAction: TextInputAction.newline,
                  capitalization: TextCapitalization.sentences,
                  focusNode: addressNode,
                  controller: addressTextController,
                ),
              ],
            ),
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

  Widget _buildSectionCard(BuildContext context, {required IconData icon, required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withValues(alpha: 0.10),
            blurRadius: 18, spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: _slate.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 18, color: _slate),
            ),
            const SizedBox(width: 10),
            Text(title, style: rubikMedium.copyWith(fontSize: Dimensions.fontSizeLarge)),
          ]),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildDropdownContainer(BuildContext context, {required Widget child}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: 2),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(10),
      ),
      alignment: Alignment.centerLeft,
      child: child,
    );
  }
}
