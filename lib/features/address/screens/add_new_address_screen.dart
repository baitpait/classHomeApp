import 'package:country_code_picker/country_code_picker.dart';
import 'package:hexacom_user/common/enums/footer_type_enum.dart';
import 'package:hexacom_user/common/models/address_model.dart';
import 'package:hexacom_user/common/models/config_model.dart';
import 'package:hexacom_user/common/widgets/footer_web_widget.dart';
import 'package:hexacom_user/common/widgets/web_app_bar_widget.dart';
import 'package:hexacom_user/features/address/providers/address_provider.dart';
import 'package:hexacom_user/features/address/providers/location_provider.dart';
import 'package:hexacom_user/features/address/widgets/address_button_widget.dart';
import 'package:hexacom_user/features/address/widgets/address_details_widget.dart';
import 'package:hexacom_user/features/address/widgets/address_web_widget.dart';
import 'package:hexacom_user/features/profile/providers/profile_provider.dart';
import 'package:hexacom_user/features/splash/providers/splash_provider.dart';
import 'package:hexacom_user/helper/phone_number_checker_helper.dart';
import 'package:hexacom_user/helper/responsive_helper.dart';
import 'package:hexacom_user/localization/language_constrants.dart';
import 'package:hexacom_user/utill/dimensions.dart';
import 'package:hexacom_user/utill/styles.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AddNewAddressScreen extends StatefulWidget {
  final bool isUpdateEnable;
  final bool fromCheckout;
  final AddressModel? address;
  const AddNewAddressScreen({super.key, this.isUpdateEnable = true, this.address, this.fromCheckout = false});

  @override
  State<AddNewAddressScreen> createState() => _AddNewAddressScreenState();
}

class _AddNewAddressScreenState extends State<AddNewAddressScreen> {
  final TextEditingController _contactPersonNameController = TextEditingController();
  final TextEditingController _contactPersonNumberController = TextEditingController();
  final TextEditingController _addressTextController = TextEditingController();

  final FocusNode _addressNode = FocusNode();
  final FocusNode _nameNode = FocusNode();
  final FocusNode _numberNode = FocusNode();

  String? _selectedCity;
  int? _selectedAreaId;

  static const _slate = Color(0xFF1F4C5C);

  @override
  void initState() {
    super.initState();
    _initLoading();

    if (widget.address != null && !widget.fromCheckout) {
      Provider.of<LocationProvider>(context, listen: false).setAddress = widget.address?.address;
      _addressTextController.text = widget.address!.address ?? '';
      _selectedCity = widget.address!.city;
      _selectedAreaId = widget.address!.areaId;
    }
  }

  @override
  Widget build(BuildContext context) {

    final AddressProvider addressProvider = context.read<AddressProvider>();
    final bool isUpdate = widget.isUpdateEnable;

    return Scaffold(
      appBar: ResponsiveHelper.isDesktop(context)
          ? const PreferredSize(preferredSize: Size.fromHeight(90), child: WebAppBarWidget())
          : null,
      body: Selector<SplashProvider, ConfigModel?>(
        selector: (ctx, splashProvider)=> splashProvider.configModel,
        builder: (context, configModel,_) {

          addressProvider.setCountryCode(CountryCode.fromCountryCode(configModel!.countryCode!).dialCode ?? '');
          final bool isDesktop = ResponsiveHelper.isDesktop(context);

          return Column(children: [

            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minHeight: constraints.maxHeight),
                      child: Column(
                        mainAxisAlignment: isDesktop ? MainAxisAlignment.center : MainAxisAlignment.start,
                        children: [

              if(!isDesktop)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  decoration: const BoxDecoration(color: _slate),
                  child: Row(children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 22),
                      padding: const EdgeInsets.all(8),
                      constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        isUpdate ? Icons.edit_location_alt_rounded : Icons.add_location_alt_rounded,
                        color: Colors.white, size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isUpdate ? getTranslated('update_address', context) : getTranslated('add_new_address', context),
                          style: rubikBold.copyWith(color: Colors.white, fontSize: Dimensions.fontSizeLarge),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          isUpdate
                              ? getTranslated('update_your_delivery_address', context)
                              : getTranslated('enter_your_delivery_details', context),
                          style: rubikRegular.copyWith(color: Colors.white.withValues(alpha: 0.7), fontSize: Dimensions.fontSizeSmall),
                        ),
                      ],
                    )),
                  ]),
                ),

