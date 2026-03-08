import 'package:hexacom_user/common/enums/footer_type_enum.dart';
import 'package:hexacom_user/common/enums/product_filter_type_enum.dart';
import 'package:hexacom_user/common/widgets/custom_app_bar_widget.dart';
import 'package:hexacom_user/common/widgets/custom_icon_button.dart';
import 'package:hexacom_user/common/widgets/footer_web_widget.dart';
import 'package:hexacom_user/common/widgets/no_data_screen.dart';
import 'package:hexacom_user/common/widgets/paginated_list_view.dart';
import 'package:hexacom_user/common/widgets/product_card_widget.dart';
import 'package:hexacom_user/common/widgets/product_shimmer_widget.dart';
import 'package:hexacom_user/common/widgets/show_custom_bottom_sheet.dart';
import 'package:hexacom_user/common/widgets/title_widget.dart';
import 'package:hexacom_user/features/flash_sale/providers/flash_sale_provider.dart';
import 'package:hexacom_user/features/flash_sale/widgets/flash_sale_timer_widget.dart';
import 'package:hexacom_user/features/search/providers/search_provider.dart';
import 'package:hexacom_user/features/search/widgets/product_filter_bottom_sheet_widget.dart';
import 'package:hexacom_user/features/menu/widgets/options_widget.dart';
import 'package:hexacom_user/helper/product_filter_helper.dart';
import 'package:hexacom_user/helper/responsive_helper.dart';
import 'package:hexacom_user/localization/language_constrants.dart';
import 'package:hexacom_user/main.dart';
import 'package:hexacom_user/utill/dimensions.dart';
import 'package:hexacom_user/utill/images.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';

class FlashSaleDetailsScreen extends StatefulWidget {
  const FlashSaleDetailsScreen({super.key});

  @override
  State<FlashSaleDetailsScreen> createState() => _FlashSaleDetailsScreenState();
}

class _FlashSaleDetailsScreenState extends State<FlashSaleDetailsScreen> {
  final GlobalKey<ScaffoldState> drawerGlobalKey = GlobalKey();

  final ScrollController _scrollController = ScrollController();
  ProductFilterType? filterType;



