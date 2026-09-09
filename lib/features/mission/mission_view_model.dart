import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/training/intro_mission.dart';
import '../../domain/training/mission_scoring.dart';

/// Estado de la pantalla de inspeccion.
@immutable
class MissionUiState {
  const MissionUiState({
    this.marks = const <HazardMark>[],
    this.result,
  });

  final List<HazardMark> marks;

  /// Nulo mientras la inspeccion sigue abierta.
  final MissionResult? result;

  bool get finished => result != null;
}

/// Vista-modelo de la mision de entrada.
///
/// No contiene reglas: delega la puntuacion en `MissionScoring`, que vive en
/// el dominio y se testea sin interfaz. Aqui solo se guarda lo que el
/// estudiante lleva tocado y si ya cerro la inspeccion.
class MissionViewModel extends AutoDisposeNotifier<MissionUiState> {
  Mission get mission => IntroMission.definition;

  @override
  MissionUiState build() => const MissionUiState();

  void addMark(double x, double y) {
    if (state.finished) {
      return;
    }
    state = MissionUiState(
      marks: <HazardMark>[...state.marks, HazardMark(x: x, y: y)],
    );
  }

  /// Quita la ultima marca. Permite corregir un toque sin reiniciar todo.
  void undo() {
    if (state.finished || state.marks.isEmpty) {
      return;
    }
    state = MissionUiState(
      marks: state.marks.sublist(0, state.marks.length - 1),
    );
  }

  MissionResult finish() {
    final result = MissionScoring.evaluate(
      hazards: mission.hazards,
      marks: state.marks,
    );
    state = MissionUiState(marks: state.marks, result: result);
    return result;
  }

  void reset() {
    state = const MissionUiState();
  }
}

final missionViewModelProvider =
    NotifierProvider.autoDispose<MissionViewModel, MissionUiState>(
  MissionViewModel.new,
);
