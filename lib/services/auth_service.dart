import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Obtener usuario actual
  User? get currentUser => _auth.currentUser;

  // Stream de cambios de autenticación
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Verificar si un email ya existe en Firestore
  Future<bool> _emailExists(String email) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();
      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  // Registro de usuario
  Future<Map<String, dynamic>> registerUser({
    required String username,
    required String email,
    required String password,
    required String role,
  }) async {
    try {
      // Verificar si el email ya existe en Firestore
      final emailExists = await _emailExists(email);
      
      if (emailExists) {
        // Intentar iniciar sesión para verificar el estado
        try {
          UserCredential tempCredential = await _auth.signInWithEmailAndPassword(
            email: email,
            password: password,
          );
          
          if (!tempCredential.user!.emailVerified) {
            await _auth.signOut();
            return {
              'success': false,
              'message': 'Este correo ya está registrado pero no ha sido verificado. Por favor revisa tu bandeja de entrada y spam para verificar tu cuenta.',
              'needsVerification': true,
            };
          } else {
            await _auth.signOut();
            return {
              'success': false,
              'message': 'Este correo ya está registrado y verificado. Por favor inicia sesión.',
              'alreadyExists': true,
            };
          }
        } catch (e) {
          return {
            'success': false,
            'message': 'Este correo ya está registrado. Si olvidaste tu contraseña, usa la opción de recuperación.',
            'alreadyExists': true,
          };
        }
      }

      // Crear usuario en Firebase Auth
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Enviar correo de verificación
      await userCredential.user?.sendEmailVerification();

      // Crear documento de usuario en Firestore
      UserModel newUser = UserModel(
        uid: userCredential.user!.uid,
        username: username,
        email: email,
        role: role,
        state: 'inactive', // Inactivo hasta verificar email
        createdAt: DateTime.now(),
      );

      await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .set(newUser.toFirestore());

      // Cerrar sesión inmediatamente después del registro
      await _auth.signOut();

      return {
        'success': true,
        'message': '¡Cuenta creada exitosamente! Hemos enviado un correo de verificación a $email. Por favor verifica tu correo antes de iniciar sesión.',
        'user': newUser,
      };
    } on FirebaseAuthException catch (e) {
      return {
        'success': false,
        'message': _handleAuthException(e),
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error inesperado al registrar usuario: $e',
      };
    }
  }

  // Inicio de sesión con verificación de email
  Future<Map<String, dynamic>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Recargar el usuario para obtener el estado más reciente
      await userCredential.user!.reload();
      User? currentUser = _auth.currentUser;

      // Verificar si el email está verificado
      if (currentUser == null || !currentUser.emailVerified) {
        await _auth.signOut();
        return {
          'success': false,
          'message': 'Tu correo electrónico aún no ha sido verificado.\n\n'
              '📧 Revisa tu bandeja de entrada y la carpeta de spam.\n'
              '✉️ Si no encuentras el correo, puedes solicitar uno nuevo desde la pantalla de inicio de sesión.',
          'needsVerification': true,
          'canResend': true,
        };
      }

      // Obtener datos del usuario desde Firestore
      DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      if (!userDoc.exists) {
        await _auth.signOut();
        return {
          'success': false,
          'message': 'Error: Usuario no encontrado en la base de datos. Contacta al administrador.',
        };
      }

      UserModel user = UserModel.fromFirestore(userDoc);

      // Activar usuario si estaba inactivo pero ya verificó email
      if (user.state == 'inactive') {
        await _firestore
            .collection('users')
            .doc(user.uid)
            .update({'state': 'active'});
        user = user.copyWith(state: 'active');
      }

      // Verificar que el usuario esté activo
      if (user.state != 'active') {
        await _auth.signOut();
        return {
          'success': false,
          'message': '⚠️ Tu cuenta ha sido deshabilitada.\n\nPor favor contacta al administrador para más información.',
        };
      }

      return {
        'success': true,
        'message': '¡Bienvenido de nuevo, ${user.username}!',
        'user': user,
      };
    } on FirebaseAuthException catch (e) {
      return {
        'success': false,
        'message': _handleAuthException(e),
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error al iniciar sesión: $e',
      };
    }
  }

  // Reenviar correo de verificación
  Future<Map<String, dynamic>> resendVerificationEmail(String email, String password) async {
    try {
      // Intentar iniciar sesión temporalmente
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Verificar si ya está verificado
      await userCredential.user!.reload();
      User? currentUser = _auth.currentUser;

      if (currentUser != null && currentUser.emailVerified) {
        await _auth.signOut();
        return {
          'success': false,
          'message': '✅ Tu correo ya está verificado. Puedes iniciar sesión normalmente.',
          'alreadyVerified': true,
        };
      }

      // Enviar nuevo correo de verificación
      await currentUser?.sendEmailVerification();
      await _auth.signOut();

      return {
        'success': true,
        'message': '📧 Correo de verificación reenviado exitosamente.\n\n'
            'Revisa tu bandeja de entrada y carpeta de spam en: $email',
      };
    } on FirebaseAuthException catch (e) {
      if (e.code == 'too-many-requests') {
        return {
          'success': false,
          'message': '⏰ Demasiados intentos. Por favor espera unos minutos antes de solicitar otro correo.',
        };
      }
      return {
        'success': false,
        'message': _handleAuthException(e),
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error al reenviar correo: $e',
      };
    }
  }

  // Cerrar sesión
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Recuperación de contraseña
  Future<Map<String, dynamic>> resetPassword(String email) async {
    try {
      // Verificar si el email existe en Firestore
      final emailExists = await _emailExists(email);
      
      if (!emailExists) {
        return {
          'success': false,
          'message': 'No existe una cuenta registrada con este correo electrónico.',
        };
      }

      await _auth.sendPasswordResetEmail(email: email);
      
      return {
        'success': true,
        'message': '📧 Correo de recuperación enviado exitosamente.\n\n'
            'Revisa tu bandeja de entrada en: $email\n\n'
            'Si no lo encuentras, revisa la carpeta de spam.',
      };
    } on FirebaseAuthException catch (e) {
      return {
        'success': false,
        'message': _handleAuthException(e),
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error al enviar correo de recuperación: $e',
      };
    }
  }

  // Cambiar contraseña
  Future<Map<String, dynamic>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      User? user = currentUser;
      if (user == null) {
        return {
          'success': false,
          'message': 'No hay usuario autenticado',
        };
      }

      // Re-autenticar usuario
      AuthCredential credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );

      await user.reauthenticateWithCredential(credential);

      // Cambiar contraseña
      await user.updatePassword(newPassword);

      return {
        'success': true,
        'message': '✅ Contraseña actualizada exitosamente',
      };
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password') {
        return {
          'success': false,
          'message': '❌ La contraseña actual es incorrecta',
        };
      }
      return {
        'success': false,
        'message': _handleAuthException(e),
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error al cambiar contraseña: $e',
      };
    }
  }

  // Actualizar perfil de usuario
  Future<void> updateUserProfile({
    required String uid,
    required Map<String, dynamic> data,
  }) async {
    try {
      await _firestore.collection('users').doc(uid).update(data);
    } catch (e) {
      throw 'Error al actualizar perfil: $e';
    }
  }

  // Obtener datos del usuario actual
  Future<UserModel?> getCurrentUserData() async {
    try {
      User? user = currentUser;
      if (user == null) return null;

      // Verificar si el email está verificado
      await user.reload();
      user = _auth.currentUser;

      if (user == null || !user.emailVerified) {
        await _auth.signOut();
        return null;
      }

      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(user.uid).get();

      if (!userDoc.exists) return null;

      return UserModel.fromFirestore(userDoc);
    } catch (e) {
      return null;
    }
  }

  // Manejo de excepciones mejorado
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return '🔒 La contraseña es demasiado débil. Usa al menos 6 caracteres.';
      case 'email-already-in-use':
        return '📧 Este correo ya está registrado. Intenta iniciar sesión o recupera tu contraseña.';
      case 'invalid-email':
        return '❌ El formato del correo electrónico no es válido.';
      case 'user-not-found':
        return '❌ No existe una cuenta con este correo electrónico.';
      case 'wrong-password':
        return '🔑 Contraseña incorrecta. Verifica tus credenciales.';
      case 'too-many-requests':
        return '⏰ Demasiados intentos fallidos. Espera unos minutos e intenta nuevamente.';
      case 'user-disabled':
        return '⚠️ Esta cuenta ha sido deshabilitada. Contacta al administrador.';
      case 'requires-recent-login':
        return '🔐 Por seguridad, necesitas volver a iniciar sesión para realizar esta acción.';
      case 'network-request-failed':
        return '📡 Error de conexión. Verifica tu conexión a internet.';
      case 'invalid-credential':
        return '❌ Credenciales inválidas. Verifica tu correo y contraseña.';
      default:
        return '❌ Error de autenticación: ${e.message ?? 'Error desconocido'}';
    }
  }
}