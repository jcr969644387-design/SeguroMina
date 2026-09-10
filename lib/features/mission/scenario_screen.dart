import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/flow/app_flow_controller.dart';
import '../../core/l10n/app_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../data/scenarios/scenario_repository.dart';
import '../../domain/training/hazard.dart';
import '../../domain/training/mission_scoring.dart';
import '../../domain/training/scenario.dart';
import 'mission_view_model.dart';
import 'widgets/technical_scene.dart';

/// Inspeccion de un escenario.
///
/// Toda la app se explica aqui: leer la situacion, mirar el corte, marcar lo
/// que parece un peligro, cerrar la inspeccion y leer que se acerto, que se
/// paso por alto y que control corresponde en cada caso.
class ScenarioScreen extends ConsumerWidget {
  const ScenarioScreen({required this.scenario, super.key});

  final TrainingScenario scenario;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final state = ref.watch(missionViewModelProvider);
    final viewModel = ref.read(missionViewModelProvider.notifier);
    final strings = ref.watch(appStringsProvider).valueOrNull;

    if (strings == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(scenario.title),
        actions: <Widget>[
          if (!state.finished && state.marks.isNotEmpty)
            IconButton(
              onPressed: viewModel.undo,
              icon: const Icon(Icons.undo),
              tooltip: strings('common.back'),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.md,
          AppSpacing.lg,
          AppSpacing.xxl,
        ),
        children: <Widget>[
          _SituationCard(scenario: scenario, strings: strings),
          const SizedBox(height: AppSpacing.md),
          Text(
            state.finished ? scenario.briefing : strings('mission.instruction'),
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.md),
          TechnicalScene(
            scene: scenario.scene,
            hazards: scenario.hazards,
            marks: state.marks,
            revealed: state.finished,
            semanticLabel: strings('mission.sceneLabel'),
            onTapPoint: viewModel.addMark,
          ),
          const SizedBox(height: AppSpacing.md),
          if (!state.finished)
            _InspectionControls(
              strings: strings,
              markCount: state.marks.length,
              hazardCount: scenario.hazards.length,
              onFinish: () {
                final result = viewModel.finish(scenario.hazards);
                final controller = ref.read(appFlowProvider.notifier);
                unawaited(
                  controller.completeScenario(
                    scenarioId: scenario.id,
                    score: result.score,
                  ),
                );
              },
            )
          else
            _MissionResultCard(
              strings: strings,
              result: state.result!,
              onRetry: viewModel.reset,
              onContinue: () => Navigator.of(context).pop(),
            ),
        ],
      ),
    );
  }
}

/// Punto de entrada que resuelve la carga del contenido.
class ScenarioEntry extends ConsumerWidget {
  const ScenarioEntry({required this.scenarioId, super.key});

  final String scenarioId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = ref.watch(appStringsProvider).valueOrNull;
    final scenarios = ref.watch(scenariosProvider).valueOrNull;

    if (strings == null || scenarios == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    for (final scenario in scenarios) {
      if (scenario.id == scenarioId) {
        return ScenarioScreen(scenario: scenario);
      }
    }

    return Scaffold(
      appBar: AppBar(),
      body: Center(child: Text(strings('error.contentTitle'))),
    );
  }
}

/// Situacion inicial de la labor.
///
/// Va antes del corte y no despues: la probabilidad de un peligro depende de
/// las condiciones, y sin leerlas la inspeccion es adivinar.
class _SituationCard extends StatelessWidget {
  const _SituationCard({required this.scenario, required this.strings});

