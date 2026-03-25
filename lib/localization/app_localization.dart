import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hexacom_user/utill/app_constants.dart';

class AppLocalization {
  AppLocalization(this.locale);

  final Locale locale;

  static AppLocalization? of(BuildContext context) {
    return Localizations.of<AppLocalization>(context, AppLocalization);
  }

  late Map<String, String> _localizedValues;

  Future<void> load() async {
    final languageFilePath = 'assets/language/${locale.languageCode}.json';
    try {
      final jsonStringValues = await rootBundle.loadString(languageFilePath, cache: false);
      final Map<String, dynamic> mappedJson = json.decode(jsonStringValues);
      _localizedValues = mappedJson.map((key, value) => MapEntry(key, value.toString()));
      if (kDebugMode) {
        debugPrint('AppLocalization loaded: $languageFilePath');
      }
    } catch (_) {
      // Fallback to English when a dynamic language file does not exist.
      final jsonStringValues = await rootBundle.loadString('assets/language/en.json', cache: false);
      final Map<String, dynamic> mappedJson = json.decode(jsonStringValues);
      _localizedValues = mappedJson.map((key, value) => MapEntry(key, value.toString()));
      if (kDebugMode) {
        debugPrint('AppLocalization fallback to: assets/language/en.json');
      }
    }
  }

  /// Returns the string for [key], or null if missing (language_constrants fallbacks apply).
  String? translate(String? key) {
    if (key == null) return null;
    return _localizedValues[key];
  }

  static const LocalizationsDelegate<AppLocalization> delegate = _DemoLocalizationsDelegate();
}

class _DemoLocalizationsDelegate extends LocalizationsDelegate<AppLocalization> {
  const _DemoLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    List<String?> languageString = [];
    for (var language in AppConstants.languages) {
      languageString.add(language.languageCode);
    }
    return languageString.contains(locale.languageCode);
  }

  @override
  Future<AppLocalization> load(Locale locale) async {
    AppLocalization localization = AppLocalization(locale);
    await localization.load();
    return localization;
  }

  /// Must be true so changing [MaterialApp.locale] reloads JSON; `false` left stale strings from the first load.
  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalization> old) => true;
}
