import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/flow/app_flow_controller.dart';
import '../../../core/l10n/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/iperc/iperc_exercise_repository.dart';
import '../../../domain/iperc/iperc_evaluation.dart';
import '../../../domain/iperc/iperc_exercise.dart';
import '../../../domain/training/risk_level.dart';
import 'iperc_practice_view_model.dart';
import 'widgets/practice_inputs.dart';

/// Ejercicio guiado de construccion de una linea de IPERC.
///
/// Cinco pasos encadenados: identificar los peligros de la actividad,
/// redactar el riesgo, evaluarlo con la matriz, elegir controles y recalcular
/// el riesgo residual. Cada paso se corrige antes de pasar al siguiente,
/// porque un error arrastrado invalida todo lo que viene detras.
class IpercPracticeScreen extends ConsumerWidget {
  const IpercPracticeScreen({required this.exercise, super.key});

  final IpercExercise exercise;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = ref.watch(appStringsProvider).valueOrNull;
    final state = ref.watch(ipercPracticeProvider);
    final viewModel = ref.read(ipercPracticeProvider.notifier);

    if (strings == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final Widget body;
    if (state.isFinished) {
      body = _Summary(
        exercise: exercise,
        strings: strings,
        state: state,
        onRestart: viewModel.restart,
        onClose: () => Navigator.of(context).pop(),
      );
    } else {
      body = _StepBody(
        exercise: exercise,
        strings: strings,
        state: state,
        viewModel: viewModel,
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(strings('practice.title'))),
      body: SafeArea(child: body),
    );
  }
}

class _StepBody extends ConsumerWidget {
  const _StepBody({
    required this.exercise,
    required this.strings,
    required this.state,
    required this.viewModel,
  });

  final IpercExercise exercise;
  final AppStrings strings;
  final IpercPracticeState state;
  final IpercPracticeViewModel viewModel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final step = state.step!;
    final result = state.checked ? state.results.last : null;

    return Column(
      children: <Widget>[
        _StepBar(strings: strings, current: state.stepIndex),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.md,
              AppSpacing.lg,
              AppSpacing.lg,
            ),
            children: <Widget>[
              _ActivityCard(exercise: exercise, strings: strings),
              const SizedBox(height: AppSpacing.lg),
              Text(
                strings('practice.prompt.${step.name}'),
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: AppSpacing.md),
              _StepContent(
                exercise: exercise,
                strings: strings,
                state: state,
                viewModel: viewModel,
              ),
              if (result != null) ...<Widget>[
                const SizedBox(height: AppSpacing.lg),
                PracticeFeedback(result: result, strings: strings),
              ],
            ],
          ),
        ),
        _ActionBar(
          strings: strings,
          state: state,
          onCheck: () => viewModel.check(exercise),
          onAdvance: () {
            viewModel.advance();
            if (state.stepIndex == IpercStep.values.length - 1) {
              // Al cerrar el ultimo paso ya hay nota: se registra aqui, una
              // sola vez, en vez de en cada correccion parcial.
              final score = IpercEvaluator.score(state.results);
              unawaited(
                ref
                    .read(appFlowProvider.notifier)
                    .completeIpercPractice(score: score),
              );
            }
          },
        ),
      ],
    );
  }
}

class _StepContent extends StatelessWidget {
  const _StepContent({
    required this.exercise,
    required this.strings,
    required this.state,
    required this.viewModel,
  });

