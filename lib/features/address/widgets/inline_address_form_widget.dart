import 'package:country_code_picker/country_code_picker.dart';
import 'package:hexacom_user/common/models/address_model.dart';
import 'package:hexacom_user/common/models/config_model.dart';
import 'package:hexacom_user/common/models/response_model.dart';
import 'package:hexacom_user/common/widgets/custom_button_widget.dart';
import 'package:hexacom_user/features/address/providers/address_provider.dart';
import 'package:hexacom_user/features/address/providers/location_provider.dart';
import 'package:hexacom_user/features/address/widgets/address_details_widget.dart';
import 'package:hexacom_user/features/order/providers/order_provider.dart';
import 'package:hexacom_user/features/profile/providers/profile_provider.dart';
import 'package:hexacom_user/features/splash/providers/splash_provider.dart';
import 'package:hexacom_user/helper/custom_snackbar_helper.dart';
import 'package:hexacom_user/helper/phone_number_checker_helper.dart';
import 'package:hexacom_user/localization/language_constrants.dart';
import 'package:hexacom_user/utill/dimensions.dart';
import 'package:hexacom_user/utill/styles.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Lets an external widget (e.g. the place-order button) trigger saving the inline address form.
class AddressFormController {
  Future<bool> Function()? _save;
  bool Function()? _isSaved;

  /// Saves the form; returns true on success (or if already saved). Shows validation snackbars on failure.
  Future<bool> save() async => _save == null ? false : await _save!();

  /// Whether the form has already been saved (avoids creating duplicate addresses).
  bool get isSaved => _isSaved?.call() ?? false;
}

/// Inline form to add a new address (e.g. inside cart). Uses same fields and validation as [AddNewAddressScreen].
/// On save success calls [onSaved] so parent can refresh list, select new address, and recalc delivery.
class InlineAddressFormWidget extends StatefulWidget {
  /// Async so the caller can finish selecting the new address / recalculating
  /// delivery before [save] returns (fixes needing a second tap).
  final Future<void> Function()? onSaved;
  final AddressFormController? controller;
  final bool showSaveButton;

  const InlineAddressFormWidget({super.key, this.onSaved, this.controller, this.showSaveButton = true});

  @override
  State<InlineAddressFormWidget> createState() => _InlineAddressFormWidgetState();
}

class _InlineAddressFormWidgetState extends State<InlineAddressFormWidget> {
  final TextEditingController _contactPersonNameController = TextEditingController();
  final TextEditingController _contactPersonNumberController = TextEditingController();
  final TextEditingController _addressTextController = TextEditingController();
  final FocusNode _addressNode = FocusNode();
  final FocusNode _nameNode = FocusNode();
  final FocusNode _numberNode = FocusNode();

  String? _selectedCity;
  int? _selectedAreaId;
  bool _isSaved = false;

  static const _slate = Color(0xFF1F4C5C);

  @override
  void initState() {
    super.initState();
    widget.controller?._save = save;
    widget.controller?._isSaved = () => _isSaved;
    WidgetsBinding.instance.addPostFrameCallback((_) => _initForm());
  }

  @override
  void dispose() {
    _contactPersonNameController.dispose();
    _contactPersonNumberController.dispose();
    _addressTextController.dispose();
    _addressNode.dispose();
    _nameNode.dispose();
    _numberNode.dispose();
    super.dispose();
  }

