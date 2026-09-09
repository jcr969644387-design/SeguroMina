import 'dart:convert';

import '../../domain/iperc/iperc_exercise.dart';
import '../../domain/iperc/risk_assessment.dart';

/// Lectura de los ejercicios guiados de IPERC.
///
/// Dart puro, como el resto de los lectores de contenido: un ejercicio mal
/// formado se detecta en integracion continua y no cuando un estudiante lo
/// abre.
class IpercExerciseFormatException implements Exception {
  const IpercExerciseFormatException(this.message);

  final String message;

  @override
  String toString() => 'IpercExerciseFormatException: $message';
}

List<IpercExercise> parseIpercExercises(String raw) {
  final Object? decoded = jsonDecode(raw);
  if (decoded is! Map<String, dynamic>) {
    throw const IpercExerciseFormatException('La raiz debe ser un objeto.');
  }

  final exercises = decoded['exercises'];
  if (exercises is! List) {
    throw const IpercExerciseFormatException('Falta la lista "exercises".');
  }

  return <IpercExercise>[
    for (final item in exercises) _exercise(item),
  ];
}

IpercExercise _exercise(Object? item) {
  final map = _object(item, 'ejercicio');

  final hazards = _list(map, 'hazards');
  final riskOptions = _list(map, 'riskOptions');
  final controls = _list(map, 'controls');

  final exercise = IpercExercise(
    id: _string(map, 'id'),
    activity: _string(map, 'activity'),
    context: _string(map, 'context'),
    primaryHazardId: _string(map, 'primaryHazardId'),
    hazards: <HazardOption>[
      for (final entry in hazards) _hazard(entry),
    ],
    riskOptions: <RiskOption>[
      for (final entry in riskOptions) _riskOption(entry),
    ],
    expectedSeverity: _severity(map, 'expectedSeverity'),
    expectedProbability: _probability(map, 'expectedProbability'),
    assessmentRationale: _string(map, 'assessmentRationale'),
    controls: <ControlOption>[
      for (final entry in controls) _control(entry),
    ],
    expectedResidualSeverity: _severity(map, 'expectedResidualSeverity'),
    expectedResidualProbability: _probability(
      map,
      'expectedResidualProbability',
    ),
    residualRationale: _string(map, 'residualRationale'),
  );

  _validate(exercise);
  return exercise;
}

/// Comprobaciones que el tipo no puede garantizar.
///
/// Se hacen al leer y no al mostrar: un ejercicio sin respuesta correcta o
/// sin peligro principal es un fallo de contenido, y debe fallar temprano.
void _validate(IpercExercise exercise) {
  final ids = exercise.hazards.map((HazardOption h) => h.id).toSet();
  if (!ids.contains(exercise.primaryHazardId)) {
    throw IpercExerciseFormatException(
      'El ejercicio "${exercise.id}" apunta a un peligro principal que no '
      'esta en su lista.',
    );
  }
  if (exercise.presentHazards.isEmpty) {
    throw IpercExerciseFormatException(
      'El ejercicio "${exercise.id}" no tiene ningun peligro presente.',
    );
  }
  final correct = exercise.riskOptions.where((RiskOption o) => o.correct);
  if (correct.length != 1) {
    throw IpercExerciseFormatException(
      'El ejercicio "${exercise.id}" debe tener exactamente una redaccion '
      'correcta del riesgo.',
    );
  }
  if (exercise.recommendedControls.isEmpty) {
    throw IpercExerciseFormatException(
      'El ejercicio "${exercise.id}" no propone ningun control.',
    );
  }
}

HazardOption _hazard(Object? item) {
  final map = _object(item, 'peligro');
  return HazardOption(
    id: _string(map, 'id'),
    label: _string(map, 'label'),
    present: _bool(map, 'present'),
    explanation: _string(map, 'explanation'),
  );
}

RiskOption _riskOption(Object? item) {
  final map = _object(item, 'redaccion del riesgo');
  return RiskOption(
    label: _string(map, 'label'),
    correct: _bool(map, 'correct'),
    explanation: _string(map, 'explanation'),
  );
}

ControlOption _control(Object? item) {
  final map = _object(item, 'control');
  return ControlOption(
    id: _string(map, 'id'),
    label: _string(map, 'label'),
    level: _controlLevel(map, 'level'),
    recommended: _bool(map, 'recommended'),
    explanation: _string(map, 'explanation'),
  );
}

Severity _severity(Map<String, dynamic> map, String key) {
  final name = _string(map, key);
  for (final value in Severity.values) {
    if (value.name == name) {
      return value;
    }
  }
  throw IpercExerciseFormatException('Severidad desconocida: "$name".');
}

Probability _probability(Map<String, dynamic> map, String key) {
  final name = _string(map, key);
  for (final value in Probability.values) {
    if (value.name == name) {
      return value;
    }
  }
  throw IpercExerciseFormatException('Probabilidad desconocida: "$name".');
}

ControlLevel _controlLevel(Map<String, dynamic> map, String key) {
  final name = _string(map, key);
  for (final value in ControlLevel.values) {
    if (value.name == name) {
      return value;
    }
  }
  throw IpercExerciseFormatException('Nivel de control desconocido: "$name".');
}

List<Object?> _list(Map<String, dynamic> map, String key) {
  final value = map[key];
  if (value is! List || value.isEmpty) {
    throw IpercExerciseFormatException('Falta la lista "$key" o esta vacia.');
  }
  return value;
}

Map<String, dynamic> _object(Object? item, String what) {
  if (item is! Map<String, dynamic>) {
    throw IpercExerciseFormatException('Se esperaba un objeto para $what.');
  }
  return item;
}

String _string(Map<String, dynamic> map, String key) {
  final value = map[key];
  if (value is! String || value.trim().isEmpty) {
    throw IpercExerciseFormatException('Falta el campo "$key" o esta vacio.');
  }
  return value;
}

bool _bool(Map<String, dynamic> map, String key) {
  final value = map[key];
  if (value is! bool) {
    throw IpercExerciseFormatException('El campo "$key" debe ser booleano.');
  }
  return value;
}
