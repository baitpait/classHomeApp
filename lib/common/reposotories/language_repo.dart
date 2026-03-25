import 'package:flutter/material.dart';
import 'package:hexacom_user/common/models/language_model.dart';
import 'package:hexacom_user/data/datasource/remote/dio/dio_client.dart';
import 'package:hexacom_user/utill/app_constants.dart';

class LanguageRepo {
  final DioClient dioClient;
  LanguageRepo({required this.dioClient});

  List<LanguageModel> getAllLanguages({BuildContext? context}) {
    return AppConstants.languages;
  }

  Future<List<LanguageModel>> getLanguagesFromServer() async {
    try {
      final response = await dioClient.get(AppConstants.languageUri);
      final data = response.data;
      if (data is! List) {
        return AppConstants.languages;
      }

      final List<LanguageModel> languages = data
          .whereType<Map>()
          .map((item) {
            final map = Map<String, dynamic>.from(item);
            final code = (map['key'] ?? '').toString().trim().toLowerCase();
            final name = (map['value'] ?? code).toString().trim();
            if (code.isEmpty) {
              return null;
            }
            return LanguageModel(
              imageUrl: '',
              languageName: name.isNotEmpty ? name : code.toUpperCase(),
              languageCode: code,
              countryCode: _countryCodeByLanguageCode(code),
            );
          })
          .whereType<LanguageModel>()
          .toList();

      return languages.isNotEmpty ? languages : AppConstants.languages;
    } catch (_) {
      return AppConstants.languages;
    }
  }

  String _countryCodeByLanguageCode(String code) {
    switch (code) {
      case 'ar':
        return 'SA';
      case 'en':
        return 'US';
      case 'he':
        return 'IL';
      default:
        return code.toUpperCase();
    }
  }
}
