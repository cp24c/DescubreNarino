import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'providers/theme_provider.dart'; // NUEVO
import 'screens/auth/login_screen.dart';
import 'screens/home/organizer_home_screen.dart';
import 'constants/app_theme.dart'; // NUEVO

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Inicializar localizaciones de fecha en español
  await initializeDateFormatting('es_ES', null);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()), // NUEVO: Provider del tema
      ],
      child: Consumer<ThemeProvider>(
        // NUEVO: Consumer que escucha cambios en el tema
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'DescubreNariño',
            debugShowCheckedModeBanner: false,
            
            // CONFIGURACIÓN DE TEMA
            theme: AppTheme.lightTheme, // Tema claro
            darkTheme: AppTheme.darkTheme, // Tema oscuro
            themeMode: themeProvider.themeModeEnum, // Modo actual: system, light o dark
            
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
        // Mostrar pantalla de carga mientras se verifica el estado
        if (authProvider.isLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // Si está autenticado, ir a home
        if (authProvider.isLoggedIn) {
          return const OrganizerHomeScreen();
        }

        // Si no está autenticado, ir a login
        return const LoginScreen();
      },
    );
  }
}