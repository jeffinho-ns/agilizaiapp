import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider extends ChangeNotifier {
  static const String _languageKey = 'selected_language';

  Locale _currentLocale =
      const Locale('pt'); // Português Brasileiro como padrão

  Locale get currentLocale => _currentLocale;

  // Lista de idiomas disponíveis
  static const List<Map<String, String>> availableLanguages = [
    {
      'code': 'pt',
      'name': 'Português Brasileiro',
      'flag': '🇧🇷',
      'nativeName': 'Português Brasileiro'
    },
    {
      'code': 'en',
      'name': 'English US',
      'flag': '🇺🇸',
      'nativeName': 'English US'
    },
    {'code': 'es', 'name': 'Español', 'flag': '🇪🇸', 'nativeName': 'Español'},
    {'code': 'de', 'name': 'Deutsch', 'flag': '🇩🇪', 'nativeName': 'Deutsch'},
  ];

  LanguageProvider() {
    _loadSavedLanguage();
  }

  // Carrega o idioma salvo
  Future<void> _loadSavedLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedLanguage = prefs.getString(_languageKey);
      if (savedLanguage != null) {
        _currentLocale = Locale(savedLanguage);
        notifyListeners();
      }
    } catch (e) {
      // Se houver erro, mantém o idioma padrão
      debugPrint('Erro ao carregar idioma salvo: $e');
    }
  }

  // Salva o idioma selecionado
  Future<void> setLanguage(String languageCode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_languageKey, languageCode);
      _currentLocale = Locale(languageCode);
      notifyListeners();
    } catch (e) {
      debugPrint('Erro ao salvar idioma: $e');
    }
  }

  // Obtém o nome do idioma pelo código
  String getLanguageName(String languageCode) {
    final language = availableLanguages.firstWhere(
      (lang) => lang['code'] == languageCode,
      orElse: () => availableLanguages.first,
    );
    return language['name'] ?? 'Português Brasileiro';
  }

  // Obtém o nome nativo do idioma pelo código
  String getNativeLanguageName(String languageCode) {
    final language = availableLanguages.firstWhere(
      (lang) => lang['code'] == languageCode,
      orElse: () => availableLanguages.first,
    );
    return language['nativeName'] ?? 'Português Brasileiro';
  }

  // Obtém a bandeira do idioma pelo código
  String getLanguageFlag(String languageCode) {
    final language = availableLanguages.firstWhere(
      (lang) => lang['code'] == languageCode,
      orElse: () => availableLanguages.first,
    );
    return language['flag'] ?? '🇧🇷';
  }
}
