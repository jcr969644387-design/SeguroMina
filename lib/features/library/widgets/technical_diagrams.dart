import 'package:flutter/material.dart';

import '../../../core/l10n/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../domain/iperc/risk_assessment.dart';
import '../../../domain/training/risk_level.dart';

/// Diagramas tecnicos de las fichas de la biblioteca.
///
/// Se construyen con widgets de composicion y no con imagenes ni
/// [CustomPainter]: asi crecen con la escala de texto del sistema, respetan
/// el tema claro y oscuro y no anaden peso a la descarga.
///
/// El registro esta centralizado para que una ficha con un identificador de
/// diagrama inexistente no rompa la pantalla: simplemente no dibuja nada.
class TechnicalDiagram extends StatelessWidget {
  const TechnicalDiagram({
    required this.id,
    required this.strings,
    super.key,
  });

  final String id;
  final AppStrings strings;

  static const Set<String> available = <String>{
    'hazard_vs_risk',
    'accident_pyramid',
    'control_hierarchy',
    'iperc_flow',
    'risk_matrix',
    'residual_risk',
  };

  @override
  Widget build(BuildContext context) {
    final diagram = switch (id) {
      'hazard_vs_risk' => _HazardVsRisk(strings: strings),
      'accident_pyramid' => _AccidentPyramid(strings: strings),
      'control_hierarchy' => ControlHierarchyDiagram(strings: strings),
      'iperc_flow' => IpercFlowDiagram(strings: strings),
      'risk_matrix' => RiskMatrixDiagram(strings: strings),
      'residual_risk' => _ResidualRisk(strings: strings),
      _ => null,
    };

    if (diagram == null) {
      return const SizedBox.shrink();
    }
    return _DiagramFrame(child: diagram);
  }
}

/// Marco comun: fondo neutro y un filete fino, como una lamina tecnica.
class _DiagramFrame extends StatelessWidget {
  const _DiagramFrame({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppSpacing.sm),
        border: Border.all(
          color: AppColors.textSecondary.withValues(alpha: 0.25),
        ),
      ),
      child: child,
    );
  }
}

/// Matriz basica de evaluacion de riesgos del Anexo 7.
///
/// Se dibuja con los mismos datos que usa el motor de evaluacion, no con una
/// copia: si la tabla del dominio cambiara, el diagrama cambia con ella.
class RiskMatrixDiagram extends StatelessWidget {
  const RiskMatrixDiagram({
    required this.strings,
    this.highlightSeverity,
    this.highlightProbability,
    super.key,
  });

  final AppStrings strings;

  /// Celda resaltada, si la pantalla esta evaluando un riesgo concreto.
  final Severity? highlightSeverity;
  final Probability? highlightProbability;

