import 'package:flutter_test/flutter_test.dart';
import 'package:seguromina/domain/training/hazard.dart';
import 'package:seguromina/domain/training/mission_scoring.dart';
import 'package:seguromina/domain/training/risk_level.dart';

/// Reglas de puntuacion de la inspeccion de un escenario.
///
/// Se prueban sobre peligros de laboratorio y no sobre el contenido real,
/// para que corregir un escenario no rompa los tests de las reglas.
void main() {
  const hazards = <Hazard>[
    Hazard(
      id: 'alto',
      label: 'Peligro de severidad alta',
      explanation: 'Explicacion',
      control: 'Control',
      severity: RiskLevel.alto,
      area: HazardArea(left: 0.0, top: 0.0, width: 0.3, height: 0.3),
    ),
    Hazard(
      id: 'medio-a',
      label: 'Peligro de severidad media',
      explanation: 'Explicacion',
      control: 'Control',
      severity: RiskLevel.medio,
      area: HazardArea(left: 0.4, top: 0.0, width: 0.3, height: 0.3),
    ),
    Hazard(
      id: 'medio-b',
      label: 'Otro peligro de severidad media',
      explanation: 'Explicacion',
      control: 'Control',
      severity: RiskLevel.medio,
      area: HazardArea(left: 0.0, top: 0.5, width: 0.3, height: 0.3),
    ),
  ];

  const onHigh = HazardMark(x: 0.15, y: 0.15);
  const onMediumA = HazardMark(x: 0.55, y: 0.15);
  const onMediumB = HazardMark(x: 0.15, y: 0.65);
  const nowhere = HazardMark(x: 0.95, y: 0.95);

  MissionResult evaluate(List<HazardMark> marks) {
    return MissionScoring.evaluate(hazards: hazards, marks: marks);
  }

  test('identificar los tres peligros da la puntuacion maxima', () {
    final result = evaluate(<HazardMark>[onHigh, onMediumA, onMediumB]);

    expect(result.score, 100);
    expect(result.found.length, 3);
    expect(result.missed, isEmpty);
    expect(result.isPerfect, isTrue);
    expect(result.passed, isTrue);
  });

  test('no marcar nada deja la puntuacion en cero', () {
    final result = evaluate(<HazardMark>[]);

    expect(result.score, 0);
    expect(result.missed.length, 3);
    expect(result.passed, isFalse);
  });

  test('el peligro alto pesa mas que uno medio', () {
    expect(
      evaluate(<HazardMark>[onHigh]).score,
      greaterThan(evaluate(<HazardMark>[onMediumA]).score),
    );
  });

  test('marcar una zona sin peligro penaliza', () {
    final clean = evaluate(<HazardMark>[onHigh, onMediumA, onMediumB]);
    final withMiss = evaluate(
      <HazardMark>[onHigh, onMediumA, onMediumB, nowhere],
    );

    expect(withMiss.falsePositives, 1);
    expect(
      withMiss.score,
      clean.score - MissionScoring.falsePositivePenalty,
    );
    expect(withMiss.isPerfect, isFalse);
  });

  test('insistir sobre el mismo peligro no suma dos veces', () {
    final once = evaluate(<HazardMark>[onHigh]);
    final twice = evaluate(<HazardMark>[onHigh, onHigh]);

    expect(twice.found.length, 1);
    expect(twice.score, once.score);
    expect(twice.falsePositives, 0);
  });

  test('la puntuacion nunca baja de cero', () {
    final result = evaluate(
      <HazardMark>[nowhere, nowhere, nowhere, nowhere, nowhere],
    );

    expect(result.score, 0);
  });
}
