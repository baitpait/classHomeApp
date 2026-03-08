class Dimensions {
  // Type scale (clear hierarchy)
  static const double fontSizeExtraSmall = 10.0;
  static const double fontSizeSmall = 12.0;
  static const double fontSizeDefault = 14.0;
  static const double fontSizeLarge = 16.0;
  static const double fontSizeExtraLarge = 18.0;
  static const double fontSizeOverLarge = 24.0;
  static const double fontSizeThirty = 30.0;

  // Spacing scale
  static const double paddingSizeExtraSmall = 5.0;
  static const double paddingSizeSmall = 10.0;
  static const double paddingSizeDefault = 15.0;
  static const double paddingSizeLarge = 20.0;
  static const double paddingSizeExtraLarge = 24.0;
  static const double paddingSizeSection = 32.0;

  static const double ratingHeight = 3.0;

  // Border radius (consistent rounded look)
  static const double radiusSizeSmall = 6.0;
  static const double radiusSizeDefault = 10.0;
  static const double radiusSizeLarge = 12.0;
  static const double radiusExtraLarge = 20.0;
  static const double radiusSizeFifty = 50.0;
  static const double radiusButton = 12.0;


  /// Breakpoints for responsive web content width.
  static const double webBreakpoint = 1400.0;
  static const double webContentWidthSmall = 1170.0;
  static const double webContentWidthLarge = 1440.0;

  /// Max content width on desktop: 1170 for viewport < 1400px, 1440 for larger. Use [getWebContentWidth] when you have [BuildContext].
  static const double webScreenWidth = webContentWidthSmall;

  static const int messageInputLength = 250;
  static const int webHeaderHeight = 90;

  /// Returns content width based on viewport: [webContentWidthSmall] below [webBreakpoint], [webContentWidthLarge] above.
  static double getWebContentWidth(double viewportWidth) {
    return viewportWidth >= webBreakpoint ? webContentWidthLarge : webContentWidthSmall;
  }

  /// Mobile home screen: consistent spacing between sections and edges.
  static const double mobileHomePaddingTop = 10.0;
  static const double mobileHomeSectionGap = 12.0;
  static const double mobileHomePaddingHorizontal = 12.0;
  static const double mobileHomePaddingBottom = 12.0;

  /// Single grid margin for mobile: inline padding used app-wide (slider, categories, products, etc.).
  static const double mobileContentPaddingHorizontal = 4.0;

  /// Product list / product pages: same as [mobileContentPaddingHorizontal] for unified grid.
  static const double mobileProductPaddingHorizontal = 4.0;
  static const double mobileProductGridGap = 4.0;
  static const double mobileProductGridCrossAxisSpacing = 2.0;
  /// Inline (horizontal) padding inside each product card cell on mobile grid.
  static const double mobileProductCardPaddingHorizontal = 2.0;
  static const double mobileProductCardPaddingVertical = 4.0;

  /// Bottom nav bar: max width so the pill doesn't stretch on wide/shrunk viewports.
  static const double bottomNavBarMaxWidth = 420.0;
  /// Bottom nav bar: visual height (pill + bottom padding) for content padding so last items can scroll above the pill.
  static const double bottomNavBarHeight = 66.0;

  /// Category slider: card width by viewport (mobile vs desktop). Use with [getCategoryImageSize].
  static double getCategoryCardWidth(double viewportWidth) {
    return viewportWidth >= webBreakpoint ? 116.0 : 80.0;
  }

  /// Category slider: circle image size by viewport (mobile vs desktop). Use with [getCategoryCardWidth].
  static double getCategoryImageSize(double viewportWidth) {
    return viewportWidth >= webBreakpoint ? 104.0 : 76.0;
  }

  /// Horizontal product card (flash sale, offers, new arrival): fixed size so parents always provide constraints.
  static const double horizontalProductCardWidth = 320.0;
  static const double horizontalProductCardHeight = 160.0;
}
