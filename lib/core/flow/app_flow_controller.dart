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
  });

  final bool hasSeenOnboarding;
  final bool hasCompletedIntro;
  final bool hidesAcademicNotice;
  final int points;

  TraineeLevel get level => TraineeLevel.forPoints(points);

  double get levelProgress => TraineeLevel.progressForPoints(points);

  AppFlowState copyWith({
    bool? hasSeenOnboarding,
    bool? hasCompletedIntro,
    bool? hidesAcademicNotice,
    int? points,
  }) {
    return AppFlowState(
      hasSeenOnboarding: hasSeenOnboarding ?? this.hasSeenOnboarding,
      hasCompletedIntro: hasCompletedIntro ?? this.hasCompletedIntro,
      hidesAcademicNotice: hidesAcademicNotice ?? this.hidesAcademicNotice,
      points: points ?? this.points,
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
}

class AppFlowController extends Notifier<AppFlowState> {
  PreferencesRepository get _repository {
    return ref.read(preferencesRepositoryProvider);
  }

  @override
  AppFlowState build() {
    final repository = ref.watch(preferencesRepositoryProvider);
    return AppFlowState(
      hasSeenOnboarding: repository.readBool(AppFlowKeys.seenOnboarding),
      hasCompletedIntro: repository.readBool(AppFlowKeys.completedIntro),
      hidesAcademicNotice: repository.readBool(AppFlowKeys.hidesNotice),
      points: repository.readInt(AppFlowKeys.points),
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

    state = state.copyWith(hasCompletedIntro: true, points: points);

    await _repository.writeBool(AppFlowKeys.completedIntro, value: true);
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
