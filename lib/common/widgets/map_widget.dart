import 'package:hexacom_user/common/enums/footer_type_enum.dart';
import 'package:hexacom_user/common/models/order_model.dart';
import 'package:hexacom_user/helper/responsive_helper.dart';
import 'package:hexacom_user/common/widgets/footer_web_widget.dart';
import 'package:flutter/material.dart';
import 'package:hexacom_user/localization/language_constrants.dart';
import 'package:hexacom_user/utill/color_resources.dart';
import 'package:hexacom_user/utill/dimensions.dart';
import 'package:hexacom_user/utill/styles.dart';
import 'package:hexacom_user/common/widgets/custom_app_bar_widget.dart';

import 'web_app_bar_widget.dart';

class MapWidget extends StatefulWidget {
  final DeliveryAddress? address;
  const MapWidget({super.key, required this.address});

  @override
  State<MapWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height;
    return Scaffold(
      appBar: (ResponsiveHelper.isDesktop(context)? const PreferredSize(preferredSize: Size.fromHeight(90), child: WebAppBarWidget()):  CustomAppBarWidget(title: getTranslated('delivery_address', context))) as PreferredSizeWidget?,
      body: SingleChildScrollView(
        physics: ResponsiveHelper.isDesktop(context) ? const AlwaysScrollableScrollPhysics() : const NeverScrollableScrollPhysics(),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(ResponsiveHelper.isDesktop(context) ? Dimensions.paddingSizeSmall : 0 ),
              child: Center(
                child: Container(
                  padding: EdgeInsets.all(ResponsiveHelper.isDesktop(context) ? Dimensions.paddingSizeSmall : 0 ),
                  decoration: ResponsiveHelper.isDesktop(context) ? BoxDecoration(
                    color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(10),
                    boxShadow: [BoxShadow(color: Theme.of(context).shadowColor, blurRadius: 5, spreadRadius: 1)],
                  ) : null,
                  height: ResponsiveHelper.isDesktop(context) ?   height * 0.7 : height * 0.9,
                  width: Dimensions.webScreenWidth,
                  child: Container(
                    padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: Theme.of(context).cardColor,
                      boxShadow: [BoxShadow(color: Theme.of(context).shadowColor, spreadRadius: 3, blurRadius: 10)],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.location_on_outlined,
                              size: 30,
                              color: Theme.of(context).primaryColor,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (widget.address?.city != null && widget.address!.city!.isNotEmpty)
                                    Text(
                                      widget.address!.city!,
                                      style: rubikRegular.copyWith(
                                        fontSize: Dimensions.fontSizeSmall,
                                        color: ColorResources.getGreyBunkerColor(context),
                                      ),
                                    ),
                                  Text(
                                    widget.address?.address ?? '',
                                    style: rubikMedium,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: Dimensions.paddingSizeLarge),
                        if (widget.address?.contactPersonName != null)
                          Text(
                            '- ${widget.address!.contactPersonName}',
                            style: rubikMedium.copyWith(
                              color: Theme.of(context).primaryColor,
                              fontSize: Dimensions.fontSizeLarge,
                            ),
                          ),
                        if (widget.address?.contactPersonNumber != null)
                          Text(
                            '- ${widget.address!.contactPersonNumber}',
                            style: rubikRegular,
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            if(ResponsiveHelper.isDesktop(context)) const SizedBox(height: Dimensions.paddingSizeLarge),
            const FooterWebWidget(footerType: FooterType.nonSliver),
          ],
        ),
      ),
    );
  }
}
