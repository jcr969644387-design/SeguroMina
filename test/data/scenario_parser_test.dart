import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:seguromina/data/scenarios/scenario_parser.dart';
import 'package:seguromina/domain/training/scenario.dart';

/// Validacion de los escenarios empaquetados.
void main() {
  const path = 'assets/content/scenarios/scenarios.json';
  final raw = File(path).readAsStringSync();
  final scenarios = parseScenarios(raw);

  test('estan los cinco escenarios del MVP', () {
    expect(scenarios, hasLength(5));

    const expected = <String>[
      'labor-subterranea',
      'voladura',
      'mantenimiento',
      'transporte',
      'ventilacion',
    ];
    final ids = <String>[
      for (final scenario in scenarios) scenario.id,
    ];
    expect(ids, expected);
  });

  test('los codigos no se repiten y van en orden', () {
    final codes = <String>[
      for (final scenario in scenarios) scenario.code,
    ];
    expect(codes.toSet().length, codes.length);
    expect(codes.first, '01');
  });

  test('cada escenario propone varios peligros', () {
    for (final scenario in scenarios) {
      expect(
        scenario.hazards.length,
        greaterThanOrEqualTo(5),
        reason: 'El escenario "${scenario.id}" tiene muy pocos peligros',
      );
    }
  });

  test('todo peligro trae explicacion y control', () {
    for (final scenario in scenarios) {
      for (final hazard in scenario.hazards) {
        expect(
          hazard.explanation.trim(),
          isNotEmpty,
          reason: 'Sin explicacion: "${hazard.id}"',
        );
        expect(
          hazard.control.trim(),
          isNotEmpty,
          reason: 'Sin control: "${hazard.id}"',
        );
      }
    }
  });

  test('las zonas sensibles caen dentro de la escena', () {
    for (final scenario in scenarios) {
      for (final hazard in scenario.hazards) {
        final area = hazard.area;
        expect(area.left, inInclusiveRange(0, 1));
        expect(area.top, inInclusiveRange(0, 1));
        expect(area.left + area.width, lessThanOrEqualTo(1));
        expect(area.top + area.height, lessThanOrEqualTo(1));
      }
    }
  });

  test('cada peligro tiene un elemento dibujado sobre su zona', () {
    // Sin esto, el estudiante tendria que tocar una zona vacia: el corte
    // dejaria de ser lo que se inspecciona y pasaria a ser decoracion.
    for (final scenario in scenarios) {
      for (final hazard in scenario.hazards) {
        final covered = scenario.scene.elements.any(
          (SceneElement e) => hazard.area.contains(e.x, e.y),
        );
        expect(
          covered,
          isTrue,
          reason: 'La zona de "${hazard.id}" en "${scenario.id}" no tiene '
              'ningun elemento dibujado',
        );
      }
    }
  });

  test('un escenario mal formado se rechaza', () {
    expect(
      () => parseScenarios('{}'),
      throwsA(isA<ScenarioFormatException>()),
    );
    expect(
      () => parseScenarios('{"scenarios": [{"id": "x"}]}'),
      throwsA(isA<ScenarioFormatException>()),
    );
  });
}
