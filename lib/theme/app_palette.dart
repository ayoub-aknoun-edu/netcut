import 'package:flutter/widgets.dart';

class AppPalette {
  final Color primary;
  final Color onPrimary;
  final Color primaryContainer;
  final Color onPrimaryContainer;

  final Color secondary;
  final Color onSecondary;
  final Color secondaryContainer;
  final Color onSecondaryContainer;

  final Color tertiary;
  final Color onTertiary;

  final Color background;
  final Color onBackground;

  final Color surface;
  final Color onSurface;

  final Color surfaceVariant;
  final Color onSurfaceVariant;

  final Color outline;
  final Color outlineVariant;

  final Color error;
  final Color onError;
  final Color errorContainer;
  final Color onErrorContainer;

  final Color inverseSurface;
  final Color onInverseSurface;

  const AppPalette({
    required this.primary,
    required this.onPrimary,
    required this.primaryContainer,
    required this.onPrimaryContainer,
    required this.secondary,
    required this.onSecondary,
    required this.secondaryContainer,
    required this.onSecondaryContainer,
    required this.tertiary,
    required this.onTertiary,
    required this.background,
    required this.onBackground,
    required this.surface,
    required this.onSurface,
    required this.surfaceVariant,
    required this.onSurfaceVariant,
    required this.outline,
    required this.outlineVariant,
    required this.error,
    required this.onError,
    required this.errorContainer,
    required this.onErrorContainer,
    required this.inverseSurface,
    required this.onInverseSurface,
  });

  static const light = AppPalette(
    primary: Color(0xFF4F46E5),
    onPrimary: Color(0xFFFFFFFF),
    primaryContainer: Color(0xFFE0E7FF),
    onPrimaryContainer: Color(0xFF1E1B4B),

    secondary: Color(0xFF14B8A6),
    onSecondary: Color(0xFFFFFFFF),
    secondaryContainer: Color(0xFFCCFBF1),
    onSecondaryContainer: Color(0xFF042F2E),

    tertiary: Color(0xFFF59E0B),
    onTertiary: Color(0xFF1F1300),

    background: Color(0xFFF8FAFC),
    onBackground: Color(0xFF0F172A),

    surface: Color(0xFFFFFFFF),
    onSurface: Color(0xFF0F172A),

    surfaceVariant: Color(0xFFEEF2F7),
    onSurfaceVariant: Color(0xFF334155),

    outline: Color(0xFFCBD5E1),
    outlineVariant: Color(0xFFE2E8F0),

    error: Color(0xFFDC2626),
    onError: Color(0xFFFFFFFF),
    errorContainer: Color(0xFFFEE2E2),
    onErrorContainer: Color(0xFF450A0A),

    inverseSurface: Color(0xFF0F172A),
    onInverseSurface: Color(0xFFF8FAFC),
  );

  static const dark = AppPalette(
    primary: Color(0xFF818CF8),
    onPrimary: Color(0xFF0B1220),
    primaryContainer: Color(0xFF2A2F6F),
    onPrimaryContainer: Color(0xFFE0E7FF),

    secondary: Color(0xFF2DD4BF),
    onSecondary: Color(0xFF062A2A),
    secondaryContainer: Color(0xFF0F3D3A),
    onSecondaryContainer: Color(0xFFCCFBF1),

    tertiary: Color(0xFFFBBF24),
    onTertiary: Color(0xFF1F1300),

    background: Color(0xFF0B1220),
    onBackground: Color(0xFFE5E7EB),

    surface: Color(0xFF111827),
    onSurface: Color(0xFFE5E7EB),

    surfaceVariant: Color(0xFF1F2937),
    onSurfaceVariant: Color(0xFFCBD5E1),

    outline: Color(0xFF334155),
    outlineVariant: Color(0xFF1F2A3A),

    error: Color(0xFFF87171),
    onError: Color(0xFF3B0A0A),
    errorContainer: Color(0xFF4C1010),
    onErrorContainer: Color(0xFFFEE2E2),

    inverseSurface: Color(0xFFE5E7EB),
    onInverseSurface: Color(0xFF0B1220),
  );
}
