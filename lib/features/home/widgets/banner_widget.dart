import 'dart:async';
import 'package:hexacom_user/helper/product_helper.dart';
import 'package:hexacom_user/helper/responsive_helper.dart';
import 'package:hexacom_user/localization/language_constrants.dart';
import 'package:hexacom_user/features/home/providers/banner_provider.dart';
import 'package:hexacom_user/features/splash/providers/splash_provider.dart';
import 'package:hexacom_user/utill/dimensions.dart';
import 'package:hexacom_user/utill/images.dart';
import 'package:hexacom_user/common/widgets/custom_image_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

class BannerWidget extends StatefulWidget {
  const BannerWidget({super.key});

  static const double mobileRadius = 14.0;
  static const double desktopRadius = 10.0;

  @override
  State<BannerWidget> createState() => _BannerWidgetState();
}

class _BannerWidgetState extends State<BannerWidget> {
  // Keep banner image at a fixed aspect ratio (width / height).
  static const double _heroAspectRatio = 16 / 7;

  late PageController _pageController;
  double _pageOffset = 0.0;
  int _currentIndex = 0;
  Timer? _autoPlayTimer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 1.0);
    _pageController.addListener(_onPageChanged);
  }

  void _onPageChanged() {
    if (_pageController.hasClients && _pageController.position.hasContentDimensions) {
      setState(() => _pageOffset = _pageController.page ?? 0.0);
    }
  }

  void _startAutoPlay(int itemCount) {
    _autoPlayTimer?.cancel();
    if (itemCount <= 1) return;
    _autoPlayTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!_pageController.hasClients) return;
      final next = (_currentIndex + 1) % itemCount;
      _pageController.animateToPage(
        next,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOutCubic,
      );
    });
  }

  @override
  void dispose() {
    _autoPlayTimer?.cancel();
    _pageController.removeListener(_onPageChanged);
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isMobile = !ResponsiveHelper.isDesktop(context);
    final contentWidth = isMobile ? width - 2 * Dimensions.mobileContentPaddingHorizontal : width;
    final heroHeight = contentWidth / _heroAspectRatio;

    return SizedBox(
      height: heroHeight,
      width: width,
      child: Consumer<BannerProvider>(
        builder: (context, banner, child) {
          if (banner.bannerList == null) {
            return BannerShimmer(isMobile: isMobile);
          }
          if (banner.bannerList!.isEmpty) {
            return Center(child: Text(getTranslated('no_banner_available', context)));
          }

          final list = banner.bannerList!;
          if (_autoPlayTimer == null || !_autoPlayTimer!.isActive) {
            WidgetsBinding.instance.addPostFrameCallback((_) => _startAutoPlay(list.length));
          }

          Widget content = Stack(
            alignment: Alignment.bottomCenter,
            children: [
              SizedBox(
                height: heroHeight,
                width: contentWidth,
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: list.length,
                  onPageChanged: (i) => setState(() => _currentIndex = i),
                  itemBuilder: (context, index) {
                    final delta = (_pageOffset - index).abs();
                    final opacity = (1.0 - delta.clamp(0.0, 1.0)).clamp(0.0, 1.0);
                    return Opacity(
                      opacity: opacity,
                      child: InkWell(
                        onTap: () => ProductHelper.onTapBannerForRoute(list[index], context),
                        child: CustomImageWidget(
                          placeholder: Images.placeholder(context),
                          image: '${Provider.of<SplashProvider>(context, listen: false).baseUrls!.bannerImageUrl}/${list[index].image}',
                          width: contentWidth,
                          height: heroHeight,
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  },
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Colors.black.withValues(alpha: 0.35)],
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 14,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ...List.generate(list.length, (i) {
                    final isActive = i == _currentIndex;
                    return GestureDetector(
                      onTap: () {
                        _pageController.animateToPage(
                          i,
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeOutCubic,
                        );
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        height: 8,
                        width: isActive ? 24 : 8,
                        decoration: BoxDecoration(
                          color: isActive ? Colors.white : Colors.white.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(4),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                  ],
                ),
              ),
            ],
          );

          if (isMobile) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: Dimensions.mobileHomePaddingHorizontal),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    height: heroHeight,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(BannerWidget.mobileRadius),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context).shadowColor.withValues(alpha: 0.12),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(BannerWidget.mobileRadius),
                      child: content,
                    ),
                  ),
                ],
              ),
            );
          }

          return ClipRRect(
            borderRadius: BorderRadius.circular(BannerWidget.desktopRadius),
            child: content,
          );
        },
      ),
    );
  }
}

class BannerShimmer extends StatelessWidget {
  const BannerShimmer({super.key, this.isMobile = false});

  final bool isMobile;

  @override
  Widget build(BuildContext context) {
    final width = ResponsiveHelper.isDesktop(context)
        ? 320.0
        : (MediaQuery.sizeOf(context).width - 2 * Dimensions.mobileContentPaddingHorizontal);
    // Match the same aspect ratio used in [BannerWidget].
    final height = width / _BannerWidgetState._heroAspectRatio;
    final radius = isMobile ? BannerWidget.mobileRadius : BannerWidget.desktopRadius;

    Widget child = Shimmer(
      duration: const Duration(seconds: 2),
      enabled: Provider.of<BannerProvider>(context).bannerList == null,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Theme.of(context).shadowColor.withValues(alpha: 0.25),
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );

    if (isMobile) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: Dimensions.mobileHomePaddingHorizontal),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(BannerWidget.mobileRadius),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).shadowColor.withValues(alpha: 0.12),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(BannerWidget.mobileRadius),
            child: child,
          ),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(BannerWidget.desktopRadius),
      child: child,
    );
  }
}
