import 'package:hexacom_user/common/widgets/text_hover_widget.dart';
import 'package:hexacom_user/utill/dimensions.dart';
import 'package:hexacom_user/utill/styles.dart';
import 'package:flutter/material.dart';

class CartCountWidget extends StatelessWidget {
  final int count;
  final IconData icon;
  final Color? iconColor;
  const CartCountWidget({
    super.key, required this.count, required this.icon, this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final color = iconColor ?? (Theme.of(context).focusColor);
    return TextHoverWidget(builder: (isHover)=> Stack(clipBehavior: Clip.none, children: [
      Icon(icon, color: isHover ? Theme.of(context).primaryColor : color,
        size: Dimensions.paddingSizeExtraLarge,
      ),

      if(count > 0) Positioned(top: -15, right: -10, child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Theme.of(context).cardColor, width: 2),
        ),
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Theme.of(context).primaryColor,
          ),
          padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
          child: Text('$count',style: rubikRegular.copyWith(
            color: Colors.white,
            fontSize: Dimensions.fontSizeExtraSmall,
          )),
        ),
      )),


    ]));
  }
}
