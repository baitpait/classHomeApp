import 'package:hexacom_user/utill/app_constants.dart';
import 'package:hexacom_user/utill/dimensions.dart';
import 'package:flutter/material.dart';

// محفوظ: أحمر #EC2227، عنابي #741113، رمادي #D2D3D4
const Color _brandRed = Color(0xFFEC2227);
const Color _brandMaroon = Color(0xFF741113);
const Color _onBrandRed = Color(0xFFFFFFFF);
const Color _onBrandMaroon = Color(0xFFFFFFFF);
const Color _surface = Color(0xFFFFFFFF);
const Color _errorBrand = Color(0xFFC62828);
const Color _hintMuted = Color(0xFF6D5658);

ThemeData light = ThemeData(
  fontFamily: AppConstants.fontFamily,
  primaryColor: _brandRed,
  secondaryHeaderColor: _brandMaroon,
  brightness: Brightness.light,
  cardColor: Colors.white,
  focusColor: const Color(0xFFD2D3D4),
  hintColor: _hintMuted,
  canvasColor: _surface,
  scaffoldBackgroundColor: _surface,
  shadowColor: const Color(0xFFD2D3D4),
  textTheme: TextTheme(
    displaySmall: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: const Color(0xFF000000)),
    headlineMedium: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: const Color(0xFF000000)),
    titleLarge: TextStyle(fontSize: Dimensions.fontSizeOverLarge, fontWeight: FontWeight.w600, color: const Color(0xFF000000)),
    titleMedium: TextStyle(fontSize: Dimensions.fontSizeLarge, fontWeight: FontWeight.w500, color: const Color(0xFF000000)),
    titleSmall: TextStyle(fontSize: Dimensions.fontSizeDefault, fontWeight: FontWeight.w500, color: const Color(0xFF000000)),
    bodyLarge: TextStyle(fontSize: Dimensions.fontSizeLarge, fontWeight: FontWeight.w400, color: const Color(0xFF000000)),
    bodyMedium: TextStyle(fontSize: Dimensions.fontSizeDefault, fontWeight: FontWeight.w400, color: const Color(0xFF000000)),
    bodySmall: TextStyle(fontSize: Dimensions.fontSizeSmall, fontWeight: FontWeight.w300, color: const Color(0xFF000000)),
    labelLarge: TextStyle(fontSize: Dimensions.fontSizeDefault, fontWeight: FontWeight.w600, color: const Color(0xFF000000)),
    labelMedium: TextStyle(fontSize: Dimensions.fontSizeSmall, fontWeight: FontWeight.w500, color: const Color(0xFF000000)),
    labelSmall: TextStyle(fontSize: Dimensions.fontSizeExtraSmall, fontWeight: FontWeight.w500, color: const Color(0xFF000000)),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: _brandRed,
      foregroundColor: _onBrandRed,
      minimumSize: const Size(0, 48),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusButton)),
      elevation: 0,
    ),
  ),
  filledButtonTheme: FilledButtonThemeData(
    style: FilledButton.styleFrom(
      backgroundColor: _brandRed,
      foregroundColor: _onBrandRed,
      minimumSize: const Size(0, 48),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusButton)),
      elevation: 0,
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: _brandRed,
      minimumSize: const Size(0, 48),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusButton)),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(Dimensions.radiusSizeDefault)),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(Dimensions.radiusSizeDefault),
      borderSide: const BorderSide(color: _brandRed, width: 1.5),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
  ),
  cardTheme: CardThemeData(
    elevation: 0,
    color: Colors.white,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusSizeLarge)),
  ),
  popupMenuTheme: const PopupMenuThemeData(color: Colors.white, surfaceTintColor: Colors.white),
  colorScheme: ColorScheme(
    brightness: Brightness.light,
    primary: _brandRed,
    onPrimary: _onBrandRed,
    secondary: _brandMaroon,
    onSecondary: _onBrandMaroon,
    error: _errorBrand,
    onError: Colors.white,
    surface: _surface,
    onSurface: const Color(0xFF1C1C1E),
    shadow: const Color(0xFFD2D3D4),
  ),
  tabBarTheme: TabBarThemeData(
    indicatorColor: _brandRed,
    labelColor: _brandMaroon,
    unselectedLabelColor: _hintMuted,
  ),
);
