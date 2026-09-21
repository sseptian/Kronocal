import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData buildTheme(Brightness brightness) {
    final bool isLight = brightness == Brightness.light;

    final scheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF9C27B0),
      brightness: brightness,
      primary: const Color(0xFF7B1FA2),
      secondary: const Color(0xFFE91E63),
      surface: isLight ? Colors.white : const Color(0xFF1A1222),
      surfaceContainerHighest: isLight
          ? const Color(0xFFF8F0FC)
          : const Color(0xFF2C1F38),
      surfaceContainerHigh: isLight
          ? const Color(0xFFFDF4FA)
          : const Color(0xFF261930),
      primaryContainer: isLight
          ? const Color(0xFFF3E5F5)
          : const Color(0xFF4A148C),
      onPrimaryContainer: isLight
          ? const Color(0xFF4A148C)
          : const Color(0xFFF3E5F5),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      appBarTheme: AppBarTheme(
        centerTitle: true,
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: isLight ? const Color(0xFFFAFAFA) : const Color(0xFF23182B),
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: isLight
              ? const BorderSide(color: Color(0xFFF0E5F5), width: 1)
              : BorderSide.none,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isLight ? const Color(0xFFF8F0FC) : const Color(0xFF2C1F38),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: scheme.surface,
        indicatorColor: const Color(0xFFF3E5F5),
      ),
    );
  }
}