  final TrainingScenario scenario;
  final AppStrings strings;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppSpacing.sm),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  strings.format(
                    'mission.codeLabel',
                    <String, Object?>{'codigo': scenario.code},
                  ),
                  style: theme.textTheme.labelLarge,
                ),
              ),
              Text(
                strings.format(
                  'mission.estimated',
                  <String, Object?>{'minutos': scenario.estimatedMinutes},
                ),
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            strings('mission.situationTitle'),
            style: theme.textTheme.bodySmall,
          ),
          Text(scenario.situation, style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class _InspectionControls extends StatelessWidget {
  const _InspectionControls({
    required this.strings,
    required this.markCount,
    required this.hazardCount,
    required this.onFinish,
  });

  final AppStrings strings;
  final int markCount;
  final int hazardCount;
  final VoidCallback onFinish;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(
          strings.format(
            'mission.foundCount',
            <String, Object?>{'vistos': markCount, 'total': hazardCount},
          ),
          textAlign: TextAlign.center,
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: AppSpacing.md),
        FilledButton(
          onPressed: markCount == 0 ? null : onFinish,
          child: Text(strings('mission.finish')),
        ),
      ],
    );
  }
}

/// Retroalimentacion inmediata.
///
/// Muestra los aciertos y, sobre todo, lo que no se vio: en seguridad el
/// peligro que se pasa por alto ensena mas que el que se identifica.
class _MissionResultCard extends StatelessWidget {
  const _MissionResultCard({
    required this.strings,
    required this.result,
    required this.onRetry,
    required this.onContinue,
  });

  final AppStrings strings;
  final MissionResult result;
  final VoidCallback onRetry;
  final VoidCallback onContinue;

  String get _verdictKey {
    if (result.isPerfect) {
      return 'result.perfect';
    }
    return result.passed ? 'result.passed' : 'result.failed';
  }

  Color get _verdictColor {
    if (result.isPerfect) {
      return AppColors.riskLow;
    }
    return result.passed ? AppColors.riskLow : AppColors.riskMedium;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppSpacing.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            strings('result.title'),
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: <Widget>[
              Text(
                strings.format(
                  'result.score',
                  <String, Object?>{'puntos': result.score},
                ),
                style: theme.textTheme.displaySmall?.copyWith(
                  color: _verdictColor,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  strings(_verdictKey),
                  style: theme.textTheme.labelLarge,
                ),
              ),
            ],
          ),
          if (result.found.isNotEmpty) ...<Widget>[
            const SizedBox(height: AppSpacing.md),
            _HazardList(
              strings: strings,
              titleKey: 'result.foundTitle',
              hazards: result.found,
              color: AppColors.riskLow,
              icon: Icons.check_circle_outline,
            ),
          ],
          if (result.missed.isNotEmpty) ...<Widget>[
            const SizedBox(height: AppSpacing.md),
            _HazardList(
              strings: strings,
              titleKey: 'result.missedTitle',
              hazards: result.missed,
              color: AppColors.riskMedium,
              icon: Icons.error_outline,
            ),
          ],
          if (result.falsePositives > 0) ...<Widget>[
            const SizedBox(height: AppSpacing.sm),
            Text(
              strings.format(
                'result.falsePositives',
                <String, Object?>{'total': result.falsePositives},
              ),
              style: theme.textTheme.bodySmall,
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          Row(
            children: <Widget>[
              Expanded(
                child: OutlinedButton(
                  onPressed: onRetry,
                  child: Text(strings('result.retry')),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: FilledButton(
                  onPressed: onContinue,
                  child: Text(strings('result.continue')),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HazardList extends StatelessWidget {
  const _HazardList({
    required this.strings,
    required this.titleKey,
    required this.hazards,
    required this.color,
    required this.icon,
  });

  final AppStrings strings;
  final String titleKey;
  final List<Hazard> hazards;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(strings(titleKey), style: theme.textTheme.labelLarge),
        const SizedBox(height: AppSpacing.xs),
        for (final hazard in hazards)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Icon(icon, size: 18, color: color),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        hazard.label,
                        style: theme.textTheme.bodyMedium,
                      ),
                      Text(
                        hazard.explanation,
                        style: theme.textTheme.bodySmall,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${strings('result.controlLabel')}: ${hazard.control}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
