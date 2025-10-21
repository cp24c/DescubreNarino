import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;
  Map<String, dynamic>? _authResponse;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  Map<String, dynamic>? get authResponse => _authResponse;
  bool get isLoggedIn => _currentUser != null;
  bool get isOrganizer => _currentUser?.role == 'organizer';

  AuthProvider() {
    _initAuth();
  }

  // Inicializar autenticación
  void _initAuth() {
    _authService.authStateChanges.listen((user) async {
      if (user != null && user.emailVerified) {
        _currentUser = await _authService.getCurrentUserData();
        notifyListeners();
      } else {
        _currentUser = null;
        notifyListeners();
      }
    });
  }

  // Registro
  Future<Map<String, dynamic>> register({
    required String username,
    required String email,
    required String password,
    required String role,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    _authResponse = null;
    notifyListeners();

    try {
      final response = await _authService.registerUser(
        username: username,
        email: email,
        password: password,
        role: role,
      );

      _authResponse = response;
      
      if (response['success']) {
        _successMessage = response['message'];
        _currentUser = null; // No iniciar sesión automáticamente
      } else {
        _errorMessage = response['message'];
      }

      _isLoading = false;
      notifyListeners();
      return response;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  // Inicio de sesión
  Future<Map<String, dynamic>> signIn({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    _authResponse = null;
    notifyListeners();

    try {
      final response = await _authService.signIn(
        email: email,
        password: password,
      );

      _authResponse = response;

      if (response['success']) {
        _currentUser = response['user'];
        _successMessage = response['message'];
      } else {
        _errorMessage = response['message'];
        _currentUser = null;
      }

      _isLoading = false;
      notifyListeners();
      return response;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  // Reenviar correo de verificación
  Future<Map<String, dynamic>> resendVerificationEmail({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final response = await _authService.resendVerificationEmail(email, password);

      if (response['success']) {
        _successMessage = response['message'];
      } else {
        _errorMessage = response['message'];
      }

      _isLoading = false;
      notifyListeners();
      return response;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  // Cerrar sesión
  Future<void> signOut() async {
    await _authService.signOut();
    _currentUser = null;
    _errorMessage = null;
    _successMessage = null;
    _authResponse = null;
    notifyListeners();
  }

  // Recuperar contraseña
  Future<Map<String, dynamic>> resetPassword(String email) async {
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final response = await _authService.resetPassword(email);

      if (response['success']) {
        _successMessage = response['message'];
      } else {
        _errorMessage = response['message'];
      }

      _isLoading = false;
      notifyListeners();
      return response;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  // Cambiar contraseña
  Future<Map<String, dynamic>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final response = await _authService.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );

      if (response['success']) {
        _successMessage = response['message'];
      } else {
        _errorMessage = response['message'];
      }

      _isLoading = false;
      notifyListeners();
      return response;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  // Limpiar mensajes
  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    _authResponse = null;
    notifyListeners();
  }
}