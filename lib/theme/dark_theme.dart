import 'package:hexacom_user/utill/app_constants.dart';
import 'package:hexacom_user/utill/dimensions.dart';
import 'package:flutter/material.dart';

// Dark theme: higher contrast text and surfaces for readability
// Primary: #EC2227, Surface: #29292D, Text: bright grays for readability
ThemeData dark = ThemeData(
  fontFamily: AppConstants.fontFamily,
  primaryColor: const Color(0xFFEC2227),
  secondaryHeaderColor: const Color(0xFF394756),
  brightness: Brightness.dark,
  scaffoldBackgroundColor: const Color(0xFF1E1E22),
  cardColor: const Color(0xFF29292D),
  hintColor: const Color(0xFFB0B1B3),
  focusColor: const Color(0xFFE0E1E3),
  disabledColor: const Color(0xFF6B6C6E),
  shadowColor: Colors.black.withValues(alpha: 0.45),
  dividerColor: const Color(0xFF3A3A3E),
  textTheme: TextTheme(
    displaySmall: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: const Color(0xFFF0F0F2)),
    headlineMedium: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: const Color(0xFFF0F0F2)),
    titleLarge: TextStyle(fontSize: Dimensions.fontSizeOverLarge, fontWeight: FontWeight.w600, color: const Color(0xFFF0F0F2)),
    titleMedium: TextStyle(fontSize: Dimensions.fontSizeLarge, fontWeight: FontWeight.w500, color: const Color(0xFFE8E9EA)),
    titleSmall: TextStyle(fontSize: Dimensions.fontSizeDefault, fontWeight: FontWeight.w500, color: const Color(0xFFE8E9EA)),
    bodyLarge: TextStyle(fontSize: Dimensions.fontSizeLarge, fontWeight: FontWeight.w400, color: const Color(0xFFE8E9EA)),
    bodyMedium: TextStyle(fontSize: Dimensions.fontSizeDefault, fontWeight: FontWeight.w400, color: const Color(0xFFE8E9EA)),
    bodySmall: TextStyle(fontSize: Dimensions.fontSizeSmall, fontWeight: FontWeight.w300, color: const Color(0xFFD0D1D3)),
    labelLarge: TextStyle(fontSize: Dimensions.fontSizeDefault, fontWeight: FontWeight.w600, color: const Color(0xFFE8E9EA)),
    labelMedium: TextStyle(fontSize: Dimensions.fontSizeSmall, fontWeight: FontWeight.w500, color: const Color(0xFFE8E9EA)),
    labelSmall: TextStyle(fontSize: Dimensions.fontSizeExtraSmall, fontWeight: FontWeight.w500, color: const Color(0xFFD0D1D3)),
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
    fillColor: const Color(0xFF252529),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(Dimensions.radiusSizeDefault)),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(Dimensions.radiusSizeDefault),
      borderSide: const BorderSide(color: Color(0xFF3A3A3E)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(Dimensions.radiusSizeDefault),
      borderSide: const BorderSide(color: Color(0xFFEC2227), width: 1.5),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
  ),
  cardTheme: CardThemeData(
    elevation: 0,
    color: const Color(0xFF29292D),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusSizeLarge)),
  ),
  popupMenuTheme: const PopupMenuThemeData(
    color: Color(0xFF29292D),
    surfaceTintColor: Color(0xFF29292D),
  ),
  colorScheme: const ColorScheme.dark(
    primary: Color(0xFFEC2227),
    onPrimary: Colors.white,
    secondary: Color(0xFF394756),
    onSecondary: Color(0xFFE8E9EA),
    error: Color(0xFFEC2227),
    onError: Colors.white,
    surface: Color(0xFF29292D),
    onSurface: Color(0xFFE8E9EA),
    onSurfaceVariant: Color(0xFFB0B1B3),
    outline: Color(0xFF3A3A3E),
    surfaceContainerHighest: Color(0xFF333337),
  ),
  tabBarTheme: TabBarThemeData(
    indicatorColor: const Color(0xFFEC2227),
    labelColor: const Color(0xFFE8E9EA),
    unselectedLabelColor: Color(0xFFB0B1B3),
  ),
  appBarTheme: const AppBarThemeData(
    backgroundColor: Color(0xFF1E1E22),
    foregroundColor: Color(0xFFE8E9EA),
    elevation: 0,
    surfaceTintColor: Colors.transparent,
  ),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: Color(0xFF29292D),
    selectedItemColor: Color(0xFFEC2227),
    unselectedItemColor: Color(0xFFB0B1B3),
  ),
);
