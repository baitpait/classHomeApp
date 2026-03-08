import 'package:hexacom_user/utill/dimensions.dart';
import 'package:hexacom_user/utill/styles.dart';
import 'package:hexacom_user/common/widgets/custom_directionality_widget.dart';
import 'package:flutter/material.dart';

class CartItemWidget extends StatelessWidget {
  const CartItemWidget({super.key, required this.title, required this.subTitle, this.style});

  final String title;
  final String subTitle;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final TextStyle defaultLabelStyle = rubikRegular.copyWith(
      fontSize: Dimensions.fontSizeDefault,
      color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.85),
    );
    final TextStyle defaultValueStyle = rubikSemiBold.copyWith(
      fontSize: Dimensions.fontSizeLarge,
      color: Theme.of(context).textTheme.bodyLarge?.color,
    );

    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(title, style: style ?? defaultLabelStyle),

      CustomDirectionalityWidget(child: Text(
        subTitle,
        style: style ?? defaultValueStyle,
      )),
    ]);
  }
}