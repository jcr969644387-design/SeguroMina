import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Ajustes de apariencia y accesibilidad.
///
/// En el Módulo 1 viven solo en memoria. El Módulo 12 los persistirá con
/// `shared_preferences` sin cambiar esta interfaz.
@immutable
class AppSettings {
  const AppSettings({
    this.themeMode = ThemeMode.system,
    this.textScale = 1.0,
  });

  final ThemeMode themeMode;

  /// Factor de escala del texto, entre 0.9 y 1.6.
  ///
  /// Se limita por arriba porque la pantalla de inspección tiene una hoja
  /// inferior con contenido fijo; por encima de 1.6 el diseño deja de
  /// respetarse y hay que ofrecer un layout alternativo.
  final double textScale;

  AppSettings copyWith({ThemeMode? themeMode, double? textScale}) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      textScale: textScale ?? this.textScale,
    );
  }
}

class AppSettingsNotifier extends Notifier<AppSettings> {
  static const double minTextScale = 0.9;
  static const double maxTextScale = 1.6;

  @override
  AppSettings build() => const AppSettings();

  void setThemeMode(ThemeMode mode) {
    state = state.copyWith(themeMode: mode);
  }

  void setTextScale(double scale) {
    state = state.copyWith(
      textScale: scale.clamp(minTextScale, maxTextScale),
    );
  }
}

final appSettingsProvider =
    NotifierProvider<AppSettingsNotifier, AppSettings>(AppSettingsNotifier.new);