                    Padding(
                      padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
                      child: Center(
                        child: SizedBox(
                          width: Dimensions.webScreenWidth,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (!isDesktop)
                                AddressDetailsWidget(
                                  contactPersonNameController: _contactPersonNameController,
                                  contactPersonNumberController: _contactPersonNumberController,
                                  addressTextController: _addressTextController,
                                  addressNode: _addressNode,
                                  nameNode: _nameNode,
                                  numberNode: _numberNode,
                                  fromCheckout: widget.fromCheckout,
                                  address: widget.address,
                                  isUpdateEnable: widget.isUpdateEnable,
                                  selectedCity: _selectedCity,
                                  onCityChanged: (String? city) => setState(() => _selectedCity = city),
                                  selectedAreaId: _selectedAreaId,
                                  onAreaChanged: (int? id) => setState(() => _selectedAreaId = id),
                                ),
                              if (isDesktop)
                                AddressWebWidget(
                                  contactPersonNameController: _contactPersonNameController,
                                  contactPersonNumberController: _contactPersonNumberController,
                                  addressTextController: _addressTextController,
                                  addressNode: _addressNode,
                                  nameNode: _nameNode,
                                  numberNode: _numberNode,
                                  fromCheckout: widget.fromCheckout,
                                  address: widget.address,
                                  isUpdateEnable: widget.isUpdateEnable,
                                  selectedCity: _selectedCity,
                                  onCityChanged: (String? city) => setState(() => _selectedCity = city),
                                  selectedAreaId: _selectedAreaId,
                                  onAreaChanged: (int? id) => setState(() => _selectedAreaId = id),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                      ),
                    ),
                  );
                },
              ),
            ),

            const FooterWebWidget(footerType: FooterType.nonSliver),

            if(!ResponsiveHelper.isDesktop(context))
              AddressButtonWidget(
                isUpdateEnable: widget.isUpdateEnable,
                fromCheckout: widget.fromCheckout,
                contactPersonNumberController: _contactPersonNumberController,
                contactPersonNameController: _contactPersonNameController,
                addressTextController: _addressTextController,
                address: widget.address,
                selectedCity: _selectedCity ?? '',
                countryCode : addressProvider.countryCode ?? '',
                selectedAreaId: _selectedAreaId,
              ),

          ]);
        }
      ),
    );
  }

  void _initLoading() async {

    final LocationProvider locationProvider = Provider.of<LocationProvider>(context, listen: false);
    final AddressProvider addressProvider = Provider.of<AddressProvider>(context, listen: false);
    final userModel =  Provider.of<ProfileProvider>(context, listen: false).userInfoModel ;
    final ConfigModel configModel = context.read<SplashProvider>().configModel!;

    addressProvider.setCountryCode(CountryCode.fromCountryCode(Provider.of<SplashProvider>(context, listen: false).configModel!.countryCode!).dialCode ?? '');

    locationProvider.setPickedAddressLatLon(null, null, isUpdate: false);

    if(widget.address == null) {
      locationProvider.setLocationData(false);
    }

    await addressProvider.initializeAllAddressType(context: context);
    addressProvider.setAddressStatusMessage = '';
    addressProvider.setErrorMessage = '';

    if (widget.isUpdateEnable && widget.address != null) {

      _contactPersonNameController.text = '${widget.address!.contactPersonName}';

      addressProvider.setCountryCode(PhoneNumberCheckerHelper.getCountryCode('${widget.address!.contactPersonNumber}') ?? '');
      _contactPersonNumberController.text = PhoneNumberCheckerHelper.getPhoneNumber('+${widget.address!.contactPersonNumber?.replaceAll('++', '+')}', addressProvider.countryCode ?? '') ?? '';
      _addressTextController.text = widget.address!.address ?? '';
      _selectedCity = widget.address!.city;
      _selectedAreaId = widget.address!.areaId;
    } else {
      _contactPersonNameController.text = '${userModel?.fName ?? ''} ${userModel?.lName ?? ''}';
      addressProvider.setCountryCode(PhoneNumberCheckerHelper.getCountryCode(userModel?.phone ?? CountryCode.fromCountryCode(configModel.countryCode!).dialCode) ?? '', isUpdate: true);
      _contactPersonNumberController.text = PhoneNumberCheckerHelper.getPhoneNumber(userModel?.phone ?? '', addressProvider.countryCode ?? '') ?? '';
      _addressTextController.text = widget.address?.address ?? '';
      _selectedCity = widget.address?.city;
      _selectedAreaId = widget.address?.areaId;
    }
  }
}
