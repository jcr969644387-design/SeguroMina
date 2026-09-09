import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:seguromina/domain/progress/trainee_level.dart';
import 'package:seguromina/domain/training/intro_mission.dart';
import 'package:seguromina/domain/training/risk_level.dart';
import 'package:seguromina/features/home/widgets/module_grid.dart';

/// Contrato entre el codigo y el archivo de textos.
///
/// `AppStrings` devuelve `[clave]` cuando falta una entrada, para que un
/// texto ausente se vea en QA en vez de romper la pantalla. Ese respaldo es
/// util en ejecucion y peligroso en revision: sin este test, una clave mal
/// escrita llega a produccion como un corchete en medio de la interfaz.
void main() {
  final file = File('assets/i18n/es.json');
  final raw = file.readAsStringSync();
  final decoded = jsonDecode(raw) as Map<String, dynamic>;
  final strings = decoded.map(
    (key, value) => MapEntry(key, value.toString()),
  );

  void expectKey(String key) {
    expect(
      strings.containsKey(key),
      isTrue,
      reason: 'Falta la clave "$key" en assets/i18n/es.json',
    );
  }

  test('el archivo de textos es JSON valido y no tiene valores vacios', () {
    expect(strings, isNotEmpty);
    for (final entry in strings.entries) {
      expect(
        entry.value.trim(),
        isNotEmpty,
        reason: 'La clave "${entry.key}" no tiene texto',
      );
    }
  });

  test('existen los textos de los modulos del home', () {
    for (final module in HomeModule.values) {
      expectKey(module.titleKey);
      expectKey(module.bodyKey);
    }
  });

  test('existen los textos de los niveles de riesgo y de estudiante', () {
    for (final level in RiskLevel.values) {
      expectKey(level.labelKey);
    }
    for (final level in TraineeLevel.values) {
      expectKey(level.labelKey);
    }
  });

  test('existen los textos de la mision de entrada', () {
    const mission = IntroMission.definition;
    expectKey(mission.titleKey);
    expectKey(mission.briefingKey);

    for (final hazard in mission.hazards) {
      expectKey(hazard.labelKey);
      expectKey(hazard.explanationKey);
      expectKey(hazard.controlKey);
    }
  });

  test('existen los textos de navegacion, splash y aviso academico', () {
    const required = <String>[
      'splash.tagline',
      'onboarding.skip',
      'onboarding.next',
      'onboarding.start',
      'onboarding.observe.title',
      'onboarding.observe.body',
      'onboarding.evaluate.title',
      'onboarding.evaluate.body',
      'onboarding.decide.title',
      'onboarding.decide.body',
      'home.greeting',
      'home.quickAccess',
      'home.pointsLabel',
      'notice.title',
      'notice.body',
      'notice.understood',
      'notice.dontShow',
      'mission.codeLabel',
      'mission.estimated',
      'mission.start',
      'mission.resume',
      'mission.instruction',
      'mission.finish',
      'mission.foundCount',
      'mission.sceneLabel',
      'mission.intro.objective',
      'result.title',
      'result.score',
      'result.passed',
      'result.failed',
      'result.perfect',
      'result.foundTitle',
      'result.missedTitle',
      'result.falsePositives',
      'result.controlLabel',
      'result.retry',
      'result.continue',
      'nav.home',
      'nav.scenarios',
      'nav.iperc',
      'nav.progress',
      'nav.profile',
      'scenarios.lockedTitle',
      'scenarios.locked',
      'scenarios.lockedBody',
      'comingSoon.title',
      'comingSoon.body',
      'content.sourceLabel',
      'common.back',
    ];

    for (final key in required) {
      expectKey(key);
    }
  });
}
