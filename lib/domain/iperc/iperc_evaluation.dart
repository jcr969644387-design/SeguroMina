import 'iperc_exercise.dart';
import 'risk_assessment.dart';

/// Los cinco pasos de la construccion de una linea de IPERC.
enum IpercStep {
  hazards,
  risk,
  assessment,
  controls,
  residual;

  String get labelKey => 'practice.step.$name';

  /// Peso del paso en la nota final. Suman 100.
  int get weight {
    switch (this) {
      case IpercStep.hazards:
        return 25;
      case IpercStep.risk:
        return 15;
      case IpercStep.assessment:
        return 25;
      case IpercStep.controls:
        return 20;
      case IpercStep.residual:
        return 15;
    }
  }
}

/// Resultado de un paso.
///
/// Separa los avisos estructurales, que son claves de texto de la interfaz,
/// de las explicaciones concretas del ejercicio, que son contenido educativo
/// y viajan como texto. El dominio no conoce cadenas visibles; las
/// explicaciones ya venian escritas en el archivo de contenido.
class IpercStepResult {
  const IpercStepResult({
    required this.step,
    required this.ratio,
    this.noteKeys = const <String>[],
    this.details = const <String>[],
  });

  final IpercStep step;

  /// Acierto del paso, de 0 a 1.
  final double ratio;

  final List<String> noteKeys;
  final List<String> details;

  bool get isPerfect => ratio >= 0.999;
}

/// Lo que el estudiante ha respondido.
class IpercAttempt {
  const IpercAttempt({
    this.hazards = const <String>{},
    this.riskChoice,
    this.severity,
    this.probability,
    this.controls = const <String>{},
    this.residualSeverity,
    this.residualProbability,
  });

  final Set<String> hazards;
  final int? riskChoice;
  final Severity? severity;
  final Probability? probability;
  final Set<String> controls;
  final Severity? residualSeverity;
  final Probability? residualProbability;

  IpercAttempt copyWith({
    Set<String>? hazards,
    int? riskChoice,
    Severity? severity,
    Probability? probability,
    Set<String>? controls,
    Severity? residualSeverity,
    Probability? residualProbability,
  }) {
    return IpercAttempt(
      hazards: hazards ?? this.hazards,
      riskChoice: riskChoice ?? this.riskChoice,
      severity: severity ?? this.severity,
      probability: probability ?? this.probability,
      controls: controls ?? this.controls,
      residualSeverity: residualSeverity ?? this.residualSeverity,
      residualProbability: residualProbability ?? this.residualProbability,
    );
  }
}

/// Correccion de un ejercicio de IPERC.
///
/// Vive en el dominio, sin Flutter, para que las reglas con las que se
/// califica a un estudiante puedan revisarse y ejecutarse sin la interfaz.
abstract final class IpercEvaluator {
  static IpercStepResult hazards(
    IpercExercise exercise,
    Set<String> selected,
  ) {
    final present = exercise.presentHazards.map((HazardOption h) => h.id);
    final presentIds = present.toSet();

    final hits = selected.intersection(presentIds);
    final extra = selected.difference(presentIds);
    final missed = presentIds.difference(selected);

    final raw = (hits.length - extra.length) / presentIds.length;

    final noteKeys = <String>[];
    if (missed.isNotEmpty) {
      noteKeys.add('practice.feedback.hazards.missed');
    }
    if (extra.isNotEmpty) {
      noteKeys.add('practice.feedback.hazards.extra');
    }

    final details = <String>[];
    for (final hazard in exercise.hazards) {
      if (missed.contains(hazard.id) || extra.contains(hazard.id)) {
        details.add('${hazard.label}. ${hazard.explanation}');
      }
    }

    return IpercStepResult(
      step: IpercStep.hazards,
      ratio: raw.clamp(0.0, 1.0),
      noteKeys: noteKeys,
      details: details,
    );
  }

  static IpercStepResult risk(IpercExercise exercise, int? choice) {
    if (choice == null || choice < 0 || choice >= exercise.riskOptions.length) {
      return const IpercStepResult(step: IpercStep.risk, ratio: 0);
    }

    final chosen = exercise.riskOptions[choice];
    final details = <String>[chosen.explanation];

    if (!chosen.correct) {
      for (final option in exercise.riskOptions) {
        if (option.correct) {
          details.add('${option.label}. ${option.explanation}');
        }
      }
    }

    return IpercStepResult(
      step: IpercStep.risk,
      ratio: chosen.correct ? 1 : 0,
      details: details,
    );
  }

