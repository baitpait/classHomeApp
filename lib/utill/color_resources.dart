import 'package:flutter/material.dart';
import 'package:hexacom_user/provider/theme_provider.dart';
import 'package:provider/provider.dart';

/// App color palette:
/// #EC2227 - Primary (red)
/// #8B1A1A - Secondary (dark red)
/// #d2d3d4 - Light gray (borders, disabled)
/// #ffffff - White
/// #000000 - Black
class ColorResources {
  static const Color primary = Color(0xFFEC2227);
  static const Color secondary = Color(0xFF8B1A1A);
  static const Color lightGray = Color(0xFFD2D3D4);
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);

  /// Navy used for bottom nav bar and mobile top app bar (footer/header).
  static const Color navBarNavy = Color(0xFF2C2C2E);

  static Color getGreyColor(BuildContext context) {
    return Provider.of<ThemeProvider>(context).darkTheme ? const Color(0xFF6f7275) : lightGray;
  }
  static Color getGrayColor(BuildContext context) {
    return Provider.of<ThemeProvider>(context).darkTheme ? const Color(0xFF919191) : const Color(0xFF8B1A1A);
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
  static const Color colorGreen = Color(0xFF8B1A1A);
  static const Color colorBlue = Color(0xFFEC2227);
  static const Color snackBarBackgroundColor = Color(0xFF1D2D2B);

  /// Shared accent used for text/icons (dark navy #3A4756)
  static const Color accentNavy = Color(0xFF3A4756);

  /// Same as flash sale: red #E53935 at 50% opacity
  static final Color offerSectionBackground = Color(0x80E53935).withValues(alpha: 0.12);
  static const Color offerSectionBackgroundDark = Color(0xFF2D3238);

  /// Section backgrounds
  /// - Flash sale: low-opacity primary red
  /// - New arrival & offers: shared low-opacity navy
  static Color getFlashSaleSectionBackground(BuildContext context) {
    return primary.withValues(alpha: 0.06);
  }

  static Color getOfferSectionBackground(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).darkTheme;
    return isDark
        ? offerSectionBackgroundDark
        : accentNavy.withValues(alpha: 0.05);
  }

}
