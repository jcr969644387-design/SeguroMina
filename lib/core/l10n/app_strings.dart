import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../constants/app_constants.dart';

/// Textos de la interfaz, cargados desde `assets/i18n/<locale>.json`.
///
/// Ninguna cadena visible para el usuario debe escribirse dentro de un widget.
/// Agregar un idioma nuevo debe ser agregar un archivo, no editar código: por
/// eso el i18n entra desde el Módulo 1 aunque las traducciones queden fuera
/// del MVP.
class AppStrings {
  const AppStrings(this._values, this.locale);

  final Map<String, String> _values;
  final String locale;

  /// Devuelve el texto de [key]. Si falta, devuelve la clave entre corchetes
  /// en vez de una cadena vacía: un texto faltante debe ser visible en QA,
  /// no silencioso.
  String call(String key) => _values[key] ?? '[$key]';

  /// Sustituye marcadores `{nombre}` por los valores dados.
  String format(String key, Map<String, Object?> args) {
    var text = call(key);
    args.forEach((name, value) {
      text = text.replaceAll('{$name}', '${value ?? ''}');
    });
    return text;
  }

  static Future<AppStrings> load(String locale) async {
    final raw = await rootBundle.loadString('${AppConstants.i18nPath}/$locale.json');
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    final values = decoded.map(
      (key, value) => MapEntry(key, value.toString()),
    );
    return AppStrings(values, locale);
  }
}

/// Locale activo. El Módulo 12 lo conectará con las preferencias guardadas.
final localeProvider = StateProvider<String>(
  (ref) => AppConstants.defaultLocale,
);

final appStringsProvider = FutureProvider<AppStrings>((ref) {
  final locale = ref.watch(localeProvider);
  return AppStrings.load(locale);
});
