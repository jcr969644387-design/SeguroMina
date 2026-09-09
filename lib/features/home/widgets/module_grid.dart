import 'package:flutter/material.dart';

import '../../../core/l10n/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/pressable_card.dart';

/// Modulos del centro de entrenamiento.
///
/// El nombre de la clave se guarda aparte del nombre del valor porque
/// `library` es palabra reservada en Dart y el archivo de textos no tiene
/// por que reflejar esa limitacion.
enum HomeModule {
  scenarios('scenarios', Icons.terrain, AppColors.primary),
  iperc('iperc', Icons.grid_view_rounded, AppColors.riskMedium),
  reference('library', Icons.menu_book_outlined, AppColors.riskLow),
  assessments('assessments', Icons.fact_check_outlined, AppColors.onSecondary),
  badges('badges', Icons.workspace_premium_outlined, AppColors.primaryLight),
  progress('progress', Icons.insights_outlined, AppColors.textSecondary);

  const HomeModule(this.keyBase, this.icon, this.color);

  final String keyBase;
  final IconData icon;
  final Color color;

  String get titleKey => 'module.$keyBase.title';
  String get bodyKey => 'module.$keyBase.body';
}

/// Cuadricula de accesos rapidos.
///
/// Usa [Wrap] y no [GridView] con proporcion fija porque la app admite una
/// escala de texto de hasta 1.6: con altura fija, las tarjetas desbordarian
/// en cuanto el estudiante agrande la letra.
class ModuleGrid extends StatelessWidget {
  const ModuleGrid({
    required this.strings,
    required this.onOpen,
    super.key,
  });

  final AppStrings strings;
  final void Function(HomeModule module) onOpen;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = AppSpacing.md;
        final width = (constraints.maxWidth - spacing) / 2;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: HomeModule.values.map((HomeModule module) {
            return SizedBox(
              width: width,
              child: _ModuleTile(
                module: module,
                title: strings(module.titleKey),
                body: strings(module.bodyKey),
                onTap: () => onOpen(module),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

class _ModuleTile extends StatelessWidget {
  const _ModuleTile({
    required this.module,
    required this.title,
    required this.body,
    required this.onTap,
  });

  final HomeModule module;
  final String title;
  final String body;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PressableCard(
      onTap: onTap,
      semanticLabel: '$title. $body',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: module.color.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(AppSpacing.sm),
            ),
            child: Icon(module.icon, size: 22, color: module.color),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(title, style: theme.textTheme.labelLarge),
          const SizedBox(height: 2),
          Text(body, style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }
}
