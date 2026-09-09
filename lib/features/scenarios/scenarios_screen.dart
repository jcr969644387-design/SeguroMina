import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/flow/app_flow_controller.dart';
import '../../core/l10n/app_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../domain/training/intro_mission.dart';
import '../home/widgets/hero_mission_card.dart';
import '../mission/intro_mission_screen.dart';

/// Catalogo de misiones.
///
/// Solo la mision de entrada tiene contenido. Las plazas restantes se
/// muestran bloqueadas y sin titulo inventado: anunciar escenarios de
/// seguridad que aun no existen —ni han pasado revision— seria prometer
/// criterio tecnico que la app todavia no puede respaldar.
class ScenariosScreen extends ConsumerWidget {
  const ScenariosScreen({super.key});

  static const int _lockedSlots = 4;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final flow = ref.watch(appFlowProvider);
    final strings = ref.watch(appStringsProvider).valueOrNull;

    if (strings == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: Text(strings('nav.scenarios'))),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.md,
          AppSpacing.lg,
          AppSpacing.xxl,
        ),
        children: <Widget>[
          HeroMissionCard(
            mission: IntroMission.definition,
            strings: strings,
            completed: flow.hasCompletedIntro,
            onStart: () {
              unawaited(
                Navigator.of(context).push<void>(
                  MaterialPageRoute<void>(
                    builder: (context) => const IntroMissionScreen(),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            strings('scenarios.lockedTitle'),
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.sm),
          for (int i = 0; i < _lockedSlots; i++) ...<Widget>[
            _LockedSlot(
              label: strings('scenarios.locked'),
              body: strings('scenarios.lockedBody'),
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
        ],
      ),
    );
  }
}

class _LockedSlot extends StatelessWidget {
  const _LockedSlot({required this.label, required this.body});

  final String label;
  final String body;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSpacing.radius),
        border: Border.all(
          color: AppColors.textSecondary.withValues(alpha: 0.35),
        ),
      ),
      child: Row(
        children: <Widget>[
          const Icon(
            Icons.lock_outline,
            size: 20,
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(label, style: theme.textTheme.labelLarge),
                Text(body, style: theme.textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
