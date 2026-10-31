import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  static ThemeData dark() {
    final scheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF8E44AD),
      brightness: Brightness.dark,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: const Color(0xFF120A1C),
      appBarTheme: AppBarTheme(
        backgroundColor: const Color(0xFF1C102B),
        foregroundColor: scheme.onSurface,
      ),
    );
  }
}
