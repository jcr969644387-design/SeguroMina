import 'package:flutter/material.dart';

import '../../../core/l10n/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/pressable_card.dart';
import '../../../domain/training/risk_level.dart';
import '../../../domain/training/scenario.dart';

/// Catalogo de escenarios.
///
/// Se construye desde el contenido cargado, no desde una lista fija: los
/// cinco escenarios del MVP estan disponibles y anadir un sexto es escribir
/// contenido.
class ScenarioList extends StatelessWidget {
  const ScenarioList({
    required this.strings,
    required this.scenarios,
    required this.completed,
    required this.onOpen,
    super.key,
  });

  final AppStrings strings;
  final List<TrainingScenario> scenarios;

  /// Identificadores de los escenarios ya superados.
  final Set<String> completed;

  final void Function(TrainingScenario scenario) onOpen;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        for (final scenario in scenarios) ...<Widget>[
          _ScenarioRow(
            strings: strings,
            scenario: scenario,
            completed: completed.contains(scenario.id),
            onTap: () => onOpen(scenario),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
      ],
    );
  }
}

class _ScenarioRow extends StatelessWidget {
  const _ScenarioRow({
    required this.strings,
    required this.scenario,
    required this.completed,
    required this.onTap,
  });

  final AppStrings strings;
  final TrainingScenario scenario;
  final bool completed;
  final VoidCallback onTap;

  Color get _riskColor {
    switch (scenario.dominantRisk) {
      case RiskLevel.alto:
        return AppColors.riskHigh;
      case RiskLevel.medio:
        return AppColors.riskMedium;
      case RiskLevel.bajo:
        return AppColors.riskLow;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PressableCard(
      onTap: onTap,
      semanticLabel: '${scenario.title}. ${scenario.briefing}',
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: _riskColor.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(AppSpacing.sm),
            ),
            child: Text(
              scenario.code,
              style: theme.textTheme.labelLarge?.copyWith(color: _riskColor),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(scenario.title, style: theme.textTheme.labelLarge),
                Text(scenario.briefing, style: theme.textTheme.bodySmall),
                const SizedBox(height: AppSpacing.xs),
                Row(
                  children: <Widget>[
                    Text(
                      strings(scenario.dominantRisk.labelKey),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: _riskColor,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      strings.format(
                        'mission.estimated',
                        <String, Object?>{
                          'minutos': scenario.estimatedMinutes,
                        },
                      ),
                      style: theme.textTheme.bodySmall,
                    ),
                    if (completed) ...<Widget>[
                      const SizedBox(width: AppSpacing.sm),
                      const Icon(
                        Icons.check_circle,
                        size: 14,
                        color: AppColors.riskLow,
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          const Icon(
            Icons.chevron_right,
            size: 20,
            color: AppColors.textSecondary,
          ),
        ],
      ),
    );
  }
}