  final IpercExercise exercise;
  final AppStrings strings;
  final IpercPracticeState state;
  final IpercPracticeViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    switch (state.step!) {
      case IpercStep.hazards:
        return Column(
          children: <Widget>[
            for (final hazard in exercise.hazards)
              SelectableRow(
                label: hazard.label,
                selected: state.attempt.hazards.contains(hazard.id),
                locked: state.checked,
                onTap: () => viewModel.toggleHazard(hazard.id),
              ),
          ],
        );

      case IpercStep.risk:
        return Column(
          children: <Widget>[
            for (int i = 0; i < exercise.riskOptions.length; i++)
              SelectableRow(
                label: exercise.riskOptions[i].label,
                selected: state.attempt.riskChoice == i,
                locked: state.checked,
                onTap: () => viewModel.chooseRisk(i),
              ),
          ],
        );

      case IpercStep.assessment:
        return MatrixPicker(
          strings: strings,
          severity: state.attempt.severity,
          probability: state.attempt.probability,
          locked: state.checked,
          onSeverity: viewModel.setSeverity,
          onProbability: viewModel.setProbability,
        );

      case IpercStep.controls:
        return Column(
          children: <Widget>[
            for (final control in exercise.controls)
              SelectableRow(
                label: control.label,
                caption: strings(control.level.labelKey),
                selected: state.attempt.controls.contains(control.id),
                locked: state.checked,
                onTap: () => viewModel.toggleControl(control.id),
              ),
          ],
        );

      case IpercStep.residual:
        return MatrixPicker(
          strings: strings,
          severity: state.attempt.residualSeverity,
          probability: state.attempt.residualProbability,
          locked: state.checked,
          onSeverity: viewModel.setResidualSeverity,
          onProbability: viewModel.setResidualProbability,
        );
    }
  }
}

/// Indicador de avance por pasos.
class _StepBar extends StatelessWidget {
  const _StepBar({required this.strings, required this.current});

