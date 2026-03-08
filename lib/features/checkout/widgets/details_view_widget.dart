import 'package:hexacom_user/common/models/cart_model.dart';
import 'package:hexacom_user/common/models/config_model.dart';
import 'package:hexacom_user/common/widgets/custom_directionality_widget.dart';
import 'package:hexacom_user/common/widgets/custom_image_widget.dart';
import 'package:hexacom_user/common/widgets/custom_text_field_widget.dart';
import 'package:hexacom_user/utill/images.dart';
import 'package:hexacom_user/features/cart/widgets/cart_item_widget.dart';
import 'package:hexacom_user/features/checkout/providers/checkout_provider.dart';
import 'package:hexacom_user/features/checkout/widgets/payment_info_widget.dart';
import 'package:hexacom_user/features/checkout/widgets/place_order_button_view.dart';
import 'package:hexacom_user/features/order/providers/order_provider.dart';
import 'package:hexacom_user/features/splash/providers/splash_provider.dart';
import 'package:hexacom_user/helper/price_converter_helper.dart';
import 'package:hexacom_user/helper/responsive_helper.dart';
import 'package:hexacom_user/localization/language_constrants.dart';
import 'package:hexacom_user/utill/dimensions.dart';
import 'package:hexacom_user/utill/styles.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


class DetailsViewWidget extends StatelessWidget {
  final bool kmWiseCharge;
  final bool selfPickup;
  final double deliveryCharge;
  final double amount;
  final TextEditingController orderNoteController;
  final List<CartModel?> cartList;
  final String? orderType;
  final ScrollController? scrollController;
  final GlobalKey? dropdownKey;

  const DetailsViewWidget({
    super.key, required this.kmWiseCharge,
    required this.selfPickup,
    required this.deliveryCharge,
    required this.orderNoteController,
    required this.amount, required this.cartList, required this.orderType,
    this.scrollController, this.dropdownKey
  });

