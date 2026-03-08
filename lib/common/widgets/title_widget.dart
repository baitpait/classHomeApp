import 'package:hexacom_user/helper/responsive_helper.dart';
import 'package:flutter/material.dart';
import 'package:hexacom_user/localization/language_constrants.dart';
import 'package:hexacom_user/utill/dimensions.dart';
import 'package:hexacom_user/utill/styles.dart';

class TitleWidget extends StatelessWidget {
  final String? title;
  final Function? onTap;
  final Widget? leadingButton;

  const TitleWidget({super.key, required this.title, this.onTap, this.leadingButton});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDesktop = ResponsiveHelper.isDesktop(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraSmall),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.center, children: [
        Expanded(
          child: Text(
            title!,
            style: rubikBold.copyWith(
              color: theme.colorScheme.onSurface,
              fontSize: isDesktop ? 20 : 18,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        leadingButton != null ? leadingButton! : onTap != null ? InkWell(
          onTap: onTap as void Function()?,
          borderRadius: BorderRadius.circular(Dimensions.radiusSizeSmall),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraSmall, horizontal: Dimensions.paddingSizeSmall),
            child: Text(
              getTranslated('view_all', context),
              style: rubikMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: const Color(0xFF3A4756)),
            ),
          ),
        ) : const SizedBox(),
      ]),
    );
  }
}
