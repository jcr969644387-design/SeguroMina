import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Acceso a las preferencias locales del estudiante.
///
/// Es una interfaz y no una llamada directa a `shared_preferences` para que
/// los tests corran sin canales de plataforma y para que cambiar el
/// almacenamiento no obligue a tocar la interfaz.
abstract interface class PreferencesRepository {
  bool readBool(String key, {bool fallback = false});
  Future<void> writeBool(String key, {required bool value});

  int readInt(String key, {int fallback = 0});
  Future<void> writeInt(String key, int value);

  List<String> readStringList(String key);
  Future<void> writeStringList(String key, List<String> value);
}

/// Implementacion sobre `shared_preferences`.
///
/// Recibe la instancia ya resuelta: la lectura debe ser sincrona para que el
/// primer frame sepa si toca onboarding o home, sin un parpadeo intermedio.
class SharedPreferencesRepository implements PreferencesRepository {
  const SharedPreferencesRepository(this._prefs);

  final SharedPreferences _prefs;

  @override
  bool readBool(String key, {bool fallback = false}) {
    return _prefs.getBool(key) ?? fallback;
  }

  @override
  Future<void> writeBool(String key, {required bool value}) {
    return _prefs.setBool(key, value);
  }

  @override
  int readInt(String key, {int fallback = 0}) {
    return _prefs.getInt(key) ?? fallback;
  }

  @override
  Future<void> writeInt(String key, int value) {
    return _prefs.setInt(key, value);
  }

  @override
  List<String> readStringList(String key) {
    return _prefs.getStringList(key) ?? const <String>[];
  }

  @override
  Future<void> writeStringList(String key, List<String> value) {
    return _prefs.setStringList(key, value);
  }
}

/// Implementacion en memoria para tests y para el modo de demostracion.
class InMemoryPreferencesRepository implements PreferencesRepository {
  InMemoryPreferencesRepository([Map<String, Object>? seed])
      : _values = <String, Object>{...?seed};

  final Map<String, Object> _values;

  @override
  bool readBool(String key, {bool fallback = false}) {
    final value = _values[key];
    return value is bool ? value : fallback;
  }

  @override
  Future<void> writeBool(String key, {required bool value}) async {
    _values[key] = value;
  }

  @override
  int readInt(String key, {int fallback = 0}) {
    final value = _values[key];
    return value is int ? value : fallback;
  }

  @override
  Future<void> writeInt(String key, int value) async {
    _values[key] = value;
  }

  @override
  List<String> readStringList(String key) {
    final value = _values[key];
    return value is List<String> ? value : const <String>[];
  }

  @override
  Future<void> writeStringList(String key, List<String> value) async {
    _values[key] = value;
  }
}

/// Se sobrescribe en `main()` con la instancia real y en los tests con la
/// version en memoria. No tiene implementacion por defecto a proposito: un
/// olvido debe fallar al arrancar, no guardar en un almacen que se descarta.
final preferencesRepositoryProvider = Provider<PreferencesRepository>((ref) {
  throw UnimplementedError(
    'preferencesRepositoryProvider debe sobrescribirse en main() o en el test.',
  );
});
