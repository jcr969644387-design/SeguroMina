import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:seguromina/domain/iperc/risk_assessment.dart';
import 'package:seguromina/domain/progress/trainee_level.dart';
import 'package:seguromina/domain/training/intro_mission.dart';
import 'package:seguromina/domain/training/risk_level.dart';
import 'package:seguromina/features/home/widgets/scenario_list.dart';

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

  test('existen los textos de los niveles de riesgo y de estudiante', () {
    for (final level in RiskLevel.values) {
      expectKey(level.labelKey);
      expectKey(level.rangeKey);
      expectKey(level.deadlineKey);
    }
    for (final level in TraineeLevel.values) {
      expectKey(level.labelKey);
    }
  });

  test('existen los textos de la matriz IPERC', () {
    for (final severity in Severity.values) {
      expectKey(severity.labelKey);
      expectKey(severity.detailKey);
    }
    for (final probability in Probability.values) {
      expectKey(probability.labelKey);
      expectKey(probability.detailKey);
    }
    for (final control in ControlLevel.values) {
      expectKey(control.labelKey);
      expectKey(control.detailKey);
      expectKey(control.exampleKey);
    }
  });

  test('existen los textos de los escenarios del itinerario', () {
    for (final scenario in ScenarioList.scenarios) {
      expectKey(scenario.labelKey);
    }
    expectKey('scenario.available');
    expectKey('scenario.completed');
    expectKey('scenario.locked');
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

  test('existen los textos de pantallas, diagramas y navegacion', () {
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
      'home.subtitle',
      'home.pointsLabel',
      'home.progressTitle',
      'home.scenariosCompleted',
      'home.hazardAccuracy',
      'home.ipercAccuracy',
      'home.notMeasured',
      'home.continueTitle',
      'home.continueAction',
      'home.quickTitle',
      'home.quick.identify',
      'home.quick.evaluate',
      'home.quick.control',
      'home.quick.iperc',
      'home.scenariosTitle',
      'home.foundationsTitle',
      'library.title',
      'library.subtitle',
      'library.topicCount',
      'library.sourceNote',
      'topic.exampleTitle',
      'topic.checkTitle',
      'topic.checkCorrect',
      'topic.checkIncorrect',
      'topic.checkAgain',
      'iperc.moduleSubtitle',
      'iperc.processTitle',
      'iperc.matrixTitle',
      'iperc.topicsTitle',
      'iperc.flow.activity',
      'iperc.flow.hazard',
      'iperc.flow.risk',
      'iperc.flow.assessment',
      'iperc.flow.control',
      'iperc.flow.residual',
      'diagram.matrix.probability',
      'diagram.matrix.severity',
      'diagram.hierarchy.note',
      'diagram.hazardRisk.hazard',
      'diagram.hazardRisk.hazardBody',
      'diagram.hazardRisk.exposure',
      'diagram.hazardRisk.exposureBody',
      'diagram.hazardRisk.risk',
      'diagram.hazardRisk.riskBody',
      'diagram.hazardRisk.note',
      'diagram.pyramid.fatal',
      'diagram.pyramid.disabling',
      'diagram.pyramid.minor',
      'diagram.pyramid.incident',
      'diagram.pyramid.note',
      'diagram.residual.initial',
      'diagram.residual.initialBody',
      'diagram.residual.controls',
      'diagram.residual.controlsBody',
      'diagram.residual.residual',
      'diagram.residual.residualBody',
      'diagram.residual.note',
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
      'notice.title',
      'notice.body',
      'notice.understood',
      'notice.dontShow',
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
