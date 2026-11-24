import 'package:flutter/material.dart';

/// Tema institucional de la aplicación.
///
/// Un solo esquema generado con `ColorScheme.fromSeed` alimenta cuatro
/// variantes: claro, oscuro y sus versiones de alto contraste. La tipografía
/// mantiene un cuerpo base de 18 sp y objetivos táctiles de 48 × 48.
class AppTheme {
  const AppTheme._();

  static const Color azulInstitucional = Color(0xFF194D84);
  static const Color cianInstitucional = Color(0xFF00CEFE);

  static ThemeData get claro => _tema(Brightness.light);

  static ThemeData get oscuro => _tema(Brightness.dark);

  static ThemeData get altoContrasteClaro =>
      _tema(Brightness.light, contraste: 1.0);

  static ThemeData get altoContrasteOscuro =>
      _tema(Brightness.dark, contraste: 1.0);

  static ThemeData _tema(
    Brightness brillo, {
    double contraste = 0.0,
  }) {
    final esquema = ColorScheme.fromSeed(
      seedColor: azulInstitucional,
      brightness: brillo,
      contrastLevel: contraste,
    );

    final base = ThemeData(
      useMaterial3: true,
      colorScheme: esquema,
    );

    final tipografia = base.textTheme.copyWith(
      headlineSmall: base.textTheme.headlineSmall?.copyWith(
        fontSize: 26,
        fontWeight: FontWeight.w700,
      ),
      titleLarge: base.textTheme.titleLarge?.copyWith(
        fontSize: 22,
        fontWeight: FontWeight.w600,
      ),
      titleMedium: base.textTheme.titleMedium?.copyWith(
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: base.textTheme.bodyLarge?.copyWith(
        fontSize: 18,
        height: 1.4,
      ),
      bodyMedium: base.textTheme.bodyMedium?.copyWith(
        fontSize: 18,
        height: 1.4,
      ),
      labelLarge: base.textTheme.labelLarge?.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
    );

    return base.copyWith(
      scaffoldBackgroundColor: esquema.surface,
      textTheme: tipografia,
      appBarTheme: AppBarTheme(
        backgroundColor: esquema.primary,
        foregroundColor: esquema.onPrimary,
        centerTitle: false,
        elevation: 0,
        titleTextStyle: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: esquema.onPrimary,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: esquema.surfaceContainerHighest,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(64, 48),
          textStyle: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(64, 48),
          textStyle: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: esquema.primary,
        foregroundColor: esquema.onPrimary,
      ),
    );
  }
}
