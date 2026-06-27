import 'dart:math' as math;

import 'package:hexacom_user/common/enums/footer_type_enum.dart';
import 'package:hexacom_user/common/models/category_model.dart';
import 'package:hexacom_user/common/widgets/custom_image_widget.dart';
import 'package:hexacom_user/common/widgets/custom_slider_list_widget.dart';
import 'package:hexacom_user/common/widgets/home_app_bar_widget.dart';
import 'package:hexacom_user/common/widgets/no_data_screen.dart';
import 'package:hexacom_user/common/widgets/product_card_widget.dart';
import 'package:hexacom_user/common/widgets/product_shimmer_widget.dart';
import 'package:hexacom_user/common/widgets/footer_web_widget.dart';
import 'package:hexacom_user/common/widgets/web_app_bar_widget.dart';
import 'package:hexacom_user/utill/images.dart';
import 'package:hexacom_user/features/category/providers/category_provider.dart';
import 'package:hexacom_user/features/home/enums/banner_type_enum.dart';
import 'package:hexacom_user/features/home/providers/banner_provider.dart';
import 'package:hexacom_user/features/home/widgets/banner_widget.dart';
import 'package:hexacom_user/features/home/widgets/main_slider_shimmer_widget.dart';
import 'package:hexacom_user/features/home/widgets/main_slider_widget.dart';
import 'package:hexacom_user/features/menu/widgets/options_widget.dart';
import 'package:hexacom_user/helper/responsive_helper.dart';
import 'package:hexacom_user/localization/language_constrants.dart';
import 'package:hexacom_user/utill/color_resources.dart';
import 'package:hexacom_user/utill/dimensions.dart';
import 'package:hexacom_user/utill/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';

class StoreScreen extends StatefulWidget {
  final int? initialCategoryId;
  const StoreScreen({super.key, this.initialCategoryId});

