import 'package:flutter/material.dart';
import 'package:hexacom_user/provider/theme_provider.dart';
import 'package:provider/provider.dart';

/// App color palette:
/// #EC2227 - Primary (red)
/// #747113 - Secondary (olive)
/// #d2d3d4 - Light gray (borders, disabled)
/// #ffffff - White
/// #000000 - Black
class ColorResources {
  // Palette: #EC2227, #747113, #D2D3D4, #FFFFFF, #000000
  static const Color primary = Color(0xFFEC2227);
  static const Color secondary = Color(0xFF747113);
  static const Color lightGray = Color(0xFFD2D3D4);
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);

  static Color getGreyColor(BuildContext context) {
    return Provider.of<ThemeProvider>(context).darkTheme ? const Color(0xFF6f7275) : lightGray;
  }
  static Color getGrayColor(BuildContext context) {
    return Provider.of<ThemeProvider>(context).darkTheme ? const Color(0xFF919191) : const Color(0xFF747113);
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
    return Provider.of<ThemeProvider>(context).darkTheme ? secondary : secondary;
  }

  static Color getTextColor(BuildContext context) {
    return Provider.of<ThemeProvider>(context).darkTheme ? white : black;
  }

  static Color getIndicatorColor(BuildContext context) {
    return primary;
  }

  static const Color colorGrey = Color(0xFFD2D3D4);
  static const Color colorGreen = Color(0xFF747113);
  static const Color colorBlue = Color(0xFFEC2227);
  static const Color snackBarBackgroundColor = Color(0xFF1D2D2B);

  /// Neutral section background (offer products, flash sale). Cool gray, works for men’s/unisex sites.
  static const Color offerSectionBackground = Color(0xFFE8ECF0);
  static const Color offerSectionBackgroundDark = Color(0xFF2D3238);

}
