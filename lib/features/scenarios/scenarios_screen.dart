import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/flow/app_flow_controller.dart';
import '../../core/l10n/app_strings.dart';
import '../../core/theme/app_typography.dart';
import '../../domain/training/intro_mission.dart';
import '../home/widgets/hero_mission_card.dart';
import '../home/widgets/scenario_list.dart';
import '../mission/intro_mission_screen.dart';

/// Catalogo de escenarios.
///
/// Destaca el escenario disponible y lista el itinerario completo. Los cuatro
/// restantes aparecen bloqueados con su nombre real: el estudiante debe saber
/// que viene despues, no descubrirlo cuando aparezca.
class ScenariosScreen extends ConsumerWidget {
  const ScenariosScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final flow = ref.watch(appFlowProvider);
    final strings = ref.watch(appStringsProvider).valueOrNull;

    if (strings == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    void openIntro() {
      unawaited(
        Navigator.of(context).push<void>(
          MaterialPageRoute<void>(
            builder: (context) => const IntroMissionScreen(),
          ),
        ),
      );
    }

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
            mission: IntroMission.definition,
            strings: strings,
            completed: flow.hasCompletedIntro,
            onStart: openIntro,
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            strings('home.scenariosTitle'),
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.sm),
          ScenarioList(
            strings: strings,
            introCompleted: flow.hasCompletedIntro,
            onOpenIntro: openIntro,
          ),
        ],
      ),
    );
  }
}
