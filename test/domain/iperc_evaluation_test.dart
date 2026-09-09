import 'package:flutter_test/flutter_test.dart';
import 'package:seguromina/domain/iperc/iperc_evaluation.dart';
import 'package:seguromina/domain/iperc/iperc_exercise.dart';
import 'package:seguromina/domain/iperc/risk_assessment.dart';

/// Reglas con las que se corrige un ejercicio guiado de IPERC.
///
/// Se prueban sobre un ejercicio de laboratorio y no sobre el contenido real,
/// para que corregir una ficha no rompa los tests de las reglas.
void main() {
  const exercise = IpercExercise(
    id: 'prueba',
    activity: 'Actividad de prueba',
    context: 'Condiciones de prueba',
    primaryHazardId: 'h1',
    hazards: <HazardOption>[
      HazardOption(
        id: 'h1',
        label: 'Peligro uno',
        present: true,
        explanation: 'Esta presente',
      ),
      HazardOption(
        id: 'h2',
        label: 'Peligro dos',
        present: true,
        explanation: 'Tambien esta presente',
      ),
      HazardOption(
        id: 'h3',
        label: 'Peligro tres',
        present: false,
        explanation: 'No corresponde a esta actividad',
      ),
    ],
    riskOptions: <RiskOption>[
      RiskOption(
        label: 'El peligro',
        correct: false,
        explanation: 'Nombra la fuente, no el riesgo',
      ),
      RiskOption(
        label: 'Dano sobre una persona expuesta',
        correct: true,
        explanation: 'Dice a quien alcanza y con que consecuencia',
      ),
    ],
    expectedSeverity: Severity.mortalidad,
    expectedProbability: Probability.haSucedido,
    assessmentRationale: 'Justificacion de la evaluacion',
    controls: <ControlOption>[
      ControlOption(
        id: 'c1',
        label: 'Control de ingenieria',
        level: ControlLevel.ingenieria,
        recommended: true,
        explanation: 'Actua sobre el peligro',
      ),
      ControlOption(
        id: 'c2',
        label: 'Control administrativo',
        level: ControlLevel.administrativo,
        recommended: true,
        explanation: 'Complementa al anterior',
      ),
      ControlOption(
        id: 'c3',
        label: 'Equipo de proteccion',
        level: ControlLevel.epp,
        recommended: false,
        explanation: 'No es el control principal de este riesgo',
      ),
    ],
    expectedResidualSeverity: Severity.mortalidad,
    expectedResidualProbability: Probability.raroQueSuceda,
    residualRationale: 'Justificacion del residual',
  );

  group('Identificacion de peligros', () {
    test('marcar los presentes da el maximo', () {
      final result = IpercEvaluator.hazards(exercise, <String>{'h1', 'h2'});

      expect(result.ratio, 1);
      expect(result.noteKeys, isEmpty);
    });

    test('omitir uno y marcar uno que no aplica penaliza dos veces', () {
      final result = IpercEvaluator.hazards(exercise, <String>{'h1', 'h3'});

      expect(result.ratio, 0);
      expect(result.noteKeys, contains('practice.feedback.hazards.missed'));
      expect(result.noteKeys, contains('practice.feedback.hazards.extra'));
    });
  });

  group('Redaccion del riesgo', () {
    test('la redaccion correcta puntua entera', () {
      expect(IpercEvaluator.risk(exercise, 1).ratio, 1);
    });

    test('una redaccion incorrecta muestra tambien la correcta', () {
      final result = IpercEvaluator.risk(exercise, 0);

      expect(result.ratio, 0);
      expect(result.details.length, greaterThan(1));
    });

    test('no responder no puntua', () {
      expect(IpercEvaluator.risk(exercise, null).ratio, 0);
    });
  });

  group('Evaluacion del riesgo', () {
    test('acertar severidad y probabilidad da el maximo', () {
      final result = IpercEvaluator.assessment(
        exercise,
        Severity.mortalidad,
        Probability.haSucedido,
      );

      expect(result.ratio, 1);
      expect(result.noteKeys, isEmpty);
    });

    test('acertar el nivel con otra combinacion puntua parcialmente', () {
      // Catastrofico con Podria suceder da indice 4: tambien nivel Alto.
      final result = IpercEvaluator.assessment(
        exercise,
        Severity.catastrofico,
        Probability.podriaSuceder,
      );

      expect(result.ratio, 0.6);
      expect(
        result.noteKeys,
        contains('practice.feedback.assessment.levelOnly'),
      );
    });

    test('subestimar el riesgo queda senalado', () {
      final result = IpercEvaluator.assessment(
        exercise,
        Severity.menor,
        Probability.casiImposible,
      );

      expect(result.ratio, 0);
      expect(
        result.noteKeys,
        contains('practice.feedback.assessment.underestimated'),
      );
    });

    test('sobrestimar no se senala como subestimacion', () {
      final result = IpercEvaluator.assessment(
        exercise,
        Severity.catastrofico,
        Probability.comun,
      );

      expect(
        result.noteKeys,
        isNot(contains('practice.feedback.assessment.underestimated')),
      );
    });
  });

  group('Seleccion de controles', () {
    test('elegir los recomendados da el maximo', () {
      final result = IpercEvaluator.controls(exercise, <String>{'c1', 'c2'});

      expect(result.ratio, 1);
      expect(result.noteKeys, isEmpty);
    });

    test('quedarse solo en el EPP queda senalado y limita la nota', () {
      final result = IpercEvaluator.controls(exercise, <String>{'c3'});

      expect(result.noteKeys, contains('practice.feedback.controls.onlyPpe'));
      expect(result.ratio, lessThanOrEqualTo(0.3));
    });

    test('sin control que actue sobre el peligro se avisa', () {
      final result = IpercEvaluator.controls(exercise, <String>{'c2'});

      expect(
        result.noteKeys,
        contains('practice.feedback.controls.noHazardControl'),
      );
    });
  });

  group('Riesgo residual', () {
    test('acertar el nivel residual da el maximo', () {
      final result = IpercEvaluator.residual(
        exercise,
        Severity.mortalidad,
        Probability.raroQueSuceda,
      );

      expect(result.ratio, 1);
      expect(result.noteKeys, isEmpty);
    });

    test('bajar la severidad queda senalado y limita la nota', () {
      // El error clasico: dar por hecho que el control tambien reduce el
      // dano. El sostenimiento evita que la roca caiga, no que mate.
      final result = IpercEvaluator.residual(
        exercise,
        Severity.menor,
        Probability.raroQueSuceda,
      );

      expect(
        result.noteKeys,
        contains('practice.feedback.residual.severityLowered'),
      );
      expect(result.ratio, lessThanOrEqualTo(0.3));
    });
  });

  group('Nota final', () {
    test('un ejercicio perfecto da 100', () {
      const attempt = IpercAttempt(
        hazards: <String>{'h1', 'h2'},
        riskChoice: 1,
        severity: Severity.mortalidad,
        probability: Probability.haSucedido,
        controls: <String>{'c1', 'c2'},
        residualSeverity: Severity.mortalidad,
        residualProbability: Probability.raroQueSuceda,
      );

      final results = IpercEvaluator.evaluate(exercise, attempt);

      expect(results, hasLength(5));
      expect(IpercEvaluator.score(results), 100);
    });

    test('un ejercicio en blanco da 0', () {
      const attempt = IpercAttempt();
      final results = IpercEvaluator.evaluate(exercise, attempt);

      expect(IpercEvaluator.score(results), 0);
    });

    test('los pesos de los pasos suman 100', () {
      var total = 0;
      for (final step in IpercStep.values) {
        total += step.weight;
      }
      expect(total, 100);
    });
  });
}
