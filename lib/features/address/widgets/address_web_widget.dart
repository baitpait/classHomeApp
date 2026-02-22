import 'package:flutter/material.dart';
import 'package:hexacom_user/common/models/address_model.dart';
import 'package:hexacom_user/features/address/providers/address_provider.dart';
import 'package:hexacom_user/features/address/widgets/address_button_widget.dart';
import 'package:hexacom_user/features/address/widgets/address_details_web_widget.dart';
import 'package:provider/provider.dart';

class AddressWebWidget extends StatefulWidget {
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

  const AddressWebWidget({
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

  @override
  State<AddressWebWidget> createState() => _AddressWebWidgetState();
}

class _AddressWebWidgetState extends State<AddressWebWidget> {
  @override
  Widget build(BuildContext context) {

    final Size size = MediaQuery.of(context).size;
    final AddressProvider addressProvider = context.read<AddressProvider>();

    return Container(
      padding: EdgeInsets.symmetric(horizontal: size.width * 0.06, vertical: size.height * 0.02),
      margin: EdgeInsets.symmetric(horizontal: size.width * 0.08),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(color:Theme.of(context).shadowColor, blurRadius: 10)
        ],
      ),
      child: Column(children: [

        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [

          Expanded(flex: 5, child: AddressDetailsWebWidget(
            contactPersonNameController: widget.contactPersonNameController,
            contactPersonNumberController: widget.contactPersonNumberController,
            addressTextController: widget.addressTextController,
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
          )),

        ]),

        Row(children: [
          Expanded(child: Container()),
          Expanded(child: AddressButtonWidget(
            isUpdateEnable: widget.isUpdateEnable,
            fromCheckout: widget.fromCheckout,
            contactPersonNumberController: widget.contactPersonNumberController,
            contactPersonNameController: widget.contactPersonNameController,
            addressTextController: widget.addressTextController,
            address: widget.address,
            selectedCity: widget.selectedCity ?? '',
            countryCode: addressProvider.countryCode ?? '',
            selectedAreaId: widget.selectedAreaId,
          )),
          Expanded(child: Container()),
        ]),

      ]),
    );
  }
}
