import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData darkAmber() {
    final scheme =
        ColorScheme.fromSeed(
          seedColor: Colors.amber,
          brightness: Brightness.dark,
        ).copyWith(
          background: const Color(0xFF0A0A0A),
          surface: const Color(0xFF111111),
          onPrimary: Colors.black,
        );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.background,
      appBarTheme: const AppBarTheme(centerTitle: true, elevation: 4),

      bottomAppBarTheme: BottomAppBarThemeData(
        color: scheme.surface,
        elevation: 10,
        surfaceTintColor: Colors.transparent,
        height: 64,
      ),

      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        elevation: 3,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: scheme.surface,
        contentTextStyle: TextStyle(color: scheme.onSurface),
      ),
      dividerTheme: DividerThemeData(color: Colors.white.withOpacity(0.08)),
    );
  }
}
