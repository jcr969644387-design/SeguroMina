import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/constants/app_constants.dart';
import 'core/flow/app_flow_controller.dart';
import 'core/l10n/app_strings.dart';
import 'core/settings/app_settings.dart';
import 'core/theme/app_theme.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'features/shell/app_shell.dart';
import 'features/splash/splash_screen.dart';
import 'features/splash/startup_error_screen.dart';

/// Raiz de SeguroMina.
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
        // que ya aumento el tamano de letra en Android no debe perder ese
        // ajuste al abrir SeguroMina. El resultado se acota para que la
        // pantalla de inspeccion siga siendo utilizable.
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
      home: const RootGate(),
    );
  }
}

/// Decide que pantalla ve el estudiante al abrir la app.
///
/// Splash siempre; onboarding solo la primera vez; a partir de ahi, el centro
/// de entrenamiento. La decision vive en un unico sitio para que no haya dos
/// caminos distintos hacia la primera pantalla.
class RootGate extends ConsumerStatefulWidget {
  const RootGate({super.key});

  @override
  ConsumerState<RootGate> createState() => _RootGateState();
}

class _RootGateState extends ConsumerState<RootGate> {
  bool _splashDone = false;

  @override
  Widget build(BuildContext context) {
    final flow = ref.watch(appFlowProvider);
    final strings = ref.watch(appStringsProvider);

    final Widget screen;
    if (!_splashDone) {
      screen = SplashScreen(
        onFinished: () {
          if (mounted) {
            setState(() => _splashDone = true);
          }
        },
      );
    } else if (strings.hasError) {
      screen = StartupErrorScreen(error: strings.error!);
    } else if (!flow.hasSeenOnboarding) {
      screen = const OnboardingScreen();
    } else {
      screen = const AppShell();
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 320),
      child: screen,
    );
  }
}
