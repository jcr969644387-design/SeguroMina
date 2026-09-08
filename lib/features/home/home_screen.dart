import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';
import '../../core/l10n/app_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

/// Pantalla de entrada.
///
/// Provisional: en el Módulo 5 la reemplaza el catálogo de escenarios. Existe
/// ahora para verificar que el tema, el escalado de texto y la carga de
/// textos externos funcionan de extremo a extremo.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = ref.watch(appStringsProvider);

    return Scaffold(
      body: SafeArea(
        child: strings.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => _StartupError(error: error),
          data: (s) => _HomeContent(strings: s),
        ),
      ),
    );
  }
}

class _HomeContent extends StatelessWidget {
  const _HomeContent({required this.strings});

  final AppStrings strings;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Spacer(),
          Text(strings('app.name'), style: theme.textTheme.displaySmall),
          const SizedBox(height: AppSpacing.sm),
          Text(strings('app.tagline'), style: theme.textTheme.bodyLarge),
          const SizedBox(height: AppSpacing.xl),
          if (ContentValidation.requiresNotice)
            _ValidationNotice(strings: strings),
          const Spacer(),
          Text(
            '${strings('content.sourceLabel')}: ${NormativeSource.full}',
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

/// Aviso de contenido no validado.
///
/// Se muestra mientras ningún especialista haya firmado la revisión. No es
/// decorativo: enseñar criterios de seguridad sin respaldo profesional es un
/// riesgo formativo y el estudiante tiene derecho a saberlo.
class _ValidationNotice extends StatelessWidget {
  const _ValidationNotice({required this.strings});

  final AppStrings strings;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Semantics(
      container: true,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.secondary.withValues(alpha: 0.18),
          border: const Border(
            left: BorderSide(color: AppColors.secondary, width: 4),
          ),
          borderRadius: const BorderRadius.horizontal(
            right: Radius.circular(AppSpacing.radius),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              strings('content.noticeTitle'),
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              strings('content.noticeBody'),
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class _StartupError extends StatelessWidget {
  const _StartupError({required this.error});

  final Object error;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'No se pudo cargar el archivo de textos',
            style: theme.textTheme.headlineSmall,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Revisa que assets/i18n/${AppConstants.defaultLocale}.json esté '
            'declarado en pubspec.yaml.',
            style: theme.textTheme.bodyLarge,
          ),
          const SizedBox(height: AppSpacing.md),
          Text('$error', style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }
}
