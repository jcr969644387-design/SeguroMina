import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/training/hazard.dart';
import '../../domain/training/mission_scoring.dart';

/// Estado de la inspeccion de un escenario.
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

/// Vista-modelo de la inspeccion.
///
/// No contiene reglas: delega la puntuacion en `MissionScoring`, que vive en
/// el dominio y se testea sin interfaz. El escenario se pasa como argumento
/// a [finish] en vez de fijarlo en el provider, de modo que la misma
/// vista-modelo sirve para los cinco.
class MissionViewModel extends AutoDisposeNotifier<MissionUiState> {
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

  MissionResult finish(List<Hazard> hazards) {
    final result = MissionScoring.evaluate(
      hazards: hazards,
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
