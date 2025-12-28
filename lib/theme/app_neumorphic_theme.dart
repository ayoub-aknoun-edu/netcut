import 'package:flutter/material.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:google_fonts/google_fonts.dart';

class AppNeumorphicTheme {
  // Modern color palette
  static const _lightBackground = Color(0xFFF5F7FA);
  static const _lightSurface = Color(0xFFFFFFFF);
  static const _lightPrimary = Color(0xFF6366F1); // Indigo
  static const _lightSecondary = Color(0xFF8B5CF6); // Purple
  static const _lightAccent = Color(0xFF06B6D4); // Cyan

  static const _darkBackground = Color(0xFF0F172A);
  static const _darkSurface = Color(0xFF1E293B);
  static const _darkPrimary = Color(0xFF818CF8);
  static const _darkSecondary = Color(0xFFA78BFA);
  static const _darkAccent = Color(0xFF22D3EE);

  static NeumorphicThemeData lightTheme() {
    return NeumorphicThemeData(
      baseColor: _lightBackground,
      lightSource: LightSource.topLeft,
      depth: 4,
      intensity: 0.5,
      textTheme: GoogleFonts.interTextTheme(),
    );
  }

  static NeumorphicThemeData darkTheme() {
    return NeumorphicThemeData(
      baseColor: _darkBackground,
      lightSource: LightSource.topLeft,
      depth: 6,
      intensity: 0.3,
      textTheme: GoogleFonts.interTextTheme(),
    );
  }

  // Extended color system
  static ColorPalette light() => ColorPalette(
    background: _lightBackground,
    surface: _lightSurface,
    surfaceVariant: const Color(0xFFF1F5F9),
    primary: _lightPrimary,
    primaryContainer: _lightPrimary.withOpacity(0.12),
    secondary: _lightSecondary,
    secondaryContainer: _lightSecondary.withOpacity(0.12),
    accent: _lightAccent,
    error: const Color(0xFFEF4444),
    errorContainer: const Color(0xFFEF4444).withOpacity(0.12),
    onBackground: const Color(0xFF0F172A),
    onSurface: const Color(0xFF334155),
    onSurfaceVariant: const Color(0xFF64748B),
    onPrimary: Colors.white,
    outline: const Color(0xFFE2E8F0),
    outlineVariant: const Color(0xFFCBD5E1),
    shadow: Colors.black.withOpacity(0.08),
  );

  static ColorPalette dark() => ColorPalette(
    background: _darkBackground,
    surface: _darkSurface,
    surfaceVariant: const Color(0xFF334155),
    primary: _darkPrimary,
    primaryContainer: _darkPrimary.withOpacity(0.2),
    secondary: _darkSecondary,
    secondaryContainer: _darkSecondary.withOpacity(0.2),
    accent: _darkAccent,
    error: const Color(0xFFF87171),
    errorContainer: const Color(0xFFF87171).withOpacity(0.2),
    onBackground: const Color(0xFFF1F5F9),
    onSurface: const Color(0xFFE2E8F0),
    onSurfaceVariant: const Color(0xFF94A3B8),
    onPrimary: const Color(0xFF0F172A),
    outline: const Color(0xFF475569),
    outlineVariant: const Color(0xFF334155),
    shadow: Colors.black.withOpacity(0.3),
  );
}

class ColorPalette {
  final Color background;
  final Color surface;
  final Color surfaceVariant;
  final Color primary;
  final Color primaryContainer;
  final Color secondary;
  final Color secondaryContainer;
  final Color accent;
  final Color error;
  final Color errorContainer;
  final Color onBackground;
  final Color onSurface;
  final Color onSurfaceVariant;
  final Color onPrimary;
  final Color outline;
  final Color outlineVariant;
  final Color shadow;

  const ColorPalette({
    required this.background,
    required this.surface,
    required this.surfaceVariant,
    required this.primary,
    required this.primaryContainer,
    required this.secondary,
    required this.secondaryContainer,
    required this.accent,
    required this.error,
    required this.errorContainer,
    required this.onBackground,
    required this.onSurface,
    required this.onSurfaceVariant,
    required this.onPrimary,
    required this.outline,
    required this.outlineVariant,
    required this.shadow,
  });
}
