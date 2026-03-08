import 'package:flutter/material.dart';
import 'package:hexacom_user/common/enums/footer_type_enum.dart';
import 'package:hexacom_user/common/models/order_model.dart';
import 'package:hexacom_user/common/widgets/custom_web_title_widget.dart';
import 'package:hexacom_user/common/widgets/custom_directionality_widget.dart';
import 'package:hexacom_user/common/widgets/custom_loader_widget.dart';
import 'package:hexacom_user/common/widgets/custom_pop_scope_widget.dart';
import 'package:hexacom_user/common/widgets/footer_web_widget.dart';
import 'package:hexacom_user/common/widgets/no_data_screen.dart';
import 'package:hexacom_user/common/widgets/web_app_bar_widget.dart';
import 'package:hexacom_user/features/address/providers/location_provider.dart';
import 'package:hexacom_user/features/order/providers/order_provider.dart';
import 'package:hexacom_user/features/order/widgets/track_order_shimmer_widget.dart';
import 'package:hexacom_user/features/order/widgets/track_order_web_widget.dart';
import 'package:hexacom_user/features/splash/providers/splash_provider.dart';
import 'package:hexacom_user/features/order/widgets/custom_stepper_widget.dart';
import 'package:hexacom_user/features/order/widgets/delivery_man_widget.dart';
import 'package:hexacom_user/helper/date_converter_helper.dart';
import 'package:hexacom_user/helper/order_helper.dart';
import 'package:hexacom_user/helper/price_converter_helper.dart';
import 'package:hexacom_user/helper/responsive_helper.dart';
import 'package:hexacom_user/localization/language_constrants.dart';
import 'package:hexacom_user/utill/dimensions.dart';
import 'package:hexacom_user/utill/images.dart';
import 'package:hexacom_user/utill/order_constants.dart';
import 'package:hexacom_user/utill/routes.dart';
import 'package:hexacom_user/utill/styles.dart';
import 'package:provider/provider.dart';

import 'package:url_launcher/url_launcher_string.dart';

class TrackOrderScreen extends StatefulWidget {
  final String? orderID;
  final bool isBackButton;
  final OrderModel? orderModel;
  final String? phone;
  const TrackOrderScreen({super.key,  required this.orderID, this.isBackButton = false, this.orderModel, this.phone});

  @override
  State<TrackOrderScreen> createState() => _TrackOrderScreenState();
}

class _TrackOrderScreenState extends State<TrackOrderScreen> {

