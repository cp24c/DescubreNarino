import 'package:flutter/material.dart';
import '../constants/colors.dart';

/// Helper extension para obtener colores según el tema actual
extension ThemeAwareColors on BuildContext {
  /// Obtiene el color primario según el tema
  Color get primaryColor {
    return Theme.of(this).brightness == Brightness.dark
        ? AppColorsDark.primary
        : AppColors.primary;
  }

  /// Obtiene el color de fondo según el tema
  Color get backgroundColor {
    return Theme.of(this).brightness == Brightness.dark
        ? AppColorsDark.background
        : AppColors.background;
  }

  /// Obtiene el color de superficie (para cards) según el tema
  Color get surfaceColor {
    return Theme.of(this).brightness == Brightness.dark
        ? AppColorsDark.surface
        : AppColors.white;
  }

  /// Obtiene el color de texto oscuro según el tema
  Color get darkTextColor {
    return Theme.of(this).brightness == Brightness.dark
        ? AppColorsDark.darkText
        : AppColors.darkText;
  }

  /// Obtiene el color de texto claro según el tema
  Color get lightTextColor {
    return Theme.of(this).brightness == Brightness.dark
        ? AppColorsDark.lightText
        : AppColors.lightText;
  }

  /// Obtiene el color de error según el tema
  Color get errorColor {
    return Theme.of(this).brightness == Brightness.dark
        ? AppColorsDark.error
        : AppColors.error;
  }

  /// Obtiene el color de éxito según el tema
  Color get successColor {
    return Theme.of(this).brightness == Brightness.dark
        ? AppColorsDark.success
        : AppColors.success;
  }

  /// Verifica si está en modo oscuro
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;

  /// Obtiene el gradiente primario según el tema
  LinearGradient get primaryGradient {
    return Theme.of(this).brightness == Brightness.dark
        ? AppColorsDark.primaryGradient
        : AppColors.primaryGradient;
  }
}

/// Widget que adapta su color según el tema
class ThemeAwareContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadiusGeometry? borderRadius;
  final bool useSurface; // Si es true, usa color de superficie en vez de fondo

  const ThemeAwareContainer({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius,
    this.useSurface = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      margin: margin,
      decoration: BoxDecoration(
        color: useSurface
            ? context.surfaceColor
            : context.backgroundColor,
        borderRadius: borderRadius,
        boxShadow: [
          BoxShadow(
            color: context.isDarkMode
                ? Colors.black.withOpacity(0.3)
                : Colors.black.withOpacity(0.1),
            blurRadius: context.isDarkMode ? 8 : 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}