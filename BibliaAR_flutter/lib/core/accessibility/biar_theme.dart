import 'package:biblia_ar_flutter/core/accessibility/accessibility_sizes.dart';
import 'package:biblia_ar_flutter/core/accessibility/biar_design_tokens.dart';
import 'package:flutter/material.dart';

// kguanoluisa, Tema accesible BIAR extendido con tokens semanticos y estilos de formulario, sin nuevas variables, 2026-07-23
class BiarTheme {
  static const Color primaryColor = Color(0xFF6366F1); // Indigo premium
  static const Color secondaryColor = Color(0xFFFF7A00); // Naranja cálido
  static const Color backgroundColor = Color(0xFFF8FAFC); // Slate 50
  static const Color surfaceColor = Colors.white;
  static const Color textPrimary = Color(0xFF0F172A); // Slate 900
  static const Color textSecondary = Color(0xFF475569); // Slate 600
  static const Color successColor = Color(0xFF10B981); // Emerald
  static const Color infoColor = Color(0xFF3B82F6); // Blue
  static const Color warningColor = Color(0xFFF59E0B); // Amber

  static ThemeData light() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primaryColor,
      primary: primaryColor,
      secondary: secondaryColor,
      surface: surfaceColor,
      onPrimary: Colors.white,
      onSecondary: textPrimary,
      onSurface: textPrimary,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: backgroundColor,
      textTheme: const TextTheme(
        bodyLarge: TextStyle(
          fontSize: AccessibilitySizes.minFontSize,
          color: textPrimary,
          height: 1.5,
        ),
        bodyMedium: TextStyle(
          fontSize: AccessibilitySizes.minFontSize,
          color: textSecondary,
          height: 1.5,
        ),
        titleLarge: TextStyle(
          fontSize: AccessibilitySizes.titleFontSize,
          fontWeight: FontWeight.bold,
          color: textPrimary,
        ),
        labelLarge: TextStyle(
          fontSize: AccessibilitySizes.minFontSize,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size.fromHeight(AccessibilitySizes.buttonMinHeight),
          textStyle: const TextStyle(
            fontSize: AccessibilitySizes.minFontSize,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 2,
          shadowColor: primaryColor.withValues(alpha: 0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(BiarRadius.lg),
          ),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? primaryColor
              : Colors.grey.shade400,
        ),
      ),
      cardTheme: CardThemeData(
        color: surfaceColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(BiarRadius.lg),
          side: const BorderSide(
            color: Color(0xFFE2E8F0), // Borde sutil gris Slate
            width: 1.5,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(BiarRadius.md),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(BiarRadius.md),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(BiarRadius.md),
          borderSide: const BorderSide(color: primaryColor, width: 2.0),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: BiarSpacing.md,
          vertical: BiarSpacing.sm,
        ),
      ),
      dividerTheme: const DividerThemeData(space: BiarSpacing.lg),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(BiarRadius.md)),
      ),
    );
  }
}
