import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/brand/seguromina_mark.dart';
import '../../core/constants/app_constants.dart';
import '../../core/flow/app_flow_controller.dart';
import '../../core/l10n/app_strings.dart';
import '../../core/settings/app_settings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

/// Perfil del estudiante.
///
/// Reune la identidad —nivel alcanzado y puntos— con los ajustes que hasta
/// ahora existian en el codigo pero no tenian donde tocarse: apariencia y
/// tamano de texto. El escalado de texto es un requisito de accesibilidad del
/// proyecto, y un ajuste al que no se llega es un ajuste que no existe.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final flow = ref.watch(appFlowProvider);
    final settings = ref.watch(appSettingsProvider);
    final strings = ref.watch(appStringsProvider).valueOrNull;

    if (strings == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final notifier = ref.read(appSettingsProvider.notifier);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: Text(strings('nav.profile'))),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.md,
          AppSpacing.lg,
          AppSpacing.xxl,
        ),
        children: <Widget>[
          _IdentityCard(strings: strings, flow: flow, onDark: isDark),
          const SizedBox(height: AppSpacing.lg),
          Text(
            strings('settings.theme'),
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.sm),
          _ThemeOption(
            label: strings('settings.themeSystem'),
            icon: Icons.brightness_auto_outlined,
            selected: settings.themeMode == ThemeMode.system,
            onTap: () => notifier.setThemeMode(ThemeMode.system),
          ),
          _ThemeOption(
            label: strings('settings.themeLight'),
            icon: Icons.light_mode_outlined,
            selected: settings.themeMode == ThemeMode.light,
            onTap: () => notifier.setThemeMode(ThemeMode.light),
          ),
          _ThemeOption(
            label: strings('settings.themeDark'),
            icon: Icons.dark_mode_outlined,
            selected: settings.themeMode == ThemeMode.dark,
            onTap: () => notifier.setThemeMode(ThemeMode.dark),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            strings('settings.textSize'),
            style: theme.textTheme.titleMedium,
          ),
          Slider(
            value: settings.textScale,
            min: AppSettingsNotifier.minTextScale,
            max: AppSettingsNotifier.maxTextScale,
            divisions: 7,
            label: '${(settings.textScale * 100).round()} %',
            onChanged: notifier.setTextScale,
          ),
          Text(
            strings('profile.textSizeHint'),
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            strings('profile.contentTitle'),
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.sm),
          _ContentStatus(strings: strings),
        ],
      ),
    );
  }
}

class _IdentityCard extends StatelessWidget {
  const _IdentityCard({
    required this.strings,
    required this.flow,
    required this.onDark,
  });

  final AppStrings strings;
  final AppFlowState flow;
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppSpacing.radius),
        border: Border.all(
          color: AppColors.textSecondary.withValues(alpha: 0.20),
        ),
      ),
      child: Row(
        children: <Widget>[
          SeguroMinaMark(size: 52, onDark: onDark),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  strings('progress.levelTitle'),
                  style: theme.textTheme.bodySmall,
                ),
                Text(
                  strings(flow.level.labelKey),
                  style: theme.textTheme.headlineSmall,
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
          ),
        ],
      ),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  const _ThemeOption({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final border = selected
        ? AppColors.primary
        : AppColors.textSecondary.withValues(alpha: 0.30);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSpacing.sm),
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSpacing.sm),
              border: Border.all(color: border, width: selected ? 2 : 1),
            ),
            child: Row(
              children: <Widget>[
                Icon(icon, size: 20, color: border),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(label, style: theme.textTheme.bodyMedium),
                ),
                if (selected)
                  const Icon(
                    Icons.check,
                    size: 18,
                    color: AppColors.primary,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Estado de validacion del contenido y fuente normativa.
///
/// Va en el perfil y no escondido en un pie de pagina: el estudiante tiene
/// derecho a saber sobre que material se le esta formando.
class _ContentStatus extends StatelessWidget {
  const _ContentStatus({required this.strings});

  final AppStrings strings;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final validated = !ContentValidation.requiresNotice;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSpacing.sm),
        border: Border.all(
          color: AppColors.textSecondary.withValues(alpha: 0.30),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(
                validated ? Icons.verified_outlined : Icons.pending_outlined,
                size: 18,
                color: validated ? AppColors.riskLow : AppColors.riskMedium,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  strings(
                    validated
                        ? 'profile.contentValidated'
                        : 'profile.contentPending',
                  ),
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '${strings('content.sourceLabel')}: ${NormativeSource.full}',
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