  @override
  void initState() {
    final OrderProvider orderProvider = Provider.of<OrderProvider>(context, listen: false);
    Provider.of<LocationProvider>(context, listen: false).initAddressList();

    orderProvider.trackOrder(widget.orderID, widget.orderModel,  context, true, isUpdate: false, phoneNumber: widget.phone ).whenComplete((){
      if(orderProvider.trackModel?.deliveryMan != null){
        orderProvider.getDeliveryManData(widget.orderID);
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.sizeOf(context).width;
    final bool isDesktop = ResponsiveHelper.isDesktop(context);

    return CustomPopScopeWidget(
      onPopInvoked: (){
        if(!Navigator.canPop(context)){
          RouteHelper.getMainRoute(context, action: RouteAction.push);
        }else{
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        appBar: isDesktop
            ? const PreferredSize(
                preferredSize: Size.fromHeight(120),
                child: WebAppBarWidget(),
              )
            : null,
        body: Column(children: [
          Expanded(child: CustomScrollView(slivers: [
            SliverToBoxAdapter(child: Center(child: Consumer<OrderProvider>(
              builder: (context, orderProvider, child) {
                String? status;
                bool isOrderFailed = status == OrderConstants.failed || status == OrderConstants.returned || status == OrderConstants.canceled;

                if (orderProvider.trackModel != null) {
                  status = orderProvider.trackModel!.orderStatus;
                }

                return orderProvider.isLoading ? const TrackOrderShimmerWidget() : orderProvider.trackModel != null ? orderProvider.trackModel?.id == null ? NoDataScreen(
                  title: getTranslated('order_not_found', context),
                )  :  Container(
                  margin: EdgeInsets.symmetric(
                    horizontal: isDesktop
                        ? (width - Dimensions.getWebContentWidth(width)) / 2
                        : 0,
                  ),
                  decoration: isDesktop
                      ? BoxDecoration(
                          color: Theme.of(context).canvasColor,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: Theme.of(context).shadowColor.withValues(alpha: 0.10),
                              blurRadius: 18,
                              spreadRadius: 0,
                              offset: const Offset(0, 4),
                            )
                          ],
                        )
                      : null,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (!isDesktop)
                        SizedBox(
                          height: MediaQuery.paddingOf(context).top + Dimensions.paddingSizeSmall,
                        ),
                      CustomWebTitleWidget(title: getTranslated(" ", context)),
                      Container(
                        margin: const EdgeInsets.only(
                          left: Dimensions.paddingSizeSmall,
                          right: Dimensions.paddingSizeSmall,
                          bottom: Dimensions.paddingSizeLarge,
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge, vertical: Dimensions.paddingSizeDefault),
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), color: const Color(0xFF3A4756)),
                        child: Row(
                          children: [
                            if (!isDesktop) ...[
                              IconButton(
                                onPressed: () {
                                  RouteHelper.getMainRoute(context, action: RouteAction.push);
                                },
                                icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: Colors.white),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                              ),
                              const SizedBox(width: 4),
                            ],
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), shape: BoxShape.circle),
                              child: const Icon(Icons.receipt_long_rounded, color: Colors.white, size: 22),
                            ),
                            const SizedBox(width: Dimensions.paddingSizeDefault),
                            Expanded(
                              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Text('${getTranslated('order_id', context)} #${orderProvider.trackModel!.id}', style: rubikSemiBold.copyWith(fontSize: Dimensions.fontSizeLarge, color: Colors.white)),
                                const SizedBox(height: 2),
                                Text(getTranslated('track_order', context), style: rubikRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Colors.white.withValues(alpha: 0.7))),
                              ]),
                            ),
                            CustomDirectionalityWidget(
                              child: Text(
                                PriceConverterHelper.convertPrice(orderProvider.trackModel!.orderAmount),
                                style: rubikBold.copyWith(color: Colors.white, fontSize: Dimensions.fontSizeExtraLarge),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isDesktop)
                        const Padding(
                          padding: EdgeInsets.all(Dimensions.paddingSizeDefault),
                          child: TrackOrderWebWidget(phoneNumber: null),
                        )
                      else
                        Column(children: [
                    Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: Dimensions.paddingSizeSmall,
                        vertical: Dimensions.paddingSizeSmall,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        color: Theme.of(context).cardColor,
                        boxShadow: [BoxShadow(color: Theme.of(context).shadowColor.withValues(alpha: 0.10), blurRadius: 18, spreadRadius: 0, offset: const Offset(0, 4))],
                      ),
                      child: Column(children: [
                        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                          Expanded(child: Text(
                            '${getTranslated('order_id', context)} #${orderProvider.trackModel!.id}',
                            style: rubikRegular.copyWith(fontSize: Dimensions.fontSizeLarge),
                          )),

                          CustomDirectionalityWidget(child: Text(
                            PriceConverterHelper.convertPrice(orderProvider.trackModel!.orderAmount),
                            style: rubikBold.copyWith(color: const Color(0xFF3A4756), fontSize: Dimensions.fontSizeLarge),
                          )),
                        ]),

                        const Divider(height: Dimensions.paddingSizeDefault),

                        if(orderProvider.orderType != OrderConstants.selfPickUp)  Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Image.asset(Images.wareHouse, color: Theme.of(context).primaryColor, width: Dimensions.paddingSizeLarge),
                              const SizedBox(width: 20),

                              if(orderProvider.trackModel?.branchId != null) Expanded(child: Text(
                                '${OrderHelper.getBranch(id: orderProvider.trackModel!.branchId!, branchList: context.read<SplashProvider>().configModel?.branches ?? [])?.address}',
                                style: rubikRegular.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).textTheme.bodyLarge?.color),
                              )),
                            ]),

                            Container(
                              padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraSmall),
                              margin: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                              height: Dimensions.paddingSizeExtraLarge,
                              child: CustomPaint(
                                size: const Size(1, double.infinity),
                                painter: DashedLineVerticalPainter(isActive: false),
                              ),
                            ),

                            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Icon(Icons.location_on, color: Theme.of(context).primaryColor),
                              const SizedBox(width: 20),
                              Expanded(
                                child: Text(
                                  orderProvider.trackModel!.deliveryAddress != null? orderProvider.trackModel!.deliveryAddress!.address! : getTranslated('address_was_deleted', context),
                                  style: rubikRegular.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).textTheme.bodyLarge?.color),
                                ),
                              ),
                            ]),
                          ],
                        ),

