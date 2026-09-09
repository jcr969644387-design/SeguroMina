import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/brand/seguromina_mark.dart';
import '../../core/constants/app_constants.dart';
import '../../core/l10n/app_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

/// Pantalla de apertura.
///
/// Dura lo justo para que la marca se lea y para que el archivo de textos
/// termine de cargar. No es una espera decorativa: si los textos no estan
/// listos, la primera pantalla real parpadearia.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({required this.onFinished, super.key});

  /// Se invoca cuando la animacion termino y la app puede continuar.
  final VoidCallback onFinished;

  /// Duracion minima en pantalla.
  static const Duration minimumDuration = Duration(milliseconds: 1800);

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: SplashScreen.minimumDuration,
    )..forward();
    _timer = Timer(SplashScreen.minimumDuration, widget.onFinished);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final strings = ref.watch(appStringsProvider).valueOrNull;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : Colors.white,
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            return _SplashContent(
              progress: _controller.value,
              onDark: isDark,
              tagline: strings == null ? '' : strings('splash.tagline'),
            );
          },
        ),
      ),
    );
  }
}

class _SplashContent extends StatelessWidget {
  const _SplashContent({
    required this.progress,
    required this.onDark,
    required this.tagline,
  });

  final double progress;
  final bool onDark;
  final String tagline;

  double _interval(double start, double end) {
    if (progress <= start) {
      return 0;
    }
    if (progress >= end) {
      return 1;
    }
    return (progress - start) / (end - start);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final markIn = Curves.easeOutCubic.transform(_interval(0, 0.35));
    final textIn = Curves.easeOut.transform(_interval(0.25, 0.6));
    final shine = _interval(0.4, 0.85);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Opacity(
            opacity: markIn,
            child: Transform.scale(
              scale: 0.88 + 0.12 * markIn,
              child: SeguroMinaMark(
                size: 132,
                onDark: onDark,
                shine: shine > 0 && shine < 1 ? shine : 0,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Opacity(
            opacity: textIn,
            child: Column(
              children: <Widget>[
                Text(
                  AppConstants.appName,
                  style: theme.textTheme.displaySmall,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  tagline,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