  @override
  Widget build(BuildContext context) {
    final configModel = context.watch<SplashProvider>().configModel;
    final branches = configModel?.branches ?? [];
    final branchIndex = context.watch<CheckoutProvider>().branchIndex;
    final selectedBranch = (branches.isNotEmpty && branchIndex >= 0 && branchIndex < branches.length)
        ? branches[branchIndex]
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (selfPickup && selectedBranch != null) ...[
          _PickupStoreInfoCard(
            branch: selectedBranch,
            storePhone: configModel?.ecommercePhone,
            storeLogoUrl: configModel?.baseUrls != null && (configModel?.appLogo ?? '').isNotEmpty
                ? '${configModel!.baseUrls!.ecommerceImageUrl}/${configModel.appLogo}'
                : null,
          ),
          const SizedBox(height: Dimensions.paddingSizeSmall),
        ],
        if (!selfPickup) ...[
          PaymentInfoWidget(totalAmount: amount + deliveryCharge),
          const SizedBox(height: Dimensions.paddingSizeSmall),

          Container(
            margin: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeExtraSmall),
            padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [BoxShadow(color: Theme.of(context).shadowColor.withValues(alpha: 0.10), blurRadius: 18, spreadRadius: 0, offset: const Offset(0, 4))],
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3A4756).withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.note_alt_outlined, color: Color(0xFF3A4756), size: 20),
                ),
                const SizedBox(width: Dimensions.paddingSizeSmall),
                Text(getTranslated('add_delivery_note', context), style: rubikSemiBold.copyWith(fontSize: Dimensions.fontSizeLarge)),
              ]),
              const SizedBox(height: Dimensions.paddingSizeSmall),

              CustomTextFieldWidget(
                fillColor: Theme.of(context).canvasColor,
                isShowBorder: true,
                controller: orderNoteController,
                hintText: getTranslated('type', context),
                maxLines: 5,
                inputType: TextInputType.multiline,
                inputAction: TextInputAction.newline,
                capitalization: TextCapitalization.sentences,
              ),
            ]),
          ),
          const SizedBox(height: Dimensions.paddingSizeSmall),
        ],

        Container(
          margin: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeExtraSmall),
          padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [BoxShadow(color: Theme.of(context).shadowColor.withValues(alpha: 0.10), blurRadius: 18, spreadRadius: 0, offset: const Offset(0, 4))],
          ),
          child: Column(children: [
            Row(children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF3A4756).withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.receipt_long_outlined, color: Color(0xFF3A4756), size: 20),
              ),
              const SizedBox(width: Dimensions.paddingSizeSmall),
              Text(getTranslated('total_amount', context), style: rubikSemiBold.copyWith(fontSize: Dimensions.fontSizeLarge)),
            ]),
            const SizedBox(height: Dimensions.paddingSizeDefault),

            CartItemWidget(
              title: getTranslated('subtotal', context),
              subTitle: PriceConverterHelper.convertPrice(amount),
            ),
            const SizedBox(height: 10),

            if(!selfPickup)...[
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text(
                  getTranslated('delivery_fee', context),
                  style: rubikRegular.copyWith(
                    fontSize: Dimensions.fontSizeDefault,
                    color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.85),
                  ),
                ),
                Selector<OrderProvider, double?>(
                  selector: (context, orderProvider) => orderProvider.deliveryCharge,
                  builder: (context, deliveryCharge, child) {
                    return CustomDirectionalityWidget(
                      child: Text(
                        '(+) ${PriceConverterHelper.convertPrice(deliveryCharge ?? 0.0)}',
                        style: rubikSemiBold.copyWith(fontSize: Dimensions.fontSizeLarge),
                      ),
                    );
                  },
                )
              ]),
            ],

            const Divider(height: 20),

            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: Dimensions.paddingSizeSmall,
                vertical: Dimensions.paddingSizeSmall,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFF3A4756).withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Selector<OrderProvider, double?>(
                selector: (context, orderProvider) => orderProvider.deliveryCharge,
                builder: (context, deliveryCharge, child) {
                  return CartItemWidget(
                    title: getTranslated('total_amount', context),
                    subTitle: PriceConverterHelper.convertPrice(amount + (deliveryCharge ?? 0.0)),
                    style: rubikSemiBold.copyWith(
                      fontSize: Dimensions.fontSizeExtraLarge,
                      color: const Color(0xFF3A4756),
                    ),
                  );
                },
              ),
            ),

            if(ResponsiveHelper.isDesktop(context)) const SizedBox(height: Dimensions.paddingSizeDefault),

            if(ResponsiveHelper.isDesktop(context)) PlaceOrderButtonView(
              amount: amount, deliveryCharge: deliveryCharge,
              orderType: orderType,
              kmWiseCharge: kmWiseCharge,
              cartList: cartList,
              orderNote: orderNoteController.text,
              scrollController: scrollController,
              dropdownKey: dropdownKey,
            ),
          ]),
        ),
        const SizedBox(height: Dimensions.paddingSizeDefault),
      ],
    );
  }
}

class _PickupStoreInfoCard extends StatelessWidget {
  final Branches branch;
  final String? storePhone;
  final String? storeLogoUrl;

  const _PickupStoreInfoCard({
    required this.branch,
    this.storePhone,
    this.storeLogoUrl,
  });

  @override
  Widget build(BuildContext context) {
    final hasAddress = (branch.address ?? '').trim().isNotEmpty;
    final hasPhone = (storePhone ?? '').trim().isNotEmpty;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeExtraSmall),
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withValues(alpha: 0.10),
            blurRadius: 18,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (storeLogoUrl != null && storeLogoUrl!.isNotEmpty) ...[
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CustomImageWidget(
                  image: storeLogoUrl!,
                  placeholder: Images.logo,
                  height: 120,
                  width: 120,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(height: Dimensions.paddingSizeDefault),
          ],
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  getTranslated('pickup_thank_you', context),
                  textAlign: TextAlign.center,
                  style: rubikSemiBold.copyWith(fontSize: Dimensions.fontSizeLarge),
                ),
                const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                Text(
                  getTranslated('pickup_instructions', context),
                  textAlign: TextAlign.center,
                  style: rubikRegular.copyWith(
                    fontSize: Dimensions.fontSizeDefault,
                    color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.85),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: Dimensions.paddingSizeLarge * 2),
          if (hasAddress) _InfoRow(icon: Icons.location_on_outlined, label: getTranslated('address', context), value: branch.address!),
          if (hasPhone) _InfoRow(icon: Icons.phone_outlined, label: getTranslated('phone', context), value: storePhone!),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Theme.of(context).hintColor),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: rubikMedium.copyWith(
                    fontSize: Dimensions.fontSizeSmall,
                    color: Theme.of(context).hintColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: rubikRegular.copyWith(fontSize: Dimensions.fontSizeDefault),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
