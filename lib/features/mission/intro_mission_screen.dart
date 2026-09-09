import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/flow/app_flow_controller.dart';
import '../../core/l10n/app_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../domain/training/hazard.dart';
import '../../domain/training/mission_scoring.dart';
import 'mission_view_model.dart';
import 'widgets/hazard_scene.dart';

/// Mision de entrada: inspeccion de la galeria de acceso.
///
/// Toda la app se explica en un minuto aqui: mirar la escena, marcar lo que
/// parece un peligro, cerrar la inspeccion y leer que se acerto, que se paso
/// por alto y que control corresponde en cada caso.
class IntroMissionScreen extends ConsumerWidget {
  const IntroMissionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final state = ref.watch(missionViewModelProvider);
    final viewModel = ref.read(missionViewModelProvider.notifier);
    final mission = viewModel.mission;
    final strings = ref.watch(appStringsProvider).valueOrNull;

    if (strings == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(strings(mission.titleKey)),
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
          Text(
            state.finished
                ? strings('mission.intro.briefing')
                : strings('mission.instruction'),
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.md),
          HazardScene(
            hazards: mission.hazards,
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
              hazardCount: mission.hazards.length,
              onFinish: () {
                final result = viewModel.finish();
                unawaited(
                  ref
                      .read(appFlowProvider.notifier)
                      .completeIntroMission(score: result.score),
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
            crossAxisAlignment: CrossAxisAlignment.center,
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
                        strings(hazard.labelKey),
                        style: theme.textTheme.bodyMedium,
                      ),
                      Text(
                        strings(hazard.explanationKey),
                        style: theme.textTheme.bodySmall,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${strings('result.controlLabel')}: '
                        '${strings(hazard.controlKey)}',
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
