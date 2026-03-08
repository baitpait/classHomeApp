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

class _StoreScreenState extends State<StoreScreen> {
  final GlobalKey<ScaffoldState> _drawerKey = GlobalKey();
  int? _selectedCategoryId;
  int _selectedSubIndex = 0;
  static const double _headerScrollThreshold = 50.0;
  final ScrollController _scrollController = ScrollController();
  final ScrollController _categoryScrollController = ScrollController();
  late final ValueNotifier<bool> _headerScrolled;

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
    final initialId = widget.initialCategoryId;
    final int? idToSelect = (initialId != null && list.any((c) => c.id == initialId))
        ? initialId
        : list.first.id;
    if (_selectedCategoryId == null && idToSelect != null) {
      setState(() => _selectedCategoryId = idToSelect);
      cp.selectCategoryById(idToSelect);
      await cp.getSubCategoryList(idToSelect);
      cp.getCategoryProductList(idToSelect);
    }
  }

  void _onCategoryTap(int? id) {
    if (id == null) return;
    setState(() {
      _selectedCategoryId = id;
      _selectedSubIndex = 0;
    });
    final cp = context.read<CategoryProvider>();
    cp.selectCategoryById(id);
    cp.getSubCategoryList(id);
    cp.getCategoryProductList(id);
  }

  void _onSubCategoryTap(int index) {
    setState(() => _selectedSubIndex = index);
    final cp = context.read<CategoryProvider>();
    final subs = cp.subCategoryList;
    final categoryId = _selectedCategoryId;
    if (categoryId == null) return;
    if (index == 0) {
      cp.getCategoryProductList(categoryId);
    } else if (subs != null && index <= subs.length) {
      cp.getCategoryProductList(subs[index - 1].id);
    }
  }

  @override
  Widget build(BuildContext context) {
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
          final categories = category.categoryList;
          final subs = category.subCategoryList;
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

                      // Subcategories Section (desktop: gap below divider = 8, same as gap above line)
                      if (_selectedCategoryId != null && subs != null && subs.isNotEmpty) ...[
                        SizedBox(height: isDesktop ? 6 : 8),
                        SizedBox(
                          height: isDesktop ? 44 : 38,
                          child: ListView.separated(
                            padding: EdgeInsets.symmetric(
                              horizontal: isDesktop ? 14 : 10,
                              vertical: isDesktop ? 0 : 0,
                            ),
                            scrollDirection: Axis.horizontal,
                            itemCount: subs.length + 1,
                            separatorBuilder: (_, __) => SizedBox(width: isDesktop ? 8 : 6),
                            itemBuilder: (context, i) {
                              final isAll = i == 0;
                              final selected = _selectedSubIndex == i;
                              final label = isAll ? getTranslated('all', context) : (subs[i - 1].name ?? '');
                              return _SubCategoryChip(
                                label: label,
                                isSelected: selected,
                                onTap: () => _onSubCategoryTap(i),
                                isDesktop: isDesktop,
                              );
                            },
                          ),
                        ),
                        SizedBox(height: isDesktop ? 2 : 10),
                      ],

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
                                          itemBuilder: (context, index) => ProductShimmerWidget(isEnabled: true, isWeb: true),
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
                                              itemCount: products.length,
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
                                        itemBuilder: (context, index) => const ProductShimmerWidget(
                                          isEnabled: true,
                                          isWeb: false,
                                        ),
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
                                                itemCount: products.length,
                                                itemBuilder: (context, index) => ProductCardWidget(product: products[index]),
                                              )
                                            // Mobile: masonry layout (2 columns)
                                            : MasonryGridView.count(
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
  static const double _cardHeight = 8 + _imageSize + 4 + 30;
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
            padding: const EdgeInsetsDirectional.only(top: 12, start: 4),
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
          padding: const EdgeInsetsDirectional.symmetric(horizontal: 6, vertical: 4),
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
              SizedBox(
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
              const SizedBox(height: 4),
              SizedBox(
                width: double.infinity,
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
            ],
          ),
        ),
      ),
    );
  }
}

class _SubCategoryChip extends StatefulWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isDesktop;

  const _SubCategoryChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.isDesktop,
  });

  @override
  State<_SubCategoryChip> createState() => _SubCategoryChipState();
}

class _SubCategoryChipState extends State<_SubCategoryChip> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(12),
        hoverColor: Colors.transparent,
        splashColor: Theme.of(context).primaryColor.withValues(alpha: 0.1),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          padding: EdgeInsets.symmetric(
            horizontal: widget.isDesktop ? 18 : 14,
            vertical: widget.isDesktop ? 10 : 8,
          ),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? Theme.of(context).primaryColor
                : (_hovered 
                    ? Theme.of(context).primaryColor.withValues(alpha: 0.1)
                    : Theme.of(context).cardColor.withValues(alpha: 0.5)),
            border: Border.all(
              color: widget.isSelected
                  ? Theme.of(context).primaryColor
                  : (_hovered
                      ? Theme.of(context).primaryColor.withValues(alpha: 0.3)
                      : Theme.of(context).dividerColor.withValues(alpha: 0.25)),
              width: widget.isSelected ? 2 : 1.5,
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: widget.isSelected ? [
              BoxShadow(
                color: Theme.of(context).primaryColor.withValues(alpha: 0.2),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ] : (_hovered ? [
              BoxShadow(
                color: Theme.of(context).primaryColor.withValues(alpha: 0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ] : []),
          ),
          alignment: Alignment.center,
          child: Text(
            widget.label.length >= 25 
                ? '${widget.label.substring(0, 22)}...' 
                : widget.label,
            style: rubikMedium.copyWith(
              fontSize: widget.isDesktop ? 13 : 11,
              color: widget.isSelected 
                  ? Colors.white 
                  : (_hovered
                      ? Theme.of(context).primaryColor
                      : Theme.of(context).textTheme.bodyMedium?.color),
              fontWeight: widget.isSelected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
