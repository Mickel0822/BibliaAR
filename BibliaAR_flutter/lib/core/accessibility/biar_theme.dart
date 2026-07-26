import 'package:biblia_ar_flutter/core/accessibility/accessibility_sizes.dart';
import 'package:biblia_ar_flutter/core/accessibility/biar_design_tokens.dart';
import 'package:flutter/material.dart';

// kguanoluisa, Tema accesible BIAR extendido con tokens semanticos y estilos de formulario, sin nuevas variables, 2026-07-23
class BiarTheme {
  static const Color primaryColor = Color(0xFF1B4D8E);
  static const Color secondaryColor = Color(0xFFF4A024);
  static const Color backgroundColor = Color(0xFFF7F9FC);
  static const Color surfaceColor = Colors.white;
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF4A4A4A);
  static const Color successColor = Color(0xFF2E7D32);
  static const Color infoColor = Color(0xFF0277BD);
  static const Color warningColor = Color(0xFFF57C00);

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
            fontWeight: FontWeight.w600,
          ),
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
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
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(BiarRadius.lg),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(BiarRadius.md)),
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
