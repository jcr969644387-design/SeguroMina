import 'package:flutter/material.dart';

import '../../../core/l10n/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

/// Aviso de uso academico.
///
/// Sustituye a la pantalla de "contenido en revision", que ocupaba la primera
/// impresion entera. Sigue diciendo lo mismo —el material es educativo y aun
/// no lo valido un especialista— pero como tarjeta descartable, no como muro.
class AcademicNoticeCard extends StatelessWidget {
  const AcademicNoticeCard({
    required this.strings,
    required this.onUnderstood,
    required this.onNeverShow,
    super.key,
  });

  final AppStrings strings;

  /// Oculta la tarjeta hasta la proxima apertura de la app.
  final VoidCallback onUnderstood;

  /// La oculta de forma permanente.
  final VoidCallback onNeverShow;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.secondary.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(AppSpacing.radius),
        border: Border.all(
          color: AppColors.secondary.withValues(alpha: 0.55),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Icon(
                Icons.info_outline,
                size: 20,
                color: AppColors.onSecondary,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  strings('notice.title'),
                  style: theme.textTheme.titleMedium,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            strings('notice.body'),
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: AppSpacing.xs),
          Wrap(
            alignment: WrapAlignment.end,
            spacing: AppSpacing.sm,
            children: <Widget>[
              TextButton(
                onPressed: onNeverShow,
                child: Text(strings('notice.dontShow')),
              ),
              TextButton(
                onPressed: onUnderstood,
                child: Text(strings('notice.understood')),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
