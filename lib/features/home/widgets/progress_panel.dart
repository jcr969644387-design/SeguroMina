import 'package:flutter/material.dart';

import '../../../core/flow/app_flow_controller.dart';
import '../../../core/l10n/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

/// Panel de progreso del estudiante.
///
/// Presenta el avance como lo haria un tablero de operaciones: cifras y una
/// barra, sin insignias ni celebraciones. La gamificacion existe, pero aqui
/// se reduce al nombre del nivel alcanzado.
class ProgressPanel extends StatelessWidget {
  const ProgressPanel({
    required this.strings,
    required this.flow,
    super.key,
  });

  final AppStrings strings;
  final AppFlowState flow;

  /// Una metrica sin medir no es un cero: es la ausencia del dato.
  String _percent(int value) {
    if (value == AppFlowState.unmeasured) {
      return strings('home.notMeasured');
    }
    return '$value %';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppSpacing.radius),
        border: Border.all(
          color: AppColors.textSecondary.withValues(alpha: 0.20),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            strings('home.progressTitle'),
            style: theme.textTheme.labelLarge,
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Expanded(
                child: Text(
                  strings(flow.level.labelKey),
                  style: theme.textTheme.headlineSmall,
                ),
              ),
              Text(
                strings.format(
                  'home.pointsLabel',
                  <String, Object?>{'puntos': flow.points},
                ),
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: SizedBox(
              height: 6,
              child: LinearProgressIndicator(
                value: flow.levelProgress,
                backgroundColor: AppColors.textSecondary.withValues(
                  alpha: 0.20,
                ),
                valueColor: const AlwaysStoppedAnimation<Color>(
                  AppColors.primary,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: _Metric(
                  value: '${flow.scenariosCompleted}',
                  label: strings('home.scenariosCompleted'),
                ),
              ),
              Expanded(
                child: _Metric(
                  value: _percent(flow.hazardAccuracy),
                  label: strings('home.hazardAccuracy'),
                ),
              ),
              Expanded(
                child: _Metric(
                  value: _percent(flow.ipercAccuracy),
                  label: strings('home.ipercAccuracy'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(value, style: theme.textTheme.titleMedium),
        Text(label, style: theme.textTheme.bodySmall),
      ],
    );
  }
}
