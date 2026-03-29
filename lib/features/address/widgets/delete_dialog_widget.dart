import 'package:hexacom_user/common/models/address_model.dart';
import 'package:hexacom_user/features/address/providers/address_provider.dart';
import 'package:hexacom_user/helper/custom_snackbar_helper.dart';
import 'package:flutter/material.dart';
import 'package:hexacom_user/localization/language_constrants.dart';
import 'package:hexacom_user/utill/dimensions.dart';
import 'package:hexacom_user/utill/styles.dart';
import 'package:provider/provider.dart';

class DeleteDialogWidget extends StatelessWidget {
  final AddressModel addressModel;
  final int index;

  static const _slate = Color(0xFF3A4756);

  const DeleteDialogWidget({super.key, required this.addressModel, required this.index});
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SizedBox(
        width: 300,
        child: Column(mainAxisSize: MainAxisSize.min, children: [

          const SizedBox(height: 24),
          CircleAvatar(
            radius: 30,
            backgroundColor: _slate.withValues(alpha: 0.10),
            child: const Icon(Icons.contact_support, size: 40, color: _slate),
          ),

          Padding(
            padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
            child: FittedBox(
              child: Text(getTranslated('want_to_delete', context), style: rubikBold, textAlign: TextAlign.center, maxLines: 1),
            ),
          ),

          Divider(height: 0, color: Theme.of(context).dividerColor),

           Row(children: [

            Expanded(child: InkWell(
              onTap: () {
                showDialog(context: context, barrierDismissible: false, builder: (context) => const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(_slate),
                  ),
                ));
                Provider.of<AddressProvider>(context, listen: false).deleteUserAddressByID(addressModel.id, index, (bool isSuccessful, String message) {
                  Navigator.pop(context);
                  showCustomSnackBar(
                    isSuccessful ? getTranslated('address_deleted_successfully', context) : message,
                    context,
                    isError: !isSuccessful,
                  );
                  Navigator.pop(context);
                });
              },
              child: Container(
                padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                alignment: Alignment.center,
                decoration: const BoxDecoration(borderRadius: BorderRadius.only(bottomLeft: Radius.circular(16))),
                child: Text(getTranslated('yes', context), style: rubikBold.copyWith(color: _slate)),
              ),
            )),

            Expanded(child: InkWell(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: _slate,
                  borderRadius: BorderRadius.only(bottomRight: Radius.circular(16)),
                ),
                child: Text(getTranslated('no', context), style: rubikBold.copyWith(color: Colors.white)),
              ),
            )),

          ])
        ]),
      ),
    );
  }
}
