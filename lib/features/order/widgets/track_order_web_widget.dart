import 'package:flutter/material.dart';
import 'package:hexacom_user/common/widgets/custom_directionality_widget.dart';
import 'package:hexacom_user/features/order/providers/order_provider.dart';
import 'package:hexacom_user/features/splash/providers/splash_provider.dart';
import 'package:hexacom_user/features/order/widgets/custom_stepper_widget.dart';
import 'package:hexacom_user/helper/date_converter_helper.dart';
import 'package:hexacom_user/helper/order_helper.dart';
import 'package:hexacom_user/helper/price_converter_helper.dart';
import 'package:hexacom_user/localization/language_constrants.dart';
import 'package:hexacom_user/utill/dimensions.dart';
import 'package:hexacom_user/utill/images.dart';
import 'package:hexacom_user/utill/order_constants.dart';
import 'package:hexacom_user/utill/routes.dart';
import 'package:hexacom_user/utill/styles.dart';
import 'package:provider/provider.dart';

class TrackOrderWebWidget extends StatelessWidget {
  const TrackOrderWebWidget({super.key, required this.phoneNumber,});
  final String? phoneNumber;

  @override
  Widget build(BuildContext context) {
    final SplashProvider splashProvider = Provider.of<SplashProvider>(context, listen: false);
    final viewportWidth = MediaQuery.sizeOf(context).width;

    return Consumer<OrderProvider>(
        builder: (context, orderProvider, _) {
          String status = orderProvider.trackModel?.orderStatus ?? '';
          bool isOrderFailed = status == OrderConstants.failed || status == OrderConstants.returned || status == OrderConstants.canceled;

          return orderProvider.trackModel != null && orderProvider.trackModel?.id != null
              ? Center(
                  child: SizedBox(
                    width: Dimensions.getWebContentWidth(viewportWidth),
                    child: Column(children: [
                      const SizedBox(height: Dimensions.paddingSizeExtraLarge),

            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Expanded(child: Text(
                '${getTranslated('order_id', context)} #${orderProvider.trackModel!.id}',
                style: rubikMedium.copyWith(fontSize: Dimensions.fontSizeLarge),
              )),

              CustomDirectionalityWidget(child: Text(
                PriceConverterHelper.convertPrice(orderProvider.trackModel!.orderAmount),
                style: rubikBold.copyWith(color: const Color(0xFF3A4756), fontSize: Dimensions.fontSizeLarge),
              )),
            ]),
            const Divider(height: Dimensions.paddingSizeExtraLarge),

            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Row(children: [
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF3A4756).withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(Dimensions.radiusSizeDefault),
                  ),
                  padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                  child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Image.asset(Images.wareHouse, color: const Color(0xFF3A4756), width: Dimensions.paddingSizeLarge),
                    const SizedBox(width: 20),

                    if(orderProvider.trackModel?.branchId != null) Text(
                      '${OrderHelper.getBranch(id: orderProvider.trackModel!.branchId!, branchList: splashProvider.configModel?.branches ?? [])?.address}',
                      style: rubikRegular.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).textTheme.bodyLarge?.color),
                    ),
                  ]),
                ),

                if(OrderHelper.isShowDeliveryAddress(orderProvider.trackModel)) Padding(
                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                  child: CustomPaint(
                    size: const Size(50, 2),
                    painter: DashedLineVerticalPainter(isActive: false, axis: Axis.horizontal),
                  ),
                ),

