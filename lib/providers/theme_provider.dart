import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provider que maneja el tema de la aplicación
/// 
/// Funcionalidades:
/// - Detecta el tema del sistema por defecto
/// - Permite cambiar entre modo claro, oscuro o sistema
/// - Guarda la preferencia del usuario en SharedPreferences
/// - Notifica cambios a toda la app
class ThemeProvider with ChangeNotifier {
  // Valores posibles: 'system', 'light', 'dark'
  String _themeMode = 'system';
  
  // SharedPreferences para persistencia
  SharedPreferences? _prefs;

  ThemeProvider() {
    _loadThemePreference();
  }

  /// Getter del modo de tema actual
  String get themeMode => _themeMode;

  /// Convierte el string a ThemeMode de Flutter
  ThemeMode get themeModeEnum {
    switch (_themeMode) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  /// Obtiene el ícono apropiado según el modo actual
  IconData get themeIcon {
    switch (_themeMode) {
      case 'light':
        return Icons.wb_sunny; // Sol
      case 'dark':
        return Icons.nightlight_round; // Luna
      default:
        return Icons.brightness_auto; // Auto
    }
  }

  /// Obtiene el texto descriptivo del modo actual
  String get themeLabel {
    switch (_themeMode) {
      case 'light':
        return 'Modo Claro';
      case 'dark':
        return 'Modo Oscuro';
      default:
        return 'Tema del Sistema';
    }
  }

  /// Carga la preferencia guardada del usuario
  Future<void> _loadThemePreference() async {
    _prefs = await SharedPreferences.getInstance();
    // Por defecto usa el tema del sistema si no hay preferencia guardada
    _themeMode = _prefs?.getString('theme_mode') ?? 'system';
    notifyListeners();
  }

  /// Cambia el tema y lo guarda en preferencias
  Future<void> setThemeMode(String mode) async {
    _themeMode = mode;
    await _prefs?.setString('theme_mode', mode);
    notifyListeners();
  }

  /// Cicla entre los modos: system → light → dark → system
  Future<void> toggleTheme() async {
    switch (_themeMode) {
      case 'system':
        await setThemeMode('light');
        break;
      case 'light':
        await setThemeMode('dark');
        break;
      case 'dark':
        await setThemeMode('system');
        break;
    }
  }
}