import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';
import '../../domain/training/scenario.dart';
import 'scenario_parser.dart';

/// Acceso a los escenarios de entrenamiento.
abstract interface class ScenarioRepository {
  Future<List<TrainingScenario>> load();
}

class AssetScenarioRepository implements ScenarioRepository {
  const AssetScenarioRepository();

  @override
  Future<List<TrainingScenario>> load() async {
    final raw = await rootBundle.loadString(AppConstants.scenariosPath);
    return parseScenarios(raw);
  }
}

final scenarioRepositoryProvider = Provider<ScenarioRepository>(
  (ref) => const AssetScenarioRepository(),
);

final scenariosProvider = FutureProvider<List<TrainingScenario>>((ref) {
  return ref.watch(scenarioRepositoryProvider).load();
});
