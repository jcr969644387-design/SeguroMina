import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';
import '../../domain/iperc/iperc_exercise.dart';
import 'iperc_exercise_parser.dart';

/// Acceso a los ejercicios guiados de IPERC.
abstract interface class IpercExerciseRepository {
  Future<List<IpercExercise>> load();
}

class AssetIpercExerciseRepository implements IpercExerciseRepository {
  const AssetIpercExerciseRepository();

  @override
  Future<List<IpercExercise>> load() async {
    final raw = await rootBundle.loadString(AppConstants.ipercExercisesPath);
    return parseIpercExercises(raw);
  }
}

final ipercExerciseRepositoryProvider = Provider<IpercExerciseRepository>(
  (ref) => const AssetIpercExerciseRepository(),
);

final ipercExercisesProvider = FutureProvider<List<IpercExercise>>((ref) {
  return ref.watch(ipercExerciseRepositoryProvider).load();
});
