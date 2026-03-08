import 'package:hexacom_user/helper/responsive_helper.dart';
import 'package:hexacom_user/localization/language_constrants.dart';
import 'package:hexacom_user/main.dart';
import 'package:hexacom_user/utill/dimensions.dart';
import 'package:hexacom_user/utill/styles.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class LocationPermissionDialogWidget extends StatelessWidget {
  static const _slate = Color(0xFF3A4756);

  const LocationPermissionDialogWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
        child: SizedBox(
          width: 300,
          child: Column(mainAxisSize: MainAxisSize.min, children: [

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _slate.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.add_location_alt_rounded, color: _slate, size: 60),
            ),
            const SizedBox(height: Dimensions.paddingSizeLarge),

            Text(
              getTranslated('you_denied_location_permission', context), textAlign: TextAlign.justify,
              style: rubikMedium.copyWith(fontSize: Dimensions.fontSizeLarge),
            ),
            const SizedBox(height: Dimensions.paddingSizeLarge),

            Row(children: [
              Expanded(
                child: TextButton(
                  style: TextButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: const BorderSide(width: 1.5, color: _slate)),
                    minimumSize: const Size(1, 50),
                  ),
                  child: Text(getTranslated('no', context), style: const TextStyle(color: _slate)),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              const SizedBox(width: Dimensions.paddingSizeSmall),

              Expanded(child: TextButton(

                  style: TextButton.styleFrom(
                    backgroundColor: _slate,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    minimumSize: const Size(1, 50),
                  ),
                  child: Text(getTranslated('yes', context), style: TextStyle(color: Theme.of(context).cardColor)),
                  onPressed: () async {
                    if(ResponsiveHelper.isMobilePhone()) {
                      await Geolocator.openAppSettings();
                    }
                    Navigator.pop(Get.context!);
                  }
              )),
            ]),

          ]),
        ),
      ),
    );
  }
}
