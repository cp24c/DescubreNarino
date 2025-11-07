import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provider que maneja el idioma de la aplicación
/// 
/// Funcionalidades:
/// - Detecta el idioma del sistema por defecto
/// - Permite cambiar entre español e inglés
/// - Guarda la preferencia del usuario en SharedPreferences
/// - Notifica cambios a toda la app
class LanguageProvider with ChangeNotifier {
  Locale _locale = const Locale('es'); // Español por defecto
  SharedPreferences? _prefs;

  LanguageProvider() {
    _loadLanguagePreference();
  }

  /// Getter del locale actual
  Locale get locale => _locale;

  /// Obtiene el nombre del idioma actual
  String get languageName {
    switch (_locale.languageCode) {
      case 'es':
        return 'Español';
      case 'en':
        return 'English';
      default:
        return 'Español';
    }
  }

  /// Obtiene el código del idioma (es, en)
  String get languageCode => _locale.languageCode;

  /// Carga la preferencia guardada del usuario
  Future<void> _loadLanguagePreference() async {
    _prefs = await SharedPreferences.getInstance();
    final languageCode = _prefs?.getString('language_code') ?? 'es';
    _locale = Locale(languageCode);
    notifyListeners();
  }

  /// Cambia el idioma y lo guarda en preferencias
  Future<void> setLanguage(String languageCode) async {
    if (_locale.languageCode == languageCode) return;
    
    _locale = Locale(languageCode);
    await _prefs?.setString('language_code', languageCode);
    notifyListeners();
  }

  /// Alterna entre español e inglés
  Future<void> toggleLanguage() async {
    final newLanguage = _locale.languageCode == 'es' ? 'en' : 'es';
    await setLanguage(newLanguage);
  }
}