  Color _fill(RiskLevel level) {
    switch (level) {
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          strings('diagram.matrix.probability'),
          style: theme.textTheme.bodySmall,
        ),
        const SizedBox(height: AppSpacing.xs),
        Row(
          children: <Widget>[
            _AxisLabel(text: strings('diagram.matrix.severity')),
            const SizedBox(width: AppSpacing.xs),
            Expanded(
              child: Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      for (int p = 1; p <= 5; p++)
                        Expanded(child: _HeaderCell(text: '$p')),
                    ],
                  ),
                  for (final severity in Severity.values)
                    Row(
                      children: <Widget>[
                        for (final probability in Probability.values)
                          Expanded(
                            child: _buildCell(context, severity, probability),
                          ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.md,
          runSpacing: AppSpacing.xs,
          children: <Widget>[
            for (final level in RiskLevel.values)
              _LegendChip(
                color: _fill(level),
                label: '${strings(level.labelKey)} ${strings(level.rangeKey)}',
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildCell(
    BuildContext context,
    Severity severity,
    Probability probability,
  ) {
    final index = RiskMatrix.indexFor(
      severity: severity,
      probability: probability,
    );
    final level = RiskMatrix.levelFor(index);
    final selected =
        severity == highlightSeverity && probability == highlightProbability;
    final style = Theme.of(context).textTheme.bodySmall?.copyWith(
      fontWeight: FontWeight.w700,
      color: selected ? Colors.white : null,
    );

    return Container(
      margin: const EdgeInsets.all(1),
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: _fill(level).withValues(alpha: selected ? 1 : 0.22),
        border: selected
            ? Border.all(color: AppColors.textPrimary, width: 2)
            : null,
        borderRadius: BorderRadius.circular(3),
      ),
      child: Text('$index', textAlign: TextAlign.center, style: style),
    );
  }
}

class _HeaderCell extends StatelessWidget {
  const _HeaderCell({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodySmall,
      ),
    );
  }
}

class _AxisLabel extends StatelessWidget {
  const _AxisLabel({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return RotatedBox(
      quarterTurns: 3,
      child: Text(text, style: Theme.of(context).textTheme.bodySmall),
    );
  }
}

class _LegendChip extends StatelessWidget {
  const _LegendChip({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

/// Jerarquia de controles como piramide invertida.
///
/// La anchura decreciente no es decoracion: representa cuanta gente queda
/// protegida por cada nivel. La eliminacion alcanza a todos; el EPP, solo a
/// quien lo lleva puesto.
class ControlHierarchyDiagram extends StatelessWidget {
  const ControlHierarchyDiagram({
    required this.strings,
    this.highlight,
    super.key,
  });

  final AppStrings strings;
  final ControlLevel? highlight;

  static const List<Color> _tints = <Color>[
    AppColors.riskLow,
    AppColors.riskLow,
    AppColors.primary,
    AppColors.riskMedium,
    AppColors.secondary,
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        for (final level in ControlLevel.values) ...<Widget>[
          FractionallySizedBox(
            widthFactor: 1 - (level.rank - 1) * 0.11,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: _tints[level.rank - 1].withValues(
                  alpha: highlight == level ? 0.55 : 0.22,
                ),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: _tints[level.rank - 1].withValues(alpha: 0.7),
                ),
              ),
              child: Row(
                children: <Widget>[
                  Text(
                    '${level.rank}',
                    style: theme.textTheme.labelLarge,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      strings(level.labelKey),
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
        ],
        const SizedBox(height: AppSpacing.xs),
        Text(
          strings('diagram.hierarchy.note'),
          style: theme.textTheme.bodySmall,
        ),
      ],
    );
  }
}

/// Secuencia del IPERC, en vertical para que quepa en un telefono.
class IpercFlowDiagram extends StatelessWidget {
  const IpercFlowDiagram({required this.strings, this.activeStep, super.key});

  final AppStrings strings;

  /// Paso resaltado, de 0 a 5.
  final int? activeStep;

  static const List<String> _stepKeys = <String>[
    'iperc.flow.activity',
    'iperc.flow.hazard',
    'iperc.flow.risk',
    'iperc.flow.assessment',
    'iperc.flow.control',
    'iperc.flow.residual',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        for (int i = 0; i < _stepKeys.length; i++) ...<Widget>[
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: activeStep == i
                  ? AppColors.primary
                  : AppColors.primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.45),
              ),
            ),
            child: Row(
              children: <Widget>[
                Text(
                  '${i + 1}',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: activeStep == i ? Colors.white : null,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    strings(_stepKeys[i]),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: activeStep == i ? Colors.white : null,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (i < _stepKeys.length - 1)
            const Icon(
              Icons.arrow_downward,
              size: 16,
              color: AppColors.textSecondary,
            ),
        ],
      ],
    );
  }
}

/// Peligro frente a riesgo: la fuente, la exposicion y la consecuencia.
class _HazardVsRisk extends StatelessWidget {
  const _HazardVsRisk({required this.strings});

  final AppStrings strings;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _Block(
          title: strings('diagram.hazardRisk.hazard'),
          body: strings('diagram.hazardRisk.hazardBody'),
          color: AppColors.secondary,
        ),
        const _Connector(),
        _Block(
          title: strings('diagram.hazardRisk.exposure'),
          body: strings('diagram.hazardRisk.exposureBody'),
          color: AppColors.primary,
        ),
        const _Connector(),
        _Block(
          title: strings('diagram.hazardRisk.risk'),
          body: strings('diagram.hazardRisk.riskBody'),
          color: AppColors.riskHigh,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          strings('diagram.hazardRisk.note'),
          style: theme.textTheme.bodySmall,
        ),
      ],
    );
  }
}

class _Block extends StatelessWidget {
  const _Block({
    required this.title,
    required this.body,
    required this.color,
  });

  final String title;
  final String body;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(4),
        border: Border(left: BorderSide(color: color, width: 3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(title, style: theme.textTheme.labelLarge),
          Text(body, style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _Connector extends StatelessWidget {
  const _Connector();

  @override
  Widget build(BuildContext context) {
    return const Icon(
      Icons.arrow_downward,
      size: 16,
      color: AppColors.textSecondary,
    );
  }
}

/// Proporcion entre incidentes y accidentes.
class _AccidentPyramid extends StatelessWidget {
  const _AccidentPyramid({required this.strings});

  final AppStrings strings;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    const layers = <(String, double, Color)>[
      ('diagram.pyramid.fatal', 0.30, AppColors.riskHigh),
      ('diagram.pyramid.disabling', 0.50, AppColors.riskMedium),
      ('diagram.pyramid.minor', 0.72, AppColors.secondary),
      ('diagram.pyramid.incident', 1.0, AppColors.primary),
    ];

    return Column(
      children: <Widget>[
        for (final layer in layers) ...<Widget>[
          FractionallySizedBox(
            widthFactor: layer.$2,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              decoration: BoxDecoration(
                color: layer.$3.withValues(alpha: 0.22),
                border: Border.all(
                  color: layer.$3.withValues(alpha: 0.6),
                ),
                borderRadius: BorderRadius.circular(3),
              ),
              child: Text(
                strings(layer.$1),
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall,
              ),
            ),
          ),
          const SizedBox(height: 3),
        ],
        const SizedBox(height: AppSpacing.xs),
        Text(
          strings('diagram.pyramid.note'),
          style: theme.textTheme.bodySmall,
        ),
      ],
    );
  }
}

/// Riesgo inicial frente a riesgo residual.
class _ResidualRisk extends StatelessWidget {
  const _ResidualRisk({required this.strings});

  final AppStrings strings;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _Block(
          title: strings('diagram.residual.initial'),
          body: strings('diagram.residual.initialBody'),
          color: AppColors.riskHigh,
        ),
        const _Connector(),
        _Block(
          title: strings('diagram.residual.controls'),
          body: strings('diagram.residual.controlsBody'),
          color: AppColors.primary,
        ),
        const _Connector(),
        _Block(
          title: strings('diagram.residual.residual'),
          body: strings('diagram.residual.residualBody'),
          color: AppColors.riskMedium,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          strings('diagram.residual.note'),
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}
