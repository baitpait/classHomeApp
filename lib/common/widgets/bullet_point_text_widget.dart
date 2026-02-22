import 'package:flutter/material.dart';
import 'package:hexacom_user/utill/dimensions.dart';
import 'package:hexacom_user/utill/styles.dart';

class BulletPointTextWidget extends StatelessWidget {
  final String text;
  final TextStyle? textStyle;
  const BulletPointTextWidget({super.key, required this.text, this.textStyle});

  @override
  Widget build(BuildContext context) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.only(top: Dimensions.radiusSizeDefault, left: Dimensions.paddingSizeSmall),
        child: CircleAvatar(
          radius: 2,
          backgroundColor: Theme.of(context).textTheme.bodyLarge?.color?.withValues(alpha: 0.70),
        ),
      ),
      SizedBox(width: Dimensions.paddingSizeExtraSmall),

      Flexible(child: Text(text, style: textStyle ?? rubikRegular.copyWith(
        fontSize: Dimensions.fontSizeDefault,
        color: Theme.of(context).textTheme.bodyLarge?.color?.withValues(alpha: 0.70),
      ))),
    ]);
  }
}
