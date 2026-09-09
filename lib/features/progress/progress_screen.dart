import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/flow/app_flow_controller.dart';
import '../../core/l10n/app_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../data/library/library_repository.dart';
import '../../domain/library/library_content.dart';
import '../../domain/progress/trainee_level.dart';
import '../home/widgets/scenario_list.dart';

/// Avance del estudiante.
///
/// Reune lo que ya esta medido en un solo sitio: nivel, precision por tipo de
/// tarea y recorrido por la biblioteca. Lo que aun no se ha medido se declara
/// como tal en vez de mostrarse como cero, que diria algo distinto.
class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final flow = ref.watch(appFlowProvider);
    final strings = ref.watch(appStringsProvider).valueOrNull;
    final content = ref.watch(libraryContentProvider).valueOrNull;

    if (strings == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: Text(strings('nav.progress'))),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.md,
          AppSpacing.lg,
          AppSpacing.xxl,
        ),
        children: <Widget>[
          _LevelCard(strings: strings, flow: flow),
          const SizedBox(height: AppSpacing.lg),
          Text(
            strings('progress.accuracyTitle'),
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.sm),
          _AccuracyBar(
            strings: strings,
            label: strings('home.hazardAccuracy'),
            value: flow.hazardAccuracy,
          ),
          const SizedBox(height: AppSpacing.sm),
          _AccuracyBar(
            strings: strings,
            label: strings('home.ipercAccuracy'),
            value: flow.ipercAccuracy,
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            strings('progress.libraryTitle'),
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.sm),
          if (content == null)
            const Center(child: CircularProgressIndicator())
          else
            _LibraryProgress(
              strings: strings,
              content: content,
              completed: flow.completedTopics,
            ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            strings('progress.scenariosTitle'),
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.sm),
          _ScenarioProgress(strings: strings, flow: flow),
        ],
      ),
    );
  }
}

class _LevelCard extends StatelessWidget {
  const _LevelCard({required this.strings, required this.flow});

  final AppStrings strings;
  final AppFlowState flow;

  /// Puntos que faltan para el siguiente nivel, o nulo en el maximo.
  int? get _remaining {
    final level = flow.level;
    if (level == TraineeLevel.experto) {
      return null;
    }
    final next = level == TraineeLevel.principiante
        ? TraineeLevel.intermedio
        : TraineeLevel.experto;
    return next.threshold - flow.points;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final remaining = _remaining;

    final String hint;
    if (remaining == null) {
      hint = strings('progress.maxLevel');
    } else {
      final next = flow.level == TraineeLevel.principiante
          ? TraineeLevel.intermedio
          : TraineeLevel.experto;
      hint = strings.format(
        'progress.nextLevel',
        <String, Object?>{
          'puntos': remaining,
          'nivel': strings(next.labelKey),
        },
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(AppSpacing.radius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            strings('progress.levelTitle'),
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.white.withValues(alpha: 0.80),
            ),
          ),
          Text(
            strings(flow.level.labelKey),
            style: theme.textTheme.displaySmall?.copyWith(color: Colors.white),
          ),
          const SizedBox(height: AppSpacing.sm),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: SizedBox(
              height: 6,
              child: LinearProgressIndicator(
                value: flow.levelProgress,
                backgroundColor: Colors.white.withValues(alpha: 0.30),
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            hint,
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.white.withValues(alpha: 0.88),
            ),
          ),
        ],
      ),
    );
  }
}

/// Barra de precision de un tipo de tarea.
class _AccuracyBar extends StatelessWidget {
  const _AccuracyBar({
    required this.strings,
    required this.label,
    required this.value,
  });

  final AppStrings strings;
  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final measured = value != AppFlowState.unmeasured;
    final ratio = measured ? value / 100 : 0.0;

    final Color color;
    if (!measured) {
      color = AppColors.textSecondary;
    } else if (value >= 80) {
      color = AppColors.riskLow;
    } else if (value >= 60) {
      color = AppColors.riskMedium;
    } else {
      color = AppColors.riskHigh;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(child: Text(label, style: theme.textTheme.bodyMedium)),
            Text(
              measured ? '$value %' : strings('home.notMeasured'),
              style: theme.textTheme.labelLarge,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: SizedBox(
            height: 6,
            child: LinearProgressIndicator(
              value: ratio,
              backgroundColor: AppColors.textSecondary.withValues(alpha: 0.20),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ),
      ],
    );
  }
}

/// Recorrido por la biblioteca, categoria a categoria.
class _LibraryProgress extends StatelessWidget {
  const _LibraryProgress({
    required this.strings,
    required this.content,
    required this.completed,
  });

  final AppStrings strings;
  final LibraryContent content;
  final Set<String> completed;

  int _readIn(LibraryCategory category) {
    var total = 0;
    for (final topic in category.topics) {
      if (completed.contains(topic.id)) {
        total++;
      }
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final total = content.topicCount;
    final read = completed.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          strings.format(
            'progress.libraryCount',
            <String, Object?>{'leidas': read, 'total': total},
          ),
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: AppSpacing.sm),
        for (final category in content.categories) ...<Widget>[
          _CategoryRow(
            title: category.title,
            read: _readIn(category),
            total: category.topics.length,
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
      ],
    );
  }
}

class _CategoryRow extends StatelessWidget {
  const _CategoryRow({
    required this.title,
    required this.read,
    required this.total,
  });

  final String title;
  final int read;
  final int total;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final done = total > 0 && read == total;

    return Row(
      children: <Widget>[
        Icon(
          done ? Icons.check_circle : Icons.radio_button_unchecked,
          size: 18,
          color: done ? AppColors.riskLow : AppColors.textSecondary,
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(child: Text(title, style: theme.textTheme.bodyMedium)),
        Text('$read / $total', style: theme.textTheme.labelLarge),
      ],
    );
  }
}

class _ScenarioProgress extends StatelessWidget {
  const _ScenarioProgress({required this.strings, required this.flow});

  final AppStrings strings;
  final AppFlowState flow;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final total = ScenarioList.scenarios.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          strings.format(
            'progress.scenarioCount',
            <String, Object?>{
              'hechos': flow.scenariosCompleted,
              'total': total,
            },
          ),
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: AppSpacing.sm),
        for (final scenario in ScenarioList.scenarios)
          _CategoryRow(
            title: strings(scenario.labelKey),
            read: scenario.ready && flow.hasCompletedIntro ? 1 : 0,
            total: 1,
          ),
      ],
    );
  }
}
