
import 'package:hexacom_user/features/home/screens/home_screen.dart';
import 'package:hexacom_user/features/store/screens/store_screen.dart';
import 'package:hexacom_user/helper/cart_helper.dart';
import 'package:hexacom_user/helper/network_info_helper.dart';
import 'package:hexacom_user/helper/responsive_helper.dart';
import 'package:hexacom_user/localization/language_constrants.dart';
import 'package:hexacom_user/main.dart';
import 'package:hexacom_user/features/cart/providers/cart_provider.dart';
import 'package:hexacom_user/features/splash/providers/splash_provider.dart';
import 'package:hexacom_user/features/wishlist/providers/wishlist_provider.dart';
import 'package:hexacom_user/common/widgets/custom_pop_scope_widget.dart';
import 'package:hexacom_user/common/widgets/pill_bottom_nav_bar.dart';
import 'package:hexacom_user/features/cart/screens/cart_screen.dart';
import 'package:hexacom_user/features/menu/screens/menu_screen.dart';
import 'package:hexacom_user/features/wishlist/screens/wishlist_screen.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DashboardScreen extends StatefulWidget {
  final int pageIndex;
  final int? initialStoreCategoryId;
  const DashboardScreen({super.key, required this.pageIndex, this.initialStoreCategoryId});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  PageController? _pageController;
  int _pageIndex = 0;

  late List<Widget> _screens;
  final GlobalKey<ScaffoldMessengerState> _scaffoldKey = GlobalKey();


  @override
  void initState() {
    super.initState();

    final splashProvider = Provider.of<SplashProvider>(context, listen: false);

    if(splashProvider.policyModel == null) {
      Provider.of<SplashProvider>(context, listen: false).getPolicyPage();
    }
    // Defer until navigator context exists (avoids null on web during first frame).
    SchedulerBinding.instance.addPostFrameCallback((_) {
      final ctx = Get.context;
      if (ctx != null && ctx.mounted) {
        HomeScreen.loadData(ctx, false);
      }
    });

    _pageIndex = widget.pageIndex;

    _pageController = PageController(initialPage: widget.pageIndex);

    _screens = [
      const HomeScreen(),
      StoreScreen(initialCategoryId: widget.initialStoreCategoryId),
      const CartScreen(),
      const WishListScreen(),
      const MenuScreen(),
    ];

    if(ResponsiveHelper.isMobilePhone()) {
      NetworkInfoHelper.checkConnectivity(_scaffoldKey);
    }
  }

  @override
  void dispose() {
    _pageController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = !ResponsiveHelper.isDesktop(context);

    return CustomPopScopeWidget(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        key: _scaffoldKey,
        floatingActionButton: const SizedBox(),
        bottomNavigationBar: isMobile ? null : const SizedBox(),
        body: isMobile
            ? Stack(
                children: [
                  PageView.builder(
                    controller: _pageController,
                    itemCount: _screens.length,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) => _screens[index],
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: SafeArea(
                      top: false,
                      child: Consumer2<CartProvider, WishListProvider>(
                        builder: (context, cart, wishList, _) => PillBottomNavBar(
                          currentIndex: _pageIndex,
                          onTap: _setPage,
                          items: [
                            PillNavItem(icon: Icons.home_filled, label: getTranslated('home', context)),
                            PillNavItem(icon: Icons.store, label: getTranslated('store', context)),
                            PillNavItem(icon: Icons.shopping_cart, label: getTranslated('cart', context)),
                            PillNavItem(icon: Icons.favorite, label: getTranslated('favourite', context)),
                            PillNavItem(icon: Icons.menu, label: getTranslated('menu', context)),
                          ],
                          cartCount: CartHelper.getCartItemCount(cart.cartList),
                          wishlistCount: wishList.wishList?.length ?? 0,
                        ),
                      ),
                    ),
                  ),
                ],
              )
            : PageView.builder(
                controller: _pageController,
                itemCount: _screens.length,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) => _screens[index],
              ),
      ),
    );
  }

  void _setPage(int pageIndex) {
    final c = _pageController;
    if (c == null) return;
    setState(() => _pageIndex = pageIndex);
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _pageController != c) return;
      if (c.hasClients) {
        c.jumpToPage(pageIndex);
      }
    });
  }
}
