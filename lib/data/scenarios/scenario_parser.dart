import 'dart:convert';

import '../../domain/training/hazard.dart';
import '../../domain/training/risk_level.dart';
import '../../domain/training/scenario.dart';

/// Lectura de los escenarios de entrenamiento.
class ScenarioFormatException implements Exception {
  const ScenarioFormatException(this.message);

  final String message;

  @override
  String toString() => 'ScenarioFormatException: $message';
}

List<TrainingScenario> parseScenarios(String raw) {
  final Object? decoded = jsonDecode(raw);
  if (decoded is! Map<String, dynamic>) {
    throw const ScenarioFormatException('La raiz debe ser un objeto.');
  }

  final scenarios = decoded['scenarios'];
  if (scenarios is! List || scenarios.isEmpty) {
    throw const ScenarioFormatException('Falta la lista "scenarios".');
  }

  return <TrainingScenario>[
    for (final item in scenarios) _scenario(item),
  ];
}

TrainingScenario _scenario(Object? item) {
  final map = _object(item, 'escenario');
  final hazards = _list(map, 'hazards');

  final scenario = TrainingScenario(
    id: _string(map, 'id'),
    code: _string(map, 'code'),
    title: _string(map, 'title'),
    briefing: _string(map, 'briefing'),
    situation: _string(map, 'situation'),
    estimatedMinutes: _int(map, 'estimatedMinutes'),
    scene: _scene(map['scene']),
    hazards: <Hazard>[
      for (final entry in hazards) _hazard(entry),
    ],
  );

  _validate(scenario);
  return scenario;
}

/// Comprobaciones que el tipo no garantiza.
///
/// Dos peligros con zonas superpuestas harian que un mismo toque contara
/// para los dos, y el estudiante no sabria cual identifico. Se detecta al
/// leer, no en el telefono.
void _validate(TrainingScenario scenario) {
  final ids = <String>{};
  for (final hazard in scenario.hazards) {
    if (!ids.add(hazard.id)) {
      throw ScenarioFormatException(
        'El escenario "${scenario.id}" repite el peligro "${hazard.id}".',
      );
    }
  }

  for (var i = 0; i < scenario.hazards.length; i++) {
    for (var j = i + 1; j < scenario.hazards.length; j++) {
      if (_overlap(scenario.hazards[i].area, scenario.hazards[j].area)) {
        throw ScenarioFormatException(
          'En "${scenario.id}" se solapan "${scenario.hazards[i].id}" y '
          '"${scenario.hazards[j].id}".',
        );
      }
    }
  }
}

bool _overlap(HazardArea a, HazardArea b) {
  if (a.left + a.width <= b.left) {
    return false;
  }
  if (b.left + b.width <= a.left) {
    return false;
  }
  if (a.top + a.height <= b.top) {
    return false;
  }
  if (b.top + b.height <= a.top) {
    return false;
  }
  return true;
}

ScenarioScene _scene(Object? item) {
  final map = _object(item, 'escena');
  final elements = _list(map, 'elements');

  return ScenarioScene(
    profile: _profile(_string(map, 'profile')),
    elements: <SceneElement>[
      for (final entry in elements) _element(entry),
    ],
  );
}

SceneElement _element(Object? item) {
  final map = _object(item, 'elemento de escena');
  return SceneElement(
    type: _string(map, 'type'),
    x: _double(map, 'x'),
    y: _double(map, 'y'),
    width: _double(map, 'width', fallback: 0.12),
    height: _double(map, 'height', fallback: 0.12),
    flip: map['flip'] == true,
  );
}

Hazard _hazard(Object? item) {
  final map = _object(item, 'peligro');
  final area = _object(map['area'], 'area del peligro');

  return Hazard(
    id: _string(map, 'id'),
    label: _string(map, 'label'),
    explanation: _string(map, 'explanation'),
    control: _string(map, 'control'),
    severity: _severity(_string(map, 'severity')),
    area: HazardArea(
      left: _double(area, 'left'),
      top: _double(area, 'top'),
      width: _double(area, 'width'),
      height: _double(area, 'height'),
    ),
  );
}

SceneProfile _profile(String name) {
  for (final value in SceneProfile.values) {
    if (value.name == name) {
      return value;
    }
  }
  throw ScenarioFormatException('Perfil de labor desconocido: "$name".');
}

RiskLevel _severity(String name) {
  for (final value in RiskLevel.values) {
    if (value.name == name) {
      return value;
    }
  }
  throw ScenarioFormatException('Nivel de riesgo desconocido: "$name".');
}

List<Object?> _list(Map<String, dynamic> map, String key) {
  final value = map[key];
  if (value is! List || value.isEmpty) {
    throw ScenarioFormatException('Falta la lista "$key" o esta vacia.');
  }
  return value;
}

Map<String, dynamic> _object(Object? item, String what) {
  if (item is! Map<String, dynamic>) {
    throw ScenarioFormatException('Se esperaba un objeto para $what.');
  }
  return item;
}

String _string(Map<String, dynamic> map, String key) {
  final value = map[key];
  if (value is! String || value.trim().isEmpty) {
    throw ScenarioFormatException('Falta el campo "$key" o esta vacio.');
  }
  return value;
}

int _int(Map<String, dynamic> map, String key) {
  final value = map[key];
  if (value is! int) {
    throw ScenarioFormatException('El campo "$key" debe ser entero.');
  }
  return value;
}

double _double(Map<String, dynamic> map, String key, {double? fallback}) {
  final value = map[key];
  if (value is num) {
    return value.toDouble();
  }
  if (fallback != null) {
    return fallback;
  }
  throw ScenarioFormatException('El campo "$key" debe ser numerico.');
}
