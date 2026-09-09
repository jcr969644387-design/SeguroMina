import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/flow/app_flow_controller.dart';
import '../../core/l10n/app_strings.dart';
import '../../core/theme/app_typography.dart';
import '../../data/scenarios/scenario_repository.dart';
import '../../domain/training/scenario.dart';
import '../home/widgets/hero_mission_card.dart';
import '../home/widgets/scenario_list.dart';
import '../mission/scenario_screen.dart';

/// Catalogo de escenarios.
///
/// Destaca el siguiente escenario pendiente y lista el itinerario completo.
/// Los cinco tienen contenido; ninguno esta bloqueado.
class ScenariosScreen extends ConsumerWidget {
  const ScenariosScreen({super.key});

  /// El primero sin superar, o el primero de la lista si ya estan todos.
  TrainingScenario _featured(
    List<TrainingScenario> scenarios,
    Set<String> completed,
  ) {
    for (final scenario in scenarios) {
      if (!completed.contains(scenario.id)) {
        return scenario;
      }
    }
    return scenarios.first;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final flow = ref.watch(appFlowProvider);
    final strings = ref.watch(appStringsProvider).valueOrNull;
    final scenarios = ref.watch(scenariosProvider).valueOrNull;

    if (strings == null || scenarios == null || scenarios.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    void open(TrainingScenario scenario) {
      unawaited(
        Navigator.of(context).push<void>(
          MaterialPageRoute<void>(
            builder: (context) => ScenarioScreen(scenario: scenario),
          ),
        ),
      );
    }

    final featured = _featured(scenarios, flow.completedScenarios);

    return Scaffold(
      appBar: AppBar(title: Text(strings('nav.scenarios'))),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.md,
          AppSpacing.lg,
          AppSpacing.xxl,
        ),
        children: <Widget>[
          HeroMissionCard(
            scenario: featured,
            strings: strings,
            completed: flow.completedScenarios.contains(featured.id),
            onStart: () => open(featured),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            strings('home.scenariosTitle'),
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.sm),
          ScenarioList(
            strings: strings,
            scenarios: scenarios,
            completed: flow.completedScenarios,
            onOpen: open,
          ),
        ],
      ),
    );
  }
}
