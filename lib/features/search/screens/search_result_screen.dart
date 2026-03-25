import 'package:hexacom_user/common/enums/footer_type_enum.dart';
import 'package:hexacom_user/common/enums/search_short_by_enum.dart';
import 'package:hexacom_user/common/widgets/custom_app_bar_widget.dart';
import 'package:hexacom_user/features/search/widgets/product_filter_bottom_sheet_widget.dart';
import 'package:hexacom_user/helper/product_filter_helper.dart';
import 'package:hexacom_user/helper/responsive_helper.dart';
import 'package:hexacom_user/localization/language_constrants.dart';
import 'package:hexacom_user/features/search/providers/search_provider.dart';
import 'package:hexacom_user/provider/theme_provider.dart';
import 'package:hexacom_user/utill/color_resources.dart';
import 'package:hexacom_user/utill/dimensions.dart';
import 'package:hexacom_user/utill/images.dart';
import 'package:hexacom_user/utill/styles.dart';
import 'package:hexacom_user/common/widgets/custom_text_field_widget.dart';
import 'package:hexacom_user/common/widgets/footer_web_widget.dart';
import 'package:hexacom_user/common/widgets/no_data_screen.dart';
import 'package:hexacom_user/common/widgets/paginated_list_view.dart';
import 'package:hexacom_user/common/widgets/product_card_widget.dart';
import 'package:hexacom_user/common/widgets/product_shimmer_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';

class SearchResultScreen extends StatefulWidget {
  final String searchString;
  final SearchShortBy? shortBy;
  const SearchResultScreen({super.key, required this.searchString, this.shortBy});

  @override
  State<SearchResultScreen> createState() => _SearchResultScreenState();
}

