import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hexacom_user/utill/app_constants.dart';
import 'package:hexacom_user/utill/images.dart';
import 'package:flutter/cupertino.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

class CustomImageWidget extends StatelessWidget {
  final String image;
  final double? height;
  final double? width;
  final BoxFit? fit;
  final bool isNotification;
  final String placeholder;
  final bool useShimmerPlaceholder;
  /// When set, tints the placeholder/error image (e.g. to match theme primary).
  final Color? placeholderColor;
  const CustomImageWidget({
    super.key,
    required this.image,
    this.height,
    this.width,
    this.fit = BoxFit.cover,
    this.isNotification = false,
    this.placeholder = '',
    this.useShimmerPlaceholder = false,
    this.placeholderColor,
  });

  Widget _shimmerPlaceholderWidget(BuildContext context) {
    return Shimmer(
      duration: const Duration(seconds: 2),
      child: Container(
        height: height,
        width: width,
        color: Theme.of(context).shadowColor.withValues(alpha: 0.22),
      ),
    );
  }

  Widget _placeholderOrErrorWidget(String placeholderPath) {
    return Image.asset(
      placeholderPath,
      height: height,
      width: width,
      fit: fit,
      color: placeholderColor,
      colorBlendMode: placeholderColor != null ? BlendMode.srcIn : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final placeholderPath = placeholder.isNotEmpty ? placeholder : Images.placeholder(context);
    final dpr = MediaQuery.devicePixelRatioOf(context);
    final memWidth = width != null ? (width! * dpr).round() : null;
    final memHeight = height != null ? (height! * dpr).round() : null;
    return CachedNetworkImage(
      imageUrl: kIsWeb ? '${AppConstants.baseUrl}/image-proxy?url=${Uri.encodeComponent(image)}' : image,
      height: height,
      width: width,
      fit: fit,
      memCacheWidth: memWidth,
      memCacheHeight: memHeight,
      maxWidthDiskCache: memWidth != null ? memWidth * 2 : null,
      maxHeightDiskCache: memHeight != null ? memHeight * 2 : null,
      fadeInDuration: const Duration(milliseconds: 150),
      placeholder: (context, url) => useShimmerPlaceholder
          ? _shimmerPlaceholderWidget(context)
          : _placeholderOrErrorWidget(placeholderPath),
      errorWidget: (context, url, error) => useShimmerPlaceholder
          ? _shimmerPlaceholderWidget(context)
          : _placeholderOrErrorWidget(placeholderPath),
    );
  }
}
