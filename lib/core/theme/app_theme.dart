import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_typography.dart';

/// Construcción de los temas claro y oscuro.
///
/// Ambos temas se generan desde la misma paleta para que un cambio de color
/// de marca no obligue a tocar dos definiciones.
abstract final class AppTheme {
  static ThemeData get light => _build(
        brightness: Brightness.light,
        scheme: const ColorScheme.light(
          primary: AppColors.primary,
          onPrimary: Colors.white,
          secondary: AppColors.secondary,
          onSecondary: AppColors.onSecondary,
          tertiary: AppColors.accent,
          onTertiary: Colors.white,
          surface: AppColors.backgroundLight,
          onSurface: AppColors.textPrimary,
          surfaceContainerHighest: AppColors.surfaceLight,
          error: AppColors.error,
          onError: Colors.white,
        ),
        textColor: AppColors.textPrimary,
        mutedTextColor: AppColors.textSecondary,
      );

  static ThemeData get dark => _build(
        brightness: Brightness.dark,
        scheme: const ColorScheme.dark(
          // En fondo oscuro el azul de marca no alcanza contraste AA,
          // por eso se usa la variante clara como primario.
          primary: AppColors.primaryLight,
          onPrimary: Color(0xFF10243A),
          secondary: AppColors.secondary,
          onSecondary: AppColors.onSecondary,
          tertiary: AppColors.accent,
          onTertiary: Color(0xFF08160D),
          surface: AppColors.backgroundDark,
          onSurface: AppColors.textPrimaryDark,
          surfaceContainerHighest: AppColors.surfaceDark,
          error: AppColors.error,
          onError: Colors.white,
        ),
        textColor: AppColors.textPrimaryDark,
        mutedTextColor: AppColors.textSecondaryDark,
      );

  static ThemeData _build({
    required Brightness brightness,
    required ColorScheme scheme,
    required Color textColor,
    required Color mutedTextColor,
  }) {
    final TextTheme textTheme = TextTheme(
      displaySmall: AppTypography.display.copyWith(color: textColor),
      headlineSmall: AppTypography.heading.copyWith(color: textColor),
      titleMedium: AppTypography.subheading.copyWith(color: textColor),
      bodyLarge: AppTypography.body.copyWith(color: textColor),
      bodyMedium: AppTypography.bodySmall.copyWith(color: textColor),
      labelLarge: AppTypography.label.copyWith(color: textColor),
      bodySmall: AppTypography.caption.copyWith(color: mutedTextColor),
    );

    return ThemeData(
      useMaterial3: true,
      fontFamily: AppTypography.fontFamily,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: textColor,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: AppTypography.subheading.copyWith(color: textColor),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(AppSpacing.minTouchTarget),
          textStyle: AppTypography.label,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radius),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(AppSpacing.minTouchTarget),
          textStyle: AppTypography.label,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radius),
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: scheme.surfaceContainerHighest,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radius),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: mutedTextColor.withValues(alpha: 0.25),
        space: 1,
        thickness: 1,
      ),
    );
  }
}