  static IpercStepResult assessment(
    IpercExercise exercise,
    Severity? severity,
    Probability? probability,
  ) {
    if (severity == null || probability == null) {
      return const IpercStepResult(step: IpercStep.assessment, ratio: 0);
    }

    final expected = RiskMatrix.evaluate(
      severity: exercise.expectedSeverity,
      probability: exercise.expectedProbability,
    );
    final actual = RiskMatrix.evaluate(
      severity: severity,
      probability: probability,
    );

    final sameSeverity = severity == exercise.expectedSeverity;
    final sameProbability = probability == exercise.expectedProbability;
    final exact = sameSeverity && sameProbability;
    final partial = sameSeverity || sameProbability;

    final noteKeys = <String>[];
    final double ratio;
    if (exact) {
      ratio = 1;
    } else if (actual == expected) {
      // El nivel es lo que decide el plazo de correccion y si la tarea se
      // ejecuta. Acertarlo con otra combinacion es un acierto parcial real.
      ratio = 0.6;
      noteKeys.add('practice.feedback.assessment.levelOnly');
    } else {
      ratio = partial ? 0.25 : 0;
    }

    // Subestimar es el error peligroso: lleva a operar una labor que deberia
    // estar detenida. Sobrestimar cuesta tiempo, no vidas.
    if (actual.weight < expected.weight) {
      noteKeys.add('practice.feedback.assessment.underestimated');
    }

    return IpercStepResult(
      step: IpercStep.assessment,
      ratio: ratio,
      noteKeys: noteKeys,
      details: <String>[exercise.assessmentRationale],
    );
  }

  static IpercStepResult controls(
    IpercExercise exercise,
    Set<String> selected,
  ) {
    final byId = <String, ControlOption>{
      for (final control in exercise.controls) control.id: control,
    };
    final chosen = <ControlOption>[
      for (final id in selected)
        if (byId[id] != null) byId[id]!,
    ];

    final recommended = exercise.recommendedControls;
    final recommendedIds = recommended.map((ControlOption c) => c.id).toSet();
    final hits = selected.intersection(recommendedIds);
    final extra = selected.difference(recommendedIds);
    final missed = recommendedIds.difference(selected);

    var ratio = 0.0;
    if (recommendedIds.isNotEmpty) {
      ratio = (hits.length - extra.length * 0.5) / recommendedIds.length;
    }

    final noteKeys = <String>[];

    final allPpe = chosen.every(
      (ControlOption c) => c.level == ControlLevel.epp,
    );
    final onlyPpe = chosen.isNotEmpty && allPpe;
    if (onlyPpe) {
      noteKeys.add('practice.feedback.controls.onlyPpe');
      // No se anula la nota: a veces el EPP es parte de la respuesta. Pero
      // un IPERC que se queda ahi no puede puntuar como uno completo.
      ratio = ratio.clamp(0.0, 0.3);
    }

    final actsOnHazard = chosen.any((ControlOption c) => c.level.actsOnHazard);
    final expectedActs = recommended.any(
      (ControlOption c) => c.level.actsOnHazard,
    );
    if (!actsOnHazard && expectedActs && !onlyPpe) {
      noteKeys.add('practice.feedback.controls.noHazardControl');
    }

    if (missed.isNotEmpty) {
      noteKeys.add('practice.feedback.controls.missed');
    }

    final details = <String>[];
    for (final control in exercise.controls) {
      if (missed.contains(control.id) || extra.contains(control.id)) {
        details.add('${control.label}. ${control.explanation}');
      }
    }

    return IpercStepResult(
      step: IpercStep.controls,
      ratio: ratio.clamp(0.0, 1.0),
      noteKeys: noteKeys,
      details: details,
    );
  }

  static IpercStepResult residual(
    IpercExercise exercise,
    Severity? severity,
    Probability? probability,
  ) {
    if (severity == null || probability == null) {
      return const IpercStepResult(step: IpercStep.residual, ratio: 0);
    }

    final expected = RiskMatrix.evaluate(
      severity: exercise.expectedResidualSeverity,
      probability: exercise.expectedResidualProbability,
    );
    final actual = RiskMatrix.evaluate(
      severity: severity,
      probability: probability,
    );

    final noteKeys = <String>[];
    var ratio = actual == expected ? 1.0 : 0.3;

    // El error clasico: dar por hecho que el control tambien reduce el dano.
    // Un sostenimiento hace menos probable que la roca caiga; si cae, sigue
    // matando.
    if (severity.rank > exercise.expectedResidualSeverity.rank) {
      noteKeys.add('practice.feedback.residual.severityLowered');
      ratio = ratio.clamp(0.0, 0.3);
    }

    if (actual.weight < expected.weight) {
      noteKeys.add('practice.feedback.residual.tooOptimistic');
    }

    return IpercStepResult(
      step: IpercStep.residual,
      ratio: ratio,
      noteKeys: noteKeys,
      details: <String>[exercise.residualRationale],
    );
  }

  /// Corrige el intento completo.
  static List<IpercStepResult> evaluate(
    IpercExercise exercise,
    IpercAttempt attempt,
  ) {
    return <IpercStepResult>[
      hazards(exercise, attempt.hazards),
      risk(exercise, attempt.riskChoice),
      assessment(exercise, attempt.severity, attempt.probability),
      controls(exercise, attempt.controls),
      residual(exercise, attempt.residualSeverity, attempt.residualProbability),
    ];
  }

  /// Nota de 0 a 100, ponderada por el peso de cada paso.
  static int score(List<IpercStepResult> results) {
    var total = 0.0;
    var weight = 0;
    for (final result in results) {
      total += result.ratio * result.step.weight;
      weight += result.step.weight;
    }
    if (weight == 0) {
      return 0;
    }
    return (total / weight * 100).round().clamp(0, 100);
  }
}