  final AppStrings strings;
  final int current;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const steps = IpercStep.values;
    final safeIndex = current.clamp(0, steps.length - 1);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.lg,
        0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              for (int i = 0; i < steps.length; i++)
                Expanded(
                  child: Container(
                    height: 4,
                    margin: const EdgeInsets.only(right: 3),
                    color: i <= safeIndex
                        ? AppColors.primary
                        : AppColors.textSecondary.withValues(alpha: 0.25),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            strings.format(
              'practice.stepCounter',
              <String, Object?>{
                'actual': safeIndex + 1,
                'total': steps.length,
                'nombre': strings(steps[safeIndex].labelKey),
              },
            ),
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _ActivityCard extends StatelessWidget {
  const _ActivityCard({required this.exercise, required this.strings});

  final IpercExercise exercise;
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
          Text(
            strings('practice.activityTitle'),
            style: theme.textTheme.bodySmall,
          ),
          Text(exercise.activity, style: theme.textTheme.labelLarge),
          const SizedBox(height: AppSpacing.sm),
          Text(exercise.context, style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _ActionBar extends StatelessWidget {
  const _ActionBar({
    required this.strings,
    required this.state,
    required this.onCheck,
    required this.onAdvance,
  });

  final AppStrings strings;
  final IpercPracticeState state;
  final VoidCallback onCheck;
  final VoidCallback onAdvance;

  @override
  Widget build(BuildContext context) {
    final isLast = state.stepIndex == IpercStep.values.length - 1;

    final VoidCallback? action;
    if (state.checked) {
      action = onAdvance;
    } else if (state.canCheck) {
      action = onCheck;
    } else {
      action = null;
    }

    final String label;
    if (!state.checked) {
      label = strings('practice.check');
    } else if (isLast) {
      label = strings('practice.finish');
    } else {
      label = strings('practice.next');
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.lg,
        AppSpacing.md,
      ),
      child: SizedBox(
        width: double.infinity,
        child: FilledButton(
          onPressed: action,
          child: Text(label),
        ),
      ),
    );
  }
}

/// Resumen final con la linea de IPERC construida.
class _Summary extends StatelessWidget {
  const _Summary({
    required this.exercise,
    required this.strings,
    required this.state,
    required this.onRestart,
    required this.onClose,
  });

  final IpercExercise exercise;
  final AppStrings strings;
  final IpercPracticeState state;
  final VoidCallback onRestart;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final expected = exercise.expectedLevels;

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.xxl,
      ),
      children: <Widget>[
        Text(
          strings('practice.summaryTitle'),
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          strings.format(
            'practice.summaryScore',
            <String, Object?>{'puntos': state.score},
          ),
          style: theme.textTheme.displaySmall,
        ),
        const SizedBox(height: AppSpacing.lg),
        for (final result in state.results) ...<Widget>[
          _StepScoreRow(result: result, strings: strings),
          const SizedBox(height: AppSpacing.xs),
        ],
        const SizedBox(height: AppSpacing.lg),
        Text(
          strings('practice.lineTitle'),
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: AppSpacing.sm),
        _IpercLine(exercise: exercise, strings: strings, expected: expected),
        const SizedBox(height: AppSpacing.lg),
        Row(
          children: <Widget>[
            Expanded(
              child: OutlinedButton(
                onPressed: onRestart,
                child: Text(strings('practice.restart')),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: FilledButton(
                onPressed: onClose,
                child: Text(strings('practice.close')),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _StepScoreRow extends StatelessWidget {
  const _StepScoreRow({required this.result, required this.strings});

  final IpercStepResult result;
  final AppStrings strings;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final percent = (result.ratio * 100).round();

    return Row(
      children: <Widget>[
        Icon(
          result.isPerfect ? Icons.check_circle_outline : Icons.remove_circle,
          size: 18,
          color: result.isPerfect ? AppColors.riskLow : AppColors.riskMedium,
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            strings(result.step.labelKey),
            style: theme.textTheme.bodyMedium,
          ),
        ),
        Text('$percent %', style: theme.textTheme.labelLarge),
      ],
    );
  }
}

/// La linea correcta de IPERC, para contrastar con lo respondido.
class _IpercLine extends StatelessWidget {
  const _IpercLine({
    required this.exercise,
    required this.strings,
    required this.expected,
  });

  final IpercExercise exercise;
  final AppStrings strings;
  final RiskLevelPair expected;

  @override
  Widget build(BuildContext context) {
    final correctRisk = exercise.riskOptions.firstWhere(
      (RiskOption o) => o.correct,
    );
    final controlLabels = <String>[
      for (final control in exercise.recommendedControls) control.label,
    ];
    final controlText = controlLabels.join('. ');

    return Column(
      children: <Widget>[
        LineRow(
          labelKey: 'iperc.flow.activity',
          value: exercise.activity,
          strings: strings,
        ),
        LineRow(
          labelKey: 'iperc.flow.hazard',
          value: exercise.primaryHazard.label,
          strings: strings,
        ),
        LineRow(
          labelKey: 'iperc.flow.risk',
          value: correctRisk.label,
          strings: strings,
        ),
        LineRow(
          labelKey: 'iperc.flow.assessment',
          value: _levelText(strings, expected.initial),
          strings: strings,
        ),
        LineRow(
          labelKey: 'iperc.flow.control',
          value: controlText,
          strings: strings,
        ),
        LineRow(
          labelKey: 'iperc.flow.residual',
          value: _levelText(strings, expected.residual),
          strings: strings,
        ),
      ],
    );
  }

  String _levelText(AppStrings strings, RiskLevel level) {
    return '${strings(level.labelKey)}. ${strings(level.deadlineKey)}';
  }
}

/// Punto de entrada al ejercicio guiado.
///
/// Resuelve la carga del contenido antes de construir la pantalla, para que
/// el ejercicio no tenga que lidiar con estados asincronos en cada paso.
class IpercPracticeEntry extends ConsumerWidget {
  const IpercPracticeEntry({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = ref.watch(appStringsProvider).valueOrNull;
    final exercises = ref.watch(ipercExercisesProvider);

    if (strings == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return exercises.when(
      loading: () => Scaffold(
        appBar: AppBar(title: Text(strings('practice.title'))),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Scaffold(
        appBar: AppBar(title: Text(strings('practice.title'))),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Text(strings('error.contentBody')),
          ),
        ),
      ),
      data: (List<IpercExercise> list) {
        if (list.isEmpty) {
          return Scaffold(
            appBar: AppBar(title: Text(strings('practice.title'))),
            body: Center(child: Text(strings('error.contentTitle'))),
          );
        }
        return IpercPracticeScreen(exercise: list.first);
      },
    );
  }
}