                if(OrderHelper.isShowDeliveryAddress(orderProvider.trackModel)) Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF3A4756).withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(Dimensions.radiusSizeDefault),
                  ),
                  padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                  child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Icon(Icons.location_on, color: const Color(0xFF3A4756)),
                    const SizedBox(width: 20),

                    ConstrainedBox(constraints: const BoxConstraints(maxWidth: 400), child: Text(
                         orderProvider.trackModel?.orderType == 'take_away'
                             ? getTranslated('take_away', context)
                             :  orderProvider.trackModel!.deliveryAddress != null
                             ? orderProvider.trackModel!.deliveryAddress!.address!
                             : getTranslated('address_was_deleted', context),
                        overflow: TextOverflow.ellipsis, maxLines: 1,
                        style: rubikRegular.copyWith(
                          fontSize: Dimensions.fontSizeLarge,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      )),
                  ]),
                ),
              ]),

              if(phoneNumber != null) InkWell(
                onTap: () {
                  RouteHelper.getOrderDetailsRoute(context, orderProvider.trackModel!.id, orderProvider.trackModel, isFromTrackOrderPage: true, userPhoneNumber: phoneNumber);
                },
                child: Container(
                  width: 120, height: 40,
                  padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(Dimensions.radiusSizeDefault),
                    border: Border.all(color: const Color(0xFF3A4756).withValues(alpha: 0.5), width: 2),
                  ),
                  child: Text(getTranslated('view_details', context), style: rubikBold.copyWith(color: const Color(0xFF3A4756))),
                ),
              ),

            ]),
            const SizedBox(height: 50),

            Builder(builder: (context) {
              final steps = <Widget>[
                CustomStepperWidget(
                title: getTranslated('order_placed', context),
                isComplete: true,
                isActive: status == OrderConstants.pending,
                statusImage: Images.orderPlace,
                subTitleWidget: Row(children: [
                  const Icon(Icons.schedule, size: Dimensions.fontSizeLarge),
                  const SizedBox(width: Dimensions.paddingSizeSmall),

                  Text(DateConverterHelper.localDateToISOAMPMString(DateConverterHelper.convertStringToDatetime(orderProvider.trackModel!.createdAt!)),
                    style: rubikRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor),
                  ),
                ]),
              ),
              ];

              if (isOrderFailed) {
                steps.add(CustomStepperWidget(
                height: orderProvider.trackModel?.deliveryMan == null ? 30 : 130,
                title: getTranslated(status, context),
                isComplete: isOrderFailed,
                isActive: isOrderFailed,
                statusImage: Images.orderFailed,
                color: status == OrderConstants.failed ? Theme.of(context).colorScheme.error : null,
                ));
              }

              steps.add(CustomStepperWidget(
                title: getTranslated('order_accepted', context),
                isComplete: status == OrderConstants.confirmed
                    || status == OrderConstants.processing
                    || status == OrderConstants.outForDelivery
                    || status == OrderConstants.delivered,
                isActive: status == OrderConstants.confirmed,
                statusImage: Images.orderAccepted,
              ));

              steps.add(CustomStepperWidget(
                title: getTranslated('preparing_items', context),
                isComplete: status == OrderConstants.processing
                    || status == OrderConstants.outForDelivery
                    ||status == OrderConstants.delivered,
                statusImage: Images.preparingItems,
                isActive: status == OrderConstants.processing,
              ));

              if (!isOrderFailed) {
                steps.add(CustomStepperWidget(
                title: getTranslated('order_is_on_the_way', context),
                isComplete: status == OrderConstants.outForDelivery || status == OrderConstants.delivered,
                statusImage: Images.outForDelivery,
                isActive: status == OrderConstants.outForDelivery,
                subTitleWidget: status == OrderConstants.outForDelivery ?  Text(
                  getTranslated('your_delivery_man_is_coming', context),
                  style: rubikRegular.copyWith(color: Theme.of(context).disabledColor, fontSize: Dimensions.fontSizeSmall),
                ) : const SizedBox(),
                ));
              }

              steps.add(CustomStepperWidget(
                height: orderProvider.trackModel?.deliveryMan == null ? 30 : 130,
                title: getTranslated('order_delivered', context),
                isComplete: status == OrderConstants.delivered,
                isActive: status == OrderConstants.delivered,
                statusImage: Images.orderDelivered,
                haveTopBar: false,
              ));

              return LayoutBuilder(
                builder: (context, constraints) {
                  // Prevent RenderFlex overflow on smaller desktop widths by allowing horizontal scroll.
                  final row = Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: steps,
                  );

                  return constraints.maxWidth < 1100
                      ? Scrollbar(
                          thumbVisibility: false,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 6),
                              child: row,
                            ),
                          ),
                        )
                      : row;
                },
              );
            }),
            const SizedBox(height: 100),

                    ]),
                  ),
                )
              : const SizedBox();
        }
    );
  }
}
