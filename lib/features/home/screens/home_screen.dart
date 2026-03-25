import 'package:hexacom_user/common/enums/footer_type_enum.dart';
import 'package:hexacom_user/common/enums/product_filter_type_enum.dart';
import 'package:hexacom_user/common/widgets/custom_app_bar_widget.dart';
import 'package:hexacom_user/common/widgets/custom_single_child_list_widget.dart';
import 'package:hexacom_user/common/widgets/footer_web_widget.dart';
import 'package:hexacom_user/common/widgets/home_app_bar_widget.dart';
import 'package:hexacom_user/features/auth/providers/auth_provider.dart';
import 'package:hexacom_user/features/category/providers/category_provider.dart';
import 'package:hexacom_user/features/home/enums/banner_type_enum.dart';
import 'package:hexacom_user/features/home/providers/banner_provider.dart';
import 'package:hexacom_user/features/flash_sale/providers/flash_sale_provider.dart';
import 'package:hexacom_user/features/home/widgets/banner_widget.dart';
import 'package:hexacom_user/features/home/widgets/category_widget.dart';
import 'package:hexacom_user/features/home/widgets/feature_category_widget.dart';
import 'package:hexacom_user/features/home/widgets/flash_sale_widget.dart';
import 'package:hexacom_user/features/home/widgets/main_slider_shimmer_widget.dart';
import 'package:hexacom_user/features/home/widgets/main_slider_widget.dart';
import 'package:hexacom_user/features/home/widgets/new_arrival_widget.dart';
import 'package:hexacom_user/features/home/widgets/offer_product_widget.dart';
import 'package:hexacom_user/features/home/widgets/category_products_section_widget.dart';
import 'package:hexacom_user/features/menu/widgets/options_widget.dart';
import 'package:hexacom_user/features/product/providers/product_provider.dart';
import 'package:hexacom_user/features/profile/providers/profile_provider.dart';
import 'package:hexacom_user/features/splash/providers/splash_provider.dart';
import 'package:hexacom_user/features/wishlist/providers/wishlist_provider.dart';
import 'package:hexacom_user/helper/responsive_helper.dart';
import 'package:hexacom_user/utill/dimensions.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();

  static Future<void> loadData(BuildContext context, bool reload) async {
    final categoryProvider = Provider.of<CategoryProvider>(context, listen: false);
    final bannerProvider = Provider.of<BannerProvider>(context, listen: false);
    final productProvider = Provider.of<ProductProvider>(context, listen: false);
    final splashProvider = Provider.of<SplashProvider>(context, listen: false);
    final wishListProvider = Provider.of<WishListProvider>(context, listen: false);
    final flashSaleProvider = Provider.of<FlashSaleProvider>(context, listen: false);
    final profileProvider = Provider.of<ProfileProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    productProvider.getLatestProductList(1, isUpdate: reload);

    final futures = <Future>[
      categoryProvider.getFeatureCategories(reload, isUpdate: reload),
      categoryProvider.getPopularCategories(false),
      categoryProvider.getCategoryList(reload),
      bannerProvider.getBannerList(reload),
      productProvider.getOfferProductList(reload),
      flashSaleProvider.getFlashSaleProducts(1, reload),
      productProvider.getNewArrivalProducts(1, reload),
      splashProvider.getPolicyPage(reload: reload),
    ];

    if (reload) {
      futures.add(splashProvider.initConfig());
      futures.add(splashProvider.getDeliveryInfo());
    }

    if (authProvider.isLoggedIn()) {
      if (profileProvider.userInfoModel == null || reload) {
        futures.add(profileProvider.getUserInfo());
      }
      futures.add(wishListProvider.getWishList());
    }

    await Future.wait(futures);
  }


}

class _HomeScreenState extends State<HomeScreen> with AutomaticKeepAliveClientMixin {
  final GlobalKey<ScaffoldState> drawerGlobalKey = GlobalKey();
  ProductFilterType? filterType;
  final ScrollController scrollController = ScrollController();
  final ScrollController newArrivalScrollController = ScrollController();
  static const double _headerScrollThreshold = 50.0;
  late final ValueNotifier<bool> _headerScrolled;

  @override
  void initState() {
    super.initState();
    _headerScrolled = ValueNotifier(false);
    scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final scrolled = scrollController.offset > _headerScrollThreshold;
    if (_headerScrolled.value != scrolled) _headerScrolled.value = scrolled;
  }

