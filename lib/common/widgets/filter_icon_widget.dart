import 'package:flutter/material.dart';
import 'package:hexacom_user/common/widgets/custom_asset_image_widget.dart';
import 'package:hexacom_user/helper/responsive_helper.dart';
import 'package:hexacom_user/localization/language_constrants.dart';
import 'package:hexacom_user/utill/dimensions.dart';
import 'package:hexacom_user/utill/images.dart';
import 'package:hexacom_user/utill/styles.dart';

class FilterIconWidget extends StatelessWidget {
  final int filterCount;
  final double? height;
  final double? width;
  final Function()? onTap;

  const FilterIconWidget({super.key, this.filterCount = 3, this.onTap, this.height = 30, this.width = 30});

  @override
  Widget build(BuildContext context) {
    return InkWell(onTap: onTap, child: Stack(children: [

      Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.all(Dimensions.radiusSizeDefault),
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).primaryColor.withValues(alpha: 0.90)),
          borderRadius: BorderRadius.circular(Dimensions.radiusSizeSmall),
        ),
          child: ResponsiveHelper.isMobile(context) ?
          CustomAssetImageWidget(Images.filterIconSvg, width: width, height: height) : Row(children: [
            Text(getTranslated('filter', context), style: rubikMedium.copyWith(fontSize: Dimensions.fontSizeDefault)),
            SizedBox(width: Dimensions.paddingSizeExtraSmall),

            CustomAssetImageWidget(Images.filterIconSvg, width: width, height: height),
          ]),
      ),

      if(filterCount > 0) Positioned(right: 0, top: 0, child: Container(
        width: 17, height: 17,
        transform: Matrix4.translationValues(6, -6, 0),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.error,
          border: Border.all(color: Theme.of(context).highlightColor, width: 1,),
          borderRadius: BorderRadius.circular(Dimensions.radiusSizeFifty),
        ),
        child: Center(child: Text('$filterCount', style: rubikRegular.copyWith(
          fontSize: Dimensions.paddingSizeSmall,
          color: Theme.of(context).cardColor,
        ))),
      )),
    ]));
  }
}
