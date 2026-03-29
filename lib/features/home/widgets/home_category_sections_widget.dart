import 'package:hexacom_user/common/models/feature_category_model.dart';
import 'package:hexacom_user/features/category/providers/category_provider.dart';
import 'package:hexacom_user/features/home/widgets/category_products_section_widget.dart';
import 'package:hexacom_user/features/home/widgets/feature_category_widget.dart';
import 'package:hexacom_user/helper/responsive_helper.dart';
import 'package:hexacom_user/utill/dimensions.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Home: featured strips first (API order, max 10 products each), then every non-featured
/// category (max 5 products each), loaded via [CategoryProvider.preloadHomeNonFeaturedProductPreviews].
class HomeCategorySectionsWidget extends StatelessWidget {
  const HomeCategorySectionsWidget({super.key});

  static Map<int, FeaturedCategory> _featuredByCategoryId(
    List<FeaturedCategory>? list,
  ) {
    final map = <int, FeaturedCategory>{};
    if (list == null) return map;
    for (final f in list) {
      final id = f.category?.id;
      if (id != null) map[id] = f;
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CategoryProvider>(
      builder: (context, categoryProvider, _) {
        final categories = categoryProvider.categoryList;
        final featuredList = categoryProvider.featureCategoryMode?.featuredData;
        final featuredById = _featuredByCategoryId(featuredList);
        final featuredIds = featuredById.keys.toSet();
        final previews = categoryProvider.homeNonFeaturedPreviews;
        final isDesktop = ResponsiveHelper.isDesktop(context);

        if (categories == null || categories.isEmpty) {
          return const SizedBox.shrink();
        }

        if (previews == null && !categoryProvider.isHomeNonFeaturedPreloadInFlight) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!context.mounted) return;
            context.read<CategoryProvider>().preloadHomeNonFeaturedProductPreviews();
          });
        }

        final children = <Widget>[];

        final featuredAdded = <int>{};
        if (featuredList != null) {
          for (final f in featuredList) {
            final id = f.category?.id;
            if (id == null || featuredAdded.contains(id)) continue;
            featuredAdded.add(id);
            children.add(
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: FeatureCategoryWidget(featuredCategory: f),
              ),
            );
          }
        }

        if (previews == null) {
          children.add(
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        } else {
          for (final cat in categories) {
            final id = cat.id;
            if (id == null || featuredIds.contains(id)) continue;

            children.add(
              CategoryProductSectionCard(
                category: cat,
                products: previews[id] ?? [],
              ),
            );
          }
        }

        if (!isDesktop && children.isNotEmpty) {
          children.add(const SizedBox(height: Dimensions.mobileHomePaddingBottom));
        }

        if (children.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: children,
        );
      },
    );
  }
}