                        const SizedBox(height: Dimensions.paddingSizeDefault),

                        if(orderProvider.trackModel!.deliveryMan != null) DeliveryManWidget(deliveryMan: orderProvider.trackModel!.deliveryMan),




                      ]),
                    ),

                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: Dimensions.paddingSizeSmall,
                      ),
                      child: Column(children: [
                      CustomStepperWidget(
                        title: getTranslated('order_placed', context),
                        isComplete: true,
                        isActive: status == OrderConstants.pending,
                        haveTopBar: false,
                        statusImage: Images.orderPlace,
                        subTitleWidget: Row(children: [
                          const Icon(Icons.schedule, size: Dimensions.fontSizeLarge),
                          const SizedBox(width: Dimensions.paddingSizeSmall),

                          Text(DateConverterHelper.localDateToISOAMPMString(DateConverterHelper.convertStringToDatetime(orderProvider.trackModel!.createdAt!))),
                        ]),
                      ),

                      if(isOrderFailed) CustomStepperWidget(
                        height: orderProvider.trackModel?.deliveryMan == null ? 30 : 130,
                        title: getTranslated(status, context),
                        isComplete: isOrderFailed,
                        isActive: isOrderFailed,
                        statusImage: Images.orderFailed,
                      ),

                      CustomStepperWidget(
                        title: getTranslated('order_accepted', context),
                        isComplete: status == OrderConstants.confirmed
                            || status == OrderConstants.processing
                            || status == OrderConstants.outForDelivery
                            || status == OrderConstants.delivered,
                        isActive: status == OrderConstants.confirmed,
                        statusImage: Images.orderAccepted,
                      ),

                      CustomStepperWidget(
                        title: getTranslated('preparing_product', context),
                        isComplete: status == OrderConstants.processing
                            || status == OrderConstants.outForDelivery
                            ||status == OrderConstants.delivered,
                        statusImage: Images.preparingItems,
                        isActive: status == OrderConstants.processing,
                      ),

                      if(!(orderProvider.trackModel?.orderType == 'self_pickup'))
                        Consumer<LocationProvider>(builder: (context, locationProvider, _) {
                        return CustomStepperWidget(
                          title: getTranslated('order_is_on_the_way', context),
                          isComplete: status == OrderConstants.outForDelivery || status == OrderConstants.delivered,
                          statusImage: Images.outForDelivery,
                          isActive: status == OrderConstants.outForDelivery,
                          subTitle: getTranslated('your_delivery_man_is_coming', context),
                          trailing: orderProvider.trackModel?.deliveryMan?.phone != null ? InkWell(
                            onTap: ()=> launchUrlString('tel:${orderProvider.trackModel?.deliveryMan?.phone}'),
                            child: const Icon(Icons.phone_in_talk),
                          ) : const SizedBox(),
                        );
                      }),


                      CustomStepperWidget(
                        height: 30,
                        title: getTranslated('order_delivered', context),
                        isComplete: status == OrderConstants.delivered,
                        isActive: status == OrderConstants.delivered,
                        statusImage: Images.orderDelivered,
                        child: const SizedBox(),
                      ),
                      ]),
                    ),

                  ]),
                    ],
                  )
                ) : Center(child: CustomLoaderWidget(color: Theme.of(context).primaryColor));
              },
            ))),

            const FooterWebWidget(footerType: FooterType.sliver),
          ])),

        ]),
      ),
    );
  }
}

