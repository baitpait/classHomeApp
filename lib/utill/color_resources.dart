import 'package:flutter/material.dart';
import 'package:hexacom_user/provider/theme_provider.dart';
import 'package:provider/provider.dart';

/// Anagheem Home logo identity: teal + peach + cream (pastel ecommerce).
/// Primary = brand teal; secondary = peach (CTAs); errors stay red via Theme [ColorScheme.error].
class ColorResources {
  static const Color brandTeal = Color(0xFF88C0B7);
  static const Color brandTealDark = Color(0xFF5A948B);
  static const Color brandPeach = Color(0xFFF9A891);
  static const Color brandPeachDark = Color(0xFFE07865);
  static const Color brandCream = Color(0xFFFDE3C9);

  /// Brand / links / accents (teal from logo).
  static const Color primary = brandTeal;
  /// Main action buttons — warm peach (logo “E‑COMMERCE” tone).
  static const Color secondary = brandPeach;
  static const Color lightGray = Color(0xFFD2D3D4);
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);

  /// Bottom nav / mobile header / web header strip & main footer — deep teal (Anagheem).
  static const Color navBarNavy = Color(0xFF2A3836);

  /// Same as [navBarNavy]; use for web footer background.
  static const Color footerWebBackground = navBarNavy;

  static Color getGreyColor(BuildContext context) {
    return Provider.of<ThemeProvider>(context).darkTheme ? const Color(0xFF6f7275) : lightGray;
  }
  static Color getGrayColor(BuildContext context) {
    return Provider.of<ThemeProvider>(context).darkTheme ? const Color(0xFF919191) : const Color(0xFF5C6A68);
  }
  static Color getSearchBg(BuildContext context) {
    return Provider.of<ThemeProvider>(context).darkTheme ? const Color(0xFF585a5c) : white;
  }
  static Color getBackgroundColor(BuildContext context) {
    return Provider.of<ThemeProvider>(context).darkTheme ? const Color(0xFF343636) : white;
  }

  static Color getGreyBunkerColor(BuildContext context) {
    return Provider.of<ThemeProvider>(context).darkTheme ? lightGray : black;
  }

  static Color getRatingColor(BuildContext context) {
    return const Color(0xFFFFA41C);
  }

  static Color getTextColor(BuildContext context) {
    return Provider.of<ThemeProvider>(context).darkTheme ? white : black;
  }

  static Color getIndicatorColor(BuildContext context) {
    return primary;
  }

  static const Color colorGrey = Color(0xFFD2D3D4);
  static const Color colorGreen = Color(0xFF5A948B);
  static const Color colorBlue = Color(0xFF88C0B7);
  static const Color snackBarBackgroundColor = Color(0xFF1D2D2B);

  /// Muted teal-gray for section labels / icons (replaces old #3A4756 slate).
  static const Color accentNavy = Color(0xFF4A6562);

  /// Soft peach tint for offer strips (matches logo secondary).
  static final Color offerSectionBackground = brandPeach.withValues(alpha: 0.14);
  static const Color offerSectionBackgroundDark = Color(0xFF2D3238);

  /// Section backgrounds — flash sale: soft peach; offers: navy tint.
  static Color getFlashSaleSectionBackground(BuildContext context) {
    return brandPeach.withValues(alpha: 0.08);
  }

  static Color getOfferSectionBackground(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).darkTheme;
    return isDark
        ? offerSectionBackgroundDark
        : accentNavy.withValues(alpha: 0.05);
  }

  /// New arrivals should feel distinct from featured/offer sections.
  /// - Light: soft mint tint
  /// - Dark: deep slate tint (not pure black)
  static Color getNewArrivalSectionBackground(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).darkTheme;
    return isDark
        ? const Color(0xFF1F2B2A)
        : brandTeal.withValues(alpha: 0.10);
  }

}
