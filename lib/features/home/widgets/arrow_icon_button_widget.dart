import 'package:hexacom_user/common/widgets/on_hover.dart';
import 'package:hexacom_user/helper/responsive_helper.dart';
import 'package:flutter/material.dart';

class ArrowIconButtonWidget extends StatelessWidget {
  final bool isRight;
  final void Function()? onTap;
  const ArrowIconButtonWidget({super.key, this.isRight = true, this.onTap});

  @override
  Widget build(BuildContext context) {
    // Icon points logically: isRight = "next", !isRight = "previous".
    // Flutter will automatically mirror these in RTL layouts.
    final icon = Icon(
      isRight ? Icons.arrow_forward : Icons.arrow_back,
      color: Theme.of(context).primaryColor,
      size: 25,
    );
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        height: 40, width: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Theme.of(context).cardColor,
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
        ),
        child: ResponsiveHelper.isWeb() ? icon : OnHover(child: icon),
      ),
    );
  }
}
