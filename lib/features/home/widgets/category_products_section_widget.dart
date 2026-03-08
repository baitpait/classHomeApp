import 'package:hexacom_user/features/category/providers/category_provider.dart';
import 'package:hexacom_user/features/product/providers/product_provider.dart';
import 'package:hexacom_user/common/models/category_model.dart';
import 'package:hexacom_user/common/models/product_model.dart';
import 'package:hexacom_user/common/widgets/product_card_widget.dart';
import 'package:hexacom_user/helper/responsive_helper.dart';
import 'package:hexacom_user/localization/language_constrants.dart';
import 'package:hexacom_user/utill/color_resources.dart';
import 'package:hexacom_user/utill/dimensions.dart';
import 'package:hexacom_user/utill/routes.dart';
import 'package:hexacom_user/utill/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';

/// Home: grouped product sections by category, replacing the old "All products" grid.
class CategoryProductsSectionWidget extends StatelessWidget {
  const CategoryProductsSectionWidget({super.key});

  static const int _maxProductsPerCategory = 10;

  @override
  Widget build(BuildContext context) {
    return Consumer2<CategoryProvider, ProductProvider>(
      builder: (context, categoryProvider, productProvider, _) {
        final categories = categoryProvider.categoryList;
        final products = productProvider.allLatestProducts ?? productProvider.latestProductModel?.products;

        if (categories == null || categories.isEmpty || products == null || products.isEmpty) {
          return const SizedBox();
        }

        // Group latest products by their first category id, capped to [_maxProductsPerCategory] per group.
        final Map<int, List<Product>> byCategory = {};
        for (final product in products) {
          final catIds = product.categoryIds;
          if (catIds == null || catIds.isEmpty) continue;
          final rawId = catIds.first.id;
          final int? categoryId = rawId == null ? null : int.tryParse(rawId.toString());
          if (categoryId == null) continue;

          final list = byCategory.putIfAbsent(categoryId, () => <Product>[]);
          if (list.length < _maxProductsPerCategory) {
            list.add(product);
          }
        }

        if (byCategory.isEmpty) {
          return const SizedBox();
        }

        final isDesktop = ResponsiveHelper.isDesktop(context);
        final isTab = ResponsiveHelper.isTab(context);

        final List<Widget> children = [];
        final sectionBg = ColorResources.getOfferSectionBackground(context);

        byCategory.forEach((categoryId, items) {
          final CategoryModel? category = categories.firstWhere(
            (c) => c.id == categoryId,
            orElse: () => CategoryModel(id: categoryId, name: 'Category $categoryId'),
          );

          children.add(
            Container(
              margin: isDesktop
                  ? const EdgeInsets.symmetric(
                      horizontal: Dimensions.paddingSizeLarge,
                      vertical: 8,
                    )
                  : EdgeInsets.only(
                      top: Dimensions.mobileHomeSectionGap,
                    ),
              decoration: BoxDecoration(
                color: sectionBg,
                borderRadius: BorderRadius.circular(16),
              ),
              padding: EdgeInsets.symmetric(
                vertical: 16,
                horizontal: isDesktop ? Dimensions.paddingSizeLarge : Dimensions.mobileProductPaddingHorizontal,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _CategoryHeader(
                    title: category?.name ?? 'Category $categoryId',
                  ),
                  const SizedBox(height: 16),
                  _CategoryProductGrid(
                    products: items,
                    isDesktop: isDesktop,
                    isTab: isTab,
                  ),
                  const SizedBox(height: 24),
                  _CategoryFooter(
                    onShowMore: () => RouteHelper.getDashboardRoute(context, 'store', categoryId: category?.id, action: RouteAction.push),
                  ),
                ],
              ),
            ),
          );
        });

        if (!isDesktop && children.isNotEmpty) {
          children.add(const SizedBox(height: Dimensions.mobileHomePaddingBottom));
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: children,
        );
      },
    );
  }
}

class _CategoryHeader extends StatelessWidget {
  const _CategoryHeader({
    required this.title,
  });

  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDesktop = ResponsiveHelper.isDesktop(context);

    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: Text(
        title,
        style: rubikBold.copyWith(
          fontSize: isDesktop ? 20 : 18,
          color: theme.colorScheme.onSurface,
        ),
        textAlign: TextAlign.start,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

class _CategoryFooter extends StatelessWidget {
  const _CategoryFooter({
    required this.onShowMore,
  });

  final VoidCallback onShowMore;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: TextButton(
        onPressed: onShowMore,
        style: TextButton.styleFrom(
          padding: EdgeInsets.zero,
          minimumSize: const Size(0, 0),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          foregroundColor: Colors.white,
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 12),
          decoration: BoxDecoration(
            color: theme.primaryColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            getTranslated('view_all', context),
            style: rubikMedium.copyWith(
              fontSize: Dimensions.fontSizeDefault,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

class _CategoryProductGrid extends StatelessWidget {
  const _CategoryProductGrid({
    required this.products,
    required this.isDesktop,
    required this.isTab,
  });

  final List<Product> products;
  final bool isDesktop;
  final bool isTab;

  @override
  Widget build(BuildContext context) {
    if (isDesktop || isTab) {
      final crossAxisCount = isDesktop ? 5 : 3;
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisSpacing: 13,
          mainAxisSpacing: 13,
          childAspectRatio: 1 / 1.4,
          crossAxisCount: crossAxisCount,
        ),
        itemCount: products.length,
        itemBuilder: (context, index) {
          return ProductCardWidget(product: products[index]);
        },
      );
    }

    return MasonryGridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: Dimensions.mobileProductGridGap,
      crossAxisSpacing: Dimensions.mobileProductGridCrossAxisSpacing,
      itemCount: products.length,
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: Dimensions.mobileProductCardPaddingHorizontal,
          vertical: Dimensions.mobileProductCardPaddingVertical,
        ),
        child: ProductCardWidget(product: products[index]),
      ),
    );
  }
}

