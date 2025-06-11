import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ─────────────────────────  PALETA CORPORATIVA
const _kTomato = Color(0xFFF06449);
const _kSoftWhite = Color(0xFFEDE6E3);
const _kSoftGrey = Color(0xFFDADAD9);
const _kOlive = Color(0xFF36382E);
const _kSky = Color(0xFF5BC3EB);

// ─────────────────────────  COLOR SCHEMES
const _lightScheme = ColorScheme(
  brightness: Brightness.light,
  primary: _kTomato,
  onPrimary: Colors.white,
  primaryContainer: _kSoftGrey,
  onPrimaryContainer: _kTomato,
  secondary: _kSky,
  onSecondary: Colors.white,
  secondaryContainer: _kSoftGrey,
  onSecondaryContainer: Colors.black,
  surface: _kSoftWhite, // <─ usado por Scaffold & Cards
  onSurface: Colors.black,
  surfaceContainerHighest: _kSoftGrey,
  onSurfaceVariant: Colors.black87,
  error: Colors.red,
  onError: Colors.white,
  outline: Colors.black45,
);

const _darkScheme = ColorScheme(
  brightness: Brightness.dark,
  primary: _kTomato,
  onPrimary: Colors.black,
  primaryContainer: _kOlive,
  onPrimaryContainer: _kTomato,
  secondary: _kSky,
  onSecondary: Colors.black,
  secondaryContainer: _kOlive,
  onSecondaryContainer: Colors.white,
  surface: _kOlive,
  onSurface: Colors.white,
  surfaceContainerHighest: Color(0xFF2B2C28),
  onSurfaceVariant: Colors.white70,
  error: Colors.redAccent,
  onError: Colors.black,
  outline: Colors.white54,
);

// ─────────────────────────  TIPOGRAFÍA (Source Sans 3)
TextTheme _textTheme(ColorScheme c) => GoogleFonts.ralewayTextTheme().apply(
      bodyColor: c.onSurface,
      displayColor: c.onSurface,
    );

// ─────────────────────────  SHIMMER / SKELETON COLORS
@immutable
class ShimmerColors extends ThemeExtension<ShimmerColors> {
  const ShimmerColors({required this.base, required this.highlight});
  final Color base;
  final Color highlight;

  @override
  ShimmerColors copyWith({Color? base, Color? highlight}) => ShimmerColors(
      base: base ?? this.base, highlight: highlight ?? this.highlight);

  @override
  ThemeExtension<ShimmerColors> lerp(
      ThemeExtension<ShimmerColors>? other, double t) {
    if (other is! ShimmerColors) return this;
    return ShimmerColors(
      base: Color.lerp(base, other.base, t)!,
      highlight: Color.lerp(highlight, other.highlight, t)!,
    );
  }
}

// ─────────────────────────  THEME BUILDER
ThemeData _build(ColorScheme scheme) {
  final txt = _textTheme(scheme);

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: scheme.surface,
    textTheme: txt,
    appBarTheme: AppBarTheme(
      elevation: 0,
      backgroundColor: scheme.surface,
      iconTheme: IconThemeData(color: scheme.onSurface),
      titleTextStyle: txt.titleLarge?.copyWith(fontWeight: FontWeight.w600),
    ),

    // ─────────────── BOTONES  ───────────────
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        minimumSize: const Size.fromHeight(48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        textStyle: txt.labelLarge?.copyWith(
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        backgroundColor: scheme.primaryContainer,
        foregroundColor: scheme.onPrimaryContainer,
        textStyle: txt.labelLarge?.copyWith(
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        side: BorderSide(color: scheme.outline),
        foregroundColor: scheme.onSurface,
        textStyle: txt.labelLarge?.copyWith(
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
    ),

    // ─────────────── TEXTFIELDS ──────────
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: scheme.surfaceContainerHighest.withAlpha(77),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.l,
        vertical: AppSpacing.l,
      ),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(4)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: BorderSide(color: scheme.outline),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: BorderSide(color: scheme.primary, width: 2),
      ),
      labelStyle: txt.bodyLarge,
    ),
    // ───────────────────────────────────────────────────────────────────

    cardTheme: const CardThemeData(
      elevation: 1,
      margin: EdgeInsets.all(8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(4)),
      ),
    ),
    extensions: [
      ShimmerColors(
        base: scheme.surfaceContainerHighest.withAlpha(38), // 15 %
        highlight: scheme.surfaceContainerHighest.withAlpha(13), // 5 %
      ),
    ],
  );
}

// ─────────────────────────  PUNTO DE ACCESO PÚBLICO
class AppTheme {
  static final light = _build(_lightScheme);
  static final dark = _build(_darkScheme);
}

// ─────────────────────────  ESPACIADOS (dp)
class AppSpacing {
  static const double xs = 4;
  static const double s = 8;
  static const double m = 12;
  static const double l = 16;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 48;
}
