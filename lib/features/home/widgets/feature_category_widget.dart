import 'package:hexacom_user/common/models/category_model.dart';
import 'package:hexacom_user/common/models/feature_category_model.dart';
import 'package:hexacom_user/utill/dimensions.dart';
import 'package:hexacom_user/utill/routes.dart';
import 'package:hexacom_user/utill/styles.dart';
import 'package:hexacom_user/utill/color_resources.dart';
import 'package:hexacom_user/common/widgets/custom_slider_list_widget.dart';
import 'package:hexacom_user/common/widgets/product_card_widget.dart';
import 'package:hexacom_user/helper/responsive_helper.dart';
import 'package:hexacom_user/localization/language_constrants.dart';
import 'package:flutter/material.dart';

class FeatureCategoryWidget extends StatefulWidget {
  final FeaturedCategory? featuredCategory;
  const FeatureCategoryWidget({super.key, required this.featuredCategory});

  @override
  State<FeatureCategoryWidget> createState() => _FeatureCategoryWidgetState();
}

class _FeatureCategoryWidgetState extends State<FeatureCategoryWidget> {
  final ScrollController scrollController = ScrollController();
  bool _scrollControllerDisposed = false;

  void _onViewAllTap() {
    if (widget.featuredCategory?.category == null) return;
    final category = widget.featuredCategory!.category!;
    RouteHelper.getCategoryRoute(
      context,
      CategoryModel(
        id: category.id,
        banner: category.banner,
        name: category.name,
        image: category.image,
      ),
      action: RouteAction.push,
    );
  }

  @override
  void dispose() {
    if (!_scrollControllerDisposed) {
      _scrollControllerDisposed = true;
      scrollController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.featuredCategory == null) return const SizedBox();

    final products = widget.featuredCategory!.products
        ?.where((p) => p.status == true)
        .toList();
    if (products == null || products.isEmpty) return const SizedBox();

    final isDesktop = ResponsiveHelper.isDesktop(context);
    final backgroundColor = ColorResources.getOfferSectionBackground(context);
    final title = widget.featuredCategory?.category?.name ?? '';

    return isDesktop
        ? CustomSliderListWidget(
            controller: scrollController,
            verticalPosition: 125,
            horizontalPosition: 0,
            isShowForwardButton: products.length > 3,
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
                    padding: const EdgeInsets.fromLTRB(
                      Dimensions.paddingSizeLarge,
                      18,
                      Dimensions.paddingSizeLarge,
                      14,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: rubikBold.copyWith(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontSize: 20,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        _ViewAllLink(onTap: _onViewAllTap),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: SizedBox(
                      height: Dimensions.horizontalProductCardHeight,
                      child: ListView.builder(
                        physics: const ClampingScrollPhysics(),
                        controller: scrollController,
                        scrollDirection: Axis.horizontal,
                        itemCount: products.length,
                        itemBuilder: (ctx, index) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: SizedBox(
                            width: Dimensions.horizontalProductCardWidth,
                            height: Dimensions.horizontalProductCardHeight,
                            child: ProductCardWidget(
                              product: products[index],
                              direction: Axis.horizontal,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        : Container(
            color: backgroundColor,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    Dimensions.paddingSizeLarge,
                    14,
                    Dimensions.paddingSizeLarge,
                    6,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: rubikBold.copyWith(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontSize: 18,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      _ViewAllLink(onTap: _onViewAllTap),
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
                  child: SizedBox(
                    height: Dimensions.horizontalProductCardHeight,
                    child: ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      scrollDirection: Axis.horizontal,
                      itemCount: products.length > 5 ? 5 : products.length,
                      itemBuilder: (ctx, index) => Padding(
                        padding: const EdgeInsets.only(right: 14),
                        child: SizedBox(
                          width: Dimensions.horizontalProductCardWidth,
                          height: Dimensions.horizontalProductCardHeight,
                          child: ProductCardWidget(
                            product: products[index],
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
  }
}

class _ViewAllLink extends StatelessWidget {
  const _ViewAllLink({required this.onTap});

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
