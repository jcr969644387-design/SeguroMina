import 'package:flutter/material.dart';

import '../../../core/l10n/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/pressable_card.dart';

/// Un escenario del itinerario del MVP.
class ScenarioEntry {
  const ScenarioEntry({
    required this.labelKey,
    required this.icon,
    required this.ready,
  });

  final String labelKey;
  final IconData icon;

  /// Si tiene contenido construido. Los que no lo tienen se muestran
  /// bloqueados en lugar de ocultarse: el estudiante debe ver el itinerario
  /// completo y saber que falta, no descubrirlo a medida que aparece.
  final bool ready;
}

/// Catalogo de escenarios.
class ScenarioList extends StatelessWidget {
  const ScenarioList({
    required this.strings,
    required this.introCompleted,
    required this.onOpenIntro,
    super.key,
  });

  final AppStrings strings;
  final bool introCompleted;
  final VoidCallback onOpenIntro;

  static const List<ScenarioEntry> scenarios = <ScenarioEntry>[
    ScenarioEntry(
      labelKey: 'scenario.underground',
      icon: Icons.terrain,
      ready: true,
    ),
    ScenarioEntry(
      labelKey: 'scenario.blasting',
      icon: Icons.warning_amber_rounded,
      ready: false,
    ),
    ScenarioEntry(
      labelKey: 'scenario.maintenance',
      icon: Icons.build_outlined,
      ready: false,
    ),
    ScenarioEntry(
      labelKey: 'scenario.haulage',
      icon: Icons.local_shipping_outlined,
      ready: false,
    ),
    ScenarioEntry(
      labelKey: 'scenario.ventilation',
      icon: Icons.air,
      ready: false,
    ),
  ];

  String _subtitleFor(ScenarioEntry scenario) {
    if (!scenario.ready) {
      return strings('scenario.locked');
    }
    return strings(
      introCompleted ? 'scenario.completed' : 'scenario.available',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        for (final scenario in scenarios) ...<Widget>[
          _ScenarioRow(
            title: strings(scenario.labelKey),
            subtitle: _subtitleFor(scenario),
            icon: scenario.icon,
            ready: scenario.ready,
            onTap: scenario.ready ? onOpenIntro : null,
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
      ],
    );
  }
}

class _ScenarioRow extends StatelessWidget {
  const _ScenarioRow({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.ready,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final bool ready;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final content = Row(
      children: <Widget>[
        Icon(
          ready ? icon : Icons.lock_outline,
          size: 20,
          color: ready ? AppColors.primary : AppColors.textSecondary,
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(title, style: theme.textTheme.labelLarge),
              Text(subtitle, style: theme.textTheme.bodySmall),
            ],
          ),
        ),
        if (ready)
          const Icon(
            Icons.chevron_right,
            size: 20,
            color: AppColors.textSecondary,
          ),
      ],
    );

    final callback = onTap;
    if (callback == null) {
      return Opacity(
        opacity: 0.55,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSpacing.radius),
            border: Border.all(
              color: AppColors.textSecondary.withValues(alpha: 0.30),
            ),
          ),
          child: content,
        ),
      );
    }

    return PressableCard(
      onTap: callback,
      semanticLabel: '$title. $subtitle',
      child: content,
    );
  }
}
