import 'package:hexacom_user/utill/app_constants.dart';
import 'package:hexacom_user/utill/dimensions.dart';
import 'package:flutter/material.dart';

// Same palette in dark mode: #EC2227, #747113, #d2d3d4, #ffffff, #000000
ThemeData dark = ThemeData(
  fontFamily: AppConstants.fontFamily,
  primaryColor: const Color(0xFFEC2227),
  secondaryHeaderColor: const Color(0xFF394756),
  brightness: Brightness.dark,
  cardColor: const Color(0xFF29292D),
  hintColor: const Color(0xFFd2d3d4),
  focusColor: const Color(0xFFd2d3d4),
  shadowColor: Colors.black.withValues(alpha: 0.4),
  textTheme: TextTheme(
    displaySmall: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: const Color(0xFFd2d3d4)),
    headlineMedium: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: const Color(0xFFd2d3d4)),
    titleLarge: TextStyle(fontSize: Dimensions.fontSizeOverLarge, fontWeight: FontWeight.w600, color: const Color(0xFFd2d3d4)),
    titleMedium: TextStyle(fontSize: Dimensions.fontSizeLarge, fontWeight: FontWeight.w500, color: const Color(0xFFd2d3d4)),
    titleSmall: TextStyle(fontSize: Dimensions.fontSizeDefault, fontWeight: FontWeight.w500, color: const Color(0xFFd2d3d4)),
    bodyLarge: TextStyle(fontSize: Dimensions.fontSizeLarge, fontWeight: FontWeight.w400, color: const Color(0xFFd2d3d4)),
    bodyMedium: TextStyle(fontSize: Dimensions.fontSizeDefault, fontWeight: FontWeight.w400, color: const Color(0xFFd2d3d4)),
    bodySmall: TextStyle(fontSize: Dimensions.fontSizeSmall, fontWeight: FontWeight.w300, color: const Color(0xFFd2d3d4)),
    labelLarge: TextStyle(fontSize: Dimensions.fontSizeDefault, fontWeight: FontWeight.w600, color: const Color(0xFFd2d3d4)),
    labelMedium: TextStyle(fontSize: Dimensions.fontSizeSmall, fontWeight: FontWeight.w500, color: const Color(0xFFd2d3d4)),
    labelSmall: TextStyle(fontSize: Dimensions.fontSizeExtraSmall, fontWeight: FontWeight.w500, color: const Color(0xFFd2d3d4)),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      minimumSize: const Size(0, 48),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusButton)),
      elevation: 0,
    ),
  ),
  filledButtonTheme: FilledButtonThemeData(
    style: FilledButton.styleFrom(
      minimumSize: const Size(0, 48),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusButton)),
      elevation: 0,
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      minimumSize: const Size(0, 48),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusButton)),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(Dimensions.radiusSizeDefault)),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
  ),
  cardTheme: CardThemeData(
    elevation: 0,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusSizeLarge)),
  ),
  popupMenuTheme: const PopupMenuThemeData(color: Color(0xFF29292D), surfaceTintColor: Color(0xFF29292D)),
  colorScheme: const ColorScheme.dark(
    primary: Color(0xFFEC2227),
    secondary: Color(0xFF394756),
    error: Color(0xFFEC2227),
    surface: Color(0xFF29292D),
    onSurface: Color(0xFFd2d3d4),
  ),
  tabBarTheme: TabBarThemeData(indicatorColor: const Color(0xFFEC2227)),
);
