import 'package:cached_network_image/cached_network_image.dart';
import 'package:hexacom_user/common/widgets/custom_image_widget.dart';
import 'package:hexacom_user/features/category/providers/category_provider.dart';
import 'package:hexacom_user/common/widgets/custom_slider_list_widget.dart';
import 'package:hexacom_user/features/home/widgets/category_shimmer_widget.dart';
import 'package:hexacom_user/helper/responsive_helper.dart';
import 'package:hexacom_user/localization/language_constrants.dart';
import 'package:hexacom_user/utill/dimensions.dart';
import 'package:hexacom_user/utill/routes.dart';
import 'package:hexacom_user/utill/styles.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:provider/provider.dart';

class CategoryWidget extends StatefulWidget {
  const CategoryWidget({super.key});

  @override
  State<CategoryWidget> createState() => _CategoryWidgetState();
}

class _CategoryWidgetState extends State<CategoryWidget> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveHelper.isDesktop(context);

    final double cardWidth = 112.0;
    final double imageSize = 100.0; // Larger image, less border
    // Row height: vertical padding (8) + image + gap (4) + 2-line text (~30)
    final double cardHeight = 12 + imageSize + 4 + 30;
    final double itemSpacing = 8.0;

    return Consumer<CategoryProvider>(
      builder: (context, category, child) {
        if (category.categoryList == null) {
          return const CategoryShimmerWidget();
        }
        if (category.categoryList!.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
              child: Text(
                getTranslated('no_category_available', context),
                style: rubikMedium.copyWith(color: Theme.of(context).hintColor),
              ),
            ),
          );
        }

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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: cardHeight,
                child: CustomSliderListWidget(
                  controller: _scrollController,
                  verticalPosition: cardHeight * 0.5 - 20,
                  horizontalPosition: 0,
                  isShowForwardButton: category.categoryList!.length > 4,
                  child: ListView.builder(
                    controller: _scrollController,
                    itemCount: category.categoryList!.length,
                    padding: const EdgeInsetsDirectional.only(top: 12, start: 4),
                    physics: const BouncingScrollPhysics(),
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) {
                      final item = category.categoryList![index];
                      return Padding(
                        padding: EdgeInsetsDirectional.only(end: itemSpacing),
                        child: _CategoryCircleCard(
                          name: item.name ?? '',
                          imageUrl: item.image ?? '',
                          onTap: () => RouteHelper.getCategoryRoute(context, item, action: RouteAction.push),
                          imageSize: imageSize,
                          cardWidth: cardWidth,
                          isDesktop: isDesktop,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CategoryCircleCard extends StatefulWidget {
  const _CategoryCircleCard({
    required this.name,
    required this.imageUrl,
    required this.onTap,
    required this.imageSize,
    required this.cardWidth,
    required this.isDesktop,
  });

  final String name;
  final String imageUrl;
  final VoidCallback onTap;
  final double imageSize;
  final double cardWidth;
  final bool isDesktop;

  @override
  State<_CategoryCircleCard> createState() => _CategoryCircleCardState();
}

class _CategoryCircleCardState extends State<_CategoryCircleCard> {
  Color? _dominantColor;

  @override
  void initState() {
    super.initState();
    _generatePalette();
  }

  Future<void> _generatePalette() async {
    if (widget.imageUrl.isEmpty) {
      if (mounted) setState(() => _dominantColor = _fallbackColorFromUrl(widget.imageUrl));
      return;
    }
    // Skip palette on web to avoid decode errors (CORS/proxy often break image decoding).
    if (kIsWeb) {
      if (mounted) setState(() => _dominantColor = _fallbackColorFromUrl(widget.imageUrl));
      return;
    }
    try {
      final provider = CachedNetworkImageProvider(widget.imageUrl);
      final palette = await PaletteGenerator.fromImageProvider(
        provider,
        maximumColorCount: 12,
      );
      var color = _pickAccentColor(palette);
      color ??= _fallbackColorFromUrl(widget.imageUrl);
      if (mounted) {
        setState(() => _dominantColor = color);
      }
    } on Object catch (_) {
      // Catch Exception and Error (e.g. EncodingError when image cannot be decoded). Use URL-based fallback.
      final fallback = _fallbackColorFromUrl(widget.imageUrl);
      if (mounted) {
        setState(() => _dominantColor = fallback);
      }
    }
  }

  Color? _pickAccentColor(PaletteGenerator palette) {
    final candidates = <Color?>[
      palette.vibrantColor?.color,
      palette.lightVibrantColor?.color,
      palette.darkVibrantColor?.color,
      palette.mutedColor?.color,
      palette.dominantColor?.color,
    ];

    for (final c in candidates) {
      if (c == null) continue;
      // Skip almost-gray colors (black/white/neutral)
      final r = c.red.toDouble();
      final g = c.green.toDouble();
      final b = c.blue.toDouble();
      final maxCh = [r, g, b].reduce((a, b) => a > b ? a : b);
      final minCh = [r, g, b].reduce((a, b) => a < b ? a : b);
      if (maxCh - minCh < 18) continue; // too close to gray/black/white

      final luminance = c.computeLuminance();
      if (luminance < 0.08 || luminance > 0.9) continue; // too dark or too light
      return c;
    }
    return null;
  }

  Color _fallbackColorFromUrl(String url) {
    // Deterministic but varied color based on URL hash, avoiding extremes.
    final hash = url.hashCode;
    final r = 80 + (hash & 0x3F); // 80-143
    final g = 80 + ((hash >> 6) & 0x3F);
    final b = 80 + ((hash >> 12) & 0x3F);
    return Color.fromARGB(255, r, g, b);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final circleBg = theme.cardColor;

    // Use image-based color for the pill background; avoid black/white-ish colors via _pickAccentColor
    final baseColor = _dominantColor ?? theme.primaryColor;
    final pillColor = baseColor.withValues(alpha: 0.95);
    final onColor = baseColor.computeLuminance() > 0.6 ? Colors.black : Colors.white;
    final borderColor = baseColor.withValues(alpha: 0.95);
    final chipTextColor = onColor;

    final pillRadius = BorderRadius.circular(widget.isDesktop ? 20 : 16);
    // Single value for width and height so the image is always square
    final double imageSize = widget.imageSize;
    final double imageRadiusValue = widget.isDesktop ? 14.0 : 12.0;
    const double fontSize = 12.0; // Same on PC and mobile

    return InkWell(
      onTap: widget.onTap,
      borderRadius: pillRadius,
      child: SizedBox(
        width: widget.cardWidth,
        child: Container(
          padding: const EdgeInsetsDirectional.symmetric(horizontal: 6, vertical: 6),
          decoration: BoxDecoration(
            color: pillColor,
            borderRadius: pillRadius,
            border: Border.all(
              color: borderColor,
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
                      color: circleBg,
                      borderRadius: BorderRadius.circular(imageRadiusValue),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(imageRadiusValue - 2),
                      child: CustomImageWidget(
                        image: widget.imageUrl,
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
                  widget.name,
                  style: rubikMedium.copyWith(
                    fontSize: fontSize,
                    color: chipTextColor,
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
