import 'dart:convert';

import '../../domain/library/library_content.dart';

/// Lectura del archivo de contenido de la biblioteca.
///
/// Dart puro y sin Flutter, a proposito: asi el contenido se puede validar en
/// un test que corre en milisegundos, y una ficha mal formada se detecta en
/// integracion continua y no en el telefono de un estudiante.
class LibraryFormatException implements Exception {
  const LibraryFormatException(this.message);

  final String message;

  @override
  String toString() => 'LibraryFormatException: $message';
}

LibraryContent parseLibraryContent(String raw) {
  final Object? decoded = jsonDecode(raw);
  if (decoded is! Map<String, dynamic>) {
    throw const LibraryFormatException('La raiz debe ser un objeto.');
  }

  final categories = decoded['categories'];
  if (categories is! List) {
    throw const LibraryFormatException('Falta la lista "categories".');
  }

  return LibraryContent(
    categories: <LibraryCategory>[
      for (final item in categories) _category(item),
    ],
  );
}

LibraryCategory _category(Object? item) {
  final map = _object(item, 'categoria');
  final topics = map['topics'];
  if (topics is! List || topics.isEmpty) {
    throw LibraryFormatException(
      'La categoria "${map['id']}" no tiene temas.',
    );
  }

  return LibraryCategory(
    id: _string(map, 'id'),
    title: _string(map, 'title'),
    description: _string(map, 'description'),
    topics: topics.map((Object? item) => _topic(item)).toList(growable: false),
  );
}

LibraryTopic _topic(Object? item) {
  final map = _object(item, 'tema');
  final sections = map['sections'];
  if (sections is! List || sections.isEmpty) {
    throw LibraryFormatException('El tema "${map['id']}" no tiene secciones.');
  }

  return LibraryTopic(
    id: _string(map, 'id'),
    title: _string(map, 'title'),
    summary: _string(map, 'summary'),
    miningExample: _string(map, 'miningExample'),
    diagram: map['diagram'] as String?,
    sections: <LibrarySection>[
      for (final item in sections) _section(item),
    ],
    check: map['check'] == null ? null : _check(map['check']),
  );
}

LibrarySection _section(Object? item) {
  final map = _object(item, 'seccion');
  return LibrarySection(
    heading: _string(map, 'heading'),
    body: _string(map, 'body'),
  );
}

CheckQuestion _check(Object? item) {
  final map = _object(item, 'pregunta');
  final options = map['options'];
  if (options is! List || options.length < 2) {
    throw const LibraryFormatException(
      'Una pregunta necesita al menos dos opciones.',
    );
  }

  final correct = map['correctIndex'];
  if (correct is! int || correct < 0 || correct >= options.length) {
    throw const LibraryFormatException(
      'correctIndex fuera del rango de opciones.',
    );
  }

  return CheckQuestion(
    prompt: _string(map, 'prompt'),
    options: options.map((Object? o) => o.toString()).toList(growable: false),
    correctIndex: correct,
    explanation: _string(map, 'explanation'),
  );
}

Map<String, dynamic> _object(Object? item, String what) {
  if (item is! Map<String, dynamic>) {
    throw LibraryFormatException('Se esperaba un objeto para $what.');
  }
  return item;
}

String _string(Map<String, dynamic> map, String key) {
  final value = map[key];
  if (value is! String || value.trim().isEmpty) {
    throw LibraryFormatException('Falta el campo "$key" o esta vacio.');
  }
  return value;
}
