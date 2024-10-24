import 'package:flutter/material.dart';

enum Language { English, Spanish }

class LanguageProvider extends ChangeNotifier {
  Language _currentLanguage = Language.English;

  Language get currentLanguage => _currentLanguage;

  void changeLanguage(Language newLanguage) {
    _currentLanguage = newLanguage;
    notifyListeners();
  }

  
}