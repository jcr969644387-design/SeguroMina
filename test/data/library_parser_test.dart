import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:seguromina/data/library/library_parser.dart';
import 'package:seguromina/domain/library/library_content.dart';
import 'package:seguromina/features/library/widgets/technical_diagrams.dart';

/// Validacion del contenido educativo empaquetado.
///
/// El material de la biblioteca crece sin tocar codigo, asi que nada impide
/// que una ficha entre mal formada. Esto lo detecta en integracion continua y
/// no en el telefono de un estudiante en medio de una labor.
void main() {
  final raw = File('assets/content/library.json').readAsStringSync();
  final content = parseLibraryContent(raw);

  test('el archivo de contenido se lee y trae las dos categorias', () {
    expect(content.categories, hasLength(2));
    expect(content.categoryById('fundamentos'), isNotNull);
    expect(content.categoryById('iperc'), isNotNull);
  });

  test('los identificadores de las fichas no se repiten', () {
    final ids = content.allTopics.map((LibraryTopic t) => t.id).toList();
    expect(ids.toSet().length, ids.length);
  });

  test('toda ficha tiene secciones y ejemplo minero', () {
    for (final topic in content.allTopics) {
      expect(
        topic.sections,
        isNotEmpty,
        reason: 'La ficha "${topic.id}" no tiene secciones',
      );
      expect(
        topic.miningExample.trim(),
        isNotEmpty,
        reason: 'La ficha "${topic.id}" no tiene ejemplo minero',
      );
    }
  });

  test('los diagramas referenciados existen', () {
    for (final topic in content.allTopics) {
      final diagram = topic.diagram;
      if (diagram == null) {
        continue;
      }
      expect(
        TechnicalDiagram.available,
        contains(diagram),
        reason: 'La ficha "${topic.id}" pide un diagrama inexistente',
      );
    }
  });

  test('las preguntas de comprobacion son coherentes', () {
    for (final topic in content.allTopics) {
      final check = topic.check;
      if (check == null) {
        continue;
      }
      expect(
        check.options.length,
        greaterThanOrEqualTo(2),
        reason: 'La pregunta de "${topic.id}" necesita mas opciones',
      );
      expect(
        check.correctIndex,
        inInclusiveRange(0, check.options.length - 1),
        reason: 'La pregunta de "${topic.id}" apunta fuera de rango',
      );
      expect(
        check.explanation.trim(),
        isNotEmpty,
        reason: 'La pregunta de "${topic.id}" no explica la respuesta',
      );
      expect(check.isCorrect(check.correctIndex), isTrue);
    }
  });

  test('los fundamentos cubren los conceptos exigidos', () {
    const expected = <String>[
      'peligro',
      'riesgo',
      'incidente-accidente',
      'acto-inseguro',
      'condicion-insegura',
      'jerarquia-controles',
    ];
    for (final id in expected) {
      expect(
        content.topicById(id),
        isNotNull,
        reason: 'Falta la ficha de fundamentos "$id"',
      );
    }
  });

  test('el modulo IPERC cubre el proceso completo', () {
    const expected = <String>[
      'que-es-iperc',
      'identificacion',
      'evaluacion',
      'controles-iperc',
      'riesgo-residual',
    ];
    for (final id in expected) {
      expect(
        content.topicById(id),
        isNotNull,
        reason: 'Falta la ficha de IPERC "$id"',
      );
    }
  });

  test('un contenido mal formado se rechaza con un mensaje util', () {
    expect(
      () => parseLibraryContent('{"categories": []}'),
      returnsNormally,
    );
    expect(
      () => parseLibraryContent('{}'),
      throwsA(isA<LibraryFormatException>()),
    );
    expect(
      () => parseLibraryContent('[]'),
      throwsA(isA<LibraryFormatException>()),
    );
  });
}
