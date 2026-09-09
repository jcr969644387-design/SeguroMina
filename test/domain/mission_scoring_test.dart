import 'package:flutter_test/flutter_test.dart';
import 'package:seguromina/domain/training/intro_mission.dart';
import 'package:seguromina/domain/training/mission_scoring.dart';

/// Reglas de puntuacion de la mision de entrada.
///
/// Se prueban sin interfaz: un especialista debe poder revisar como se
/// califica a un estudiante sin ejecutar la app.
void main() {
  final hazards = IntroMission.definition.hazards;

  // Centros de las tres zonas sensibles y un punto sin peligro.
  const rock = HazardMark(x: 0.73, y: 0.26);
  const eyes = HazardMark(x: 0.54, y: 0.56);
  const cable = HazardMark(x: 0.24, y: 0.79);
  const nowhere = HazardMark(x: 0.95, y: 0.95);

  MissionResult evaluate(List<HazardMark> marks) {
    return MissionScoring.evaluate(hazards: hazards, marks: marks);
  }

  test('identificar los tres peligros da la puntuacion maxima', () {
    final result = evaluate(<HazardMark>[rock, eyes, cable]);

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
    final onlyHigh = evaluate(<HazardMark>[rock]);
    final onlyMedium = evaluate(<HazardMark>[cable]);

    expect(onlyHigh.score, greaterThan(onlyMedium.score));
  });

  test('marcar una zona sin peligro penaliza', () {
    final clean = evaluate(<HazardMark>[rock, eyes, cable]);
    final withMiss = evaluate(<HazardMark>[rock, eyes, cable, nowhere]);

    expect(withMiss.falsePositives, 1);
    expect(
      withMiss.score,
      clean.score - MissionScoring.falsePositivePenalty,
    );
    expect(withMiss.isPerfect, isFalse);
  });

  test('insistir sobre el mismo peligro no suma dos veces', () {
    final once = evaluate(<HazardMark>[rock]);
    final twice = evaluate(<HazardMark>[rock, rock]);

    expect(twice.found.length, 1);
    expect(twice.score, once.score);
    expect(twice.falsePositives, 0);
  });

  test('la puntuacion nunca baja de cero', () {
    final result = evaluate(<HazardMark>[
      nowhere,
      nowhere,
      nowhere,
      nowhere,
      nowhere,
    ]);

    expect(result.score, 0);
  });
}