class _SearchResultScreenState extends State<SearchResultScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    final SearchProvider searchProvider = Provider.of<SearchProvider>(context, listen: false);

    searchProvider.resetSearchFilterData(context, false, isUpdate: false, fromInitState: true);

    bool isFirst = true;


    searchProvider.setSelectShortBy(null, isUpdate: false);
    if(widget.shortBy != null) {
      searchProvider.setSelectShortBy(widget.shortBy, isUpdate: false);
    }

    if (isFirst) {
      _searchController.text = widget.searchString;
      isFirst = false;
    }

    searchProvider.searchProduct(offset: 1, query: widget.searchString, shortBy: widget.shortBy);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (ResponsiveHelper.isDesktop(context)) {
        searchProvider.loadTags();
        searchProvider.loadAttributes();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Provider.of<ThemeProvider>(context, listen: false).darkTheme;
    final size = MediaQuery.sizeOf(context);
    final isDesktop = ResponsiveHelper.isDesktop(context);

    return Scaffold(
      appBar: isDesktop ? const CustomAppBarWidget(onlyDesktop: true) : null,
      body: SafeArea(
        child: Consumer<SearchProvider>(
          builder: (context, searchProvider, child) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if(!isDesktop) Center(child: Container(
                width: Dimensions.webScreenWidth,
                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge, vertical: Dimensions.paddingSizeDefault),
                decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    boxShadow: [BoxShadow(
                      color: Theme.of(context).textTheme.bodyMedium!.color!.withValues(alpha: 0.05),
                      offset: const Offset(0, 2),
                      blurRadius: 30,
                    )]
                ),
                child: Row(
                  children: [
                    ResponsiveHelper.isDesktop(context) ? const SizedBox(): Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Theme.of(context).hintColor.withValues(alpha: 0.2), width: 1),
                          borderRadius: BorderRadius.circular(40),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(40),
                          child: CustomTextFieldWidget(
                            fillColor: Theme.of(context).primaryColor.withValues(alpha: 0.04),
                            hintText: getTranslated('search_items_here', context),
                            controller: _searchController,
                            isShowPrefixIcon: true,
                            prefixAssetUrl: Images.search,
                            inputAction: TextInputAction.search,
                            prefixAssetImageColor: Theme.of(context).primaryColor,
                            isIcon: true,
                            onSubmit: (String text)=> searchProvider.searchProduct(offset: 1, query: _searchController.text),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 5),

                    ResponsiveHelper.isDesktop(context) || _searchController.text.isEmpty ?
                    const SizedBox() : IconButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      icon: Icon(Icons.close, color: Theme.of(context).disabledColor, size: 25),
                    ),
                  ],
                ),
              )),
              const SizedBox(height: 10),

              // Mobile/tablet: keep the compact "X products found" + filter button row.
              // Desktop: this header is rendered inside the results area, aligned with the grid.
              if(!isDesktop && searchProvider.searchProductModel != null)...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                  child: Center(
                    child: SizedBox(
                      width: Dimensions.webScreenWidth,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: Dimensions.paddingSizeSmall,
                          vertical: Dimensions.paddingSizeDefault,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).secondaryHeaderColor.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(Dimensions.radiusSizeDefault),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                '${searchProvider.searchProductModel?.totalSize ?? '0'} ${getTranslated('product_found', context)}',
                                style: rubikRegular.copyWith(color: ColorResources.getGreyBunkerColor(context)),
                              ),
                            ),
                            InkWell(
                                onTap: () async {
                                  await searchProvider.loadTags();
                                  await searchProvider.loadAttributes();
                                  if (!context.mounted) return;
                                  showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true,
                                    builder: (context) {
                                      return Consumer<SearchProvider>(
                                        builder: (context, searchProvider, child) => ProductFilterBottomSheetWidget(
                                          sliderMax: searchProvider.searchProductModel?.productHighPrice,
                                          sliderMin: searchProvider.searchProductModel?.productLowestPrice,
                                          searchMaxPrice: searchProvider.searchProductModel?.sortedHighPrice,
                                          searchMinPrice: searchProvider.searchProductModel?.sortedLowestPrice,
                                          onClearTap: () => searchProvider.resetSearchFilterData(context, false, isUpdate: true),
                                          canFiltered: ProductFilterHelper.canProductFilter(),
                                          tagList: searchProvider.tagList,
                                          attributeList: searchProvider.attributeList,
                                          onSubmitTap: () {
                                            searchProvider.searchProduct(
                                              offset: 1,
                                              query: _searchController.text,
                                              rating: searchProvider.rating == -1 ? null : searchProvider.rating,
                                              priceLow: searchProvider.lowerValue,
                                              priceHigh: searchProvider.upperValue,
                                              categoryIds: searchProvider.selectCategoryList.toList(),
                                              tagIds: searchProvider.selectedTagIds.isEmpty ? null : searchProvider.selectedTagIds.toList(),
                                              attributeIds: searchProvider.selectedAttributeIds.isEmpty ? null : searchProvider.selectedAttributeIds.toList(),
                                              shortBy: searchProvider.selectedSearchShotBy,
                                              isUpdate: true,
                                            );
                                            Navigator.pop(context);
                                          },
                                        ),
                                      );
                                    },
                                  );
                                },
                                child: Stack(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeSmall),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).cardColor,
                                        borderRadius: BorderRadius.circular(Dimensions.radiusSizeDefault),
                                        border: Border.all(color: isDark ? Colors.white : Theme.of(context).primaryColor),
                                      ),
                                      child: Icon(Icons.filter_list, color: Theme.of(context).primaryColor, size: 20),
                                    ),

                                    if(ProductFilterHelper.isProductFiltered())  Positioned(
                                      top: 8, right: 7,
                                      child: Container(
                                        height: 10, width: 10,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          color: Theme.of(context).colorScheme.error,
                                          shape: BoxShape.circle,
                                        ),
                                      ),

                                    ),
                                  ],
                                )
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 13)
              ],

              Expanded(
                child: _SearchResultsBody(
                  isDesktop: isDesktop,
                  size: size,
                  scrollController: scrollController,
                  searchController: _searchController,
                  widgetShortBy: widget.shortBy,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchResultsBody extends StatelessWidget {
  final bool isDesktop;
  final Size size;
  final ScrollController scrollController;
  final TextEditingController searchController;
  final SearchShortBy? widgetShortBy;

  const _SearchResultsBody({
    required this.isDesktop,
    required this.size,
    required this.scrollController,
    required this.searchController,
    required this.widgetShortBy,
  });

  int _desktopCrossAxisCount(double availableWidth) {
    if (availableWidth >= 1650) return 5;
    if (availableWidth >= 1350) return 4;
    return 3;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SearchProvider>(
      builder: (context, searchProvider, _) {
        final model = searchProvider.searchProductModel;
        final products = model?.products ?? [];

        if (model != null && products.isEmpty) {
          if (!isDesktop) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
              child: Column(
                children: [
                  ConstrainedBox(
                    constraints: BoxConstraints(minHeight: !isDesktop && size.height < 600 ? size.height : size.height - 400),
                    child: NoDataScreen(title: getTranslated('no_product_found', context)),
                  ),
                  const FooterWebWidget(footerType: FooterType.nonSliver),
                ],
              ),
            );
          }

          // Desktop: keep the page layout (sidebar + header) and show "no results"
          // only inside the products area.
          final filterSidebar = Container(
            width: 340,
            margin: const EdgeInsetsDirectional.only(end: Dimensions.paddingSizeDefault),
            padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(Dimensions.radiusSizeDefault),
              border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.15)),
            ),
            child: SizedBox(
              height: size.height - 220,
              child: ProductFilterBottomSheetWidget(
                key: ValueKey<String>(
                  'sidebar-${model.productLowestPrice}-${model.productHighPrice}-${model.sortedLowestPrice}-${model.sortedHighPrice}',
                ),
                showCloseButton: false,
                autoApply: true,
                sliderMax: model.productHighPrice,
                sliderMin: model.productLowestPrice,
                searchMaxPrice: model.sortedHighPrice,
                searchMinPrice: model.sortedLowestPrice,
                onClearTap: () => searchProvider.resetSearchFilterData(context, false, isUpdate: true),
                canFiltered: ProductFilterHelper.canProductFilter(),
                tagList: searchProvider.tagList,
                attributeList: searchProvider.attributeList,
                onSubmitTap: () {
                  searchProvider.searchProduct(
                    offset: 1,
                    query: searchController.text,
                    rating: searchProvider.rating == -1 ? null : searchProvider.rating,
                    priceLow: searchProvider.lowerValue,
                    priceHigh: searchProvider.upperValue,
                    categoryIds: searchProvider.selectCategoryList.toList(),
                    tagIds: searchProvider.selectedTagIds.isEmpty ? null : searchProvider.selectedTagIds.toList(),
                    attributeIds: searchProvider.selectedAttributeIds.isEmpty ? null : searchProvider.selectedAttributeIds.toList(),
                    shortBy: searchProvider.selectedSearchShotBy,
                    isUpdate: true,
                  );
                },
              ),
            ),
          );

          return SingleChildScrollView(
            controller: scrollController,
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                Center(
                  child: SizedBox(
                    width: Dimensions.webScreenWidth,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        filterSidebar,
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 4, bottom: Dimensions.paddingSizeDefault),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        '${model.totalSize ?? 0} ${getTranslated('product_found', context)}',
                                        style: rubikSemiBold.copyWith(fontSize: Dimensions.fontSizeLarge),
                                      ),
                                    ),
                                    if (ProductFilterHelper.isProductFiltered())
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: Theme.of(context).primaryColor.withValues(alpha: 0.08),
                                          borderRadius: BorderRadius.circular(999),
                                          border: Border.all(color: Theme.of(context).primaryColor.withValues(alpha: 0.18)),
                                        ),
                                        child: Text(
                                          getTranslated('filters_applied', context),
                                          style: rubikRegular.copyWith(
                                            fontSize: Dimensions.fontSizeSmall,
                                            color: Theme.of(context).primaryColor,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).cardColor,
                                  borderRadius: BorderRadius.circular(Dimensions.radiusSizeDefault),
                                  border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.12)),
                                ),
                                child: NoDataScreen(title: getTranslated('no_product_found', context)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: Dimensions.paddingSizeDefault),
                const FooterWebWidget(footerType: FooterType.nonSliver),
              ],
            ),
          );
        }

        final productsView = SingleChildScrollView(
          controller: scrollController,
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: !isDesktop && size.height < 600 ? size.height : size.height - 400),
                  child: SizedBox(
                    width: Dimensions.webScreenWidth,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final crossAxisCount = isDesktop ? _desktopCrossAxisCount(constraints.maxWidth) : 2;
                        final crossAxisSpacing = isDesktop ? 13.0 : 5.0;
                        final mainAxisSpacing = isDesktop ? 13.0 : 5.0;

                        return PaginatedListView(
                          scrollController: scrollController,
                          totalSize: model?.totalSize,
                          offset: model?.offset,
                          onPaginate: (int? offset) => searchProvider.searchProduct(
                            offset: offset!,
                            query: searchController.text,
                            rating: searchProvider.rating == -1 ? null : searchProvider.rating,
                            priceLow: searchProvider.lowerValue,
                            priceHigh: searchProvider.upperValue,
                            categoryIds: searchProvider.selectCategoryList.isEmpty ? null : searchProvider.selectCategoryList.toList(),
                            tagIds: searchProvider.selectedTagIds.isEmpty ? null : searchProvider.selectedTagIds.toList(),
                            attributeIds: searchProvider.selectedAttributeIds.isEmpty ? null : searchProvider.selectedAttributeIds.toList(),
                            shortBy: searchProvider.selectedSearchShotBy ?? widgetShortBy,
                            isUpdate: true,
                          ),
                          itemView: isDesktop || model == null
                              ? GridView.builder(
                                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisSpacing: crossAxisSpacing,
                                    mainAxisSpacing: mainAxisSpacing,
                                    childAspectRatio: isDesktop ? (1/1.505) : 0.7,
                                    crossAxisCount: crossAxisCount,
                                  ),
                                  itemCount: model == null ? 10 : products.length,
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
                                  itemBuilder: (context, index) {
                                    return model == null
                                        ? const ProductShimmerWidget(isEnabled: true, isWeb: true)
                                        : ProductCardWidget(product: products[index]);
                                  },
                                )
                              : StaggeredGrid.count(
                                  crossAxisCount: 2,
                                  mainAxisSpacing: 4,
                                  crossAxisSpacing: 4,
                                  children: products
                                      .map((product) => StaggeredGridTile.fit(
                                            crossAxisCellCount: 1,
                                            child: Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: ProductCardWidget(product: product),
                                            ),
                                          ))
                                      .toList(),
                                ),
                        );
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: Dimensions.paddingSizeDefault),
              const FooterWebWidget(footerType: FooterType.nonSliver),
            ],
          ),
        );

        if (!isDesktop) return productsView;

        final filterSidebar = Container(
          width: 340,
          margin: const EdgeInsetsDirectional.only(end: Dimensions.paddingSizeDefault),
          padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(Dimensions.radiusSizeDefault),
            border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.15)),
          ),
          child: ProductFilterBottomSheetWidget(
            key: ValueKey<String>(
              'sidebar-${model?.productLowestPrice}-${model?.productHighPrice}-${model?.sortedLowestPrice}-${model?.sortedHighPrice}',
            ),
            showCloseButton: false,
            autoApply: true,
            scrollContent: false,
            sliderMax: model?.productHighPrice,
            sliderMin: model?.productLowestPrice,
            searchMaxPrice: model?.sortedHighPrice,
            searchMinPrice: model?.sortedLowestPrice,
            onClearTap: () => searchProvider.resetSearchFilterData(context, false, isUpdate: true),
            canFiltered: ProductFilterHelper.canProductFilter(),
            tagList: searchProvider.tagList,
            attributeList: searchProvider.attributeList,
            onSubmitTap: () {
              searchProvider.searchProduct(
                offset: 1,
                query: searchController.text,
                rating: searchProvider.rating == -1 ? null : searchProvider.rating,
                priceLow: searchProvider.lowerValue,
                priceHigh: searchProvider.upperValue,
                categoryIds: searchProvider.selectCategoryList.toList(),
                tagIds: searchProvider.selectedTagIds.isEmpty ? null : searchProvider.selectedTagIds.toList(),
                attributeIds: searchProvider.selectedAttributeIds.isEmpty ? null : searchProvider.selectedAttributeIds.toList(),
                shortBy: searchProvider.selectedSearchShotBy,
                isUpdate: true,
              );
            },
          ),
        );

        // Desktop: keep filters within the results area (scrolls with products)
        return SingleChildScrollView(
          controller: scrollController,
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              Center(
                child: SizedBox(
                  width: Dimensions.webScreenWidth,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      filterSidebar,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 4, bottom: Dimensions.paddingSizeDefault),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      '${model?.totalSize ?? 0} ${getTranslated('product_found', context)}',
                                      style: rubikSemiBold.copyWith(fontSize: Dimensions.fontSizeLarge),
                                    ),
                                  ),
                                  if (ProductFilterHelper.isProductFiltered())
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).primaryColor.withValues(alpha: 0.08),
                                        borderRadius: BorderRadius.circular(999),
                                        border: Border.all(color: Theme.of(context).primaryColor.withValues(alpha: 0.18)),
                                      ),
                                      child: Text(
                                        getTranslated('filters_applied', context),
                                        style: rubikRegular.copyWith(
                                          fontSize: Dimensions.fontSizeSmall,
                                          color: Theme.of(context).primaryColor,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            // Reuse the same grid/pagination body but without its own scroll on desktop.
                            LayoutBuilder(
                              builder: (context, constraints) {
                                final crossAxisCount = _desktopCrossAxisCount(constraints.maxWidth);
                                return PaginatedListView(
                                  scrollController: scrollController,
                                  totalSize: model?.totalSize,
                                  offset: model?.offset,
                                  onPaginate: (int? offset) => searchProvider.searchProduct(
                                    offset: offset!,
                                    query: searchController.text,
                                    rating: searchProvider.rating == -1 ? null : searchProvider.rating,
                                    priceLow: searchProvider.lowerValue,
                                    priceHigh: searchProvider.upperValue,
                                    categoryIds: searchProvider.selectCategoryList.isEmpty ? null : searchProvider.selectCategoryList.toList(),
                                    tagIds: searchProvider.selectedTagIds.isEmpty ? null : searchProvider.selectedTagIds.toList(),
                                    attributeIds: searchProvider.selectedAttributeIds.isEmpty ? null : searchProvider.selectedAttributeIds.toList(),
                                    shortBy: searchProvider.selectedSearchShotBy ?? widgetShortBy,
                                    isUpdate: true,
                                  ),
                                  itemView: GridView.builder(
                                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisSpacing: 13,
                                      mainAxisSpacing: 13,
                                      childAspectRatio: (1 / 1.505),
                                      crossAxisCount: crossAxisCount,
                                    ),
                                    itemCount: model == null ? 10 : products.length,
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
                                    itemBuilder: (context, index) {
                                      return model == null
                                          ? const ProductShimmerWidget(isEnabled: true, isWeb: true)
                                          : ProductCardWidget(product: products[index]);
                                    },
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: Dimensions.paddingSizeDefault),
              const FooterWebWidget(footerType: FooterType.nonSliver),
            ],
          ),
        );
      },
    );
  }
}
