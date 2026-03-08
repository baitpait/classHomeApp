import 'package:hexacom_user/common/enums/product_filter_type_enum.dart';
import 'package:hexacom_user/helper/responsive_helper.dart';
import 'package:hexacom_user/features/product/providers/product_provider.dart';
import 'package:hexacom_user/utill/dimensions.dart';
import 'package:hexacom_user/common/widgets/no_data_screen.dart';
import 'package:hexacom_user/common/widgets/paginated_list_view.dart';
import 'package:hexacom_user/common/widgets/product_card_widget.dart';
import 'package:hexacom_user/common/widgets/product_shimmer_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';


class ProductListWidget extends StatelessWidget {
  final ProductFilterType? filterType;
  final ScrollController? scrollController;
  const ProductListWidget({super.key, this.scrollController, this.filterType});

  @override
  Widget build(BuildContext context) {

    return Consumer<ProductProvider>(
      builder: (context, productProvider, child) {
        final isDesktop = ResponsiveHelper.isDesktop(context);
        final isTab = ResponsiveHelper.isTab(context);
        return PaginatedListView(
          scrollController: scrollController!,
          totalSize: productProvider.latestProductModel?.totalSize,
          offset: productProvider.latestProductModel?.offset,
          limit: productProvider.latestProductModel?.limit,
          onPaginate: (int? offset)=> productProvider.getLatestProductList(
            offset!,limit: productProvider.latestProductModel?.limit,
            filterType: filterType, isUpdate: true,
          ),
          itemView: productProvider.latestProductModel != null
              ? productProvider.latestProductModel!.products!.isNotEmpty
                  ? isDesktop
                      // Desktop: fixed grid, 5 columns
                      ? GridView.builder(
                          shrinkWrap: true,
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisSpacing: 13,
                            mainAxisSpacing: 13,
                            childAspectRatio: 1 / 1.4,
                            crossAxisCount: 5,
                          ),
                          itemCount: productProvider.latestProductModel?.products?.length,
                          itemBuilder: (BuildContext context, int index) {
                            return ProductCardWidget(product: productProvider.latestProductModel!.products![index]);
                          },
                        )
                      : isTab
                          // Tablet (iPad): fixed grid, 3 columns like PC cards
                          ? GridView.builder(
                              shrinkWrap: true,
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisSpacing: 13,
                                mainAxisSpacing: 13,
                                childAspectRatio: 1 / 1.4,
                                crossAxisCount: 3,
                              ),
                              itemCount: productProvider.latestProductModel?.products?.length,
                              itemBuilder: (BuildContext context, int index) {
                                return ProductCardWidget(product: productProvider.latestProductModel!.products![index]);
                              },
                            )
                          // Mobile: masonry, 2 columns
                          : MasonryGridView.count(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              crossAxisCount: 2,
                              mainAxisSpacing: Dimensions.mobileProductGridGap,
                              crossAxisSpacing: Dimensions.mobileProductGridCrossAxisSpacing,
                              itemCount: productProvider.latestProductModel!.products!.length,
                              itemBuilder: (context, index) => Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: Dimensions.mobileProductCardPaddingHorizontal,
                                  vertical: Dimensions.mobileProductCardPaddingVertical,
                                ),
                                child: ProductCardWidget(product: productProvider.latestProductModel!.products![index]),
                              ),
                            )
                  : const NoDataScreen(

          ) : GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisSpacing: 13,
              mainAxisSpacing: 13,
              childAspectRatio: (1/1.4),
              crossAxisCount: ResponsiveHelper.isDesktop(context) ? 6 : 2,
            ),
            itemCount: 12,
            itemBuilder: (BuildContext context, int index) {
              return ProductShimmerWidget(isEnabled: productProvider.latestProductModel == null, isWeb: true);
            },
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
          ),
        );
      },
    );
  }
}
