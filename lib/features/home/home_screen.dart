import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/brand/seguromina_mark.dart';
import '../../core/constants/app_constants.dart';
import '../../core/flow/app_flow_controller.dart';
import '../../core/l10n/app_strings.dart';
import '../../core/theme/app_typography.dart';
import '../../domain/training/intro_mission.dart';
import '../mission/intro_mission_screen.dart';
import '../placeholder/coming_soon_screen.dart';
import 'widgets/academic_notice_card.dart';
import 'widgets/hero_mission_card.dart';
import 'widgets/level_badge.dart';
import 'widgets/module_grid.dart';

/// Centro de entrenamiento.
///
/// El orden de la pantalla es deliberado: primero quien eres y como vas,
/// despues la mision que puedes empezar ahora, y solo al final el resto de
/// modulos. Lo que se espera del estudiante ocupa el centro.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  /// Descarte de la sesion actual. El descarte permanente vive en el
  /// repositorio de preferencias.
  bool _noticeDismissed = false;

  Future<void> _openMission() async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (context) => const IntroMissionScreen(),
      ),
    );
  }

  Future<void> _openModule(HomeModule module) async {
    if (module == HomeModule.scenarios) {
      await _openMission();
      return;
    }
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (context) => ComingSoonScreen(titleKey: module.titleKey),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final flow = ref.watch(appFlowProvider);
    final strings = ref.watch(appStringsProvider).valueOrNull;

    if (strings == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final showNotice = !flow.hidesAcademicNotice && !_noticeDismissed;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.md,
            AppSpacing.lg,
            AppSpacing.xxl,
          ),
          children: <Widget>[
            Row(
              children: <Widget>[
                const SeguroMinaMark(size: 44),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        AppConstants.appName,
                        style: theme.textTheme.headlineSmall,
                      ),
                      Text(
                        strings('home.greeting'),
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Align(
              alignment: Alignment.centerLeft,
              child: LevelBadge(
                label: strings(flow.level.labelKey),
                points: strings.format(
                  'home.pointsLabel',
                  <String, Object?>{'puntos': flow.points},
                ),
                progress: flow.levelProgress,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            HeroMissionCard(
              mission: IntroMission.definition,
              strings: strings,
              completed: flow.hasCompletedIntro,
              onStart: _openMission,
            ),
            if (showNotice) ...<Widget>[
              const SizedBox(height: AppSpacing.md),
              AcademicNoticeCard(
                strings: strings,
                onUnderstood: () => setState(() => _noticeDismissed = true),
                onNeverShow: () {
                  unawaited(
                    ref.read(appFlowProvider.notifier).hideAcademicNotice(),
                  );
                },
              ),
            ],
            const SizedBox(height: AppSpacing.lg),
            Text(
              strings('home.quickAccess'),
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.md),
            ModuleGrid(strings: strings, onOpen: _openModule),
            const SizedBox(height: AppSpacing.lg),
            Text(
              '${strings('content.sourceLabel')}: ${NormativeSource.full}',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
