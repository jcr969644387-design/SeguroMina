import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/brand/seguromina_mark.dart';
import '../../core/constants/app_constants.dart';
import '../../core/flow/app_flow_controller.dart';
import '../../core/l10n/app_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/pressable_card.dart';
import '../iperc/practice/iperc_practice_screen.dart';
import '../library/library_screen.dart';
import '../library/topic_screen.dart';
import '../mission/intro_mission_screen.dart';
import 'widgets/academic_notice_card.dart';
import 'widgets/progress_panel.dart';
import 'widgets/scenario_list.dart';

/// Centro de entrenamiento.
///
/// El orden refleja el ciclo que estructura la app: primero donde estas,
/// despues que toca aprender ahora, luego practica corta y por ultimo los
/// escenarios completos. La gamificacion acompana y no manda: el nivel
/// aparece dentro del panel de progreso, no como cabecera de la pantalla.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _noticeDismissed = false;

  Future<void> _open(Widget screen) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(builder: (context) => screen),
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
                const SeguroMinaMark(size: 40),
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
                        strings('home.subtitle'),
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            ProgressPanel(strings: strings, flow: flow),
            // El aviso academico va arriba, dentro de la primera pantalla.
            // Al final del desplazamiento, detras de cinco fichas de
            // escenario, no lo leeria nadie: dejaria de ser un aviso y
            // pasaria a ser una formalidad escondida.
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
              strings('home.continueTitle'),
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.sm),
            _ContinueCard(
              strings: strings,
              onOpen: () => unawaited(_open(const LibraryScreen())),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              strings('home.quickTitle'),
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.sm),
            _QuickTraining(
              strings: strings,
              onIdentify: () => unawaited(_open(const IntroMissionScreen())),
              onTopic: (String id) {
                unawaited(_open(TopicScreen(topicId: id)));
              },
              onPractice: () => unawaited(_open(const IpercPracticeEntry())),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              strings('home.scenariosTitle'),
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.sm),
            ScenarioList(
              strings: strings,
              introCompleted: flow.hasCompletedIntro,
              onOpenIntro: () => unawaited(_open(const IntroMissionScreen())),
            ),
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

/// Siguiente paso del itinerario.
///
/// Apunta a la biblioteca y no a un escenario porque el ciclo empieza por
/// aprender. Cuando existan las rutas por modulo, esta tarjeta pasara a
/// senalar el punto exacto donde se quedo el estudiante.
class _ContinueCard extends StatelessWidget {
  const _ContinueCard({required this.strings, required this.onOpen});

  final AppStrings strings;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(AppSpacing.radius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            strings('home.foundationsTitle'),
            style: theme.textTheme.labelLarge?.copyWith(
              color: Colors.white.withValues(alpha: 0.80),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            strings('library.title'),
            style: theme.textTheme.headlineSmall?.copyWith(
              color: Colors.white,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            strings('library.subtitle'),
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.white.withValues(alpha: 0.88),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: onOpen,
              style: FilledButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.primary,
              ),
              child: Text(strings('home.continueAction')),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickTraining extends StatelessWidget {
  const _QuickTraining({
    required this.strings,
    required this.onIdentify,
    required this.onTopic,
    required this.onPractice,
  });

  final AppStrings strings;
  final VoidCallback onIdentify;
  final void Function(String topicId) onTopic;
  final VoidCallback onPractice;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = AppSpacing.sm;
        final width = (constraints.maxWidth - spacing) / 2;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: <Widget>[
            SizedBox(
              width: width,
              child: _QuickTile(
                label: strings('home.quick.identify'),
                icon: Icons.search,
                onTap: onIdentify,
              ),
            ),
            SizedBox(
              width: width,
              child: _QuickTile(
                label: strings('home.quick.evaluate'),
                icon: Icons.grid_view_rounded,
                onTap: () => onTopic('evaluacion'),
              ),
            ),
            SizedBox(
              width: width,
              child: _QuickTile(
                label: strings('home.quick.control'),
                icon: Icons.layers_outlined,
                onTap: () => onTopic('controles-iperc'),
              ),
            ),
            SizedBox(
              width: width,
              child: _QuickTile(
                label: strings('home.quick.iperc'),
                icon: Icons.account_tree_outlined,
                onTap: onPractice,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _QuickTile extends StatelessWidget {
  const _QuickTile({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PressableCard(
      onTap: onTap,
      semanticLabel: label,
      padding: const EdgeInsets.all(AppSpacing.sm),
      child: Row(
        children: <Widget>[
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(label, style: theme.textTheme.bodySmall),
          ),
        ],
      ),
    );
  }
}
