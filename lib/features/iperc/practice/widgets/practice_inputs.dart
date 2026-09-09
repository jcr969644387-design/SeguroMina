import 'package:flutter/material.dart';

import '../../../../core/l10n/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../domain/iperc/iperc_evaluation.dart';
import '../../../../domain/iperc/risk_assessment.dart';
import '../../../library/widgets/technical_diagrams.dart';

/// Fila seleccionable de una lista de opciones.
///
/// Sirve tanto para seleccion multiple como para eleccion unica: quien la usa
/// decide si permite mas de una marcada. Al corregir se bloquea, para que la
/// respuesta no se pueda cambiar mientras se lee la explicacion.
class SelectableRow extends StatelessWidget {
  const SelectableRow({
    required this.label,
    required this.selected,
    required this.locked,
    required this.onTap,
    this.caption,
    super.key,
  });

  final String label;

  /// Texto secundario, por ejemplo el nivel de la jerarquia de un control.
  final String? caption;

  final bool selected;
  final bool locked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final border = selected
        ? AppColors.primary
        : AppColors.textSecondary.withValues(alpha: 0.35);
    final background =
        selected ? AppColors.primary.withValues(alpha: 0.07) : null;
    final icon =
        selected ? Icons.check_box_outlined : Icons.check_box_outline_blank;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: locked ? null : onTap,
          borderRadius: BorderRadius.circular(AppSpacing.sm),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSpacing.sm),
              border: Border.all(color: border, width: selected ? 2 : 1),
              color: background,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Icon(
                  icon,
                  size: 20,
                  color: selected ? AppColors.primary : border,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(label, style: theme.textTheme.bodyMedium),
                      if (caption != null)
                        Text(caption!, style: theme.textTheme.bodySmall),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Seleccion de severidad y probabilidad sobre la matriz normativa.
///
/// El resultado se calcula y se muestra en el momento, con la celda marcada
/// sobre la propia matriz: el estudiante debe ver de donde sale el indice,
/// no recibirlo como un numero sin origen.
class MatrixPicker extends StatelessWidget {
  const MatrixPicker({
    required this.strings,
    required this.severity,
    required this.probability,
    required this.locked,
    required this.onSeverity,
    required this.onProbability,
    super.key,
  });

  final AppStrings strings;
  final Severity? severity;
  final Probability? probability;
  final bool locked;
  final ValueChanged<Severity?> onSeverity;
  final ValueChanged<Probability?> onProbability;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final chosenSeverity = severity;
    final chosenProbability = probability;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          strings('practice.severityLabel'),
          style: theme.textTheme.bodySmall,
        ),
        DropdownButton<Severity>(
          value: chosenSeverity,
          isExpanded: true,
          onChanged: locked ? null : onSeverity,
          items: <DropdownMenuItem<Severity>>[
            for (final value in Severity.values)
              DropdownMenuItem<Severity>(
                value: value,
                child: Text('${value.rank}. ${strings(value.labelKey)}'),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          strings('practice.probabilityLabel'),
          style: theme.textTheme.bodySmall,
        ),
        DropdownButton<Probability>(
          value: chosenProbability,
          isExpanded: true,
          onChanged: locked ? null : onProbability,
          items: <DropdownMenuItem<Probability>>[
            for (final value in Probability.values)
              DropdownMenuItem<Probability>(
                value: value,
                child: Text('${value.rank}. ${strings(value.labelKey)}'),
              ),
          ],
        ),
        if (chosenSeverity != null && chosenProbability != null) ...<Widget>[
          const SizedBox(height: AppSpacing.md),
          _MatrixOutcome(
            strings: strings,
            severity: chosenSeverity,
            probability: chosenProbability,
          ),
        ],
        const SizedBox(height: AppSpacing.md),
        RiskMatrixDiagram(
          strings: strings,
          highlightSeverity: chosenSeverity,
          highlightProbability: chosenProbability,
        ),
      ],
    );
  }
}

class _MatrixOutcome extends StatelessWidget {
  const _MatrixOutcome({
    required this.strings,
    required this.severity,
    required this.probability,
  });

  final AppStrings strings;
  final Severity severity;
  final Probability probability;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final index = RiskMatrix.indexFor(
      severity: severity,
      probability: probability,
    );
    final level = RiskMatrix.levelFor(index);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSpacing.sm),
        color: AppColors.primary.withValues(alpha: 0.08),
      ),
      child: Text(
        strings.format(
          'practice.levelResult',
          <String, Object?>{
            'indice': index,
            'nivel': strings(level.labelKey),
            'plazo': strings(level.deadlineKey),
          },
        ),
        style: theme.textTheme.bodyMedium,
      ),
    );
  }
}

/// Explicacion tecnica de un paso corregido.
///
/// Muestra primero los avisos estructurales —lo que el estudiante hizo mal en
/// terminos de metodo— y despues las explicaciones concretas del contenido.
/// El objetivo es que entienda por que, no que sepa cuanto saco.
class PracticeFeedback extends StatelessWidget {
  const PracticeFeedback({
    required this.result,
    required this.strings,
    super.key,
  });

  final IpercStepResult result;
  final AppStrings strings;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final good = result.isPerfect;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSpacing.sm),
        color: theme.colorScheme.surfaceContainerHighest,
        border: Border(
          left: BorderSide(
            color: good ? AppColors.riskLow : AppColors.riskMedium,
            width: 3,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(
                good ? Icons.check_circle_outline : Icons.info_outline,
                size: 18,
                color: good ? AppColors.riskLow : AppColors.riskMedium,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                strings(
                  good ? 'practice.feedback.good' : 'practice.feedback.review',
                ),
                style: theme.textTheme.labelLarge,
              ),
            ],
          ),
          for (final key in result.noteKeys) ...<Widget>[
            const SizedBox(height: AppSpacing.sm),
            Text(strings(key), style: theme.textTheme.bodyMedium),
          ],
          for (final detail in result.details) ...<Widget>[
            const SizedBox(height: AppSpacing.sm),
            Text(detail, style: theme.textTheme.bodySmall),
          ],
        ],
      ),
    );
  }
}

/// Una fila de la linea de IPERC del resumen.
class LineRow extends StatelessWidget {
  const LineRow({
    required this.labelKey,
    required this.value,
    required this.strings,
    super.key,
  });

  final String labelKey;
  final String value;
  final AppStrings strings;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: 92,
            child: Text(
              strings(labelKey),
              style: theme.textTheme.bodySmall,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(value, style: theme.textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}
