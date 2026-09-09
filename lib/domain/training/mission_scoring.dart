import 'hazard.dart';

/// Marca hecha por el estudiante sobre la escena.
class HazardMark {
  const HazardMark({required this.x, required this.y});

  /// Coordenadas relativas (0..1) dentro de la escena.
  final double x;
  final double y;
}

/// Resultado de un intento sobre una mision.
class MissionResult {
  const MissionResult({
    required this.found,
    required this.missed,
    required this.falsePositives,
    required this.score,
  });

  /// Peligros identificados correctamente.
  final List<Hazard> found;

  /// Peligros presentes que el estudiante no vio.
  final List<Hazard> missed;

  /// Marcas sobre zonas sin peligro.
  ///
  /// Se cuentan y penalizan: en una inspeccion real, senalar peligros donde
  /// no los hay tambien tiene coste. No se ocultan para no premiar la
  /// estrategia de tocar la pantalla al azar.
  final int falsePositives;

  /// Puntuacion de 0 a 100.
  final int score;

  bool get isPerfect => missed.isEmpty && falsePositives == 0;

  /// Umbral de aprobacion de la mision introductoria.
  bool get passed => score >= 60;
}

/// Evalua un intento contra la lista de peligros de la escena.
///
/// Vive en el dominio y no en el widget para que las reglas de puntuacion
/// puedan revisarse y testearse sin levantar interfaz.
abstract final class MissionScoring {
  /// Penalizacion en puntos por cada marca sobre una zona sin peligro.
  static const int falsePositivePenalty = 10;

  static MissionResult evaluate({
    required List<Hazard> hazards,
    required List<HazardMark> marks,
  }) {
    final found = <Hazard>[];
    var falsePositives = 0;

    for (final mark in marks) {
      final hit = _hazardAt(hazards, mark);
      if (hit == null) {
        falsePositives++;
        continue;
      }
      // Dos marcas sobre el mismo peligro cuentan una vez. Insistir sobre un
      // peligro ya identificado no suma ni resta.
      if (!found.any((Hazard h) => h.id == hit.id)) {
        found.add(hit);
      }
    }

    final missed = hazards
        .where((Hazard h) => !found.any((Hazard f) => f.id == h.id))
        .toList();

    return MissionResult(
      found: found,
      missed: missed,
      falsePositives: falsePositives,
      score: _score(
        hazards: hazards,
        found: found,
        falsePositives: falsePositives,
      ),
    );
  }

  static Hazard? _hazardAt(List<Hazard> hazards, HazardMark mark) {
    for (final hazard in hazards) {
      if (hazard.area.contains(mark.x, mark.y)) {
        return hazard;
      }
    }
    return null;
  }

  static int _score({
    required List<Hazard> hazards,
    required List<Hazard> found,
    required int falsePositives,
  }) {
    if (hazards.isEmpty) {
      return 0;
    }

    var total = 0;
    for (final hazard in hazards) {
      total += hazard.severity.weight;
    }

    var earned = 0;
    for (final hazard in found) {
      earned += hazard.severity.weight;
    }

    final base = earned * 100 / total;
    final penalty = falsePositives * falsePositivePenalty;
    return (base - penalty).round().clamp(0, 100);
  }
}
