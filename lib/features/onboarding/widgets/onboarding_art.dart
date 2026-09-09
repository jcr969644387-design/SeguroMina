import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

/// Ilustracion de cada pantalla del onboarding.
enum OnboardingArt { observe, evaluate, decide }

/// Ilustraciones construidas con primitivas del propio sistema de diseno.
///
/// No son imagenes: la app es offline-first y cada PNG que se empaqueta pesa
/// en la descarga. Ademas asi heredan la paleta y se ven correctas en tema
/// claro y oscuro sin mantener dos juegos de archivos.
class OnboardingArtwork extends StatelessWidget {
  const OnboardingArtwork({required this.art, super.key});

  final OnboardingArt art;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 280, maxHeight: 280),
        child: AspectRatio(
          aspectRatio: 1,
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(AppSpacing.lg),
            ),
            child: _buildArt(),
          ),
        ),
      ),
    );
  }

  Widget _buildArt() {
    switch (art) {
      case OnboardingArt.observe:
        return const _ObserveArt();
      case OnboardingArt.evaluate:
        return const _EvaluateArt();
      case OnboardingArt.decide:
        return const _DecideArt();
    }
  }
}

/// Galeria subterranea vista de frente: arcos que se alejan y una persona.
class _ObserveArt extends StatelessWidget {
  const _ObserveArt();

  Widget _arch(double factor, double alpha) {
    return FractionallySizedBox(
      widthFactor: factor,
      heightFactor: factor,
      alignment: Alignment.bottomCenter,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: alpha),
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(140),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: <Widget>[
        _arch(1, 0.10),
        _arch(0.76, 0.16),
        _arch(0.54, 0.26),
        const Padding(
          padding: EdgeInsets.only(bottom: AppSpacing.sm),
          child: Icon(
            Icons.engineering,
            size: 68,
            color: AppColors.primary,
          ),
        ),
        const Positioned(
          top: 4,
          right: 0,
          child: _ArtBadge(
            icon: Icons.search,
            background: AppColors.secondary,
            foreground: AppColors.onSecondary,
          ),
        ),
      ],
    );
  }
}

/// Matriz IPERC: probabilidad en filas, severidad en columnas.
class _EvaluateArt extends StatelessWidget {
  const _EvaluateArt();

  /// Combinacion de probabilidad y severidad. La celda marcada es la que el
  /// estudiante acaba de clasificar.
  static const List<List<Color>> _cells = <List<Color>>[
    <Color>[AppColors.riskLow, AppColors.riskLow, AppColors.riskMedium],
    <Color>[AppColors.riskLow, AppColors.riskMedium, AppColors.riskHigh],
    <Color>[AppColors.riskMedium, AppColors.riskHigh, AppColors.riskHigh],
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List<Widget>.generate(_cells.length, (row) {
        return Expanded(
          child: Row(
            children: List<Widget>.generate(_cells[row].length, (column) {
              final selected = row == 1 && column == 2;
              return Expanded(
                child: Container(
                  margin: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: _cells[row][column].withValues(
                      alpha: selected ? 1 : 0.30,
                    ),
                    borderRadius: BorderRadius.circular(AppSpacing.sm),
                    border: selected
                        ? Border.all(color: AppColors.textPrimary, width: 2.5)
                        : null,
                  ),
                  child: selected
                      ? const Icon(Icons.check, color: Colors.white, size: 26)
                      : null,
                ),
              );
            }),
          ),
        );
      }),
    );
  }
}

/// Senal preventiva y confirmacion: la decision tomada.
class _DecideArt extends StatelessWidget {
  const _DecideArt();

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        Transform.rotate(
          angle: math.pi / 4,
          child: Container(
            width: 132,
            height: 132,
            decoration: BoxDecoration(
              color: AppColors.secondary,
              borderRadius: BorderRadius.circular(AppSpacing.md),
            ),
          ),
        ),
        const Icon(
          Icons.warning_amber_rounded,
          size: 64,
          color: AppColors.onSecondary,
        ),
        const Positioned(
          right: 6,
          bottom: 10,
          child: _ArtBadge(
            icon: Icons.check,
            background: AppColors.riskLow,
            foreground: Colors.white,
            size: 56,
          ),
        ),
      ],
    );
  }
}

class _ArtBadge extends StatelessWidget {
  const _ArtBadge({
    required this.icon,
    required this.background,
    required this.foreground,
    this.size = 48,
  });

  final IconData icon;
  final Color background;
  final Color foreground;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(size / 3),
      ),
      child: Icon(icon, color: foreground, size: size * 0.55),
    );
  }
}
