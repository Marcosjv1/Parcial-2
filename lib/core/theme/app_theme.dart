import 'package:flutter/material.dart';

/// Tema visual centralizado (Material 3).
///
/// Se usa sólo `ColorScheme.fromSeed` y `SnackBarThemeData`, APIs estables
/// en todas las versiones recientes de Flutter.
class AppTheme {
  AppTheme._();

  static const Color seed = Color(0xFF00796B); // Verde azulado

  static ThemeData get light => _build(Brightness.light);
  static ThemeData get dark => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: seed,
        brightness: brightness,
      ),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
