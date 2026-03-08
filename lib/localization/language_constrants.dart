import 'package:hexacom_user/localization/app_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Fallback for known keys when JSON translation is missing (e.g. after adding new key without full restart).
String? _fallbackFor(String? key, String languageCode) {
  if (key == null) return null;
  switch (key) {
    case 'store':
      return languageCode == 'ar' ? 'المتجر' : 'Store';
    case 'explore_popular_categories':
      return languageCode == 'ar' ? 'استكشف التصنيفات الشائعة' : 'Explore Popular Categories';
    case 'enter_email_phone':
      return languageCode == 'ar' ? 'أدخل البريد الإلكتروني أو رقم الجوال' : 'Please enter email or phone';
    case 'contact_person':
      return languageCode == 'ar' ? 'اسم جهة الاتصال' : 'Contact person';
    case 'phone':
      return languageCode == 'ar' ? 'رقم الهاتف' : 'Phone';
    case 'flash_sale':
      return languageCode == 'ar' ? 'عروض حصرية' : 'Flash Sale';
    case 'pickup_thank_you':
      return languageCode == 'ar' ? 'شكراً لطلبك.' : 'Thank you for your order.';
    case 'pickup_instructions':
      return languageCode == 'ar' ? 'يرجى القدوم إلى المتجر لاستلام طلبك.' : 'Please come to the store to collect your order.';
    default:
      return null;
  }
}

String getTranslated(String? key, BuildContext context) {
  String? text = key;
  final languageCode = Localizations.localeOf(context).languageCode;
  try {
    text = AppLocalization.of(context)!.translate(key);
  } catch (error) {
    if (kDebugMode) {
      print('not localized --- $error');
    }
    text = _fallbackFor(key, languageCode) ?? text;
  }
  // Ensure flash_sale always shows correct Arabic label (overrides any cached JSON)
  if (key == 'flash_sale' && languageCode == 'ar') {
    text = 'عروض حصرية';
  }
  // Ensure pickup strings always translated (override raw key or cached JSON)
  if (key == 'pickup_thank_you') {
    text = languageCode == 'ar' ? 'شكراً لطلبك.' : 'Thank you for your order.';
  } else if (key == 'pickup_instructions') {
    text = languageCode == 'ar' ? 'يرجى القدوم إلى المتجر لاستلام طلبك.' : 'Please come to the store to collect your order.';
  }
  return text ?? '';
}