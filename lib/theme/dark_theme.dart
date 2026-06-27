import 'package:hexacom_user/utill/app_constants.dart';
import 'package:hexacom_user/utill/dimensions.dart';
import 'package:flutter/material.dart';

// الوضع الداكن: هوية كلاس هوم — برتقالي مضيء مع سطوح تركوازية داكنة
const Color _brandRedBright = Color(0xFFF59A4B);
const Color _brandMaroonSurface = Color(0xFF2C6075);
const Color _onBrandRedDark = Color(0xFF11201F);
const Color _errorBrand = Color(0xFFEF5350);

ThemeData dark = ThemeData(
  fontFamily: AppConstants.fontFamily,
  primaryColor: _brandRedBright,
  secondaryHeaderColor: _brandMaroonSurface,
  brightness: Brightness.dark,
  scaffoldBackgroundColor: const Color(0xFF111A1D),
  cardColor: const Color(0xFF1A2528),
  hintColor: const Color(0xFFB0B1B3),
  focusColor: const Color(0xFFE0E1E3),
  disabledColor: const Color(0xFF6B6C6E),
  shadowColor: Colors.black.withValues(alpha: 0.45),
  dividerColor: const Color(0xFF324448),
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
      backgroundColor: _brandRedBright,
      foregroundColor: _onBrandRedDark,
      minimumSize: const Size(0, 48),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusButton)),
      elevation: 0,
    ),
  ),
  filledButtonTheme: FilledButtonThemeData(
    style: FilledButton.styleFrom(
      backgroundColor: _brandRedBright,
      foregroundColor: _onBrandRedDark,
      minimumSize: const Size(0, 48),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusButton)),
      elevation: 0,
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: _brandRedBright,
      minimumSize: const Size(0, 48),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusButton)),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: const Color(0xFF1F2C2F),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(Dimensions.radiusSizeDefault)),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(Dimensions.radiusSizeDefault),
      borderSide: const BorderSide(color: Color(0xFF324448)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(Dimensions.radiusSizeDefault),
      borderSide: const BorderSide(color: _brandRedBright, width: 1.5),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
  ),
  cardTheme: CardThemeData(
    elevation: 0,
    color: const Color(0xFF1A2528),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusSizeLarge)),
  ),
  popupMenuTheme: const PopupMenuThemeData(
    color: Color(0xFF1A2528),
    surfaceTintColor: Color(0xFF1A2528),
  ),
  colorScheme: const ColorScheme.dark(
    primary: _brandRedBright,
    onPrimary: Color(0xFF11201F),
    secondary: _brandMaroonSurface,
    onSecondary: Color(0xFFFFFFFF),
    error: _errorBrand,
    onError: Colors.white,
    surface: Color(0xFF1A2528),
    onSurface: Color(0xFFE8E9EA),
    onSurfaceVariant: Color(0xFFB0B1B3),
    outline: Color(0xFF324448),
    surfaceContainerHighest: Color(0xFF243438),
  ),
  tabBarTheme: TabBarThemeData(
    indicatorColor: _brandRedBright,
    labelColor: _brandRedBright,
    unselectedLabelColor: Color(0xFFB0B1B3),
  ),
  appBarTheme: const AppBarThemeData(
    backgroundColor: Color(0xFF111A1D),
    foregroundColor: Color(0xFFE8E9EA),
    elevation: 0,
    surfaceTintColor: Colors.transparent,
  ),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: Color(0xFF1A2528),
    selectedItemColor: _brandRedBright,
    unselectedItemColor: Color(0xFFB0B1B3),
  ),
);
