import 'package:flutter/material.dart';
import 'package:hexacom_user/utill/dimensions.dart';


Future<void> showCustomBottomSheet({
  required Widget child,
  double? topLeftRadius,
  double? topRightRadius,
  required BuildContext context
}) async {
  await showModalBottomSheet(
    context: context,
    backgroundColor: Colors.white,
    constraints: BoxConstraints(minWidth: double.infinity, maxHeight: (MediaQuery.sizeOf(context).height * 0.95) - MediaQuery.viewInsetsOf(context).bottom),
    isScrollControlled: true,
    barrierColor: Colors.black.withValues(alpha: Theme.of(context).brightness == Brightness.dark ? 0.8 : 0.6),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(topLeftRadius ?? Dimensions.paddingSizeExtraLarge),
        topRight: Radius.circular(topRightRadius ?? Dimensions.paddingSizeExtraLarge),
      ),
    ),
    builder: (context) {
      return SafeArea(
        child: child,
      );
    },
  );
}