  @override
  State<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen> with AutomaticKeepAliveClientMixin {
  final GlobalKey<ScaffoldState> _drawerKey = GlobalKey();
  int? _selectedCategoryId;
  static const double _headerScrollThreshold = 50.0;
  final ScrollController _scrollController = ScrollController();
  final ScrollController _categoryScrollController = ScrollController();
  late final ValueNotifier<bool> _headerScrolled;
  int _visibleProductCount = 20;
  static const int _productBatchSize = 20;

  @override
  void initState() {
    super.initState();
    _headerScrolled = ValueNotifier(false);
    _scrollController.addListener(_onScroll);
    _loadCategories();
  }

  void _onScroll() {
    final scrolled = _scrollController.offset > _headerScrollThreshold;
    if (_headerScrolled.value != scrolled) _headerScrolled.value = scrolled;

    final maxScroll = _scrollController.position.maxScrollExtent;
    final current = _scrollController.position.pixels;
    if (current > maxScroll * 0.7) {
      final products = context.read<CategoryProvider>().categoryProductList;
      if (products != null && _visibleProductCount < products.length) {
        setState(() {
          _visibleProductCount = math.min(
            _visibleProductCount + _productBatchSize,
            products.length,
          );
        });
      }
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _categoryScrollController.dispose();
    _headerScrolled.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    final cp = context.read<CategoryProvider>();
    await cp.getCategoryList(true);
    if (!mounted) return;
    final list = cp.categoryList;
    if (list == null || list.isEmpty) return;
    final withProducts = list.where((c) => c.hasProductsForStoreDisplay).toList();
    if (withProducts.isEmpty) return;
    final initialId = widget.initialCategoryId;
    final int? idToSelect = (initialId != null && withProducts.any((c) => c.id == initialId))
        ? initialId
        : withProducts.first.id;
    if (_selectedCategoryId == null && idToSelect != null) {
      setState(() => _selectedCategoryId = idToSelect);
      cp.selectCategoryById(idToSelect);
      cp.getCategoryProductList(idToSelect);
    }
  }

  void _onCategoryTap(int? id) {
    if (id == null) return;
    setState(() {
      _selectedCategoryId = id;
      _visibleProductCount = _productBatchSize;
    });
    final cp = context.read<CategoryProvider>();
    cp.selectCategoryById(id);
    cp.getCategoryProductList(id);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final isDesktop = ResponsiveHelper.isDesktop(context);
    final isTab = ResponsiveHelper.isTab(context);
    final viewportWidth = MediaQuery.sizeOf(context).width;
    final contentWidth = isDesktop ? Dimensions.getWebContentWidth(viewportWidth) : viewportWidth;
    final marginWidth = isDesktop ? (viewportWidth - contentWidth) / 2 : 0.0;

    return Scaffold(
      key: _drawerKey,
      endDrawerEnableOpenDragGesture: false,
      drawer: ResponsiveHelper.isTab(context) ? const Drawer(child: OptionsWidget(onTap: null)) : const SizedBox(),
      appBar: isDesktop ? const PreferredSize(preferredSize: Size.fromHeight(90), child: WebAppBarWidget()) : null,
      body: Consumer<CategoryProvider>(
        builder: (context, category, _) {
          final rawCategories = category.categoryList;
          final categories = rawCategories == null
              ? null
              : rawCategories.where((c) => c.hasProductsForStoreDisplay).toList();
          final products = category.categoryProductList;

          return CustomScrollView(
            controller: _scrollController,
            physics: isDesktop ? const AlwaysScrollableScrollPhysics() : const BouncingScrollPhysics(),
            slivers: [
              if (!isDesktop) HomeAppBarWidget(drawerGlobalKey: _drawerKey, headerScrolled: _headerScrolled),

              SliverToBoxAdapter(
                child: Container(
                  width: isDesktop ? contentWidth : null,
                  margin: isDesktop
                      ? EdgeInsets.symmetric(horizontal: marginWidth)
                      : const EdgeInsets.symmetric(horizontal: Dimensions.mobileContentPaddingHorizontal),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: isDesktop ? Dimensions.paddingSizeExtraSmall : Dimensions.mobileHomePaddingTop),

                      // Home page banner (desktop: main slider, mobile: BannerWidget)
                      if (isDesktop)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Consumer<BannerProvider>(
                            builder: (context, bannerProvider, _) {
                              if (bannerProvider.bannerList == null) {
                                return const MainSliderShimmerWidget();
                              }
                              if (bannerProvider.bannerList!.isEmpty) {
                                return const SizedBox.shrink();
                              }
                              return SizedBox(
                                height: 420,
                                child: MainSliderWidget(
                                  bannerList: bannerProvider.bannerList,
                                  bannerType: BannerType.primary,
                                ),
                              );
                            },
                          ),
                        )
                      else
                        Padding(
                          padding: const EdgeInsets.only(bottom: Dimensions.mobileHomeSectionGap),
                          child: Consumer<BannerProvider>(
                            builder: (context, banner, _) {
                              return banner.bannerList == null
                                  ? const BannerWidget()
                                  : banner.bannerList!.isEmpty
                                      ? const SizedBox.shrink()
                                      : const BannerWidget();
                            },
                          ),
                        ),

                      // Categories Section - same style as home (pill cards), selected=red, unselected=gray
                      if (categories != null && categories.isNotEmpty) ...[
                        _StoreCategorySlider(
                          categories: categories,
                          selectedCategoryId: _selectedCategoryId,
                          onCategoryTap: _onCategoryTap,
                          scrollController: _categoryScrollController,
                          isDesktop: isDesktop,
                        ),
                        SizedBox(height: isDesktop ? 6 : Dimensions.mobileHomeSectionGap),
                      ],

                      // Visual divider between sections
                      if (categories != null && categories.isNotEmpty)
                        Container(
                          height: 1,
                          margin: EdgeInsets.symmetric(vertical: isDesktop ? 2 : 8),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Theme.of(context).dividerColor.withValues(alpha: 0),
                                Theme.of(context).dividerColor.withValues(alpha: 0.2),
                                Theme.of(context).dividerColor.withValues(alpha: 0),
                              ],
                            ),
                          ),
                        ),

                      if (categories == null || categories.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: Dimensions.mobileHomeSectionGap * 2),
                          child: Center(
                            child: Text(
                              getTranslated('no_category_found', context).isEmpty ? 'No categories' : getTranslated('no_category_found', context),
                              style: rubikRegular.copyWith(color: Theme.of(context).hintColor),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              // Secondary Banner is currently hidden on store page
              // if (!isDesktop)
              //   SliverToBoxAdapter(
              //     child: Consumer<BannerProvider>(
              //       builder: (context, bannerProvider, _) {
              //         if (bannerProvider.secondaryBannerList == null ||
              //             bannerProvider.secondaryBannerList!.isEmpty) {
              //           return const SizedBox.shrink();
              //         }
              //         return Padding(
              //           padding: const EdgeInsets.only(
              //             top: Dimensions.mobileHomeSectionGap,
              //             bottom: Dimensions.mobileHomeSectionGap,
              //           ),
              //           child: MainSliderWidget(
              //             bannerType: BannerType.secondary,
              //             bannerList: bannerProvider.secondaryBannerList,
              //           ),
              //         );
              //       },
              //     ),
              //   ),

              // Products Grid Section (desktop: Align.topCenter so grid is not vertically centered in minHeight box)
              SliverToBoxAdapter(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: isDesktop ? MediaQuery.sizeOf(context).height - 400 : MediaQuery.sizeOf(context).height - 200,
                  ),
                  child: isDesktop
                      ? Align(
                          alignment: Alignment.topCenter,
                          child: SizedBox(
                            width: contentWidth,
                            child: Padding(
                              padding: EdgeInsets.only(
                                left: Dimensions.paddingSizeSmall,
                                right: Dimensions.paddingSizeSmall,
                                top: isDesktop ? 6 : Dimensions.paddingSizeLarge,
                                bottom: isDesktop ? Dimensions.paddingSizeExtraSmall : Dimensions.paddingSizeLarge,
                              ),
                              child: _selectedCategoryId == null && (categories == null || categories.isEmpty)
                                  ? const SizedBox.shrink()
                                      : products == null
                                      ? GridView.builder(
                                          shrinkWrap: true,
                                          itemCount: 10,
                                          physics: const NeverScrollableScrollPhysics(),
                                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisSpacing: 16,
                                            mainAxisSpacing: 16,
                                            childAspectRatio: 1 / 1.4,
                                            crossAxisCount: 5,
                                          ),
                                          itemBuilder: (context, index) => ProductShimmerWidget.buildGridShimmers(
                                            itemCount: 1,
                                            isWeb: true,
                                          ).first,
                                        )
                                      : products.isEmpty
                                          ? const NoDataScreen(showFooter: false)
                                          : GridView.builder(
                                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                                crossAxisSpacing: 16,
                                                mainAxisSpacing: 16,
                                                childAspectRatio: 1 / 1.4,
                                                crossAxisCount: 5,
                                              ),
                                              itemCount: math.min(_visibleProductCount, products.length),
                                              shrinkWrap: true,
                                              physics: const NeverScrollableScrollPhysics(),
                                              padding: EdgeInsets.only(
                                                left: Dimensions.paddingSizeSmall,
                                                right: Dimensions.paddingSizeSmall,
                                                top: isDesktop ? 0 : Dimensions.paddingSizeLarge,
                                                bottom: isDesktop ? Dimensions.paddingSizeExtraSmall : Dimensions.paddingSizeLarge,
                                              ),
                                              itemBuilder: (context, index) => ProductCardWidget(product: products[index]),
                                            ),
                            ),
                          ),
                        )
                      : SizedBox(
                          width: double.infinity,
                          child: Padding(
                            padding: const EdgeInsets.only(
                              left: Dimensions.mobileContentPaddingHorizontal,
                              right: Dimensions.mobileContentPaddingHorizontal,
                              bottom: Dimensions.mobileHomePaddingBottom,
                            ),
                            child: _selectedCategoryId == null && (categories == null || categories.isEmpty)
                                ? const SizedBox.shrink()
                                : products == null
                                    // Loading skeletons
                                    ? GridView.builder(
                                        shrinkWrap: true,
                                        itemCount: 10,
                                        physics: const NeverScrollableScrollPhysics(),
                                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisSpacing: Dimensions.mobileProductGridCrossAxisSpacing,
                                          mainAxisSpacing: Dimensions.mobileProductGridGap,
                                          childAspectRatio: isTab ? (1 / 1.4) : 4,
                                          crossAxisCount: isTab ? 3 : 1,
                                        ),
                                        itemBuilder: (context, index) => ProductShimmerWidget.buildGridShimmers(
                                          itemCount: 1,
                                          isWeb: false,
                                        ).first,
                                      )
                                    : products.isEmpty
                                        ? const NoDataScreen(showFooter: false)
                                        : isTab
                                            // iPad / tablet: fixed grid, 3 columns like desktop cards
                                            ? GridView.builder(
                                                shrinkWrap: true,
                                                physics: const NeverScrollableScrollPhysics(),
                                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                                  crossAxisSpacing: Dimensions.mobileProductGridCrossAxisSpacing,
                                                  mainAxisSpacing: Dimensions.mobileProductGridGap,
                                                  childAspectRatio: 1 / 1.4,
                                                  crossAxisCount: 3,
                                                ),
                                                itemCount: math.min(_visibleProductCount, products.length),
                                                itemBuilder: (context, index) => ProductCardWidget(product: products[index]),
                                              )
                                            // Mobile: masonry layout (2 columns)
                                            : MasonryGridView.count(
                                                shrinkWrap: true,
                                                physics: const NeverScrollableScrollPhysics(),
                                                crossAxisCount: 2,
                                                mainAxisSpacing: Dimensions.mobileProductGridGap,
                                                crossAxisSpacing: Dimensions.mobileProductGridCrossAxisSpacing,
                                                itemCount: math.min(_visibleProductCount, products.length),
                                                itemBuilder: (context, index) => Padding(
                                                  padding: const EdgeInsets.symmetric(
                                                    horizontal: Dimensions.mobileProductCardPaddingHorizontal,
                                                    vertical: Dimensions.mobileProductCardPaddingVertical,
                                                  ),
                                                  child: ProductCardWidget(product: products[index]),
                                                ),
                                              ),
                          ),
                        ),
                ),
              ),

              const SliverToBoxAdapter(
                child: FooterWebWidget(footerType: FooterType.nonSliver),
              ),
              if (!ResponsiveHelper.isDesktop(context))
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: Dimensions.bottomNavBarHeight + MediaQuery.of(context).padding.bottom,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

/// Store category slider: same pill style as home. Selected = red (ColorResources.primary), unselected = gray.
class _StoreCategorySlider extends StatelessWidget {
  const _StoreCategorySlider({
    required this.categories,
    required this.selectedCategoryId,
    required this.onCategoryTap,
    required this.scrollController,
    required this.isDesktop,
  });

  final List<CategoryModel> categories;
  final int? selectedCategoryId;
  final void Function(int? id) onCategoryTap;
  final ScrollController scrollController;
  final bool isDesktop;

  static const double _cardWidth = 112.0;
  static const double _imageSize = 100.0; // Larger image, less border
  /// Vertical padding (4+4) + image + gap + label area for two lines at 12px / height 1.2.
  static const double _labelAreaHeight = 40.0;
  /// Inner pill height (image + label). ListView [padding] top reduces child max height — include it in viewport.
  static const double _listTopPadding = 12.0;
  /// Inset around image: top = start = end; same value used for label horizontal + bottom (see [_StoreCategoryCard]).
  static const double _pillImageInset = 6.0;
  static const double _cardInnerHeight =
      _pillImageInset + _imageSize + 4 + _labelAreaHeight + _pillImageInset;
  static const double _cardHeight = _listTopPadding + _cardInnerHeight;
  static const double _itemSpacing = 8.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(
        horizontal: isDesktop ? 0 : Dimensions.mobileContentPaddingHorizontal,
      ),
      padding: EdgeInsets.fromLTRB(
        isDesktop ? 16 : Dimensions.mobileContentPaddingHorizontal,
        isDesktop ? 14 : 0,
        isDesktop ? 16 : Dimensions.mobileContentPaddingHorizontal,
        isDesktop ? 16 : 6,
      ),
      decoration: BoxDecoration(
        color: isDesktop
            ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.25)
            : Colors.transparent,
        borderRadius: isDesktop ? BorderRadius.circular(16) : BorderRadius.zero,
      ),
      child: SizedBox(
        height: _cardHeight,
        child: CustomSliderListWidget(
          controller: scrollController,
          verticalPosition: _cardHeight * 0.5 - 20,
          horizontalPosition: 0,
          isShowForwardButton: categories.length > 4,
          child: ListView.builder(
            controller: scrollController,
            itemCount: categories.length,
            padding: EdgeInsetsDirectional.only(top: _listTopPadding, start: 4),
            physics: const BouncingScrollPhysics(),
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) {
              final c = categories[index];
              final selected = c.id == selectedCategoryId;
              return Padding(
                padding: const EdgeInsetsDirectional.only(end: _itemSpacing),
                child: _StoreCategoryCard(
                  name: c.name ?? '',
                  imageUrl: c.image ?? '',
                  isSelected: selected,
                  onTap: () => onCategoryTap(c.id),
                  imageSize: _imageSize,
                  cardWidth: _cardWidth,
                  isDesktop: isDesktop,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Single category pill card: selected = red, unselected = gray (from ColorResources).
class _StoreCategoryCard extends StatelessWidget {
  const _StoreCategoryCard({
    required this.name,
    required this.imageUrl,
    required this.isSelected,
    required this.onTap,
    required this.imageSize,
    required this.cardWidth,
    required this.isDesktop,
  });

  final String name;
  final String imageUrl;
  final bool isSelected;
  final VoidCallback onTap;
  final double imageSize;
  final double cardWidth;
  final bool isDesktop;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final greyColor = ColorResources.getGreyColor(context);
    final pillColor = isSelected ? ColorResources.primary : greyColor;
    final textColor = isSelected ? Colors.white : theme.textTheme.bodyMedium?.color ?? Colors.black87;
    final pillRadius = BorderRadius.circular(isDesktop ? 20 : 16);
    final imageRadiusValue = isDesktop ? 14.0 : 12.0;
    const double fontSize = 12.0; // Same on PC and mobile

    return InkWell(
      onTap: onTap,
      borderRadius: pillRadius,
      child: SizedBox(
        width: cardWidth,
        child: Container(
          decoration: BoxDecoration(
            color: pillColor,
            borderRadius: pillRadius,
            border: Border.all(
              color: pillColor,
              width: 1.3,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsetsDirectional.only(
                  start: _StoreCategorySlider._pillImageInset,
                  end: _StoreCategorySlider._pillImageInset,
                  top: _StoreCategorySlider._pillImageInset,
                ),
                child: SizedBox(
                  width: imageSize,
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: Container(
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(imageRadiusValue),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(imageRadiusValue - 2),
                        child: CustomImageWidget(
                          image: imageUrl,
                          placeholder: Images.placeholder(context),
                          width: imageSize,
                          height: imageSize,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsetsDirectional.only(
                  start: _StoreCategorySlider._pillImageInset,
                  end: _StoreCategorySlider._pillImageInset,
                  bottom: _StoreCategorySlider._pillImageInset,
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: _StoreCategorySlider._labelAreaHeight,
                  child: Center(
                    child: Text(
                      name,
                      style: rubikMedium.copyWith(
                        fontSize: fontSize,
                        color: textColor,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
