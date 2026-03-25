import 'package:hexacom_user/common/reposotories/language_repo.dart';
import 'package:flutter/material.dart';
import 'package:hexacom_user/common/models/language_model.dart';
import 'package:hexacom_user/utill/app_constants.dart';

class LanguageProvider with ChangeNotifier {
  final LanguageRepo? languageRepo;

  LanguageProvider({this.languageRepo});

  int? _selectIndex = 0;

  int? get selectIndex => _selectIndex;


  LanguageModel? _selectedLanguageModel;
  LanguageModel? get selectedLanguageModel => _selectedLanguageModel;


  void setSelectIndex(int? index) {
    _selectIndex = index;
    notifyListeners();
  }

  void setSelectedLanguageModel(LanguageModel language){
    _selectedLanguageModel = language;
    notifyListeners();
  }


  List<LanguageModel> _languages = [];

  List<LanguageModel> get languages => _languages;

  void searchLanguage(String query, BuildContext context) {
    if (query.isEmpty) {
      _languages.clear();
      _languages = languageRepo!.getAllLanguages(context: context);
      notifyListeners();
    } else {
      _selectIndex = -1;
      _languages = [];
      languageRepo!.getAllLanguages(context: context).forEach((product) async {
        if (product.languageName!.toLowerCase().contains(query.toLowerCase())) {
          _languages.add(product);
        }
      });
      notifyListeners();
    }
  }

  void initializeAllLanguages(BuildContext context) {
    _languages = [];
    _languages = languageRepo?.getAllLanguages(context: context) ?? [];
    syncLanguagesFromServer();
    notifyListeners();
  }

  Future<void> syncLanguagesFromServer() async {
    final updatedLanguages = await languageRepo?.getLanguagesFromServer() ?? [];
    if (updatedLanguages.isEmpty) {
      return;
    }

    AppConstants.languages = List<LanguageModel>.from(updatedLanguages);
    _languages = List<LanguageModel>.from(updatedLanguages);

    if (_selectIndex != null && (_selectIndex! < 0 || _selectIndex! >= _languages.length)) {
      _selectIndex = _languages.isEmpty ? -1 : 0;
      _selectedLanguageModel = _languages.isEmpty ? null : _languages.first;
    }
    notifyListeners();
  }
}