  Future<void> _initForm() async {
    final AddressProvider addressProvider = context.read<AddressProvider>();
    final SplashProvider splashProvider = context.read<SplashProvider>();
    final ProfileProvider profileProvider = context.read<ProfileProvider>();
    final ConfigModel configModel = splashProvider.configModel!;

    addressProvider.setCountryCode(CountryCode.fromCountryCode(configModel.countryCode!).dialCode ?? '');
    context.read<LocationProvider>().setPickedAddressLatLon(null, null, isUpdate: false);

    final userModel = profileProvider.userInfoModel;
    _contactPersonNameController.text = '${userModel?.fName ?? ''} ${userModel?.lName ?? ''}'.trim();
    if (_contactPersonNameController.text.isEmpty) {
      _contactPersonNameController.text = '';
    }
    addressProvider.setCountryCode(
      PhoneNumberCheckerHelper.getCountryCode(userModel?.phone ?? CountryCode.fromCountryCode(configModel.countryCode!).dialCode) ?? '',
      isUpdate: true,
    );
    _contactPersonNumberController.text =
        PhoneNumberCheckerHelper.getPhoneNumber(userModel?.phone ?? '', addressProvider.countryCode ?? '') ?? '';
    addressProvider.setAddressStatusMessage = '';
    addressProvider.setErrorMessage = '';
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final AddressProvider addressProvider = context.read<AddressProvider>();

    return Padding(
      padding: const EdgeInsets.only(top: Dimensions.paddingSizeDefault),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AddressDetailsWidget(
            contactPersonNameController: _contactPersonNameController,
            contactPersonNumberController: _contactPersonNumberController,
            addressTextController: _addressTextController,
            addressNode: _addressNode,
            nameNode: _nameNode,
            numberNode: _numberNode,
            isUpdateEnable: false,
            fromCheckout: true,
            address: null,
            selectedCity: _selectedCity,
            onCityChanged: (String? city) => setState(() => _selectedCity = city),
            selectedAreaId: _selectedAreaId,
            onAreaChanged: (int? id) {
              setState(() => _selectedAreaId = id);
              // Reflect the chosen region in delivery charge immediately (before saving),
              // so base + roll surcharge show live in the summary.
              if (id != null) {
                context.read<OrderProvider>().setAreaID(areaID: id, isUpdate: true);
              }
            },
            showSaveButton: false,
          ),
          if (addressProvider.addressStatusMessage != null && addressProvider.addressStatusMessage!.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle_rounded, color: Colors.green.shade600, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      getTranslated('address_added_successfuly', context),
                      style: rubikMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: Colors.green.shade700),
                    ),
                  ),
                ],
              ),
            ),
          if (addressProvider.addressStatusMessage == null && (addressProvider.errorMessage?.isNotEmpty ?? false))
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline_rounded, color: Colors.red.shade600, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      addressProvider.errorMessage ?? '',
                      style: rubikMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: Colors.red.shade700),
                    ),
                  ),
                ],
              ),
            ),
          if (widget.showSaveButton)
            Consumer<LocationProvider>(
              builder: (context, locationProvider, _) {
                return SizedBox(
                  width: double.infinity,
                  child: CustomButtonWidget(
                    isLoading: addressProvider.isLoading,
                    btnTxt: getTranslated('save_location', context),
                    backgroundColor: _slate,
                    onTap: addressProvider.isLoading || locationProvider.isLoading
                        ? null
                        : () => save(),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  /// Validates and saves the address. Returns true on success (or if already saved).
  /// Shows a validation snackbar and returns false on invalid input.
  Future<bool> save() async {
    if (_isSaved) return true;
    final AddressProvider addressProvider = context.read<AddressProvider>();
    final LocationProvider locationProvider = context.read<LocationProvider>();
    final SplashProvider splashProvider = context.read<SplashProvider>();
    final List<Branches>? branches = splashProvider.configModel?.branches;
    bool isAvailable = branches == null ||
        branches.isEmpty ||
        (branches.length == 1 && (branches[0].latitude == null || branches[0].latitude!.isEmpty));

    final String phone =
        (addressProvider.countryCode ?? '') + _contactPersonNumberController.text.trim().replaceFirst(RegExp(r'^0+'), '');
    final bool isValidPhone = PhoneNumberCheckerHelper.isPhoneValidWithCountryCode(phone);

    if (_contactPersonNameController.text.trim().isEmpty) {
      showCustomSnackBar(getTranslated('enter_contact_person_name', context), context);
      return false;
    }
    if (_selectedCity == null || _selectedCity!.isEmpty) {
      showCustomSnackBar('${getTranslated('select', context)} ${getTranslated('city', context)}', context);
      return false;
    }
    final String addressText = _addressTextController.text.trim();
    if (addressText.isEmpty) {
      showCustomSnackBar(getTranslated('please_enter_address', context), context);
      return false;
    }
    if (!isValidPhone) {
      showCustomSnackBar(getTranslated('invalid_phone_number', context), context);
      return false;
    }

    if (!isAvailable && branches.isNotEmpty) {
      isAvailable = true;
    }

    if (!isAvailable) {
      showCustomSnackBar(getTranslated('service_is_not_available', context), context);
      return false;
    }

    final AddressModel addressModel = AddressModel(
      addressType: 'Other',
      contactPersonName: _contactPersonNameController.text.trim(),
      contactPersonNumber: phone,
      city: _selectedCity,
      areaId: _selectedAreaId,
      address: addressText.isNotEmpty ? addressText : locationProvider.address,
      latitude: null,
      longitude: null,
    );

    final ResponseModel value = await addressProvider.addAddress(addressModel, context);
    if (!mounted) return false;
    if (value.isSuccess) {
      _isSaved = true;
      await widget.onSaved?.call();
      return true;
    } else {
      showCustomSnackBar(value.message ?? '', context);
      return false;
    }
  }
}
