import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:seguromina/data/iperc/iperc_exercise_parser.dart';
import 'package:seguromina/domain/iperc/iperc_exercise.dart';
import 'package:seguromina/domain/iperc/risk_assessment.dart';

/// Validacion de los ejercicios guiados empaquetados.
///
/// Comprueba que el contenido no solo se lee, sino que ensena lo correcto:
/// un ejercicio que propusiera solo EPP, o que bajara la severidad sin
/// eliminar el peligro, seria peor que no tener ejercicio.
void main() {
  /// Controles que si cambian la energia en juego y, por tanto, la severidad.
  const strongLevels = <ControlLevel>[
    ControlLevel.eliminacion,
    ControlLevel.sustitucion,
  ];

  final raw = File('assets/content/iperc_exercises.json').readAsStringSync();
  final exercises = parseIpercExercises(raw);

  test('el archivo trae al menos un ejercicio', () {
    expect(exercises, isNotEmpty);
  });

  test('cada ejercicio tiene una sola redaccion correcta del riesgo', () {
    for (final exercise in exercises) {
      final correct = exercise.riskOptions.where((RiskOption o) => o.correct);
      expect(correct.length, 1, reason: 'Falla en "${exercise.id}"');
    }
  });

  test('el peligro principal esta en la lista y esta presente', () {
    for (final exercise in exercises) {
      expect(exercise.primaryHazard.present, isTrue);
    }
  });

  test('los controles propuestos actuan sobre el peligro', () {
    for (final exercise in exercises) {
      final recommended = exercise.recommendedControls;
      expect(recommended, isNotEmpty, reason: 'Falla en "${exercise.id}"');

      final actsOnHazard = recommended.any(
        (ControlOption c) => c.level.actsOnHazard,
      );
      expect(actsOnHazard, isTrue, reason: 'Solo EPP en "${exercise.id}"');
    }
  });

  test('el riesgo inicial no es menor que el residual', () {
    for (final exercise in exercises) {
      final levels = exercise.expectedLevels;
      expect(
        levels.initial.weight,
        greaterThanOrEqualTo(levels.residual.weight),
        reason: 'Los controles no reducen el riesgo en "${exercise.id}"',
      );
    }
  });

  test('la severidad residual solo baja si se elimina o sustituye', () {
    for (final exercise in exercises) {
      final residualRank = exercise.expectedResidualSeverity.rank;
      final initialRank = exercise.expectedSeverity.rank;
      final lowered = residualRank > initialRank;

      final removesHazard = exercise.recommendedControls.any(
        (ControlOption c) => strongLevels.contains(c.level),
      );

      expect(
        !lowered || removesHazard,
        isTrue,
        reason: 'Baja la severidad sin justificacion en "${exercise.id}"',
      );
    }
  });

  test('un ejercicio mal formado se rechaza', () {
    expect(
      () => parseIpercExercises('{}'),
      throwsA(isA<IpercExerciseFormatException>()),
    );
    expect(
      () => parseIpercExercises('{"exercises": [{"id": "x"}]}'),
      throwsA(isA<IpercExerciseFormatException>()),
    );
  });
}
