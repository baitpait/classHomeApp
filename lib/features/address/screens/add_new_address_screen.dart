import 'package:country_code_picker/country_code_picker.dart';
import 'package:hexacom_user/common/enums/footer_type_enum.dart';
import 'package:hexacom_user/common/models/address_model.dart';
import 'package:hexacom_user/common/models/config_model.dart';
import 'package:hexacom_user/common/widgets/custom_app_bar_widget.dart';
import 'package:hexacom_user/common/widgets/custom_web_title_widget.dart';
import 'package:hexacom_user/common/widgets/footer_web_widget.dart';
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

    return Scaffold(
      appBar: CustomAppBarWidget(title: widget.isUpdateEnable ? getTranslated('update_address', context) : getTranslated('add_new_address', context)),
      body: Selector<SplashProvider, ConfigModel?>(
        selector: (ctx, splashProvider)=> splashProvider.configModel,
        builder: (context, configModel,_) {

          addressProvider.setCountryCode(CountryCode.fromCountryCode(configModel!.countryCode!).dialCode ?? '');

          return Column(children: [

            Expanded(child: SingleChildScrollView(child: Column(children: [
              Padding(
                padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
                child: Center(child: SizedBox(width: Dimensions.webScreenWidth, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                    CustomWebTitleWidget(title: getTranslated(widget.isUpdateEnable ? 'update_address' : 'add_new_address', context)),

                    if(!ResponsiveHelper.isDesktop(context))
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
                        onAreaChanged: (int? id) => setState(() {
                          _selectedAreaId = id;
                          _selectedCity = null;
                        }),
                      ),

                    if(ResponsiveHelper.isDesktop(context))
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
                        onAreaChanged: (int? id) => setState(() {
                          _selectedAreaId = id;
                          _selectedCity = null;
                        }),
                      ),

                  ],
                ))),
              ),

              const FooterWebWidget(footerType: FooterType.nonSliver),
            ]))),

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
