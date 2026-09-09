import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/progress/trainee_level.dart';
import '../preferences/preferences_repository.dart';

/// Estado de avance del estudiante en la app.
///
/// Reune lo que decide que pantalla toca al abrir y lo que el Home necesita
/// para saludar: si ya vio el onboarding, si completo la mision de entrada,
/// si oculto el aviso academico y cuantos puntos lleva.
@immutable
class AppFlowState {
  const AppFlowState({
    this.hasSeenOnboarding = false,
    this.hasCompletedIntro = false,
    this.hidesAcademicNotice = false,
    this.points = 0,
    this.scenariosCompleted = 0,
    this.hazardAccuracy = unmeasured,
    this.ipercAccuracy = unmeasured,
    this.completedTopics = const <String>{},
  });

  /// Valor de las metricas que aun no se han medido.
  ///
  /// Se distingue de cero a proposito: un estudiante que todavia no ha
  /// evaluado nada no tiene una precision del 0 %, no tiene precision.
  static const int unmeasured = -1;

  final bool hasSeenOnboarding;
  final bool hasCompletedIntro;
  final bool hidesAcademicNotice;
  final int points;
  final int scenariosCompleted;

  /// Porcentaje de aciertos identificando peligros.
  final int hazardAccuracy;

  /// Porcentaje de aciertos construyendo matrices IPERC.
  final int ipercAccuracy;

  /// Fichas de la biblioteca cuya pregunta de comprobacion ya se respondio.
  final Set<String> completedTopics;

  TraineeLevel get level => TraineeLevel.forPoints(points);

  double get levelProgress => TraineeLevel.progressForPoints(points);

  AppFlowState copyWith({
    bool? hasSeenOnboarding,
    bool? hasCompletedIntro,
    bool? hidesAcademicNotice,
    int? points,
    int? scenariosCompleted,
    int? hazardAccuracy,
    int? ipercAccuracy,
    Set<String>? completedTopics,
  }) {
    return AppFlowState(
      hasSeenOnboarding: hasSeenOnboarding ?? this.hasSeenOnboarding,
      hasCompletedIntro: hasCompletedIntro ?? this.hasCompletedIntro,
      hidesAcademicNotice: hidesAcademicNotice ?? this.hidesAcademicNotice,
      points: points ?? this.points,
      scenariosCompleted: scenariosCompleted ?? this.scenariosCompleted,
      hazardAccuracy: hazardAccuracy ?? this.hazardAccuracy,
      ipercAccuracy: ipercAccuracy ?? this.ipercAccuracy,
      completedTopics: completedTopics ?? this.completedTopics,
    );
  }
}

/// Claves de almacenamiento. Centralizadas para que renombrar una no deje
/// datos huerfanos en los dispositivos ya instalados.
abstract final class AppFlowKeys {
  static const String seenOnboarding = 'flow.seenOnboarding';
  static const String completedIntro = 'flow.completedIntro';
  static const String hidesNotice = 'flow.hidesAcademicNotice';
  static const String points = 'flow.points';
  static const String scenarios = 'flow.scenariosCompleted';
  static const String hazardAccuracy = 'flow.hazardAccuracy';
  static const String ipercAccuracy = 'flow.ipercAccuracy';
  static const String completedTopics = 'flow.completedTopics';
}

class AppFlowController extends Notifier<AppFlowState> {
  PreferencesRepository get _repository {
    return ref.read(preferencesRepositoryProvider);
  }

  @override
  AppFlowState build() {
    final repository = ref.watch(preferencesRepositoryProvider);
    final topics = repository.readStringList(AppFlowKeys.completedTopics);

    return AppFlowState(
      hasSeenOnboarding: repository.readBool(AppFlowKeys.seenOnboarding),
      hasCompletedIntro: repository.readBool(AppFlowKeys.completedIntro),
      hidesAcademicNotice: repository.readBool(AppFlowKeys.hidesNotice),
      points: repository.readInt(AppFlowKeys.points),
      scenariosCompleted: repository.readInt(AppFlowKeys.scenarios),
      hazardAccuracy: repository.readInt(
        AppFlowKeys.hazardAccuracy,
        fallback: AppFlowState.unmeasured,
      ),
      ipercAccuracy: repository.readInt(
        AppFlowKeys.ipercAccuracy,
        fallback: AppFlowState.unmeasured,
      ),
      completedTopics: topics.toSet(),
    );
  }

  /// Marca una ficha de la biblioteca como estudiada.
  ///
  /// Antes esto vivia en el estado del widget de la pregunta, asi que al
  /// salir de la ficha se perdia y la pregunta volvia a aparecer sin
  /// responder. Ahora persiste, y con ella el avance por la biblioteca que
  /// muestra la pantalla de progreso.
  Future<void> markTopicCompleted(String topicId) async {
    if (state.completedTopics.contains(topicId)) {
      return;
    }

    final next = <String>{...state.completedTopics, topicId};
    state = state.copyWith(completedTopics: next);

    await _repository.writeStringList(
      AppFlowKeys.completedTopics,
      next.toList(),
    );
  }

  Future<void> completeOnboarding() async {
    state = state.copyWith(hasSeenOnboarding: true);
    await _repository.writeBool(AppFlowKeys.seenOnboarding, value: true);
  }

  /// Registra el resultado de la mision de entrada.
  ///
  /// Solo suma puntos la primera vez que se supera: repetir la mision sirve
  /// para practicar, no para inflar el nivel.
  Future<void> completeIntroMission({required int score}) async {
    final first = !state.hasCompletedIntro;
    final points = first ? state.points + score : state.points;
    final scenarios =
        first ? state.scenariosCompleted + 1 : state.scenariosCompleted;

    // La precision refleja el ultimo intento, tambien al repetir: sirve para
    // ver si el estudiante mejoro, y congelarla en el primer intento
    // convertiria la practica en algo sin efecto visible.
    state = state.copyWith(
      hasCompletedIntro: true,
      points: points,
      scenariosCompleted: scenarios,
      hazardAccuracy: score,
    );

    await _repository.writeBool(AppFlowKeys.completedIntro, value: true);
    await _repository.writeInt(AppFlowKeys.hazardAccuracy, score);
    if (first) {
      await _repository.writeInt(AppFlowKeys.points, points);
      await _repository.writeInt(AppFlowKeys.scenarios, scenarios);
    }
  }

  /// Registra el resultado de un ejercicio guiado de IPERC.
  ///
  /// Los puntos solo se suman la primera vez, igual que en los escenarios.
  /// La precision, en cambio, refleja siempre el ultimo intento: es lo que
  /// permite al estudiante ver si repetir le sirvio de algo.
  Future<void> completeIpercPractice({required int score}) async {
    final first = state.ipercAccuracy == AppFlowState.unmeasured;
    final points = first ? state.points + score : state.points;

    state = state.copyWith(points: points, ipercAccuracy: score);

    await _repository.writeInt(AppFlowKeys.ipercAccuracy, score);
    if (first) {
      await _repository.writeInt(AppFlowKeys.points, points);
    }
  }

  Future<void> hideAcademicNotice() async {
    state = state.copyWith(hidesAcademicNotice: true);
    await _repository.writeBool(AppFlowKeys.hidesNotice, value: true);
  }
}

final appFlowProvider = NotifierProvider<AppFlowController, AppFlowState>(
  AppFlowController.new,
);
