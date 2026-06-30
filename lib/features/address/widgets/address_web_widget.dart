import 'package:flutter/material.dart';
import 'package:hexacom_user/common/models/address_model.dart';
import 'package:hexacom_user/features/address/widgets/address_details_web_widget.dart';
import 'package:hexacom_user/localization/language_constrants.dart';
import 'package:hexacom_user/utill/dimensions.dart';
import 'package:hexacom_user/utill/styles.dart';

class AddressWebWidget extends StatefulWidget {
  final TextEditingController contactPersonNameController;
  final TextEditingController contactPersonNumberController;
  final TextEditingController addressTextController;
  final TextEditingController? buildingController;
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

  const AddressWebWidget({
    super.key,
    required this.contactPersonNameController,
    required this.contactPersonNumberController,
    required this.addressTextController,
    this.buildingController,
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

  @override
  State<AddressWebWidget> createState() => _AddressWebWidgetState();
}

class _AddressWebWidgetState extends State<AddressWebWidget> {
  static const _slate = Color(0xFF3A4756);

  @override
  Widget build(BuildContext context) {

    final Size size = MediaQuery.sizeOf(context);
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640),
        child: Container(
          padding: EdgeInsets.fromLTRB(
            size.width * 0.03,
            size.height * 0.025,
            size.width * 0.03,
            size.height * 0.035,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Theme.of(context).cardColor,
            border: Border.all(color: _slate, width: 4.5),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).shadowColor.withValues(alpha: 0.10),
                blurRadius: 18,
                spreadRadius: 0,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.center,
                child: Text(
                  getTranslated(
                    widget.isUpdateEnable ? 'update_address' : 'add_new_address',
                    context,
                  ),
                  textAlign: TextAlign.center,
                  style: rubikBold.copyWith(
                    fontSize: Dimensions.fontSizeOverLarge,
                    color: _slate,
                  ),
                ),
              ),
              const SizedBox(height: Dimensions.paddingSizeLarge),
              AddressDetailsWebWidget(
                contactPersonNameController: widget.contactPersonNameController,
                contactPersonNumberController: widget.contactPersonNumberController,
                addressTextController: widget.addressTextController,
                buildingController: widget.buildingController,
                addressNode: widget.addressNode,
                nameNode: widget.nameNode,
                numberNode: widget.numberNode,
                isUpdateEnable: widget.isUpdateEnable,
                address: widget.address,
                fromCheckout: widget.fromCheckout,
                selectedCity: widget.selectedCity,
                onCityChanged: widget.onCityChanged,
                selectedAreaId: widget.selectedAreaId,
                onAreaChanged: widget.onAreaChanged,
              ),
            ],
          ),
        ),
      ),
    );
  }
}