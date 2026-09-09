import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/iperc/iperc_evaluation.dart';
import '../../../domain/iperc/iperc_exercise.dart';
import '../../../domain/iperc/risk_assessment.dart';

/// Estado de un ejercicio guiado en curso.
@immutable
class IpercPracticeState {
  const IpercPracticeState({
    this.stepIndex = 0,
    this.attempt = const IpercAttempt(),
    this.checked = false,
    this.results = const <IpercStepResult>[],
  });

  /// Paso actual, de 0 a 4. Cuando llega a 5, el ejercicio termino.
  final int stepIndex;

  final IpercAttempt attempt;

  /// Si el paso actual ya se corrigio y se esta mostrando la explicacion.
  final bool checked;

  /// Correcciones acumuladas, una por paso ya resuelto.
  final List<IpercStepResult> results;

  IpercStep? get step {
    if (stepIndex >= IpercStep.values.length) {
      return null;
    }
    return IpercStep.values[stepIndex];
  }

  bool get isFinished => stepIndex >= IpercStep.values.length;

  int get score => IpercEvaluator.score(results);

  /// Si el paso actual tiene lo suficiente respondido para corregirse.
  bool get canCheck {
    switch (step) {
      case IpercStep.hazards:
        return attempt.hazards.isNotEmpty;
      case IpercStep.risk:
        return attempt.riskChoice != null;
      case IpercStep.assessment:
        return attempt.severity != null && attempt.probability != null;
      case IpercStep.controls:
        return attempt.controls.isNotEmpty;
      case IpercStep.residual:
        return attempt.residualSeverity != null &&
            attempt.residualProbability != null;
      case null:
        return false;
    }
  }

  IpercPracticeState copyWith({
    int? stepIndex,
    IpercAttempt? attempt,
    bool? checked,
    List<IpercStepResult>? results,
  }) {
    return IpercPracticeState(
      stepIndex: stepIndex ?? this.stepIndex,
      attempt: attempt ?? this.attempt,
      checked: checked ?? this.checked,
      results: results ?? this.results,
    );
  }
}

/// Vista-modelo del ejercicio guiado.
///
/// No contiene reglas de correccion: delega en `IpercEvaluator`, que vive en
/// el dominio y se testea sin interfaz. Aqui solo se guarda lo respondido y
/// en que paso va el estudiante.
///
/// El ejercicio se pasa como argumento a [check] en vez de fijarlo como
/// familia del provider: asi la cache de Riverpod no depende de la identidad
/// del objeto de contenido.
class IpercPracticeViewModel extends AutoDisposeNotifier<IpercPracticeState> {
  @override
  IpercPracticeState build() => const IpercPracticeState();

  void toggleHazard(String id) {
    if (state.checked) {
      return;
    }
    final next = <String>{...state.attempt.hazards};
    if (!next.remove(id)) {
      next.add(id);
    }
    state = state.copyWith(attempt: state.attempt.copyWith(hazards: next));
  }

  void chooseRisk(int index) {
    if (state.checked) {
      return;
    }
    state = state.copyWith(
      attempt: state.attempt.copyWith(riskChoice: index),
    );
  }

  /// Cuatro asignadores de una sola variable en vez de uno con parametros
  /// con nombre: asi los desplegables reciben la referencia directa al metodo
  /// y la pantalla no necesita envolverlos en funciones anonimas.
  void setSeverity(Severity? value) {
    if (state.checked || value == null) {
      return;
    }
    state = state.copyWith(
      attempt: state.attempt.copyWith(severity: value),
    );
  }

  void setProbability(Probability? value) {
    if (state.checked || value == null) {
      return;
    }
    state = state.copyWith(
      attempt: state.attempt.copyWith(probability: value),
    );
  }

  void toggleControl(String id) {
    if (state.checked) {
      return;
    }
    final next = <String>{...state.attempt.controls};
    if (!next.remove(id)) {
      next.add(id);
    }
    state = state.copyWith(attempt: state.attempt.copyWith(controls: next));
  }

  void setResidualSeverity(Severity? value) {
    if (state.checked || value == null) {
      return;
    }
    state = state.copyWith(
      attempt: state.attempt.copyWith(residualSeverity: value),
    );
  }

  void setResidualProbability(Probability? value) {
    if (state.checked || value == null) {
      return;
    }
    state = state.copyWith(
      attempt: state.attempt.copyWith(residualProbability: value),
    );
  }

  /// Corrige el paso actual y muestra la explicacion.
  void check(IpercExercise exercise) {
    final step = state.step;
    if (step == null || state.checked || !state.canCheck) {
      return;
    }

    final attempt = state.attempt;
    final IpercStepResult result;
    switch (step) {
      case IpercStep.hazards:
        result = IpercEvaluator.hazards(exercise, attempt.hazards);
      case IpercStep.risk:
        result = IpercEvaluator.risk(exercise, attempt.riskChoice);
      case IpercStep.assessment:
        result = IpercEvaluator.assessment(
          exercise,
          attempt.severity,
          attempt.probability,
        );
      case IpercStep.controls:
        result = IpercEvaluator.controls(exercise, attempt.controls);
      case IpercStep.residual:
        result = IpercEvaluator.residual(
          exercise,
          attempt.residualSeverity,
          attempt.residualProbability,
        );
    }

    state = state.copyWith(
      checked: true,
      results: <IpercStepResult>[...state.results, result],
    );
  }

  void advance() {
    if (!state.checked) {
      return;
    }
    state = state.copyWith(stepIndex: state.stepIndex + 1, checked: false);
  }

  void restart() {
    state = const IpercPracticeState();
  }
}

final ipercPracticeProvider =
    NotifierProvider.autoDispose<IpercPracticeViewModel, IpercPracticeState>(
  IpercPracticeViewModel.new,
);
