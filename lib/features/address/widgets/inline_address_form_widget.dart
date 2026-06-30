import 'package:hexacom_user/common/models/address_model.dart';
import 'package:hexacom_user/common/models/config_model.dart';
import 'package:hexacom_user/common/models/response_model.dart';
import 'package:hexacom_user/common/widgets/custom_button_widget.dart';
import 'package:hexacom_user/features/address/providers/address_provider.dart';
import 'package:hexacom_user/features/address/providers/location_provider.dart';
import 'package:hexacom_user/features/address/widgets/address_details_widget.dart';
import 'package:hexacom_user/features/profile/providers/profile_provider.dart';
import 'package:hexacom_user/features/splash/providers/splash_provider.dart';
import 'package:hexacom_user/helper/custom_snackbar_helper.dart';
import 'package:hexacom_user/helper/phone_number_checker_helper.dart';
import 'package:hexacom_user/localization/language_constrants.dart';
import 'package:hexacom_user/utill/dimensions.dart';
import 'package:hexacom_user/utill/styles.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Inline form to add a new address (e.g. inside cart). Uses same fields and validation as [AddNewAddressScreen].
/// On save success calls [onSaved] so parent can refresh list, select new address, and recalc delivery.
class InlineAddressFormWidget extends StatefulWidget {
  final VoidCallback? onSaved;

  const InlineAddressFormWidget({super.key, this.onSaved});

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

  static const _slate = Color(0xFF3A4756);

  @override
  void initState() {
    super.initState();
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
    final ProfileProvider profileProvider = context.read<ProfileProvider>();

    // Fixed dial code for this store: +972
    addressProvider.setCountryCode('+972', isUpdate: false);
    context.read<LocationProvider>().setPickedAddressLatLon(null, null, isUpdate: false);

    final userModel = profileProvider.userInfoModel;
    _contactPersonNameController.text = '${userModel?.fName ?? ''} ${userModel?.lName ?? ''}'.trim();
    if (_contactPersonNameController.text.isEmpty) {
      _contactPersonNameController.text = '';
    }
    // Prefill the local part of the user's phone (without country code / leading zeros).
    final String localPhone = (PhoneNumberCheckerHelper.getPhoneNumber(userModel?.phone ?? '', '+972') ?? '')
        .replaceFirst(RegExp(r'^0+'), '');
    _contactPersonNumberController.text = localPhone;
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
            onAreaChanged: (int? id) => setState(() => _selectedAreaId = id),
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
                      : () => _onSave(context),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _onSave(BuildContext context) async {
    final AddressProvider addressProvider = context.read<AddressProvider>();
    final LocationProvider locationProvider = context.read<LocationProvider>();
    final SplashProvider splashProvider = context.read<SplashProvider>();
    final List<Branches>? branches = splashProvider.configModel?.branches;
    bool isAvailable = branches == null ||
        branches.isEmpty ||
        (branches.length == 1 && (branches[0].latitude == null || branches[0].latitude!.isEmpty));

    // Local part without leading zeros; fixed +972 prefix.
    final String localNumber = _contactPersonNumberController.text.trim().replaceFirst(RegExp(r'^0+'), '');
    final String phone = '+972$localNumber';
    final bool isValidPhone = PhoneNumberCheckerHelper.isPhoneValidWithCountryCode(phone);

    if (_contactPersonNameController.text.trim().isEmpty) {
      showCustomSnackBar(getTranslated('enter_contact_person_name', context), context);
      return;
    }
    if (_selectedCity == null || _selectedCity!.isEmpty) {
      showCustomSnackBar('${getTranslated('select', context)} ${getTranslated('city', context)}', context);
      return;
    }
    final String addressText = _addressTextController.text.trim();
    if (addressText.isEmpty) {
      showCustomSnackBar(getTranslated('please_enter_address', context), context);
      return;
    }
    if (!isValidPhone) {
      showCustomSnackBar(getTranslated('invalid_phone_number', context), context);
      return;
    }

    if (!isAvailable && branches.isNotEmpty) {
      isAvailable = true;
    }

    if (!isAvailable) {
      showCustomSnackBar(getTranslated('service_is_not_available', context), context);
      return;
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
    if (!context.mounted) return;
    if (value.isSuccess) {
      showCustomSnackBar(getTranslated('address_added_successfuly', context), context, isError: false);
      widget.onSaved?.call();
    } else {
      showCustomSnackBar(value.message ?? '', context);
    }
  }
}
