import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/constants/app_constants.dart';
import 'core/settings/app_settings.dart';
import 'core/theme/app_theme.dart';
import 'features/home/home_screen.dart';

/// Raíz de SeguroMina.
///
/// El árbol de navegación se reemplaza por `go_router` en el Módulo 2.
class SeguroMinaApp extends ConsumerWidget {
  const SeguroMinaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appSettingsProvider);

    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: settings.themeMode,
      builder: (context, child) {
        // El ajuste de la app se multiplica por el del sistema: un usuario
        // que ya aumentó el tamaño de letra en Android no debe perder ese
        // ajuste al abrir SeguroMina. El resultado se acota para que la
        // pantalla de inspección siga siendo utilizable.
        final systemScale = MediaQuery.textScalerOf(context).scale(1);
        final effective = (systemScale * settings.textScale).clamp(
          AppSettingsNotifier.minTextScale,
          AppSettingsNotifier.maxTextScale,
        );
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(effective),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
      home: const HomeScreen(),
    );
  }
}
