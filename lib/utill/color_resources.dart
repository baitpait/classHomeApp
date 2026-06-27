import 'package:flutter/material.dart';
import 'package:hexacom_user/provider/theme_provider.dart';
import 'package:provider/provider.dart';

/// كلاس هوم — ألوان الهوية حسب الشعار: برتقالي `#E97B2C`، كحلي/تركوازي داكن `#1F4C5C`، رمادي `#D2D3D4`، أسود/أبيض.
/// (الأسماء brandRed/brandMaroon أسماء قديمة محتفظ بها؛ قيمها الآن برتقالي/كحلي.)
class ColorResources {
  static const Color brandRed = Color(0xFFE97B2C);
  static const Color brandMaroon = Color(0xFF1F4C5C);
  static const Color brandMaroonDark = Color(0xFF143742);
  /// للتدرجات والظلال فوق الخلفيات الداكنة.
  static const Color brandRedSoft = Color(0xFFF4A35C);

  static const Color lightGray = Color(0xFFD2D3D4);
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);

  /// روابط / تمييز / عناصر التركيز الرئيسية.
  static const Color primary = brandRed;
  /// أزرار ثانوية وتمييز على خلفيات فاتحة.
  static const Color secondary = brandMaroon;

  /// شريط الويب العلوي، التذييل، شريط التنقل السفلي، شاشات الدخول.
  static const Color navBarNavy = brandMaroon;

  static const Color footerWebBackground = brandMaroon;

  static Color getGreyColor(BuildContext context) {
    return Provider.of<ThemeProvider>(context).darkTheme ? const Color(0xFF6f7275) : lightGray;
  }
  static Color getGrayColor(BuildContext context) {
    return Provider.of<ThemeProvider>(context).darkTheme ? const Color(0xFF919191) : const Color(0xFF3E4F54);
  }
  static Color getSearchBg(BuildContext context) {
    return Provider.of<ThemeProvider>(context).darkTheme ? const Color(0xFF585a5c) : white;
  }
  static Color getBackgroundColor(BuildContext context) {
    return Provider.of<ThemeProvider>(context).darkTheme ? const Color(0xFF1A2528) : white;
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
  /// حالة الطلب «مكتمل» — أخضر دلالي (ليس جزءًا من لوحة الشعار).
  static const Color colorGreen = Color(0xFF2E7D32);
  /// حالة «قيد الانتظار» — نفس أحمر العلامة.
  static const Color colorBlue = brandRed;

  static const Color snackBarBackgroundColor = Color(0xFF1A1213);

  /// تسميات الأقسام / أيقونات ثانوية — عنابي باهت.
  static const Color accentNavy = Color(0xFF6B2D31);

  static final Color offerSectionBackground = brandRed.withValues(alpha: 0.10);
  static const Color offerSectionBackgroundDark = Color(0xFF2D1F21);

  static Color getFlashSaleSectionBackground(BuildContext context) {
    return brandRed.withValues(alpha: 0.07);
  }

  static Color getOfferSectionBackground(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).darkTheme;
    return isDark
        ? offerSectionBackgroundDark
        : accentNavy.withValues(alpha: 0.06);
  }

  static Color getNewArrivalSectionBackground(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).darkTheme;
    return isDark
        ? const Color(0xFF241A1C)
        : brandMaroon.withValues(alpha: 0.06);
  }

}
