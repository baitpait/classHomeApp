import 'dart:async';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:hexacom_user/features/home/domain/models/banner_model.dart';
import 'package:hexacom_user/features/home/enums/banner_type_enum.dart';
import 'package:hexacom_user/features/home/widgets/main_slider_shimmer_widget.dart';
import 'package:hexacom_user/helper/product_helper.dart';
import 'package:hexacom_user/helper/responsive_helper.dart';
import 'package:hexacom_user/features/splash/providers/splash_provider.dart';
import 'package:hexacom_user/utill/dimensions.dart';
import 'package:hexacom_user/utill/images.dart';
import 'package:hexacom_user/utill/styles.dart';
import 'package:hexacom_user/common/widgets/custom_image_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MainSliderWidget extends StatefulWidget {
  final List<BannerModel>? bannerList;
  final BannerType bannerType;
  final bool isMainOnly;
  const MainSliderWidget({super.key, required this.bannerList, required this.bannerType, this.isMainOnly = false});

  @override
  State<MainSliderWidget> createState() => _MainSliderWidgetState();
}

class _MainSliderWidgetState extends State<MainSliderWidget> {
  int currentIndex = 0;
  late PageController _pageController;
  final CarouselSliderController _carouselController = CarouselSliderController();
  double _pageOffset = 0.0;
  Timer? _autoPlayTimer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 1.0);
    _pageController.addListener(_onPageChanged);
    _startAutoPlay();
  }

  void _startAutoPlay() {
    _autoPlayTimer?.cancel();
    if (widget.bannerList == null || widget.bannerList!.length <= 1) return;
    _autoPlayTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!_pageController.hasClients) return;
      final next = (currentIndex + 1) % widget.bannerList!.length;
      _pageController.animateToPage(
        next,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOutCubic,
      );
    });
  }

  void _onPageChanged() {
    if (_pageController.hasClients && _pageController.position.hasContentDimensions) {
      setState(() => _pageOffset = _pageController.page ?? 0.0);
    }
  }

  @override
  void dispose() {
    _autoPlayTimer?.cancel();
    _pageController.removeListener(_onPageChanged);
    _pageController.dispose();
    super.dispose();
  }

  /// Web hero: full width, fade transition, dot indicators.
  Widget _buildWebHeroSlider(BuildContext context) {
    final list = widget.bannerList!;
    final size = MediaQuery.sizeOf(context);
    const height = 420.0;

    return SizedBox(
      height: height,
      width: double.infinity,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          SizedBox(
            height: height,
            width: double.infinity,
            child: PageView.builder(
              controller: _pageController,
              itemCount: list.length,
              onPageChanged: (i) => setState(() => currentIndex = i),
              itemBuilder: (context, index) {
                final delta = (_pageOffset - index).abs();
                final opacity = (1.0 - delta.clamp(0.0, 1.0)).clamp(0.0, 1.0);
                return Opacity(
                  opacity: opacity,
                  child: InkWell(
                    onTap: () => ProductHelper.onTapBannerForRoute(list[index], context),
                    child: ClipRect(
                      child: CustomImageWidget(
                        placeholder: Images.placeHolderOneToOne,
                        image: '${Provider.of<SplashProvider>(context, listen: false).baseUrls!.bannerImageUrl}/${list[index].image}',
                        width: size.width,
                        height: height,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          // Gradient overlay at bottom for dot visibility
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              height: 80,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withValues(alpha: 0.25)],
                ),
              ),
            ),
          ),
          // Dot indicators
          Positioned(
            bottom: 20,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(list.length, (i) {
                final isActive = i == currentIndex;
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
                    margin: const EdgeInsets.symmetric(horizontal: 4),
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
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final isWebPrimary = ResponsiveHelper.isDesktop(context) &&
        widget.bannerType == BannerType.primary &&
        (widget.isMainOnly || widget.bannerList != null);

    if (widget.bannerList == null) {
      return const MainSliderShimmerWidget();
    }
    if (widget.bannerList!.isEmpty) {
      return const SizedBox();
    }

    // Web primary hero: full width + fade
    if (isWebPrimary) {
      return _buildWebHeroSlider(context);
    }

    // Mobile or secondary: card-style carousel (rounded, peek, dot indicators)
    final isMobile = !ResponsiveHelper.isDesktop(context);
    final mobileRadius = 24.0;
    final mobileHeight = size.width - 2 * Dimensions.mobileContentPaddingHorizontal;
    return Center(
      child: Stack(
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: ResponsiveHelper.isDesktop(context) ? 0 : Dimensions.mobileContentPaddingHorizontal,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(mobileRadius),
                  child: CarouselSlider.builder(
                    carouselController: _carouselController,
                    itemCount: widget.bannerList!.length,
                    options: CarouselOptions(
                      autoPlayInterval: Duration(
                          milliseconds: widget.bannerType == BannerType.primary ? 4200 : 5320),
                      height: ResponsiveHelper.isDesktop(context)
                          ? 420
                          : mobileHeight,
                      aspectRatio: 1.0,
                      enlargeCenterPage: true,
                      viewportFraction: isMobile ? 0.92 : 1.0,
                      autoPlay: true,
                      autoPlayCurve: Curves.easeInOutCubic,
                      autoPlayAnimationDuration: Duration(
                          milliseconds: widget.bannerType == BannerType.primary ? 1800 : 3000),
                      onPageChanged: (index, reason) {
                        setState(() => currentIndex = index);
                      },
                    ),
                    itemBuilder: (ctx, index, realIdx) {
                      return InkWell(
                        borderRadius: BorderRadius.circular(mobileRadius),
                        onTap: () => ProductHelper.onTapBannerForRoute(
                            widget.bannerList![index], context),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(mobileRadius),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.08),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(mobileRadius),
                            child: CustomImageWidget(
                              placeholder: widget.isMainOnly
                                  ? Images.placeHolderOneToOne
                                  : Images.placeholder(context),
                              image:
                                  '${Provider.of<SplashProvider>(context, listen: false).baseUrls!.bannerImageUrl}/${widget.bannerList![index].image}',
                              width: widget.bannerType == BannerType.primary
                                  ? (widget.isMainOnly ? 1140 : 762)
                                  : (ResponsiveHelper.isDesktop(context)
                                      ? 380
                                      : (size.width - 2 * Dimensions.mobileContentPaddingHorizontal)),
                              height: widget.bannerType == BannerType.primary
                                  ? 380
                                  : (ResponsiveHelper.isDesktop(context)
                                      ? 420
                                      : mobileHeight),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              if (isMobile && widget.bannerList!.length > 1) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Colors.black.withValues(alpha: 0.12)],
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(widget.bannerList!.length, (i) {
                      final isActive = i == currentIndex;
                      return GestureDetector(
                        onTap: () {
                          _carouselController.animateToPage(
                            i,
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeOutCubic,
                          );
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
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
                  ),
                ),
              ],
            ],
          ),
          if (widget.bannerType == BannerType.primary &&
              !ResponsiveHelper.isDesktop(context))
            Positioned(
              right: 20,
              bottom: 100,
              top: 100,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${currentIndex + 1}/${widget.bannerList!.length}',
                    style: rubikRegular.copyWith(
                        color: Theme.of(context).cardColor),
                  ),
                  const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                  RotatedBox(
                    quarterTurns: 3,
                    child: SizedBox(
                      height: 5,
                      width: 200,
                      child: ClipRRect(
                        borderRadius: const BorderRadius.only(
                          bottomLeft:
                              Radius.circular(Dimensions.radiusSizeDefault),
                          topLeft:
                              Radius.circular(Dimensions.radiusSizeDefault),
                        ),
                        child: LinearProgressIndicator(
                          minHeight: 5,
                          value: ((currentIndex + 1) * 100) /
                              widget.bannerList!.length /
                              100,
                          valueColor: AlwaysStoppedAnimation<Color>(
                              Theme.of(context).primaryColor),
                          backgroundColor: Theme.of(context).cardColor,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
