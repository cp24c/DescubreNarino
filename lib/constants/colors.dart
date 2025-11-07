import 'package:flutter/material.dart';

/// Paleta de colores para modo CLARO
class AppColors {
  // Colores primarios
  static const Color primary = Color(0xFFF28705);
  static const Color secondary = Color(0xFFD96704);
  static const Color warning = Color(0xFFFFC107);
  static const Color accent = Color(0xFFF2A71B);
  
  // Colores de fondo y texto
  static const Color background = Color(0xFFF8F9FA);
  static const Color darkText = Color(0xFF2C3E50);
  static const Color lightText = Color(0xFF7F8C8D);
  static const Color white = Color(0xFFFFFFFF);
  
  // Colores de estado
  static const Color error = Color(0xFFE74C3C);
  static const Color success = Color(0xFF27AE60);

  // Gradientes
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

/// Paleta de colores para modo OSCURO
/// Diseñado para ser suave a la vista y mantener buena legibilidad
class AppColorsDark {
  // Colores primarios (ligeramente más suaves y brillantes)
  static const Color primary = Color(0xFFFF9F1C); // Naranja más brillante
  static const Color secondary = Color(0xFFFFB547);
  static const Color warning = Color(0xFFFFC837);
  static const Color accent = Color(0xFFFFB84D);
  
  // Colores de fondo y texto (invertidos y ajustados)
  static const Color background = Color(0xFF121212); // Negro suave
  static const Color surface = Color(0xFF1E1E1E); // Gris oscuro para tarjetas
  static const Color surfaceVariant = Color(0xFF2C2C2C); // Variante más clara
  static const Color darkText = Color(0xFFE8E8E8); // Blanco suave
  static const Color lightText = Color(0xFFB0B0B0); // Gris claro
  static const Color white = Color(0xFFFFFFFF);
  static const Color divider = Color(0xFF2C2C2C); // Divisores sutiles
  
  // Colores de estado (ajustados para mejor visibilidad)
  static const Color error = Color(0xFFFF6B6B); // Rojo más suave
  static const Color success = Color(0xFF51CF66); // Verde más brillante

  // Gradientes (ajustados para modo oscuro)
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // Gradiente suave para fondos
  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [background, Color(0xFF1A1A1A)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}