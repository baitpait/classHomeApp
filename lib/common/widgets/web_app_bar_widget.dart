
import 'package:hexacom_user/common/enums/popup_menu_type_enum.dart';
import 'package:hexacom_user/common/widgets/custom_debounce_widget.dart';
import 'package:hexacom_user/features/auth/domain/enums/from_page_enum.dart';
import 'package:hexacom_user/features/search/widgets/search_overlay_widget.dart';
import 'package:hexacom_user/helper/cart_helper.dart';
import 'package:hexacom_user/helper/user_avatar_image_url.dart';
import 'package:hexacom_user/features/profile/providers/profile_provider.dart';
import 'package:hexacom_user/provider/theme_provider.dart';
import 'package:hexacom_user/features/wishlist/providers/wishlist_provider.dart';
import 'package:hexacom_user/common/widgets/custom_image_widget.dart';
import 'package:hexacom_user/common/widgets/on_hover.dart';
import 'package:hexacom_user/common/widgets/profile_hover_widget.dart';
import 'package:hexacom_user/common/widgets/theme_switch_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../models/language_model.dart';
import '../../localization/language_constrants.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/cart/providers/cart_provider.dart';
import '../../provider/language_provider.dart';
import '../../provider/localization_provider.dart';
import '../../features/product/providers/product_provider.dart';
import '../../features/search/providers/search_provider.dart';
import '../../features/splash/providers/splash_provider.dart';
import '../../utill/app_constants.dart';
import '../../utill/color_resources.dart';
import '../../utill/dimensions.dart';
import '../../utill/images.dart';
import '../../utill/routes.dart';
import '../../utill/styles.dart';
import 'custom_text_field_widget.dart';
import 'text_hover_widget.dart';
import 'language_hover_widget.dart';

class WebAppBarWidget extends StatefulWidget implements PreferredSizeWidget {
  const WebAppBarWidget({super.key});


  @override
  State<WebAppBarWidget> createState() => _WebAppBarWidgetState();

  @override
  Size get preferredSize => throw UnimplementedError();
}