  @override
  void dispose() {
    scrollController.removeListener(_onScroll);
    scrollController.dispose();
    newArrivalScrollController.dispose();
    _headerScrolled.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return SafeArea(
      child: Scaffold(
        key: drawerGlobalKey,
        endDrawerEnableOpenDragGesture: false,
        drawer: ResponsiveHelper.isTab(context) ? const Drawer(child: OptionsWidget(onTap: null)) : const SizedBox(),
        appBar: const CustomAppBarWidget(onlyDesktop: true, space: 0),

        body: RefreshIndicator(
          color: Colors.white,
          onRefresh: () async {
            filterType = null;
            Provider.of<ProductProvider>(context, listen: false).offset = 1;
            await HomeScreen.loadData(context, true);
          },
          backgroundColor: const Color(0xFF3A4756),
          child: CustomScrollView(
            controller: scrollController,
            slivers: [
              // App Bar (mobile: logo + search pill + coupon icon)
              ResponsiveHelper.isDesktop(context) ? const SliverToBoxAdapter(child: SizedBox()) : HomeAppBarWidget(drawerGlobalKey: drawerGlobalKey, headerScrolled: _headerScrolled),

              SliverToBoxAdapter(
                child: Column(
                  children: [
                    Center(child: SizedBox(
                      width: ResponsiveHelper.isDesktop(context) ? Dimensions.getWebContentWidth(MediaQuery.sizeOf(context).width) : MediaQuery.sizeOf(context).width,
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                        ResponsiveHelper.isDesktop(context) ? Padding(
                          padding: const EdgeInsets.only(top: Dimensions.paddingSizeDefault),
                          child: Consumer<BannerProvider>(
                            builder: (context, bannerProvider, _) {
                              if (bannerProvider.bannerList == null) {
                                return const MainSliderShimmerWidget();
                              }
                              if (bannerProvider.bannerList!.isEmpty) {
                                return const SizedBox();
                              }
                             
                              return SizedBox(
                                height: 420,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    Expanded(
                                      child: MainSliderWidget(
                                        bannerList: bannerProvider.bannerList,
                                        bannerType: BannerType.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }
                          ),
                        ) : const SizedBox(),
                        
                        /// Banner (mobile)
                        ResponsiveHelper.isDesktop(context)
                            ? const SizedBox()
                            : Padding(
                                padding: EdgeInsets.only(
                                  top: ResponsiveHelper.isDesktop(context)
                                      ? Dimensions.paddingSizeDefault
                                      : Dimensions.mobileHomeSectionGap,
                                ),
                                child: Consumer<BannerProvider>(
                                  builder: (context, banner, child) {
                                    return banner.bannerList == null
                                        ? const BannerWidget()
                                        : banner.bannerList!.isEmpty
                                            ? const SizedBox()
                                            : const BannerWidget();
                                  },
                                ),
                              ),

                        // Slightly tighter gap between banner and categories on mobile
                        if (!ResponsiveHelper.isDesktop(context))
                          const SizedBox(height: 8),
                        const CategoryWidget(),

                        if (!ResponsiveHelper.isDesktop(context))
                          const SizedBox(height: Dimensions.mobileHomeSectionGap),
                        const FlashSaleWidget(),

                        /// Offer Product
                        Consumer<ProductProvider>(
                          builder: (context, offerProduct, child) {
                            if (offerProduct.offerProductList == null ||
                                offerProduct.offerProductList!.isEmpty) {
                              return const SizedBox();
                            }
                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (!ResponsiveHelper.isDesktop(context))
                                  const SizedBox(height: 8),
                                const OfferProductWidget(),
                              ],
                            );
                          },
                        ),

                        if (!ResponsiveHelper.isDesktop(context))
                          const SizedBox(height: 8),
                        /// Campaign (mobile)
                        if (!ResponsiveHelper.isDesktop(context))
                          Consumer<BannerProvider>(
                            builder: (context, bannerProvider, _) {
                              return MainSliderWidget(
                                bannerType: BannerType.secondary,
                                bannerList: bannerProvider.secondaryBannerList,
                              );
                            },
                          ),

                        if (!ResponsiveHelper.isDesktop(context))
                          const SizedBox(height: 8),
                        const NewArrivalWidget(),

                        if (!ResponsiveHelper.isDesktop(context))
                          const SizedBox(height: 8),
                        const SizedBox(height: Dimensions.mobileHomeSectionGap),
                        Consumer<CategoryProvider>(builder: (context, categoryProvider, _) {
                          return categoryProvider.featureCategoryMode != null
                              ? CustomSingleChildListWidget(
                                  itemCount: categoryProvider.featureCategoryMode?.featuredData?.length ?? 0,
                                  itemBuilder: (index) => Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: FeatureCategoryWidget(
                                      featuredCategory: categoryProvider.featureCategoryMode!.featuredData?[index],
                                    ),
                                  ),
                                )
                              : const SizedBox();
                        }),

                        const CategoryProductsSectionWidget(),

                      ]),
                    )),

                  ],
                ),
              ),

              const FooterWebWidget(footerType: FooterType.sliver),
              if (!ResponsiveHelper.isDesktop(context))
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: Dimensions.bottomNavBarHeight + MediaQuery.of(context).padding.bottom,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}


