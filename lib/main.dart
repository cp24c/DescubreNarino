import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/language_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home/organizer_home_screen.dart';
import 'constants/app_theme.dart';
import 'l10n/app_localizations.dart';
import 'services/notification_service.dart'; // NUEVO
import 'services/event_service.dart'; // NUEVO

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // NUEVO: Inicializar servicio de notificaciones
  final notificationService = NotificationService();
  await notificationService.initialize();
  await notificationService.requestPermissions();

  // Inicializar localizaciones de fecha en español e inglés
  await initializeDateFormatting('es_ES', null);
  await initializeDateFormatting('en_US', null);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
      ],
      child: Consumer2<ThemeProvider, LanguageProvider>(
        builder: (context, themeProvider, languageProvider, _) {
          return MaterialApp(
            title: 'DescubreNariño',
            debugShowCheckedModeBanner: false,

            // CONFIGURACIÓN DE TEMA
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeModeEnum,

            // CONFIGURACIÓN DE INTERNACIONALIZACIÓN
            locale: languageProvider.locale,
            supportedLocales: const [
              Locale('es'), // Español
              Locale('en'), // English
            ],
            localizationsDelegates: const [
              AppLocalizationsDelegate(),
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],

            home: const AuthWrapper(),
          );
        },
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        if (authProvider.isLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (authProvider.isLoggedIn) {
          // NUEVO: Reprogramar notificaciones al iniciar sesión
          _rescheduleNotifications(authProvider);
          return const OrganizerHomeScreen();
        }

        return const LoginScreen();
      },
    );
  }

  /// Reprograma todas las notificaciones de eventos guardados
  Future<void> _rescheduleNotifications(AuthProvider authProvider) async {
    final userId = authProvider.currentUser?.uid;
    if (userId == null) return;

    try {
      // Importar EventService
      final eventService = EventService();
      await eventService.rescheduleAllFavoriteNotifications(userId);
    } catch (e) {
      debugPrint('Error reprogramando notificaciones: $e');
    }
  }
}
