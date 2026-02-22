import 'package:hexacom_user/features/flash_sale/widgets/flash_sale_timer_widget.dart';
import 'package:hexacom_user/helper/responsive_helper.dart';
import 'package:hexacom_user/localization/language_constrants.dart';
import 'package:hexacom_user/features/flash_sale/providers/flash_sale_provider.dart';
import 'package:hexacom_user/provider/localization_provider.dart';
import 'package:hexacom_user/utill/dimensions.dart';
import 'package:hexacom_user/utill/images.dart';
import 'package:hexacom_user/utill/routes.dart';
import 'package:hexacom_user/common/widgets/product_card_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Flash Sale section: one card with banner + products + View all.
/// Red background (no border) to grab attention.
class FlashSaleWidget extends StatelessWidget {
  const FlashSaleWidget({super.key});

  static const Color _cardBackgroundRed = Color(0xFFE53935);

  static const double _bannerWidthDesktop = 320;
  static const double _bannerHeightDesktop = 220;
  static const double _bannerHeightMobile = 180;
  static const double _productRowHeight = 180;

  @override
  Widget build(BuildContext context) {
    final bool isLtr = Provider.of<LocalizationProvider>(context, listen: false).isLtr;
    return Consumer<FlashSaleProvider>(
      builder: (context, flashProvider, _) {
        final hasProducts = flashProvider.flashSaleModel?.products != null &&
            flashProvider.flashSaleModel!.products!.isNotEmpty;
        if (!hasProducts) return const SizedBox.shrink();

        return ResponsiveHelper.isDesktop(context)
            ? _buildDesktop(context, flashProvider, isLtr)
            : _buildMobile(context, flashProvider);
      },
    );
  }

  Widget _buildDesktop(
    BuildContext context,
    FlashSaleProvider flashProvider,
    bool isLtr,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeLarge),
      decoration: BoxDecoration(
        color: _cardBackgroundRed,
        borderRadius: BorderRadius.circular(Dimensions.radiusSizeLarge),
      ),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _FlashBanner(
              width: _bannerWidthDesktop,
              height: _bannerHeightDesktop,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(Dimensions.radiusSizeLarge - 1),
                bottomLeft: Radius.circular(Dimensions.radiusSizeLarge - 1),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  Dimensions.paddingSizeLarge,
                  Dimensions.paddingSizeDefault,
                  Dimensions.paddingSizeDefault,
                  Dimensions.paddingSizeDefault,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const SizedBox.shrink(),
                        _ViewAllButton(
                          onTap: () => RouteHelper.getFlashSaleDetailsRoute(
                            context,
                            action: RouteAction.push,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: Dimensions.paddingSizeSmall),
                    SizedBox(
                      height: _productRowHeight,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        itemCount: flashProvider.flashSaleModel!.products!.length,
                        itemBuilder: (ctx, index) {
                          return Padding(
                            padding: EdgeInsets.only(
                              left: index == 0 && isLtr
                                  ? 0
                                  : Dimensions.paddingSizeSmall / 2,
                              right: index == 0 && !isLtr
                                  ? 0
                                  : Dimensions.paddingSizeSmall / 2,
                            ),
                            child: SizedBox(
                              width: 320,
                              height: _productRowHeight,
                              child: ProductCardWidget(
                                product: flashProvider
                                    .flashSaleModel!.products![index],
                                direction: Axis.horizontal,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobile(BuildContext context, FlashSaleProvider flashProvider) {
    return Container(
      margin: const EdgeInsets.only(
        top: Dimensions.paddingSizeDefault,
        bottom: Dimensions.paddingSizeLarge,
      ),
      decoration: BoxDecoration(
        color: _cardBackgroundRed,
        borderRadius: BorderRadius.circular(Dimensions.radiusSizeLarge),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _FlashBanner(
            width: double.infinity,
            height: _bannerHeightMobile,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(Dimensions.radiusSizeLarge - 1),
              topRight: Radius.circular(Dimensions.radiusSizeLarge - 1),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              Dimensions.paddingSizeDefault,
              Dimensions.paddingSizeSmall,
              Dimensions.paddingSizeDefault,
              Dimensions.paddingSizeDefault,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  height: _productRowHeight,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.only(left: Dimensions.paddingSizeDefault),
                    itemCount: flashProvider.flashSaleModel?.products?.length ?? 0,
                    itemBuilder: (ctx, index) {
                      final products = flashProvider.flashSaleModel!.products!;
                      return Padding(
                        padding: const EdgeInsets.only(right: Dimensions.paddingSizeSmall),
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width * 0.72,
                          height: _productRowHeight,
                          child: ProductCardWidget(
                            product: products[index],
                            direction: Axis.horizontal,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: Dimensions.paddingSizeDefault),
                Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: _ViewAllButton(
                    onTap: () => RouteHelper.getFlashSaleDetailsRoute(
                      context,
                      action: RouteAction.push,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Banner area: yellow gradient + flash sale image + timer.
class _FlashBanner extends StatelessWidget {
  const _FlashBanner({
    required this.width,
    required this.height,
    required this.borderRadius,
  });

  final double width;
  final double height;
  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFFFF176),
            const Color(0xFFF9A825),
          ],
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: borderRadius,
            child: Image.asset(
              Images.flashSale,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Padding(
              padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
              child: const SafeArea(
                top: false,
                child: FlashSaleTimerWidget(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Clear "View all" button: outlined style, primary color, arrow.
class _ViewAllButton extends StatelessWidget {
  const _ViewAllButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: onTap,
      style: FilledButton.styleFrom(
        minimumSize: const Size(0, 40),
        padding: const EdgeInsets.symmetric(
          horizontal: Dimensions.paddingSizeLarge,
          vertical: Dimensions.paddingSizeSmall,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Dimensions.radiusSizeDefault),
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFFE53935),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(getTranslated('view_all', context)),
          const SizedBox(width: Dimensions.paddingSizeExtraSmall),
          const Icon(Icons.arrow_forward_ios, size: 12),
        ],
      ),
    );
  }
}
