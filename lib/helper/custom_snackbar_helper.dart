import 'package:hexacom_user/common/widgets/custom_toast.dart';
import 'package:hexacom_user/helper/responsive_helper.dart';
import 'package:hexacom_user/main.dart';
import 'package:hexacom_user/utill/dimensions.dart';
import 'package:flutter/material.dart';
import 'package:hexacom_user/utill/styles.dart';

void showCustomSnackBar(String? message, BuildContext context, {bool isError = true, Duration? duration}) {

  ResponsiveHelper.isDesktop(context) ?
  CustomToast().show(
    message ?? '',
    navigatorKey: navigatorKey,
    isError: isError,
    borderRadius: Dimensions.paddingSizeSmall,
  ) :
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    elevation: 0,
    shape: OutlineInputBorder(
        borderRadius: BorderRadius.circular(50),
        borderSide: const BorderSide(color: Colors.transparent)
    ),
    content: Align(alignment: Alignment.center,
      child: Material(color: Colors.black.withValues(alpha: 0.8), elevation: 0, borderRadius: BorderRadius.circular(20),
        child: Container(
          constraints: const BoxConstraints(minHeight: 40),
          padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
          child: Row(mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.center, children: [
            CircleAvatar(
              radius: 12, // Adjust radius as needed
              backgroundColor: isError ? Colors.red : Colors.green,
              child: Icon(
                isError ? Icons.close_rounded : Icons.check,
                color: Colors.white,
                size: 16, // Icon size
              ),
            ),
            const SizedBox(width: Dimensions.paddingSizeSmall),

            Flexible(child: Text(
              message ?? '',
              style: rubikBold.copyWith(
                color: Colors.white,
                fontSize: Dimensions.fontSizeDefault,
              ),
            )),

          ]),
        ),
      ),
    ),
    behavior: ResponsiveHelper.isDesktop(Get.context!) ? SnackBarBehavior.floating : SnackBarBehavior.fixed,
    backgroundColor: Colors.transparent,

  ));
}