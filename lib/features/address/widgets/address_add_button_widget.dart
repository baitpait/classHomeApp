import 'package:hexacom_user/localization/language_constrants.dart';
import 'package:hexacom_user/utill/dimensions.dart';
import 'package:hexacom_user/utill/styles.dart';
import 'package:hexacom_user/common/widgets/on_hover.dart';
import 'package:flutter/material.dart';

class AddressAddButtonWidget extends StatelessWidget {
  final Function onTap;
  static const _slate = Color(0xFF1F4C5C);

  const AddressAddButtonWidget({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeExtraSmall),
      child: OnHover(
        child: InkWell(
          onTap: onTap as void Function()?,
          hoverColor: Colors.transparent,
          borderRadius: BorderRadius.circular(30),
          child: Container(
            width: 160.0,
            decoration: BoxDecoration(
              color: _slate,
              borderRadius: BorderRadius.circular(30.0),
              boxShadow: [
                BoxShadow(
                  color: _slate.withValues(alpha: 0.25),
                  blurRadius: 12, offset: const Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeSmall),
            child: Row(
              children: [
                const Icon(Icons.add_circle, color: Colors.white),
                const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                Flexible(child: Text(getTranslated('add_new_address', context), style: rubikRegular.copyWith(
                  color: Colors.white, fontSize: Dimensions.fontSizeSmall,
                )))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
