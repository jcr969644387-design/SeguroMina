import 'package:flutter/material.dart';

import '../../../core/l10n/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../domain/training/scenario.dart';

/// Ficha del escenario destacado.
///
/// Es el elemento con mas peso visual a proposito: la accion que se espera
/// del estudiante es entrar a un escenario, no leer el menu.
class HeroMissionCard extends StatelessWidget {
  const HeroMissionCard({
    required this.scenario,
    required this.strings,
    required this.completed,
    required this.onStart,
    super.key,
  });

  final TrainingScenario scenario;
  final AppStrings strings;
  final bool completed;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const onCard = Colors.white;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(AppSpacing.lg),
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
                  style: theme.textTheme.labelLarge?.copyWith(color: onCard),
                ),
              ),
              _RiskChip(label: strings(scenario.dominantRisk.labelKey)),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            scenario.title,
            style: theme.textTheme.headlineSmall?.copyWith(color: onCard),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            scenario.briefing,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: onCard.withValues(alpha: 0.88),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: <Widget>[
              Icon(
                Icons.schedule,
                size: 16,
                color: onCard.withValues(alpha: 0.85),
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                strings.format(
                  'mission.estimated',
                  <String, Object?>{'minutos': scenario.estimatedMinutes},
                ),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: onCard.withValues(alpha: 0.85),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Icon(
                completed ? Icons.check_circle : Icons.radio_button_unchecked,
                size: 16,
                color: onCard.withValues(alpha: 0.85),
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  strings.format(
                    'mission.intro.objective',
                    <String, Object?>{'total': scenario.hazards.length},
                  ),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: onCard.withValues(alpha: 0.85),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: onStart,
              style: FilledButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.primary,
              ),
              child: Text(
                completed
                    ? strings('mission.resume')
                    : strings('mission.start'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RiskChip extends StatelessWidget {
  const _RiskChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(AppSpacing.sm),
        border: Border.all(color: Colors.white.withValues(alpha: 0.45)),
      ),
      child: Text(
        label,
        style: theme.textTheme.bodySmall?.copyWith(color: Colors.white),
      ),
    );
  }
}
