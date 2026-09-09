import '../training/risk_level.dart';
import 'risk_assessment.dart';

/// Un peligro que el estudiante puede marcar como presente en la actividad.
class HazardOption {
  const HazardOption({
    required this.id,
    required this.label,
    required this.present,
    required this.explanation,
  });

  final String id;
  final String label;

  /// Si realmente esta presente en la actividad del ejercicio.
  final bool present;

  /// Por que esta o no esta. Se muestra siempre, se acierte o no.
  final String explanation;
}

/// Una redaccion posible del riesgo asociado al peligro.
class RiskOption {
  const RiskOption({
    required this.label,
    required this.correct,
    required this.explanation,
  });

  final String label;
  final bool correct;
  final String explanation;
}

/// Una medida que el estudiante puede elegir como control.
class ControlOption {
  const ControlOption({
    required this.id,
    required this.label,
    required this.level,
    required this.recommended,
    required this.explanation,
  });

  final String id;
  final String label;

  /// Nivel de la jerarquia al que pertenece.
  final ControlLevel level;

  /// Si forma parte del conjunto de controles esperado.
  final bool recommended;

  final String explanation;
}

/// Un ejercicio guiado de construccion de una linea de IPERC.
///
/// Recorre la secuencia completa: identificar los peligros de la actividad,
/// redactar el riesgo del principal, evaluarlo con la matriz, elegir
/// controles y recalcular el riesgo residual.
class IpercExercise {
  const IpercExercise({
    required this.id,
    required this.activity,
    required this.context,
    required this.hazards,
    required this.primaryHazardId,
    required this.riskOptions,
    required this.expectedSeverity,
    required this.expectedProbability,
    required this.assessmentRationale,
    required this.controls,
    required this.expectedResidualSeverity,
    required this.expectedResidualProbability,
    required this.residualRationale,
  });

  final String id;

  /// Actividad sobre la que se construye el IPERC.
  final String activity;

  /// Condiciones de la labor. Sin ellas no se puede evaluar la probabilidad:
  /// el mismo peligro es mas o menos probable segun el terreno, el turno y
  /// lo que haya pasado antes en ese nivel.
  final String context;

  final List<HazardOption> hazards;

  /// Peligro sobre el que continua el ejercicio a partir del paso 2.
  final String primaryHazardId;

  final List<RiskOption> riskOptions;

  final Severity expectedSeverity;
  final Probability expectedProbability;
  final String assessmentRationale;

  final List<ControlOption> controls;

  final Severity expectedResidualSeverity;
  final Probability expectedResidualProbability;
  final String residualRationale;

  HazardOption get primaryHazard {
    for (final hazard in hazards) {
      if (hazard.id == primaryHazardId) {
        return hazard;
      }
    }
    throw StateError('El ejercicio "$id" no define su peligro principal.');
  }

  List<HazardOption> get presentHazards {
    return hazards.where((HazardOption h) => h.present).toList();
  }

  List<ControlOption> get recommendedControls {
    return controls.where((ControlOption c) => c.recommended).toList();
  }

  RiskLevelPair get expectedLevels {
    return RiskLevelPair(
      initial: RiskMatrix.evaluate(
        severity: expectedSeverity,
        probability: expectedProbability,
      ),
      residual: RiskMatrix.evaluate(
        severity: expectedResidualSeverity,
        probability: expectedResidualProbability,
      ),
    );
  }
}

/// Niveles inicial y residual esperados por el ejercicio.
class RiskLevelPair {
  const RiskLevelPair({required this.initial, required this.residual});

  final RiskLevel initial;
  final RiskLevel residual;
}
