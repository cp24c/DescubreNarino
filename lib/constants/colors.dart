import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFFF28705);
  static const Color secondary = Color(0xFFD96704);
  static const Color warning = Color(0xFFFFC107);
  static const Color accent = Color(0xFFF2A71B);
  static const Color background = Color(0xFFF8F9FA);
  static const Color darkText = Color(0xFF2C3E50);
  static const Color lightText = Color(0xFF7F8C8D);
  static const Color white = Color(0xFFFFFFFF);
  static const Color error = Color(0xFFE74C3C);
  static const Color success = Color(0xFF27AE60);

  // Gradientes
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
