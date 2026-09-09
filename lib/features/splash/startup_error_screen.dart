import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_typography.dart';

/// Fallo al cargar el archivo de textos.
///
/// Es la unica pantalla de la app con las cadenas escritas dentro del widget,
/// y tiene que serlo: si se muestra es precisamente porque el archivo de
/// textos no se pudo leer. Buscar las claves aqui dejaria la pantalla llena
/// de corchetes.
class StartupErrorScreen extends StatelessWidget {
  const StartupErrorScreen({required this.error, super.key});

  final Object error;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
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
                'Revisa que assets/i18n/${AppConstants.defaultLocale}.json '
                'este declarado en pubspec.yaml.',
                style: theme.textTheme.bodyLarge,
              ),
              const SizedBox(height: AppSpacing.md),
              Text('$error', style: theme.textTheme.bodySmall),
            ],
          ),
        ),
      ),
    );
  }
}
