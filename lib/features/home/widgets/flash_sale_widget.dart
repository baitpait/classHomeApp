import 'package:hexacom_user/features/flash_sale/widgets/flash_sale_timer_widget.dart';
import 'package:hexacom_user/helper/responsive_helper.dart';
import 'package:hexacom_user/localization/language_constrants.dart';
import 'package:hexacom_user/features/flash_sale/providers/flash_sale_provider.dart';
import 'package:hexacom_user/provider/localization_provider.dart';
import 'package:hexacom_user/utill/dimensions.dart';
import 'package:hexacom_user/utill/routes.dart';
import 'package:hexacom_user/utill/styles.dart';
import 'package:hexacom_user/common/widgets/product_card_widget.dart';
import 'package:hexacom_user/utill/color_resources.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Flash Sale: header (title + timer + CTA), compact banner, horizontal products.
class FlashSaleWidget extends StatelessWidget {
  const FlashSaleWidget({super.key});


  @override
  Widget build(BuildContext context) {
    final localizationProvider = Provider.of<LocalizationProvider>(context, listen: false);
    final isLtr = localizationProvider.isLtr;
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
    final primary = Theme.of(context).primaryColor;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final backgroundColor = ColorResources.getFlashSaleSectionBackground(context);

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: Dimensions.paddingSizeLarge,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(Dimensions.paddingSizeLarge, 18, Dimensions.paddingSizeLarge, 14),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.flash_on_rounded, color: primary, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  getTranslated('flash_sale', context),
                  style: rubikBold.copyWith(color: onSurface, fontSize: 20),
                ),
                const SizedBox(width: 20),
                const Expanded(child: FlashSaleTimerWidget()),
                _ViewAllButton(
                  onTap: () => RouteHelper.getFlashSaleDetailsRoute(context, action: RouteAction.push),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: SizedBox(
              height: Dimensions.horizontalProductCardHeight,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: flashProvider.flashSaleModel!.products!.length,
                itemBuilder: (ctx, index) {
                  return Padding(
                    padding: EdgeInsets.only(
                      left: index == 0 && isLtr ? 0 : 8,
                      right: index == 0 && !isLtr ? 0 : 8,
                    ),
                    child: SizedBox(
                      width: Dimensions.horizontalProductCardWidth,
                      height: Dimensions.horizontalProductCardHeight,
                      child: ProductCardWidget(
                        product: flashProvider.flashSaleModel!.products![index],
                        direction: Axis.horizontal,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobile(BuildContext context, FlashSaleProvider flashProvider) {
    final primary = Theme.of(context).primaryColor;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final backgroundColor = ColorResources.getFlashSaleSectionBackground(context);

    return Container(
      color: backgroundColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(Dimensions.paddingSizeLarge, 14, Dimensions.paddingSizeLarge, 6),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.flash_on_rounded, color: primary, size: 18),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    getTranslated('flash_sale', context),
                    style: rubikBold.copyWith(color: onSurface, fontSize: 16),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Flexible(child: FlashSaleTimerWidget()),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              Dimensions.mobileContentPaddingHorizontal,
              16,
              Dimensions.mobileContentPaddingHorizontal,
              8,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  height: Dimensions.horizontalProductCardHeight,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.zero,
                    itemCount: flashProvider.flashSaleModel?.products?.length ?? 0,
                    itemBuilder: (ctx, index) {
                      final products = flashProvider.flashSaleModel!.products!;
                      return Padding(
                        padding: const EdgeInsets.only(right: 14),
                        child: SizedBox(
                          width: Dimensions.horizontalProductCardWidth,
                          height: Dimensions.horizontalProductCardHeight,
                          child: ProductCardWidget(
                            product: products[index],
                            direction: Axis.horizontal,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: _ViewAllButton(
                    onTap: () => RouteHelper.getFlashSaleDetailsRoute(context, action: RouteAction.push),
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

class _ViewAllButton extends StatelessWidget {
  const _ViewAllButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(0, 36),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        side: BorderSide(color: Theme.of(context).primaryColor.withValues(alpha: 0.8)),
        foregroundColor: Theme.of(context).primaryColor,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(getTranslated('view_all', context), style: rubikMedium.copyWith(fontSize: 12)),
          const SizedBox(width: 6),
          Icon(Icons.arrow_forward_ios, size: 10, color: Theme.of(context).primaryColor),
        ],
      ),
    );
  }
}
