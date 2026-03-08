import 'package:hexacom_user/helper/responsive_helper.dart';
import 'package:hexacom_user/localization/language_constrants.dart';
import 'package:hexacom_user/features/product/providers/product_provider.dart';
import 'package:hexacom_user/common/enums/search_short_by_enum.dart';
import 'package:hexacom_user/utill/dimensions.dart';
import 'package:hexacom_user/utill/routes.dart';
import 'package:hexacom_user/utill/styles.dart';
import 'package:hexacom_user/common/widgets/custom_slider_list_widget.dart';
import 'package:hexacom_user/common/widgets/product_card_widget.dart';
import 'package:hexacom_user/utill/color_resources.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class OfferProductWidget extends StatefulWidget {
  const OfferProductWidget({super.key});

  @override
  State<OfferProductWidget> createState() => _OfferProductWidgetState();
}

class _OfferProductWidgetState extends State<OfferProductWidget> {
  ScrollController scrollController = ScrollController();

  @override
  void dispose() {
    // scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductProvider>(
      builder: (context, offerProduct, child) {
        final isDesktop = ResponsiveHelper.isDesktop(context);
        final backgroundColor = ColorResources.getOfferSectionBackground(context);

        return isDesktop ? CustomSliderListWidget(
          controller: scrollController,
          verticalPosition: 125,
          horizontalPosition: 0,
          isShowForwardButton: offerProduct.offerProductList != null && offerProduct.offerProductList!.length > 5,
          child: Container(
            margin: const EdgeInsets.symmetric(
              horizontal: Dimensions.paddingSizeLarge,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(Dimensions.paddingSizeLarge, 18, Dimensions.paddingSizeLarge, 14),
                  child: _OfferHeader(
                    onTap: () => RouteHelper.getSearchResultRoute(
                      context,
                      shortBy: SearchShortBy.offerProducts,
                      action: RouteAction.push,
                    ),
                  ),
                ),
                Consumer<ProductProvider>(
                  builder: (context, offerProduct, child) {
                    return offerProduct.offerProductList == null
                        ? const SizedBox()
                        : offerProduct.offerProductList!.isEmpty
                            ? const SizedBox()
                            : Padding(
                                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                                child: SizedBox(
                                  height: Dimensions.horizontalProductCardHeight,
                                  child: ListView.builder(
                                    physics: const ClampingScrollPhysics(),
                                    controller: scrollController,
                                    itemCount: offerProduct.offerProductList!.length,
                                    scrollDirection: Axis.horizontal,
                                    itemBuilder: (ctx, index) => Padding(
                                      padding: const EdgeInsets.only(right: 8),
                                      child: SizedBox(
                                        width: Dimensions.horizontalProductCardWidth,
                                        height: Dimensions.horizontalProductCardHeight,
                                        child: ProductCardWidget(
                                          product: offerProduct.offerProductList![index],
                                          direction: Axis.horizontal,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                  },
                ),
              ],
            ),
          ),
        ) : Consumer<ProductProvider>(
          builder: (context, offerProduct, child) {
            if (offerProduct.offerProductList == null || offerProduct.offerProductList!.isEmpty) {
              return const SizedBox.shrink();
            }
            return Container(
              color: backgroundColor,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(Dimensions.paddingSizeLarge, 14, Dimensions.paddingSizeLarge, 6),
                    child: Row(
                      children: [
                        const Expanded(child: _OfferMobileTitle()),
                        _SectionViewAllLink(
                          onTap: () => RouteHelper.getSearchResultRoute(
                            context,
                            shortBy: SearchShortBy.offerProducts,
                            action: RouteAction.push,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(Dimensions.mobileContentPaddingHorizontal, 16, Dimensions.mobileContentPaddingHorizontal, 8),
                    child: SizedBox(
                      height: Dimensions.horizontalProductCardHeight,
                      child: ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        itemCount: offerProduct.offerProductList!.length > 5 ? 5 : offerProduct.offerProductList!.length,
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (ctx, index) => Padding(
                          padding: const EdgeInsets.only(right: 14),
                          child: SizedBox(
                            width: Dimensions.horizontalProductCardWidth,
                            height: Dimensions.horizontalProductCardHeight,
                            child: ProductCardWidget(
                              product: offerProduct.offerProductList![index],
                              direction: Axis.horizontal,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      }
    );
  }
}

class _OfferHeader extends StatelessWidget {
  const _OfferHeader({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final isDesktop = ResponsiveHelper.isDesktop(context);

    return Row(
      children: [
        Expanded(
          child: Text(
            getTranslated('offer_product', context),
            style: rubikBold.copyWith(
              color: onSurface,
              fontSize: isDesktop ? 20 : 18,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        _SectionViewAllLink(onTap: onTap),
      ],
    );
  }
}

class _OfferMobileTitle extends StatelessWidget {
  const _OfferMobileTitle();

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Row(
      children: [
        Expanded(
          child: Text(
            getTranslated('offer_product', context),
            style: rubikBold.copyWith(color: onSurface, fontSize: 18),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _SectionViewAllLink extends StatelessWidget {
  const _SectionViewAllLink({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(Dimensions.radiusSizeSmall),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: Dimensions.paddingSizeExtraSmall,
          horizontal: Dimensions.paddingSizeSmall,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              getTranslated('view_all', context),
              style: rubikMedium.copyWith(
                fontSize: Dimensions.fontSizeSmall,
                color: const Color(0xFF3A4756),
              ),
            ),
            const SizedBox(width: Dimensions.paddingSizeExtraSmall),
            const Icon(Icons.arrow_forward_ios, size: 12, color: Color(0xFF3A4756)),
          ],
        ),
      ),
    );
  }
}