class _WebAppBarWidgetState extends State<WebAppBarWidget> {
  String? chooseLanguage;
  final GlobalKey _searchBarKey = GlobalKey();
  final FocusNode _searchFocusNode = FocusNode();
  final CustomDebounceWidget debounceWidget = CustomDebounceWidget(milliseconds: 500);

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Provider.of<LanguageProvider>(context, listen: false).initializeAllLanguages(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final SplashProvider splashProvider = Provider.of<SplashProvider>(context, listen: false);
    final searchProvider = Provider.of<SearchProvider>(context, listen: false);
    if (searchProvider.searchController.text.isNotEmpty) {
      searchProvider.getSuggestionList(searchProvider.searchController.text, isUpdate: false);
    }

    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        return Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.10),
                blurRadius: 20,
                offset: const Offset(0,10),
              )
            ],
          ),
          child: Column(children: [

            Container(
              color: ColorResources.navBarNavy,
              height: 34,
              child: Center(
                child: DefaultTextStyle(
                  style: rubikMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: Colors.white, fontFamily: Theme.of(context).textTheme.bodyMedium?.fontFamily),
                  child: IconTheme(
                    data: const IconThemeData(color: Colors.white, size: Dimensions.paddingSizeLarge),
                    child: SizedBox(
                      width: Dimensions.getWebContentWidth(MediaQuery.sizeOf(context).width),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraSmall),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Consumer<SplashProvider>(
                              builder: (context, splash, _) {
                                final links = splash.configModel?.socialMediaLink;
                                if (links == null || links.isEmpty) return const SizedBox.shrink();
                                return Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: links.map((link) => Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 2.0),
                                    child: InkWell(
                                      onTap: () async {
                                        if (await canLaunchUrlString(link.link!)) {
                                          await launchUrlString(link.link!);
                                        }
                                      },
                                      borderRadius: BorderRadius.circular(4),
                                      child: Padding(
                                        padding: const EdgeInsets.all(2.0),
                                        child: Image.asset(
                                          Images.getSocialImage(link.name!),
                                          height: 26,
                                          width: 26,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  )).toList(),
                                );
                              },
                            ),
                            Row(mainAxisSize: MainAxisSize.min, children: [
                            const ThemeSwitchButtonWidget(),
                            const SizedBox(width: Dimensions.paddingSizeLarge),
                            Selector<LocalizationProvider, String>(
                              selector: (context, localizationProvider) => localizationProvider.locale.languageCode,
                              builder: (context, languageCode, child) {
                                return SizedBox(
                                  height: Dimensions.paddingSizeLarge,
                                  child: MouseRegion(
                                    onHover: (details) => _showPopupMenu(details.position, context, PopupMenuType.language),
                                    child: Row(
                                      children: [
                                        Text(languageCode.toUpperCase()),
                                        const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                                        const Icon(Icons.expand_more),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(width: Dimensions.paddingSizeExtraLarge),
                            ]),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            Expanded(child: Container(color: Theme.of(context).cardColor, child: Center(child: SizedBox(
              width: Dimensions.getWebContentWidth(MediaQuery.sizeOf(context).width),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Left: logo + main nav
                  Row(children: [
                    InkWell(
                      onTap: () {
                        Provider.of<ProductProvider>(context, listen: false).offset = 1;
                        RouteHelper.getMainRoute(context);
                      },
                      child: Consumer<SplashProvider>(builder:(context, splash, child) => SizedBox(
                            height: 50, width: 50,
                            child: CustomImageWidget(
                              placeholder: Images.placeholder(context),
                              image: (splash.baseUrls != null && (splash.configModel?.appLogo ?? '').isNotEmpty)
                                  ? '${splash.baseUrls!.ecommerceImageUrl}/${splash.configModel!.appLogo}'
                                  : '',
                              fit: BoxFit.contain,
                            ),
                          )),
                    ),
                    const SizedBox(width: 24),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _NavIconText(
                            icon: Icons.home_filled,
                            label: getTranslated('home', context),
                            count: 0,
                            onTap: () {
                              Provider.of<ProductProvider>(context, listen: false).offset = 1;
                              RouteHelper.getDashboardRoute(context, 'home');
                            },
                          ),
                          const SizedBox(width: 16),
                          _NavIconText(
                            icon: Icons.store,
                            label: getTranslated('store', context),
                            count: 0,
                            onTap: () => RouteHelper.getDashboardRoute(context, 'store'),
                          ),
                        ],
                      ),
                    ),
                  ]),

                  // Center: expanded search bar (keeps it visually centered)
                  Expanded(
                    child: Align(
                      alignment: Alignment.center,
                      child: TextHoverWidget(builder: (isHover)=> Container(
                        key: _searchBarKey,
                        width: 480,
                        height: 41,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(Dimensions.paddingSizeLarge),
                        ),
                        child: Consumer<SearchProvider>(builder: (context, search,_)=> Container(
                          decoration: BoxDecoration(
                              border: Border.all(color: Theme.of(context).primaryColor.withValues(alpha: 0.07), width: 1),
                              borderRadius: BorderRadius.circular(Dimensions.paddingSizeLarge)
                          ),
                          child: CustomTextFieldWidget(
                            contentPadding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall, horizontal: Dimensions.paddingSizeSmall),
                            hintText: getTranslated('search_items_here', context),
                            hintFontSize: Dimensions.fontSizeSmall,
                            fillColor: Colors.transparent,
                            isShowSuffixIcon: true,
                            isSearch: true,
                            isIcon: true,
                            suffixAssetUrl: search.isSearch ? Images.search : Images.close,

                            onSuffixTap: () {
                              if(search.searchController.text.isNotEmpty && search.isSearch == true){
                                Provider.of<SearchProvider>(context,listen: false).saveSearchAddress(search.searchController.text);
                                RouteHelper.getSearchResultRoute(context, text: search.searchController.text);

                                search.changeSearchStatus();

                              }
                              else if (search.searchController.text.isNotEmpty && search.isSearch == false) {
                                search.searchController.clear();

                                search.changeSearchStatus();
                              }
                            },
                            controller: search.searchController,
                            focusNode: _searchFocusNode,
                            inputAction: TextInputAction.search,
                            onChanged: (text) {
                              debounceWidget.run(() {
                                Provider.of<SearchProvider>(context, listen: false).getSuggestionList(text);
                              });
                            },
                            onSubmit: (text) {
                              if (search.searchController.text.isNotEmpty) {
                                Provider.of<SearchProvider>(context,listen: false).saveSearchAddress(search.searchController.text);
                                RouteHelper.getSearchResultRoute(context, text: search.searchController.text);

                                search.changeSearchStatus();
                              }

                            },
                            onTap: _showSearchDialog,
                          ),
                        )),

                      )),
                    ),
                  ),

                  const SizedBox(width: Dimensions.paddingSizeLarge),

                  // Right: icons cluster: favourite, cart, notifications, account (tight group)
                  Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Consumer<WishListProvider>(
                          builder: (context, wishListProvider, _) {
                            final count = wishListProvider.wishList?.length ?? 0;
                            return _IconBadgeButton(
                              icon: Icons.favorite_outline_rounded,
                              count: count,
                              onTap: () => RouteHelper.getDashboardRoute(context, 'favourite'),
                            );
                          },
                        ),
                        const SizedBox(width: 12),
                        Consumer<CartProvider>(
                          builder: (context, cartProvider, _) {
                            final count = CartHelper.getCartItemCount(cartProvider.cartList);
                            return _IconBadgeButton(
                              icon: Icons.shopping_cart_outlined,
                              count: count,
                              onTap: () => RouteHelper.getDashboardRoute(context, 'cart', action: RouteAction.push),
                            );
                          },
                        ),
                        const SizedBox(width: 12),
                        OnHover(
                          child: InkWell(
                            onTap: () => RouteHelper.getNotificationRoute(context, action: RouteAction.push),
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              height: 40,
                              width: 40,
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.secondary,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.notifications_none_rounded,
                                  color: Theme.of(context).colorScheme.onSecondary,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Consumer2<AuthProvider, ProfileProvider>(
                          builder: (context, authProvider, profileProvider, _) {
                            final isLoggedIn = authProvider.isLoggedIn();
                            final resolved = UserAvatarImageUrl.resolve(
                              isLoggedIn: isLoggedIn,
                              userImage: profileProvider.userInfoModel?.image,
                              customerImageUrl: splashProvider.baseUrls?.customerImageUrl,
                              appLogo: splashProvider.configModel?.appLogo,
                              ecommerceImageUrl: splashProvider.baseUrls?.ecommerceImageUrl,
                            );
                            final imageStr = resolved ??
                                (isLoggedIn
                                    ? '${splashProvider.baseUrls?.customerImageUrl ?? ''}/${profileProvider.userInfoModel?.image ?? ''}'
                                    : '');
                            final showAvatar = imageStr.isNotEmpty;
                            return MouseRegion(
                              onHover: isLoggedIn
                                  ? (e) => _showPopupMenu(e.position, context, PopupMenuType.profile)
                                  : null,
                              child: InkWell(
                                onTap: !isLoggedIn
                                    ? () => RouteHelper.getLoginRoute(context, FromPage.mainRoute.name)
                                    : null,
                                borderRadius: BorderRadius.circular(20),
                                child: Container(
                                  height: 40,
                                  width: 40,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Theme.of(context).primaryColor.withValues(alpha: 0.4),
                                      width: 1,
                                    ),
                                  ),
                                  child: showAvatar
                                      ? ClipRRect(
                                          borderRadius: BorderRadius.circular(20),
                                          child: CustomImageWidget(
                                            image: imageStr,
                                            placeholder: Images.profile,
                                            placeholderColor: Theme.of(context).primaryColor,
                                            height: 40,
                                            width: 40,
                                          ),
                                        )
                                      : Icon(
                                          Icons.person_outline_rounded,
                                          color: Theme.of(context).primaryColor,
                                          size: 22,
                                        ),
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(width: 12),
                        OnHover(
                          child: IconButton(
                            onPressed: () => RouteHelper.getDashboardRoute(context, 'menu', action: RouteAction.push),
                            icon: Icon(Icons.menu_rounded, size: Dimensions.paddingSizeExtraLarge, color: Theme.of(context).primaryColor),
                          ),
                        ),
                      ],
                    ),
                  ],
              ),
            )))),
          ]),
        );
      }
    );
  }

  Size get preferredSize => const Size(double.maxFinite, 160);


  List<PopupMenuEntry<Object>> _popUpLanguageList(BuildContext context) {
    List<PopupMenuEntry<Object>> languagePopupMenuEntryList = <PopupMenuEntry<Object>>[];
    List<LanguageModel> languageList =  AppConstants.languages;
    languagePopupMenuEntryList.add(
        PopupMenuItem(
          padding: EdgeInsets.zero,
          value: languageList,
          child: MouseRegion(
            onExit: (_)=> Navigator.of(context).pop(),
            child: LanguageHoverWidget(languageList: languageList),
          ),
        ));
    return languagePopupMenuEntryList;
  }

  List<PopupMenuEntry<Object>> _profilePopUpMenuList(BuildContext context) {
    List<PopupMenuEntry<Object>> profilePopupMenuEntryList = <PopupMenuEntry<Object>>[];
    profilePopupMenuEntryList.add(
        const PopupMenuItem(
          padding: EdgeInsets.zero,
          child: MouseRegion(
            child: ProfileHoverWidget(),
          ),
        ));
    return profilePopupMenuEntryList;
  }


  List<PopupMenuEntry<Object>> _getPopupItems(PopupMenuType type){
    switch (type) {
      case PopupMenuType.language:
        return _popUpLanguageList(context);
      case PopupMenuType.category:
        return [];
      case PopupMenuType.profile:
        return _profilePopUpMenuList(context);
    }
  }

  void _showPopupMenu(Offset offset, BuildContext context, PopupMenuType type) async {
    double left = offset.dx;
    double top = offset.dy;

    final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;

    await showMenu(
      context: context,
      position: RelativeRect.fromLTRB(left, top, overlay.size.width, overlay.size.height),
      items: _getPopupItems(type),
      elevation: 8.0,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),

    );
  }

  Future<void> _showSearchDialog() async {
    RenderBox renderBox = _searchBarKey.currentContext!.findRenderObject() as RenderBox;
    final searchBarPosition = renderBox.localToGlobal(Offset.zero);

    await showDialog(
      context: context,
      barrierColor: Colors.transparent,
      builder: (context) => GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => Navigator.of(context).pop(),
        child: Stack(
          children: [
            Positioned(
              top: searchBarPosition.dy + renderBox.size.height + 8,
              left: searchBarPosition.dx,
              width: renderBox.size.width,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {},
                child: Material(
                  color: Colors.transparent,
                  elevation: 0,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.7),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context).textTheme.bodyLarge!.color!.withValues(alpha: 0.05),
                          offset: const Offset(0, 5),
                          spreadRadius: 0,
                          blurRadius: 15,
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeLarge, horizontal: 30),
                    child: SearchOverlayWidget(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );

    if (mounted) {
      _searchFocusNode.requestFocus();
    }

  }
}

class _NavIconText extends StatelessWidget {
  final IconData icon;
  final String label;
  final int count;
  final VoidCallback onTap;

  const _NavIconText({
    required this.icon,
    required this.label,
    required this.onTap,
    this.count = 0,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? Colors.white : Colors.black87;

    return TextHoverWidget(
      builder: (isHover) => OnHover(
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Icon(
                      icon,
                      size: Dimensions.paddingSizeExtraLarge,
                      color: isHover ? Theme.of(context).primaryColor : baseColor,
                    ),
                    if (count > 0)
                    Positioned(
                      top: -8,
                      right: -8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Theme.of(context).colorScheme.secondary,
                          border: Border.all(color: Theme.of(context).cardColor, width: 1),
                        ),
                        child: Text(
                          '$count',
                          style: rubikRegular.copyWith(
                            color: Theme.of(context).colorScheme.onSecondary,
                            fontSize: Dimensions.fontSizeExtraSmall,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: rubikMedium.copyWith(
                    fontSize: Dimensions.fontSizeDefault,
                    color: isHover ? Theme.of(context).primaryColor : baseColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _IconBadgeButton extends StatelessWidget {
  final IconData icon;
  final int count;
  final VoidCallback onTap;

  const _IconBadgeButton({
    required this.icon,
    required this.onTap,
    this.count = 0,
  });

  @override
  Widget build(BuildContext context) {
    return OnHover(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).cardColor,
                border: Border.all(
                  color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
                  width: 1,
                ),
              ),
              child: Icon(
                icon,
                size: 20,
                color: Theme.of(context).primaryColor,
              ),
            ),
            if (count > 0)
              Positioned(
                top: -4,
                right: -4,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Theme.of(context).colorScheme.secondary,
                    border: Border.all(color: Theme.of(context).cardColor, width: 1),
                  ),
                  child: Text(
                    '$count',
                    style: rubikRegular.copyWith(
                      color: Theme.of(context).colorScheme.onSecondary,
                      fontSize: Dimensions.fontSizeExtraSmall,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

