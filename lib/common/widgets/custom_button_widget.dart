import 'package:hexacom_user/localization/language_constrants.dart';
import 'package:hexacom_user/utill/styles.dart';
import 'package:flutter/material.dart';
import 'package:hexacom_user/utill/color_resources.dart';
import 'package:hexacom_user/utill/dimensions.dart';

class CustomButtonWidget extends StatelessWidget {
  final Function? onTap;
  final String? btnTxt;
  final Color? backgroundColor;
  final double radius;
  final IconData? iconData;
  final TextStyle? style;
  final bool isLoading;
  final double? height;

  const CustomButtonWidget({
    super.key, this.onTap, required this.btnTxt, this.backgroundColor,
    this.radius = 12, this.iconData, this.style, this.isLoading = false, this.height,
  });

  @override
  Widget build(BuildContext context) {
    final double resolvedHeight = height ?? 56;

    final ButtonStyle flatButtonStyle = TextButton.styleFrom(
      backgroundColor: onTap == null
          ? ColorResources.getGreyColor(context)
          : backgroundColor ?? Theme.of(context).colorScheme.secondary,
      minimumSize: Size(0, resolvedHeight),
      maximumSize: Size(double.infinity, resolvedHeight),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius),
      ),
    );

    return TextButton(
      onPressed: isLoading ? null : onTap as void Function()?,
      style: flatButtonStyle,
      child: isLoading ?
      Center(child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        SizedBox(
          height: 15,
          width: 15,
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.onSecondary),
            strokeWidth: 2,
          ),
        ),
        const SizedBox(width: Dimensions.paddingSizeSmall),

        Text(
          getTranslated('loading', context),
          style: rubikBold.copyWith(color: Theme.of(context).colorScheme.onSecondary),
        ),
      ]),
      ) : Row(mainAxisAlignment: MainAxisAlignment.center, children: [

        Icon(iconData, color: Theme.of(context).colorScheme.onSecondary, size: iconData != null ? 20 : 0),
        SizedBox(width: iconData != null ?  Dimensions.paddingSizeSmall : 0),

        Flexible(
          child: Text(
            btnTxt ?? "",
            style: style ??
                rubikMedium.copyWith(
                  color: Theme.of(context).colorScheme.onSecondary,
                  fontSize: Dimensions.fontSizeLarge,
                ),
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ),

      ]),
    );
  }
}