  @override
  void initState() {
    super.initState();
    final FlashSaleProvider flashSaleProvider = Provider.of<FlashSaleProvider>(context, listen: false);

    flashSaleProvider.getFlashSaleProducts(1, false);
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
  }


  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return Scaffold(
      key: drawerGlobalKey,
      endDrawerEnableOpenDragGesture: false,
      drawer: ResponsiveHelper.isTab(context) ? const Drawer(child: OptionsWidget(onTap: null)) : const SizedBox(),
      appBar: CustomAppBarWidget(
        title: getTranslated('flash_sale', context),
        onlyDesktop: !ResponsiveHelper.isDesktop(context) ? false : true,
      ),
      body: CustomScrollView(controller: _scrollController, slivers: [
        SliverToBoxAdapter(child: Column(children: [

          Center(child: SizedBox(width: Dimensions.webScreenWidth, child: Padding(
            padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
            child: Consumer<FlashSaleProvider>(builder: (context, flashSaleProvider, child) {
              return Column(children: [

                Container(
                  height: ResponsiveHelper.isDesktop(context) ? 180 : 100,
                  width: double.maxFinite,
                  decoration: BoxDecoration(
                    color: const Color(0xFF3A4756),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).shadowColor.withValues(alpha: 0.1),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset(
                        Images.flashSale,
                        width: ResponsiveHelper.isDesktop(context) ? 200 : 90,
                        height: ResponsiveHelper.isDesktop(context) ? 180 : 100,
                        fit: BoxFit.contain,
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                          right: ResponsiveHelper.isDesktop(context) ? 20 : 14,
                        ),
                        child: const FlashSaleTimerWidget(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                Consumer<SearchProvider>(builder: (context, searchProvider, child){
                  return TitleWidget(
                      title: getTranslated('all_items', context),
                      leadingButton: CustomFilterButton(
                        isFiltered: ProductFilterHelper.isFlashSalesFiltered(),
                        onTap: (){
                          if(ResponsiveHelper.isDesktop(context)){
                            searchProvider.showProductFilter(size, context, fromFlashSales: true);
                          }else{
                            showCustomBottomSheet(
                                context: context,
                                child: Consumer<SearchProvider>(
                                  builder: (context, searchProvider, child)=> ProductFilterBottomSheetWidget(
                                      sliderMax: flashSaleProvider.flashSaleModel?.productHighPrice,
                                      sliderMin: flashSaleProvider.flashSaleModel?.productLowestPrice,
                                      searchMinPrice: flashSaleProvider.flashSaleModel?.sortedLowestPrice,
                                      searchMaxPrice: flashSaleProvider.flashSaleModel?.sortedHighPrice,
                                      canFiltered: ProductFilterHelper.canFlashSalesFilter(),
                                      onClearTap: ()=> Provider.of<SearchProvider>(context, listen: false).resetSearchFilterData(context, true, isUpdate: true),
                                      onSubmitTap: (){
                                        flashSaleProvider.getFlashSaleProducts(
                                          1, true,
                                          rating: searchProvider.rating == -1 ? null : searchProvider.rating,
                                          priceLow: searchProvider.lowerValue,
                                          priceHigh: searchProvider.upperValue,
                                          categoryIds: searchProvider.selectCategoryList.toList(),
                                          shortBy: searchProvider.getShortByValue(searchProvider.selectedSearchShotBy),
                                        );
                                        Navigator.of(Get.context!).pop();
                                      }
                                  ),
                                )
                            );
                          }
                        },
                      )
                  );
                }),
                const SizedBox(height: Dimensions.paddingSizeDefault),

                PaginatedListView(
                  scrollController: _scrollController,
                  totalSize: flashSaleProvider.flashSaleModel?.totalSize,
                  offset: flashSaleProvider.flashSaleModel?.offset,
                  onPaginate: (int? offset) async {
                    SearchProvider searchProvider = Provider.of<SearchProvider>(context, listen: false);

                    await flashSaleProvider.getFlashSaleProducts(
                      offset!, false,
                      rating: searchProvider.rating == -1 ? null : searchProvider.rating,
                      priceLow: searchProvider.lowerValue,
                      priceHigh: searchProvider.upperValue,
                      categoryIds: searchProvider.selectCategoryList.toList(),
                      shortBy: searchProvider.getShortByValue(searchProvider.selectedSearchShotBy),
                    );
                  },
                  itemView: flashSaleProvider.flashSaleModel != null ? flashSaleProvider.flashSaleModel!.products!.isNotEmpty ?

                  ResponsiveHelper.isDesktop(context) ? GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisSpacing: ResponsiveHelper.isDesktop(context) ? 13 : 5,
                      mainAxisSpacing: ResponsiveHelper.isDesktop(context) ? 13 : 5,
                      childAspectRatio: ResponsiveHelper.isDesktop(context) ? (1/1.45) : 4,
                      crossAxisCount: ResponsiveHelper.isDesktop(context) ? 5 : ResponsiveHelper.isTab(context) ? 2 : 1,
                    ),
                    itemCount: flashSaleProvider.flashSaleModel!.products?.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
                    itemBuilder: (context, index) {
                      return ProductCardWidget(product: flashSaleProvider.flashSaleModel!.products![index]);
                    },
                  ) : StaggeredGrid.count(
                    crossAxisCount: ResponsiveHelper.isDesktop(context) ? 5 : 2,
                    mainAxisSpacing: 15, crossAxisSpacing: 15,
                    children: flashSaleProvider.flashSaleModel!.products!.map((product) => StaggeredGridTile.fit(
                      crossAxisCellCount: 1,
                      child: ProductCardWidget(product: product),
                    )).toList(),
                  ) : const NoDataScreen() : GridView.builder(
                    shrinkWrap: true,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisSpacing: ResponsiveHelper.isDesktop(context) ? 13 : 5,
                      mainAxisSpacing: ResponsiveHelper.isDesktop(context) ? 13 : 5,
                      childAspectRatio: ResponsiveHelper.isDesktop(context) ? (1/1.4) : 4,
                      crossAxisCount: ResponsiveHelper.isDesktop(context) ? 6 : ResponsiveHelper.isTab(context) ? 2 : 1,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                    itemCount: 12,
                    itemBuilder: (BuildContext context, int index) {
                      return ProductShimmerWidget(isEnabled: flashSaleProvider.flashSaleModel == null, isWeb: ResponsiveHelper.isDesktop(context));
                    },
                  ),
                ),


              ]);
            }
            ),
          ))),

          const FooterWebWidget(footerType: FooterType.nonSliver),

        ])),
      ]),
    );
  }
}
