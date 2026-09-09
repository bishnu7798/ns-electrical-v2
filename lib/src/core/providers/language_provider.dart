import 'package:flutter/material.dart';
import '../utils/language_manager.dart';

class LanguageProvider extends ChangeNotifier {
  String _selectedLanguage = LanguageManager.DEFAULT_LANGUAGE;

  String get selectedLanguage => _selectedLanguage;

  LanguageProvider() {
    _loadLanguagePreference();
  }

  Future<void> _loadLanguagePreference() async {
    try {
      final language = await LanguageManager.getSelectedLanguage();
      _selectedLanguage = language;
      notifyListeners();
    } catch (e) {
      // If there's an error loading the language, use the default
      _selectedLanguage = LanguageManager.DEFAULT_LANGUAGE;
      notifyListeners();
    }
  }

  Future<void> setLanguage(String language) async {
    _selectedLanguage = language;
    await LanguageManager.saveSelectedLanguage(language);
    notifyListeners();
  }
}